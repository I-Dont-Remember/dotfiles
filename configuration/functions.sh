#! /bin/bash


# **********************************
# helpers
# **********************************
add_to_sources() {
    repo=$1
    filename=$2
    echo "$repo" >> /etc/apt/sources.list.d/"$filename".list
}

ilog() {
    log "installing $1..."
}

log() {
    echo "[*] $1"
}

error() {
    echo "[!] $1"
    # echo "[!] $1" | tee -a error.log
}

# cheeky way to make an alias
ai='apt-get install -y'
ar='apt-get remove -y'
# TODO: find out why snaps are causing kernel panics
si='snap install'
update='apt-get update'

# **********************************
# individual tasks
# **********************************
# @root
install-etcher() {
    # https://github.com/balena-io/etcher
    # TODO: check again in a bit, looks like issue on their end
    ilog "Etcher"
    add_to_sources "deb https://deb.etcher.io stable etcher" etcher
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
    $update
    apt-get install etcher-electron
}

# @root
install-arduino() {
    ilog "Arduino"
    $ai libcanberra-gtk-module \
        arduino
}

# @root
install-dropbox() {
    # https://www.dropbox.com/install-linux
    ilog "Dropbox"
}

# @root
install-react-native() {
    echo "install react native stuff"
    install-android-emulation
}

#@root
install-android-emulation() {
    # TODO: install android studio
    # https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/how-to-install-android-studio-on-ubuntu-18-04-lts-bionic-beaver.html
    echo "Installing android studio"
}

# @root
install-chromium() {
    ilog "Chromium"
    # $ai chromium-browser
    $si chromium
}

# @root
install-browser-extensions() {
    # ublock origin
    # onetab ---> TODO: session buddy instead?
    # https everywhere
    # privacy badger?
    # THIS NEEDS TO BE EXPANDED AND MADE CONSISTENT ACROSS BROWSERS
    # TODO: have one browser that's full of shopping extensions and that's the only thing it gets used for
    echo "installing browser extensions"
}

# @root
install-chrome() {
    apt install google-chrome-stable
}

# @root
install-firefox() {
    ilog "Firefox"
    $ai firefox
}

# @root
install-opera() {
    ilog "Opera"
    # $ai opera-stable
    $si opera
}

# @root
install-vscode() {
    # process borrowed from https://github.com/gantsign/ansible-role-visual-studio-code/blob/master/tasks/install-apt.yml
    # Extensions:
    #   - eamodio.gitlens
    #   - ms-vscode.go
    #   - ms-python.python
    #   - mechatroner.rainbow-csv
    #   - oderwat.indent-rainbow
    #   - coenraads.bracket-pair-colorizer
    #   - timonwong.shellcheck
    #   - wayou.vscode-todo-highlight
    #   - aaron-bond.better-comments
    ilog "vscode"
    $si vscode --classic
    #$ai gconf2 libasound2 libgtk2.0-0 libxss1
    # add_to_sources "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" vscode
    # $(curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg)
    # apt-key add microsoft.gpg
    # $update
    # $ai code

    # vsfile=vscode.deb
    # wget -O "$vsfile" https://go.microsoft.com/fwlink/?LinkID=760868
    # dpkg -i "$vsfile"
    # $ai install -f
    # rm "$vsfile"
}

# @user
finish-vscode() {
    str_extensions="eamodio.gitlens,\
ms-vscode.go,\
ms-python.python,\
mechatroner.rainbow-csv,\
oderwat.indent-rainbow,\
coenraads.bracket-pair-colorizer,\
timonwong.shellcheck,\
wayout.vscode-todo-highlight,\
minhthai.vscode-todo-parser"
    IFS=, read -r -a extensions <<< "$str_extensions"
    for ext in "${extensions[@]}"; do
        ilog "vscode extension $ext"
        code --log info --install-extension --force "$ext"
    done
}

# @root
install-virtualbox() {
    ilog "Virtualbox"
    $ai virtualbox
    $update
    $ai dkms
}

# @root 
install-vagrant() {
    ilog "Vagrant"
}

# @root
install-docker() {
    ilog "Docker"
}

# @root
install-spotify() {
    ilog "Spotify"
    $si spotify
}

# @root
install-slack() {
    ilog "Slack"
    $si
}

# @root
install-go() {
    ilog "Go"
    # https://github.com/syndbg/goenv
}

