---
name: ask-claude
description: Invoke the local Claude Code CLI from Codex when the user asks to consult Claude, get a second opinion, review work with Claude, or delegate a task to Claude.
---

# Ask Claude Code

Use the local `claude` CLI as a peer agent. Run it from the working directory that contains the files or repository relevant to the request.

## Start a Session

Use Claude's configured default model unless the user requests a specific model.

Treat the installed CLI's `claude --help` output as the compatibility source of truth. Check it before adding user-requested optional flags that are not already covered here, and check it after any flag-related failure. Do not rely on copied flag names or allowed values when the installed CLI disagrees.

When the user requests a model or effort level and the installed CLI supports those options, pass them explicitly. For example:

```bash
claude -p --model opus --effort xhigh --permission-mode plan --output-format json "<prompt>"
```

Omit `--model` and `--effort` when the user did not request overrides.

For analysis, review, or a second opinion:

```bash
claude -p --permission-mode plan --output-format json "<prompt>"
```

When the user explicitly delegates implementation or file edits:

```bash
claude -p --permission-mode acceptEdits --output-format json "<prompt>"
```

Make the prompt self-contained: state the task, relevant scope, expected result, and whether Claude should only advise or should edit files. Do not ask Claude to repeat work already completed unless independent verification is the point.

Read `result` from the JSON response. Keep its `session_id` when a follow-up is likely.

## Continue a Session

Continue by ID so unrelated Claude sessions cannot be selected accidentally:

```bash
claude --resume "<session_id>" -p --output-format json "<follow-up prompt>"
```

Use the permission mode appropriate to the follow-up when it differs from the original task.

## Return the Result

Attribute Claude's conclusions clearly rather than presenting them as Codex's independent findings. If Claude edited the worktree, inspect the resulting changes and run verification appropriate to the user's task before reporting completion.

If the command is blocked because Claude needs network access or access to its local configuration and session files, use Codex's normal approval flow and retry the same scoped command.
