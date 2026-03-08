#! /bin/bash
# Ansible is starting to seem like a time suck and overkill,
# see how quickly we can get this to a state we like
# This guy had same idea, just with less stuff https://www.switchingtomac.com/tutorials/terminal/how-to-make-a-bulk-app-installer-for-a-new-mac-os-install-using-homebrew/


# handle
function failed() {
    echo "[!] failed installing $1" \
        && echo "bi: $1" >> failure.log
}

# idempotent brew install
# TODO: this will fail if program name is different than install name
function bi() {
    item=$1
    if [ -z "$item" ]; then
        echo "[!] bi needs an argument."
    else
        command -v "$item" > /dev/null 2>&1 \
            && echo "[*] $item is already installed." \
            || { echo "[*] installing $item..."; brew install "$item"; } || failed "$item"
    fi
}

# idempotent brew cask install
# TODO: this will fail if program name is different than install name
function bci() {
    item=$1
    if [ -z "$item" ]; then
        echo "[!] bci needs an argument."
    else
        command -v "$item" > /dev/null 2>&1 \
            && echo "[*] $item is already installed." \
            || { echo "[*] installing $item..."; brew cask install "$item"; } || failed "$item"
    fi
}

function setup () {
    # check brew and brew cask and other download tools exist
    # TODO: setup homebrew & all necessary taps
    # do whatever the weird mac tools thing is that's required for stuff
    xcode-select --install
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    # double check install went well
    brew doctor || { echo "failed doctor's visit"; exit 2; }
}

function main() {
    echo "!! Did you read this link yet? if not, press Ctrl-C."
    echo "https://sourabhbajaj.com/mac-setup/SystemPreferences/"
    read  -n 1 -p "->" mainmenuinput
    setup

# browsers
    bci "chromium"
    bci "firefox"


# dev stuff
    bci "docker"
    bci "iterm2"
    bi "git"
    bi "vim"
    bi "bash-completion"
    bi "bats-core"
    bi "shellcheck"
    bi "httpie"
    bi "cowsay"
    bi "wget"
    bi "nmap"


    # Python
    bi "pyenv"
    # TODO: add pyenv init to shell (should be in dotfiles)
    # TODO: install global python versions, then install pipenv
    echo "[*] setting up Pyenv & Pipenv..."
    pyenv install 3.7.1
    pyenv global 3.7.1
    # setup pipx, pipenv/poetry
    

    # Node
    # TODO: setup NVM

    # Go
    # TODO: setup Golang
    #bi "golang"

    # 
# misc
    # bci "alfred" haven't found we really use this
    bci "virtualbox"
    bci "vagrant"
    bci "vagrant-manager"
    bci "slack"
}


# TODO: Do we like this ansible playbook better? https://github.com/geerlingguy/mac-dev-playbook/blob/master/default.config.yml
# TODO: configure our dotfiles
main