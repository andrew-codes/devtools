# Project Finder

Navigate and create projects stored under `$REPO_HOME`. Each project is a directory containing one primary clone and any number of git worktrees:

```text
$REPO_HOME/
  devtools/
    main/          ← primary clone (where .git is a directory)
    my-feature/    ← worktree
  other-project/
    main/
```

All commands tab-complete on project and worktree names.

### `proj`

| Invocation | Behaviour |
| --- | --- |
| `proj` | cd to the primary clone of the current project |
| `proj <project>` | cd to the primary clone of `<project>` |
| `proj <worktree>` | cd to `<worktree>` of the current project (when already inside one) |
| `proj <project> <worktree>` | cd to `<worktree>` of `<project>` |
| `proj --new <url>` | clone `<url>` as a new project and cd into it |
| `proj --new <url> --name <name>` | same, but override the inferred project name |

The primary clone is identified as the worktree whose `.git` entry is a directory (not a file). For `--new`, the clone directory is named after the default branch (e.g. `main`).

### `projs [filter]`

List all projects in `$REPO_HOME`. Pass an optional filter string to narrow results.
