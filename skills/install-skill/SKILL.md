---
name: install-skill
description: >-
  Use when the user asks to install, add, or get an agent skill from outside this machine's own
  skills (for example "install the X skill", "add skill owner/repo", or after find-skills turns up a
  skill worth keeping). Do not run `npx skills add` or copy files yourself: hand the request to
  firstmate so the skill and its pinned version go into the devtools repo and devtools-rebuild
  installs it everywhere.
disable-model-invocation: false
---

# Install a skill

Third-party skills are declared, not installed by hand. The devtools repo keeps one manifest,
`third-party-skills.txt`, with a line per skill:

```
<owner/repo> <git ref> <skill>
```

`devtools-rebuild` installs each line at exactly that ref and removes skills whose line is gone, on
macOS and Windows alike. A skill installed any other way (`npx skills add`, copying a folder) is
invisible to that manifest, so the next machine, or a rebuild that drops it, will not have it.

## What to do

1. Identify the skill: the `owner/repo` that hosts it and the skill name inside it. If the user gave
   only a name, find it with the find-skills skill or `npx skills add <owner/repo> -l` (list only,
   installs nothing).
2. Pin it: resolve the repo's current default-branch commit to a full SHA, for example
   `gh api repos/<owner>/<repo>/commits/HEAD --jq .sha`. Use a SHA, never a branch name.
3. Tell firstmate to add that line to `third-party-skills.txt` in the devtools repo and open a PR.
   Give it the three values and nothing else it has to rediscover: "Add `<owner/repo> <sha> <skill>`
   to `third-party-skills.txt` in andrew-codes/devtools." If you are firstmate or can drive the repo
   yourself, make that one-line change on a branch and open the PR.
4. Tell the user what was requested and that the skill arrives on the next `devtools-rebuild` after
   the PR merges. Do not claim it is installed.

## Skills the user wrote

A skill the user is writing themselves is different: it belongs in the repo's `skills/<name>/SKILL.md`
and is versioned there, not in the manifest.

## Bumping or removing

To update, change the ref on the skill's line; to remove, delete the line. Same PR flow.
