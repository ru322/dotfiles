#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: delegate.sh (--prompt <text> | --prompt-file <path>) [options]

Options:
  --prompt <text>         Prompt text to send to OpenCode
  --prompt-file <path>    File containing the prompt text
  --timeout <ms>          Wait timeout in ms (default: 600000; 0 = indefinite)
  --start-timeout <ms>    Agent startup timeout in ms (default: 60000)
  --direction <dir>       Split direction: auto, right, down (default: auto)
  --lines <n>             Recent output lines to read (default: 150)
  --name <agent_name>     Explicit agent name ([a-z][a-z0-9_-]{0,31})
  --keep-pane             Keep the created pane open after completion
  -h, --help              Show this help
EOF
}

die() {
  echo "delegate.sh: $*" >&2
  exit 1
}

prompt_text=""
prompt_file=""
timeout_ms="600000"
start_timeout_ms="60000"
direction="auto"
read_lines="150"
agent_name=""
keep_pane=0

while [ $# -gt 0 ]; do
  case "$1" in
    --prompt)
      [ $# -ge 2 ] || die "--prompt requires a value"
      prompt_text="$2"
      shift 2
      ;;
    --prompt-file)
      [ $# -ge 2 ] || die "--prompt-file requires a value"
      prompt_file="$2"
      shift 2
      ;;
    --timeout)
      [ $# -ge 2 ] || die "--timeout requires a value"
      timeout_ms="$2"
      shift 2
      ;;
    --start-timeout)
      [ $# -ge 2 ] || die "--start-timeout requires a value"
      start_timeout_ms="$2"
      shift 2
      ;;
    --direction)
      [ $# -ge 2 ] || die "--direction requires a value"
      direction="$2"
      shift 2
      ;;
    --lines)
      [ $# -ge 2 ] || die "--lines requires a value"
      read_lines="$2"
      shift 2
      ;;
    --name)
      [ $# -ge 2 ] || die "--name requires a value"
      agent_name="$2"
      shift 2
      ;;
    --keep-pane)
      keep_pane=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

if [ "${HERDR_ENV:-}" != "1" ]; then
  die "HERDR_ENV is not 1; must run inside a Herdr-managed pane"
fi

command -v herdr >/dev/null 2>&1 || die "herdr not found in PATH"
command -v jq >/dev/null 2>&1 || die "jq not found in PATH"

if [ -n "$prompt_file" ]; then
  [ -r "$prompt_file" ] || die "cannot read prompt file: $prompt_file"
  prompt_text="$(cat "$prompt_file")"
fi
[ -n "$prompt_text" ] || die "either --prompt or --prompt-file is required"

if [ -z "$agent_name" ]; then
  agent_name="opencode-$(date +%H%M%S)-$$"
fi
# Ensure agent_name fits Herdr's [a-z][a-z0-9_-]{0,31} constraint.
agent_name="${agent_name:0:32}"

# Pick split direction automatically from current pane geometry when possible.
if [ "$direction" = "auto" ]; then
  direction="right"
  if [ -n "${HERDR_PANE_ID:-}" ]; then
    if layout_json="$(herdr pane layout --pane "$HERDR_PANE_ID" 2>/dev/null)"; then
      read -r cols rows <<<"$(printf '%s' "$layout_json" | jq -r '
        [
          (.result.pane.cols // .result.cols // .result.width // 0),
          (.result.pane.rows // .result.rows // .result.height // 0)
        ] | "\(.[0]) \(.[1])"
      ' 2>/dev/null || echo "0 0")"
      # Terminal cells are roughly 2x taller than wide; split down if narrow/tall.
      if [ "${cols:-0}" -gt 0 ] && [ "${rows:-0}" -gt 0 ] && [ "$cols" -lt $((rows * 2)) ]; then
        direction="down"
      fi
    fi
  fi
fi

# 1. Create sibling pane without stealing focus.
split_json="$(herdr pane split --current --direction "$direction" --cwd "$PWD" --no-focus)"
pane_id="$(printf '%s' "$split_json" | jq -r '.result.pane.pane_id // empty')"
[ -n "$pane_id" ] || die "failed to parse pane_id from herdr pane split: $split_json"

echo "PANE_ID=$pane_id"
echo "AGENT_NAME=$agent_name"
echo "DIRECTION=$direction"

# 2. Start OpenCode in the newly created pane.
if ! herdr agent start "$agent_name" --kind opencode --pane "$pane_id" --timeout "$start_timeout_ms" >/dev/null; then
  echo "STATUS=start_failed"
  if [ "$keep_pane" -eq 0 ]; then
    herdr pane close "$pane_id" >/dev/null 2>&1 || true
    echo "PANE_CLOSED=true"
  else
    echo "PANE_CLOSED=false"
  fi
  die "failed to start opencode in pane $pane_id"
fi

# 3. Submit prompt and wait for settled state.
prompt_args=(agent prompt "$agent_name" "$prompt_text" --wait)
if [ "$timeout_ms" != "0" ]; then
  prompt_args+=(--timeout "$timeout_ms")
fi

prompt_rc=0
prompt_err=""
if ! prompt_err="$(herdr "${prompt_args[@]}" 2>&1 >/dev/null)"; then
  prompt_rc=$?
fi

# 4. Inspect final state and read recent output.
agent_json="$(herdr agent get "$agent_name" 2>/dev/null || echo '{}')"
status="$(printf '%s' "$agent_json" | jq -r '.result.agent.status // .result.status // .status // "unknown"' 2>/dev/null || echo "unknown")"

output_raw="$(herdr agent read "$agent_name" --source recent-unwrapped --lines "$read_lines" 2>/dev/null || true)"
output_text="$(printf '%s' "$output_raw" | jq -r 'if type == "object" then (.result.text // .result.output // .result.content // .text // .) else . end' 2>/dev/null || printf '%s' "$output_raw")"

echo "PROMPT_EXIT_CODE=$prompt_rc"
echo "STATUS=$status"
if [ -n "$prompt_err" ]; then
  echo "PROMPT_ERROR=$prompt_err"
fi

# 5. Close pane only on clean completion (idle/done and prompt succeeded), unless --keep-pane.
pane_closed="false"
if [ "$keep_pane" -eq 0 ] && [ "$prompt_rc" -eq 0 ] && { [ "$status" = "idle" ] || [ "$status" = "done" ]; }; then
  if herdr pane close "$pane_id" >/dev/null 2>&1; then
    pane_closed="true"
  fi
fi
echo "PANE_CLOSED=$pane_closed"

echo "=== AGENT_OUTPUT_BEGIN ==="
printf '%s\n' "$output_text"
echo "=== AGENT_OUTPUT_END ==="

if [ "$prompt_rc" -ne 0 ]; then
  exit "$prompt_rc"
fi
if [ "$status" = "blocked" ]; then
  exit 2
fi
