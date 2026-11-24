#!/usr/bin/env bash
# フタを閉じてもすぐにはスリープしないようにする (最大 MAX_MINUTES 分)。
#
# logind はフタを閉じた瞬間に HandleLidSwitch を実行するので、閉じる前に
# handle-lid-switch の inhibitor を取っておく必要がある。ここではエージェントの
# プロセスが居る間その inhibitor を保持し、フタが開いている間は時間を数えない。
# フタを閉じたまま MAX_MINUTES 経過したら inhibitor を手放し、通常どおり suspend する。

set -uo pipefail

USER_NAME=${KEEP_AWAKE_USER:?KEEP_AWAKE_USER is not set}
MAX_SECONDS=$(( ${MAX_MINUTES:-30} * 60 ))
AGENTS=${KEEP_AWAKE_AGENTS:-"opencode codex claude"}
POLL_SECONDS=5

log() { echo "agent-keepawake: $*" >&2; }

lid_closed() { grep -qs closed /proc/acpi/button/lid/*/state; }

has_lid() {
  local f
  for f in /proc/acpi/button/lid/*/state; do
    [ -e "$f" ] && return 0
  done
  return 1
}

agent_running() {
  local a
  for a in $AGENTS; do
    pgrep -f -u "$USER_NAME" "(^|/)$a( |$)" >/dev/null && return 0
  done
  return 1
}

held=0
inhibitor_pid=0
deadline=0
gave_up=0

hold() {
  (( held )) && return 0
  systemd-inhibit \
    --what=handle-lid-switch \
    --who=agent-keepawake \
    --why="AI coding agent is running" \
    --mode=block \
    -- sleep infinity &
  inhibitor_pid=$!
  held=1
  log "lid switch inhibited (pid $inhibitor_pid)"
}

release() {
  (( held )) || return 0
  kill "$inhibitor_pid" 2>/dev/null || true
  wait "$inhibitor_pid" 2>/dev/null || true
  held=0
  log "lid switch inhibitor released"
}

suspend_now() {
  log "lid is closed and nothing keeps the machine awake; suspending"
  systemctl suspend || log "systemctl suspend failed"
}

trap release EXIT
trap 'exit 0' INT TERM

if ! has_lid; then
  log "no lid switch found, nothing to do"
  exit 0
fi

while :; do
  now=$(date +%s)

  if ! agent_running; then
    if (( held )); then
      release
      # フタを閉じたイベントは inhibitor 中に起きたので logind はもう反応しない。
      # 閉じたままならこちらから suspend する。
      if lid_closed; then
        gave_up=1
        suspend_now
      fi
    fi
  elif lid_closed; then
    if (( gave_up )); then
      : # このフタ閉じではもう寝かせた。開くまで何もしない
    elif (( deadline == 0 )); then
      deadline=$(( now + MAX_SECONDS ))
      hold
    elif (( now >= deadline )); then
      release
      gave_up=1
      suspend_now
    else
      hold
    fi
  else
    # フタが開いている間はカウントダウンしない
    gave_up=0
    deadline=0
    hold
  fi

  sleep "$POLL_SECONDS"
done
