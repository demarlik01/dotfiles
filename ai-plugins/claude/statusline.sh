#!/bin/sh
# Line 1: where am I (dir, branch, version). Line 2: session (model, ctx, time, rate limits).
input=$(cat)
j() { echo "$input" | jq -r "$1 // empty"; }
DIM='\033[2m'; RST='\033[0m'
# percentage colored by level: green <50, yellow <80, red
pct() { p=$(printf '%.0f' "$1"); c=32; [ "$p" -ge 50 ] && c=33; [ "$p" -ge 80 ] && c=31; printf '\033[%sm%s%%\033[0m' "$c" "$p"; }

# ── line 1
dir=$(j '.workspace.current_dir // .cwd')
branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
printf '\033[1;36m%s\033[0m' "$(echo "$dir" | sed "s|^$HOME|~|")"
[ -n "$branch" ] && printf ' on \033[1;35m %s\033[0m' "$branch"
ver=$(j '.version');             [ -n "$ver" ] && printf "  ${DIM}v%s${RST}" "$ver"
style=$(j '.output_style.name'); [ -n "$style" ] && [ "$style" != default ] && printf "${DIM} · %s${RST}" "$style"
echo

# ── line 2: segments joined by a dim │
out=""
add() { [ -n "$out" ] && out="$out$(printf "${DIM} │ ${RST}")"; out="$out$1"; }

model=$(j '.model.display_name'); eff=$(j '.effort.level')
[ -n "$model" ] && add "$model$([ -n "$eff" ] && printf "${DIM} %s${RST}" "$eff")"

used=$(j '.context_window.used_percentage'); [ -n "$used" ] && add "ctx $(pct "$used")"

ms=$(j '.cost.total_duration_ms')
if [ -n "$ms" ]; then
  m=$((${ms%.*} / 60000))
  if [ "$m" -ge 60 ]; then add "$((m / 60))h$((m % 60))m"; else add "${m}m"; fi
fi

# rate limit: label, json key, date format of reset time
rl() {
  p=$(j ".rate_limits.$2.used_percentage"); [ -n "$p" ] || return
  r=$(j ".rate_limits.$2.resets_at")
  t=""; [ -n "$r" ] && t="$(printf "${DIM} (%s)${RST}" "$(date -r "${r%.*}" "$3")")"
  add "$1 $(pct "$p")$t"
}
rl 5h five_hour '+%H:%M'
rl 7d seven_day '+%a %H:%M'

[ -n "$out" ] && printf '%s\n' "$out"
