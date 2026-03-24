#!/usr/bin/env bash
# Notify user that Claude Code needs attention
# Usage: claude-notify [message] [sound]
#   sound: "attention" (default) | "complete"

TITLE="Claude Code"
MSG="${CLAUDE_NOTIFICATION_MESSAGE:-${1:-Waiting for your input}}"
SOUND="${2:-attention}"

# WSL2 on Windows
if grep -qi microsoft /proc/version 2>/dev/null || [ -n "$WSL_DISTRO_NAME" ]; then
    if [ "$SOUND" = "complete" ]; then
        WAV='C:\Windows\Media\Windows Notify.wav'
    else
        WAV='C:\Windows\Media\Windows Exclamation.wav'
    fi
    powershell.exe -c "(New-Object Media.SoundPlayer '$WAV').PlaySync()" 2>/dev/null &
    powershell.exe -NoProfile -c "
        Add-Type -AssemblyName System.Windows.Forms
        \$n = New-Object System.Windows.Forms.NotifyIcon
        \$n.Icon = [System.Drawing.SystemIcons]::Information
        \$n.Visible = \$true
        \$n.BalloonTipTitle = '$TITLE'
        \$n.BalloonTipText = '$MSG'
        \$n.ShowBalloonTip(5000)
        Start-Sleep -Seconds 6
        \$n.Dispose()
    " 2>/dev/null &
    printf '\a'
    exit 0
fi

# Linux with display (Mint, X11/Wayland)
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    command -v notify-send &>/dev/null && notify-send -u normal -t 8000 "$TITLE" "$MSG"
    if command -v paplay &>/dev/null; then
        if [ "$SOUND" = "complete" ]; then
            paplay /usr/share/sounds/freedesktop/stereo/message-new-instant.oga 2>/dev/null \
                || paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null
        else
            paplay /usr/share/sounds/freedesktop/stereo/dialog-warning.oga 2>/dev/null \
                || paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null
        fi
    elif command -v aplay &>/dev/null; then
        aplay /usr/share/sounds/sound-icons/guitar-12.wav 2>/dev/null
    fi
    printf '\a'
    exit 0
fi

# Fallback: terminal bell only
printf '\a'
