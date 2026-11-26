---
name: herdr-opencode
description: >-
  Delegate implementation tasks to OpenCode in a new Herdr pane and wait for completion.
  Use when the user asks to delegate coding to OpenCode via Herdr, or requests the
  Herdr/OpenCode workflow where agy estimates the implementation plan, target files,
  and acceptance criteria, then automatically hands off execution to OpenCode and
  verifies the result. Requires HERDR_ENV=1.
---

# Herdr + OpenCode Delegation Workflow

Use this workflow when agy acts as planner/verifier and delegates implementation to `opencode` running in a dedicated Herdr sibling pane.

## Prerequisites

1. Verify that agy is running inside a Herdr-managed pane:
   ```bash
   test "${HERDR_ENV:-}" = 1
   ```
   If not, inform the user that Herdr delegation requires running inside Herdr and stop.
2. Ensure `$PWD` is a project workspace directory (not `$HOME`, `/tmp`, or system paths; the local `opencode` bwrap sandbox refuses overly broad directories).

## Workflow

### 1. Plan and Estimate (agy)

Investigate the relevant code and determine:
- **Implementation plan**: Concrete approach, architecture/style constraints, and non-goals.
- **Target files**: Exact paths to create or modify.
- **Acceptance criteria**: Expected behavior plus exact test/build/lint commands to verify.

Proceed to delegation **automatically without asking for confirmation** once these three items are clear. Only pause to ask the user if requirements have major ambiguity or irreversible/destructive trade-offs.

### 2. Delegate to OpenCode and Wait

Write the delegation brief to a temporary file (for example in the conversation scratch directory or `/tmp/opencode-task-<id>.md`) using this structure:

```markdown
# Task
<1-2 sentence goal>

## Implementation Plan
- <concrete steps and constraints>

## Target Files
- <path/to/file1>
- <path/to/file2>

## Acceptance Criteria
- <verifiable condition 1>
- <command to run and pass, e.g. pytest / nix flake check>

## Instructions
- Stay strictly within the scope and target files unless a small adjacent update is required.
- Run the verification commands listed in Acceptance Criteria before finishing.
- Summarize the changes made and verification results when done.
```

Then run the helper script [delegate.sh](./scripts/delegate.sh):

```bash
bash ~/.gemini/config/skills/herdr-opencode/scripts/delegate.sh \
  --prompt-file /path/to/task.md \
  --timeout 600000
```

Notes for running `delegate.sh`:
- Because `herdr` communicates over the Herdr server socket, run it outside the sandbox (`BypassSandbox: true` if sandboxed execution fails).
- For long tasks, let `run_command` background the script (small `WaitMsBeforeAsync`, reasonable `NotificationTimeoutSeconds`) instead of polling.
- By default, `delegate.sh`:
  1. Splits a sibling pane in the current tab with `--cwd "$PWD" --no-focus`.
  2. Starts `opencode` with a unique agent name (`herdr agent start <name> --kind opencode --pane <pane_id>`).
  3. Submits the prompt with `--wait`.
  4. Prints the final agent state and recent terminal output (`herdr agent read ... --source recent-unwrapped`).
  5. **Closes the newly created pane automatically** if the agent finished cleanly (`idle` or `done`).
  6. **Keeps the pane open** if the agent is `blocked`, timed out, or errored, printing `PANE_ID` and `AGENT_NAME` so agy can inspect or intervene.

Options for `delegate.sh`:
- `--prompt-file <path>` or `--prompt <text>`: Task prompt (one is required).
- `--timeout <ms>`: Wait timeout in milliseconds (default: `600000` = 10 min; `0` for no timeout).
- `--direction <auto|right|down>`: Split direction (default: `auto`).
- `--lines <n>`: Number of recent output lines to read (default: `150`).
- `--keep-pane`: Do not close the pane even after clean completion.
- `--name <agent_name>`: Override the generated agent name (`[a-z][a-z0-9_-]{0,31}`).

### 3. Handle Blocked or Timed-Out Runs

If `delegate.sh` exits non-zero because the agent is `blocked` or timed out:
1. Read the reported output (or run `herdr agent read <agent_name> --source recent-unwrapped --lines 200`).
2. If OpenCode is waiting for approval or asking a clarifying question, ask the user before answering it.
3. Send the response via `herdr agent prompt <agent_name> "<reply>" --wait` or `herdr agent send-keys <agent_name> ...` + `herdr agent wait <agent_name>`.
4. Once finished, close the pane created for this task:
   ```bash
   herdr pane close <pane_id>
   ```
   Never close panes that were not created by this workflow.

### 4. Verify Acceptance Criteria (agy)

After OpenCode finishes:
1. Inspect changes with `git status` and `git diff`.
2. Run the verification commands defined in Acceptance Criteria (tests, typecheck, build, lint).
3. If there is a minor gap, fix it directly or delegate a focused follow-up.
4. Report the summary of changes and verification results to the user.
