#!/usr/bin/env bash
# check-tools.sh — verify expected tools are present on this machine
# Usage: bash scripts/check-tools.sh
# Exit: 0 if all tools found, 1 if any missing

tools=(
    git
    vim
    tmux
    fzf
    bat
    eza
    fd
    rg
    mise
    uv
    jq
    delta
    zoxide
    shellcheck
    bats
    curl
    wget
    make
    ssh
)

missing=0

for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
        echo "OK:      $tool"
    else
        echo "MISSING: $tool"
        missing=1
    fi
done

if [ "$missing" -eq 1 ]; then
    echo ""
    echo "Some tools are missing. Install them to get the full dotfiles experience."
    exit 1
fi

echo ""
echo "All tools present."
