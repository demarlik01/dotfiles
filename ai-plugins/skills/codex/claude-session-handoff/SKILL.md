---
name: claude-session-handoff
description: Find and read local Claude Code JSONL session logs for the current project, recover the relevant unfinished context, and continue the work in Codex. Use when the user asks to resume, continue, or hand off a Claude session, including after a Claude rate limit.
---

# Claude Session Handoff

Recover enough context from Claude Code's locally persisted session history to continue the user's task in the current Codex chat.

## Find the session

- Resolve the current working directory and repository root, then look for project session files under `~/.claude/projects/**/*.jsonl`.
- Use clues from the request such as a PR URL or number, branch, task description, file name, or quoted phrase to search the JSONL files. Prefer candidates that match the current project, the user's clues, and recent activity.
- When no clue identifies a session, inspect the most recent sessions for the current project. If one candidate is clearly strongest, proceed without asking the user to choose.
- Treat a prompt that begins with `/import` and continues with task text as a direct handoff request; do not require the user to run the interactive importer separately.

## Recover context

- Inspect the selected JSONL with targeted `rg`, `jq`, `sed`, or `tail` queries instead of loading every session in full.
- Extract the original goal, material user and assistant messages, tool calls and results, decisions, findings, changed files, commands already run, and unfinished work.
- Follow task-output files referenced by the selected session only when they contain context needed for the handoff.
- Do not start or resume Claude merely to reconstruct the session. Read the persisted JSONL directly unless the user explicitly asks to invoke Claude.

## Continue the work

- Briefly identify the session selected and the recovered stopping point.
- Reconcile recovered context with the current worktree, branch, PR, and other relevant current state; treat old session conclusions as evidence rather than current truth.
- Continue the requested task under the normal permission and verification rules. Do not stop after producing a summary when the user asked to continue the work.
