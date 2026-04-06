#!/usr/bin/env bash
# Claude Code statusline - Option C
# Line 1: model | dir | git branch + changes
# Line 2: context bar | cost | elapsed time

input=$(cat)

JQ=$(command -v jq 2>/dev/null || command -v jaq 2>/dev/null)

MODEL=$(echo "$input" | "$JQ" -r '.model.display_name // .model.id // "claude"')
DIR=$(echo "$input" | "$JQ" -r '.workspace.current_dir // .cwd // ""')
COST=$(echo "$input" | "$JQ" -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | "$JQ" -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | "$JQ" -r '.cost.total_duration_ms // 0')
RL_5H=$(echo "$input" | "$JQ" -r '.rate_limits.five_hour.used_percentage // empty')
RL_7D=$(echo "$input" | "$JQ" -r '.rate_limits.seven_day.used_percentage // empty')

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Context bar color
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"
fi

FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"
printf -v PAD "%${EMPTY}s"
BAR="${FILL// /▓}${PAD// /░}"

MINS=$((DURATION_MS / 60000))
SECS=$(((DURATION_MS % 60000) / 1000))

COST_FMT=$(printf '$%.2f' "$COST")
DIRNAME="${DIR##*/}"

# Git info
GIT_INFO=""
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
    STAGED=$(git -C "$DIR" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git -C "$DIR" diff --numstat 2>/dev/null | wc -l | tr -d ' ')

    CHANGES=""
    [ "$STAGED" -gt 0 ] && CHANGES="${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && CHANGES="${CHANGES}${YELLOW}~${MODIFIED}${RESET}"
    [ -n "$CHANGES" ] && CHANGES=" $CHANGES"

    GIT_INFO=" | 🌿 ${BRANCH}${CHANGES}"
fi

# Rate limit info
RL_INFO=""
if [ -n "$RL_5H" ] || [ -n "$RL_7D" ]; then
    RL_PARTS=""
    if [ -n "$RL_5H" ]; then
        RL_5H_INT=$(echo "$RL_5H" | cut -d. -f1)
        if [ "$RL_5H_INT" -ge 90 ]; then C="$RED"
        elif [ "$RL_5H_INT" -ge 70 ]; then C="$YELLOW"
        else C="$GREEN"; fi
        RL_PARTS="${C}5h:${RL_5H_INT}%%${RESET}"
    fi
    if [ -n "$RL_7D" ]; then
        RL_7D_INT=$(echo "$RL_7D" | cut -d. -f1)
        if [ "$RL_7D_INT" -ge 90 ]; then C="$RED"
        elif [ "$RL_7D_INT" -ge 70 ]; then C="$YELLOW"
        else C="$GREEN"; fi
        [ -n "$RL_PARTS" ] && RL_PARTS="${RL_PARTS} "
        RL_PARTS="${RL_PARTS}${C}7d:${RL_7D_INT}%%${RESET}"
    fi
    RL_INFO=" | ⚡ ${RL_PARTS}"
fi

printf "${CYAN}[${MODEL}]${RESET} ${DIRNAME}${GIT_INFO}\n"
printf "${BAR_COLOR}${BAR}${RESET} ${PCT}%% | ${YELLOW}${COST_FMT}${RESET} | ⏱ ${MINS}m ${SECS}s${RL_INFO}\n"