# @root
install-python() {
    ilog "Python"
    # install pyenv
    # install latest python versions
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

install-mise() {
    curl https://mise.run | sh
}

# Install modern CLI tool replacements (bat, eza, fd, ripgrep, delta, zoxide, jq, fzf)
# On Linux: uses apt where available, falls back to cargo/mise
# On macOS: brew install bat eza fd ripgrep git-delta zoxide jq fzf
install-modern-cli-tools() {
    log "Installing modern CLI tools"
    # apt-installable tools
    $update
    $ai \
        bat \
        fd-find \
        ripgrep \
        jq \
        fzf \
        zoxide

    # eza: not in apt on older Ubuntu; install via cargo or mise
    if ! command -v eza &>/dev/null; then
        if command -v cargo &>/dev/null; then
            cargo install eza
        else
            log "eza not available via apt; install cargo or use: mise use --global eza"
        fi
    fi

    # delta: git diff pager — install via cargo or download release
    if ! command -v delta &>/dev/null; then
        if command -v cargo &>/dev/null; then
            cargo install git-delta
        else
            log "delta not available via apt; install cargo or download from https://github.com/dandavison/delta/releases"
        fi
    fi
}

# @user
python-tools() {
    log "Finish Python setup"
    # install pipx for cli tools in pip
    # install pipenv/poetry
    # install any global pip tools (i.e. aws cli)
}

# @root
install-node() {
    ilog "Node"
    # https://github.com/creationix/nvm
    # install nvm
    # install a newish version of node
    # TODO: have to source profile to get us back?
}

node-tools() {
    # install serverless cli 
    log "Finish Node tools installation"
    npm -g serverless
}

# @root
install-java() {
    ilog "Java"
    # for the occasional time it is useful and learning other JVM languages
    # get a newer version though, we have real old ones
}

# @root
install-vpn() {
    ilog "Wisc VPN"
    $ai openconnect \
        network-manager-openconnect \
        network-manager-openconnect-gnome
}

# @root
install-zaproxy() {
    ilog "OWASP Zap"
    $si zaproxy --classic
}

# @root
install-dev-packages() {
    #   sc (shellcheck) - linter to help write better Bash - in future look into https://github.com/mvdan/sh formatters
    #   grip - markdown preview
    #   httpie - better than curl
    #   autojump - quickly move around command line
    #   yakuake - best tool ever, drop down command line
    #   zenity - graphical dialog boxes for shell scripts
    #   libncurses - for interesting graphical curses stuff
    #   code - VS Code, our favorite text editor
    ilog "Dev packages"
    # TODO: set these up as arrays, so we can run tests against it easily?  a simple command -v would suffice
    $ai shellcheck \
        bats \
        grip \
        vim \
        git \
        tmux \
        httpie \
        autojump \
        yakuake \
        strace \
        nmap \
        tcpdump \
        zenity \
        libncurses5-dev \
        libncursesw5-dev \
        code

}

install-jetbrains-toolbox() {
    # https://www.jetbrains.com/toolbox-app/
    ilog "Jetbrains ToolBox"
    file_name="jetbrains-toolbox-1.17.6856.tar.gz"
    targz_url="https://download.jetbrains.com/toolbox/${file_name}"
    wget $targz_url -O "~/Downloads/$file_name"
    # TODO: what do we do here?
}

# @root
install-timeshift() {
    # https://itsfoss.com/backup-restore-linux-timeshift/
    ilog "Timeshift"
    apt-add-repository 'ppa:teejee2008/ppa'
    $update
    $ai timeshift
}

# @root
install-misc-packages() {
    #   meld - file comparison
    #   okular - for pdf viewing
    #   fdupes/fslint - clear duplicate files
    #   cowsay/figlet/sl - fun
    #   zip,etc. - getting everything extracted
    #   ncdu - understand where space is
    #   recordmydesktop - captures video of a linux session
    #   nordvpn - current VPN service we pay for
    #   TODO: gnome tweaks & extensions
    ilog "Misc packages"
    $ai meld \
        okular \
        fdupes \
        fslint \
        rdesktop \
        kdeconnect \
        gwenview \
        libreoffice \
        wget \
        curl \
        cowsay \
        figlet \
        sl \
        ncdu \
        less \
        zip unzip tar rar unrar p7zip p7zip-full \
        make \
        gparted \
        recordmydesktop \
        gnome-tweak-tool \
        nordvpn

# htop or glances? g is from pip https://nicolargo.github.io/glances/

}

# @root
remove-default-packages() {
    log "remove default packages"
    # mostly games & unused software
    $ar aisleriot \
        gnome-accessibility-themes \
        gnome-online-accounts \
        gnome-calendar \
        gnome-contacts \
        gnome-documents \
        gnome-mines \
        gnome-mahjongg \
        gnome-maps \
        gnome-music \
        gnome-orca \
        gnome-photos \
        gnome-sudoku \
        gnome-weather \
        kwalletmanager \
        libpam-kwallet5 \
        rhythmbox \
        rhythmbox-data \
        rhythmbox-plugin-magnatune \
        rhythmbox-plugin-zeitgeist \
        rhythmbox-plugins \
        kmail 
}

# @root
# make sure all necessary tools & whatnot are setup
# TODO: make sure Dockerfile and this setup have the same contents
setup() {
    log "SETUP"
    $update && apt-get -y upgrade
    # setup for snap installation
    # - for 18.04, already installed and ready to go on real machine but not Docker image
    $ai snapd build-essential apt-transport-https net-tools
}

# ****************************************************
# ****************************************************
# Main
# ****************************************************
# ****************************************************
main() {
    log "Here we go!!"
    setup

    remove-default-packages

# browsers
    install-chromium
    install-chrome
    install-firefox
    # install-opera all in on firefox

# Setup TickTick somehow

# dev stuff
    install-python
    python-tools
    install-node
    node-tools
    install-go
    # install-react-native we don't do app development really anymore
    install-zaproxy
    install-jetbrains-toolbox
    install-dev-packages

# misc
    install-spotify
    install-virtualbox
    install-vpn
    install-etcher
    install-misc-packages
}
