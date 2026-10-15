# Claude Code status line: context tokens / 5h & weekly limit remaining / next reset.
# Reads the session JSON from stdin (see https://code.claude.com/docs/en/statusline).

input=$(cat)

IFS='|' read -r tokens size five_used five_reset week_used week_reset < <(
  printf '%s' "$input" | jq -r '[
    (.context_window.total_input_tokens // 0),
    (.context_window.context_window_size // 0),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.rate_limits.seven_day.resets_at // "")
  ] | map(tostring) | join("|")'
)

now=$(date +%s)
dim=$'\e[2m'
reset=$'\e[0m'

# 45231 -> 45.2k
human() {
  local n=${1%.*}
  if ((n >= 1000000)); then
    printf '%d.%dM' $((n / 1000000)) $((n % 1000000 / 100000))
  elif ((n >= 1000)); then
    printf '%d.%dk' $((n / 1000)) $((n % 1000 / 100))
  else
    printf '%d' "$n"
  fi
}

# Seconds until epoch -> 42m / 2h13m / 3d4h
until_str() {
  local s=$(($1 - now))
  ((s < 0)) && s=0
  if ((s >= 86400)); then
    printf '%dd%dh' $((s / 86400)) $((s % 86400 / 3600))
  elif ((s >= 3600)); then
    printf '%dh%02dm' $((s / 3600)) $((s % 3600 / 60))
  else
    printf '%dm' $((s / 60))
  fi
}

# Remaining percentage, coloured by how much is left
remain() {
  local left=$((100 - ${1%.*}))
  local color=$'\e[32m'
  ((left <= 50)) && color=$'\e[33m'
  ((left <= 20)) && color=$'\e[31m'
  printf '%s%d%%%s' "$color" "$left" "$reset"
}

parts=()

if ((${tokens%.*} > 0)); then
  parts+=("$(human "$tokens")${dim}/$(human "$size")${reset}")
else
  parts+=("${dim}0 tok${reset}")
fi

if [[ -n $five_used ]]; then
  parts+=("5h $(remain "$five_used") ${dim}↻$(until_str "$five_reset")${reset}")
fi

if [[ -n $week_used ]]; then
  parts+=("週 $(remain "$week_used") ${dim}↻$(until_str "$week_reset")${reset}")
fi

sep=" ${dim}│${reset} "
out=${parts[0]}
for p in "${parts[@]:1}"; do
  out+="$sep$p"
done
printf '%s\n' "$out"
