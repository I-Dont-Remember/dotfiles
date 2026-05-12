# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

#######################################################
#
# Environment — applies to all shells (interactive and non-interactive)
#
#######################################################
# Add personal scripts directory
export PATH="$HOME/bin:$PATH"
# pipx tools and python user installs
export PATH="$HOME/.local/bin:$PATH"

# always use VIM so i never have to see Nanos stupid face
export VISUAL=vim
export EDITOR="$VISUAL"

# If not running interactively, don't do anything else
case $- in
    *i*) ;;
      *) return;;
esac

#######################################################
#
# Interactive-only configuration below
#
#######################################################

################
# Prompt Stuff
# TODO: have to go through here and eliminate pieces that overlap each other
################
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Git Aware Prompt - shamelessly stolen from https://github.com/jimeh/git-aware-prompt
find_git_branch() {
  # Based on: http://stackoverflow.com/a/13003854/170413
  local branch
  if branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
    if [[ "$branch" == "HEAD" ]]; then
      branch='detached*'
    fi
    git_branch="($branch)"
  else
    git_branch=""
  fi
}

find_git_dirty() {
  local status=$(git status --porcelain 2> /dev/null)
  if [[ "$status" != "" ]]; then
    git_dirty='*'
  else
    git_dirty=''
  fi
}
PROMPT_COMMAND="find_git_branch; find_git_dirty; $PROMPT_COMMAND"

# use http://bashrcgenerator.com/ for easy generation
# Original \h:\W \u\$
export PS1="\[\033[38;5;11m\]\t:\w:\$git_branch\$git_dirty\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;11m\][\[$(tput sgr0)\]\[\033[38;5;7m\]\$?\[$(tput sgr0)\]\[\033[38;5;11m\]]▶ \[$(tput sgr0)\]"
export CLICOLOR=1



###################
# History Stuff
###################
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

#######################################################
#
# Load OS specific files
#
#######################################################
# https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script
case $OSTYPE in
    solaris*)
        echo "You have Solaris??"
    ;;
    darwin*)
        if [ -f ~/.bashrc_macos ]; then
            . ~/.bashrc_macos
        fi
    ;;
    linux*)
        if [ -f ~/.bashrc_linux ]; then
            . ~/.bashrc_linux
        fi
    ;;
    bsd*)
        echo "You have BSD??"
    ;;
    *)
    echo "Unknown OSTYPE $OSTYPE in bashrc check"
    ;;
esac

####################
#
# Modern tools
#
####################

# fzf — fuzzy finder shell integration (keybindings + completion)
# Requires fzf >= 0.48; no-op if not installed
command -v fzf &>/dev/null && eval "$(fzf --bash)"

# check for a saved Claude token to export
check_expiry() {
    # Example Usage:
    # check_expiry "1/1/2025"
    # Argument: Date in M/D/YYYY or MM/DD/YYYY format
    local expiry_date="$1"
    local warning_days=20

    # Get current date and expiry date in seconds since epoch
    # 'date -d' parses the string, '+%s' outputs seconds
    local now_epoch=$(date +%s)
    local exp_epoch=$(date -d "$expiry_date" +%s 2>/dev/null)

    # Check if date parsing was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Invalid date format. Please use M/D/YYYY."
        return 1
    fi

    # Calculate difference in seconds
    local diff_seconds=$((exp_epoch - now_epoch))
    # Convert seconds to days ($60*60*24 = 86400$)
    local diff_days=$((diff_seconds / 86400))

    # Warning threshold
    if [[ $diff_days -lt 0 ]]; then
        echo "WARNING: $expiry_date has already expired ($((-diff_days)) days ago)."
    elif [[ $diff_days -le $warning_days ]]; then
        echo "WARNING: $expiry_date expires in less than $warning_days days ($diff_days days away)."
    fi
}

load_claude_oauth_token() {
    token_file="$HOME/.claude/oauth-token.txt"
    if [ -f "$token_file" ]; then
        expiry_date=$(awk 'NR==2 {print $2}' $token_file)
        check_expiry $expiry_date
        token=$(awk 'NR==1' $token_file)
        current_date_in_same_format=$(date +%D)
        export CLAUDE_CODE_OAUTH_TOKEN=$token
    else
        echo "WARN: no token file found for Claude Code!"
    fi
}
load_claude_oauth_token


####################
#
# Fin
#
####################

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/user/.lmstudio/bin"
# End of LM Studio CLI section

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

