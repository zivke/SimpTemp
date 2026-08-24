#!/bin/bash
# Status line: model name, context-usage progress bar, 5h/7d rate-limit usage
# bars, then a path segment derived from the PS1 in ~/.bashrc
# (\u@\h:\w\$, trailing "$" dropped), then the current git branch if any.
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

bar_width=10

# Prints a "[#####-----] NN%" bar for a 0-100 percentage. No output if empty.
print_bar() {
    local pct="$1"
    [ -z "$pct" ] && return
    local filled empty bar i
    filled=$(awk -v u="$pct" -v w="$bar_width" \
        'BEGIN { v = int((u * w / 100) + 0.5); if (v > w) v = w; if (v < 0) v = 0; print v }')
    empty=$((bar_width - filled))
    bar=""
    for ((i = 0; i < filled; i++)); do bar+="#"; done
    for ((i = 0; i < empty; i++)); do bar+="-"; done
    printf '[\033[33m%s\033[00m %s%%] ' "$bar" "$(awk -v u="$pct" 'BEGIN { printf "%.0f", u }')"
}

printf '\033[36m%s\033[00m ' "$model"
print_bar "$used"
[ -n "$five_hour" ] && printf '5h '
print_bar "$five_hour"
[ -n "$seven_day" ] && printf '7d '
print_bar "$seven_day"
printf '\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m' "$(whoami)" "$(hostname -s)" "$(pwd)"

branch=$(git branch --show-current 2>/dev/null)
[ -n "$branch" ] && printf ' \033[35m(%s)\033[00m' "$branch"

