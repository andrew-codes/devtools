// AXI ambient context for pi.
//
// The AXI CLIs ship `<tool> setup hooks`, which installs a SessionStart hook so
// the tool's ambient context -- Lavish's live review sessions, the tasks
// backlog -- is in front of the agent from the first turn rather than costing a
// tool call to discover. It supports Claude Code, Codex, OpenCode and GitHub
// Copilot CLI. It does not support pi, and no AXI package carries any pi
// integration, so this extension is pi's half of that wiring.
//
// It is ours rather than configuration of an installed extension because none
// of the extensions in ../settings.json can inject a command's output as
// context:
//
//   - pi-yaml-hooks runs `bash` actions on session.created, but their stdout is
//     only captured for its own log; the model never sees it. Its `tool` action
//     sends a fixed follow-up prompt, not dynamic content.
//   - pi-subdir-context injects static AGENTS.md/CLAUDE.md files, discovered on
//     `read` tool calls rather than at session start, and runs no commands.
//   - pi-mcp-adapter needs an MCP server; these are plain CLIs.
//   - pi-subagents, codex-fast-mode and openai-server-compaction are unrelated.
//
// Behaviour deliberately mirrors the OpenCode plugin that AXI generates for
// itself: run each tool with no arguments, cache the result for the life of the
// session, and append it to the system prompt under the same
// "## AXI ambient context: <tool>" heading the other harnesses receive.
//
// Unlike that plugin, a tool that fails or times out contributes nothing rather
// than an error string. This runs on every turn of every pi session, and a
// missing binary mid-reinstall should stay out of the model's context the same
// way ../hook/session-start.sh keeps its own failures quiet.

import { spawn } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";

// Keep in sync with axiAmbientContextTools in home.nix, which installs the same
// two tools' hooks for the harnesses that support them.
const TOOLS = ["lavish-axi", "tasks-axi"];
const TIMEOUT_MS = 10_000;

// Volta's shim directory by absolute path, not via PATH: pi inherits whatever
// environment it was launched with, and herdr panes fork from a server process
// whose PATH predates ~/.volta/bin. ../hook/session-start.sh resolves the same
// binaries the same way for the same reason.
function toolPath(tool) {
  return join(homedir(), ".volta", "bin", tool);
}

function runTool(tool, cwd) {
  return new Promise((resolve) => {
    let settled = false;
    let stdout = "";

    const finish = (value) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      resolve(value);
    };

    const child = spawn(toolPath(tool), [], {
      cwd,
      env: process.env,
      shell: false,
      stdio: ["ignore", "pipe", "pipe"],
    });

    const timer = setTimeout(() => {
      child.kill("SIGTERM");
      finish("");
    }, TIMEOUT_MS);
    timer.unref?.();

    child.stdout?.setEncoding("utf-8");
    child.stdout?.on("data", (chunk) => {
      stdout += chunk;
    });
    // stderr is drained but discarded, so a chatty tool can't fill the pipe
    // buffer and wedge itself waiting for a reader.
    child.stderr?.resume();
    child.on("error", () => finish(""));
    child.on("close", (code) => finish(code === 0 ? stdout.trim() : ""));
  });
}

async function collectAmbientContext(cwd) {
  const sections = await Promise.all(
    TOOLS.map(async (tool) => {
      const output = await runTool(tool, cwd);
      return output ? `## AXI ambient context: ${tool}\n${output}` : "";
    }),
  );

  return sections.filter(Boolean).join("\n\n");
}

export default function axiAmbientContext(pi) {
  // One collection per session, matching the AXI OpenCode plugin's own caching:
  // the context is a snapshot taken when the session first runs, not a live
  // view refreshed every turn.
  let pending;

  pi.on("session_start", async () => {
    pending = undefined;
  });

  pi.on("before_agent_start", async (event, ctx) => {
    // Cache the promise rather than its value so overlapping turns share one
    // run of each tool.
    pending ??= collectAmbientContext(ctx.cwd);
    const context = await pending;
    if (!context) return;

    return { systemPrompt: `${event.systemPrompt}\n\n${context}` };
  });
}
