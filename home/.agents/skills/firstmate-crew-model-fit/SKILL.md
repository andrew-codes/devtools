---
name: firstmate-crew-model-fit
description: >-
  Use once, near the start of a task, when you are a task worker spawned by Firstmate (your very
  first message says "You are a crewmate: an autonomous worker agent managed by firstmate" and
  gives you a status file to report progress through) - assess whether the model you were
  launched with fits your assigned task's size and complexity, and escalate a recommendation to
  switch if there is a clear, significant mismatch.
disable-model-invocation: false
---

# Crewmate model fit

You cannot switch your own model from inside a session - slash commands like `/model` are a
human-input-layer feature, not something your own output can trigger. The only verified way to
change a running crewmate's model is an external relaunch (`claude --resume <session-id> --model
<name>`), which is exactly what Firstmate's supervising session already does via
`bin/fm-control.sh <task-id> relaunch --model <name>` when it judges a relaunch warranted. So this
skill's job is narrow: notice a clear mismatch and hand the judgment call to Firstmate through the
existing needs-decision mechanism. It never attempts to switch models itself.

## When to run this

Once, right after reading your brief and before starting deep implementation work. Do not re-run
this mid-task and do not re-litigate the decision repeatedly - relaunching has real cost (fresh
context, lost prompt cache, elapsed time), so this is for genuine mismatches, not close calls.

## What counts as a mismatch

**Task is clearly too simple for a strong/expensive model** - recommend `smaller-faster`:
- A single mechanical rename across files
- A one-line config bump
- A trivial doc typo fix
- Updating a version string

These share no ambiguity, no design judgment, and a narrow blast radius.

**Task is clearly too demanding for a weak/fast model** - recommend `larger-stronger`:
- A deep multi-file architectural change
- Subtle correctness or security reasoning
- An ambiguous design tradeoff the brief leaves to your judgment
- Anything touching authentication, secrets, or data-loss-risk logic

**Everything else - the default, uncertain, or "reasonably fits" case: do nothing and proceed with
the assigned model.** Bias strongly toward not escalating. Only escalate on a clear, defensible
mismatch you could justify in one sentence.

## How to escalate

Append this exact status-line shape (matching the existing needs-decision convention documented in
every crewmate brief) to the task's status file named in your brief:

```
needs-decision [at=<epoch>] [key=model-fit]: recommend model=<tier> because <one-line reason>
```

`<tier>` is one of `smaller-faster` or `larger-stronger` - not a specific versioned model name,
since exact model names/aliases drift over time and Firstmate is better positioned to map a tier to
the currently-appropriate concrete model.

Then STOP and wait for Firstmate's reply, exactly as your brief's existing rule about escalating
decisions to Firstmate already instructs. This is not a new rule - it is applying the existing
needs-decision mechanism to a new reason. Firstmate will resolve this like any other decision: a
`resolved [key=model-fit] ...` line lands, or Firstmate relaunches you and you continue in the same
worktree/branch with your prior commits intact. Either way, do not attempt to relaunch or restart
yourself.

## Not a Firstmate crewmate right now?

This skill only applies when the current session is a Firstmate-spawned crewmate with that
status-file reporting contract. If invoked in any other context - the captain's own interactive
session, a different tool - there is no status file to escalate through. Just mention the
model-fit observation directly to whoever you're talking to instead of trying to write a status
line that does not exist.
