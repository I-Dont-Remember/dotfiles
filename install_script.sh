#! /bin/bash

##############################
#
# Functions
#
##############################
#usage:
# in_list "10 11 12" "2" or 'in_list "$my_list" "$my_item"'
in_list() {
  list="$1"
  item="$2"
  if [[ $list =~ (^|[[:space:]])"$item"($|[[:space:]]) ]] ; then
    # yes, list include item
    result=0
  else
    result=1
  fi
  return $result
}

# TODO: non-functional
# usage:
# check_num_args "$#" "eq" "5"
# depends: is_int
# check_num_args() {
#     num_args=$1
#     conditional=$2
#     num_desired=$3

#     tests=( eq ne le ge lt gt )
#     if is_int $num_desired && is_int $num_args; then
#         # check args
#         # case $conditional in
#         # "eq")
#         #     ;;
#         # esac
#         if in_list "$tests" "$conditional"; then
#             echo "$num_args -$conditional $num_desired"
#             if [ $num_args -$conditional $num_desired ]; then
#                 return 0
#             else
#                 return 1
#             fi
#         else
#             echo "check_num_args: Invalid conditional"
#             exit 1
#         fi
#     else
#         echo "check_num_args: Not an integer"
#         exit 1
#     fi
# }

# usage:
#
# returns 1 if int and 0 otherwise
is_int() {
  #return $(test "$@" -eq "$@" > /dev/null 2>&1);
    if [[ $1 =~ ^-?[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

##############################
#
# Main
#
##############################

# Possible additions https://github.com/adamatan/bash-boilerplate/blob/master/boilerplate.sh
mock=0
dir=~/dotfiles
olddir=~/old_dotfiles
ignorefiles="README.md install_script.sh scripts scripts_deprecated log4bash.sh cheat-sheets configuration link_dotfiles.sh spinners.sh agent-docs tests Makefile CLAUDE.md claude mise ublock-origin-filters.txt gitignore_global"

echo "__________________________________________"
echo "Running install script for Kevin's dotfiles!"
echo "Must provide anything as argument to run, empty is assumed to be accidental or test."
echo "__________________________________________"
echo ""

if [ "$#" -eq 0 ]; then
    echo "Running in test mode (only lists output)"
    mock=1
fi

echo "Changing to $dir.."
cd "$dir" || exit 5

if [ "$mock" -eq "1" ]; then
    echo "Moving any existing files in $HOME to $olddir.."
    for entry in "$dir"/*; do
        fname=$(basename "$entry")

        if in_list "$ignorefiles" "$fname"; then
            echo "-> ignored $fname"
            continue
        fi
        if [ -L "$HOME/.$fname" ] && [ "$(readlink "$HOME/.$fname")" = "$entry" ]; then
            echo "-> already linked: .$fname (skipping)"
            continue
        fi
        if [[ -e "$HOME/.$fname" ]]; then
            echo "-> moving .$fname"
        fi
        if [[ $fname == "ssh-config" ]]; then
            echo "Creating symlink for .ssh/config"
        else
            echo "-> create symlink for $fname"
        fi
    done

    echo "Creating ${HOME}/bin..."

    for script in "$dir"/scripts/*; do
        scriptname=$(basename "$script")
        echo "-> (placeholder) creating symlink for $scriptname"
    done

    echo "-> (placeholder) create symlink for .claude/settings.json"
    echo "-> (placeholder) create symlink for .claude/CLAUDE.md"
    echo "-> (placeholder) create symlink for .config/mise/config.toml"
    echo "-> (placeholder) create symlink for .gitignore_global"
    echo "-> (placeholder) create symlink for ~/bin/check-tools"
    echo "-> (placeholder) create symlink for ~/bin/claude-notify"
    echo "...done"
    exit 0
fi

########################################
# Real script
########################################
echo "Moving any existing files in ~ to $olddir.."
mkdir -p "$olddir"

for entry in "$dir"/*; do
    fname=$(basename "$entry")

    if in_list "$ignorefiles" "$fname"; then
        echo "-> ignored $fname"
        continue
    fi

    if [[ $fname == "ssh-config" ]]; then
        mkdir -p "$HOME/.ssh"
        target="$HOME/.ssh/config"
        source="$entry"

        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            echo "-> already linked: .ssh/config (skipping)"
            continue
        fi

        echo "Creating symlink for .ssh/config"
        if [[ -e "$target" && ! -L "$target" ]]; then
            mv "$target" "$olddir/ssh-config"
        fi
        ln -sf "$source" "$target"
    else
        target="$HOME/.$fname"
        source="$entry"

        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            echo "-> already linked: .$fname (skipping)"
            continue
        fi

        if [[ -e "$target" ]]; then
            echo "-> moving .$fname"
            mv "$target" "$olddir"
        fi
        echo "-> create symlink for $fname"
        ln -s "$source" "$target"
    fi
done

echo "Creating ${HOME}/bin..."
mkdir -p ~/bin

# Link scripts
if [ ! -L ~/bin/gitcheck ] || [ "$(readlink ~/bin/gitcheck)" != "$dir/scripts/gitcheck.sh" ]; then
    ln -sf "$dir/scripts/gitcheck.sh" ~/bin/gitcheck
fi

# Claude Code settings
echo "Setting up Claude Code settings..."
mkdir -p ~/.claude
if [[ -e ~/.claude/settings.json && ! -L ~/.claude/settings.json ]]; then
    echo "-> backing up existing ~/.claude/settings.json"
    mv ~/.claude/settings.json "$olddir/claude-settings.json"
fi
if [ ! -L ~/.claude/settings.json ] || [ "$(readlink ~/.claude/settings.json)" != "$dir/claude/settings.json" ]; then
    ln -sf "$dir/claude/settings.json" ~/.claude/settings.json
    echo "-> symlinked ~/.claude/settings.json"
else
    echo "-> already linked: .claude/settings.json (skipping)"
fi
if [[ -e ~/.claude/CLAUDE.md && ! -L ~/.claude/CLAUDE.md ]]; then
    echo "-> backing up existing ~/.claude/CLAUDE.md"
    mv ~/.claude/CLAUDE.md "$olddir/claude-CLAUDE.md"
fi
if [ ! -L ~/.claude/CLAUDE.md ] || [ "$(readlink ~/.claude/CLAUDE.md)" != "$dir/claude/CLAUDE.md" ]; then
    ln -sf "$dir/claude/CLAUDE.md" ~/.claude/CLAUDE.md
    echo "-> symlinked ~/.claude/CLAUDE.md"
else
    echo "-> already linked: .claude/CLAUDE.md (skipping)"
fi

# mise global config
echo "Setting up mise global config..."
mkdir -p ~/.config/mise
mise_target="$HOME/.config/mise/config.toml"
mise_source="$dir/mise/config.toml"
if [ -L "$mise_target" ] && [ "$(readlink "$mise_target")" = "$mise_source" ]; then
    echo "-> already linked: .config/mise/config.toml (skipping)"
else
    if [[ -e "$mise_target" && ! -L "$mise_target" ]]; then
        mv "$mise_target" "$olddir/mise-config.toml"
    fi
    ln -sf "$mise_source" "$mise_target"
    echo "-> symlinked ~/.config/mise/config.toml"
fi

# global gitignore
echo "Setting up gitignore_global..."
gi_target="$HOME/.gitignore_global"
gi_source="$dir/gitignore_global"
if [ -L "$gi_target" ] && [ "$(readlink "$gi_target")" = "$gi_source" ]; then
    echo "-> already linked: .gitignore_global (skipping)"
else
    if [[ -e "$gi_target" && ! -L "$gi_target" ]]; then
        mv "$gi_target" "$olddir/gitignore_global"
    fi
    ln -sf "$gi_source" "$gi_target"
    echo "-> symlinked ~/.gitignore_global"
fi

# check-tools script
if [ ! -L ~/bin/check-tools ] || [ "$(readlink ~/bin/check-tools)" != "$dir/scripts/check-tools.sh" ]; then
    ln -sf "$dir/scripts/check-tools.sh" ~/bin/check-tools
    echo "-> symlinked ~/bin/check-tools"
fi

# claude-notify script
if [ ! -L ~/bin/claude-notify ] || [ "$(readlink ~/bin/claude-notify)" != "$dir/scripts/claude-notify.sh" ]; then
    ln -sf "$dir/scripts/claude-notify.sh" ~/bin/claude-notify
    echo "-> symlinked ~/bin/claude-notify"
fi

echo "...done"
