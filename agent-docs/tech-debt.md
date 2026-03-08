# Tech Debt

This document tracks known tech debt in the dotfiles repo. Items are grouped by file/area.
Each item is independently actionable — agents can be given a single item to fix.

---

## `install_script.sh`

- **Not idempotent**: Re-running the script overwrites symlinks and moves existing dotfiles to `$olddir` repeatedly. TODOed in the file itself. `$olddir` (`~/old_dotfiles`) is also never created before `mv` attempts to use it, which will cause failures.
- **Unquoted variables in mock loop**: `for entry in $dir/*` and `fname=$(basename $entry)` are unquoted, breaking on paths with spaces.
- **SSH symlink uses relative path**: `ln -s ssh-config ~/.ssh/config` (line 145) uses a bare filename, not the absolute path `$entry`. This will create a broken symlink unless CWD happens to be `$dir`.
- **Only links `gitcheck.sh`** from `scripts/`: `eye_saver.sh` and `disk-usage` are not linked.
- **Duplicate logic between mock/real modes**: The mock and real loops are nearly identical copy-paste; could be DRYed with a `--dry-run` flag pattern.
- **`link_dotfiles.sh` references non-existent files**: `bashrc_linux`, `bash_aliases`, `bash_aliases_linux`, `bash_aliases_macos` are all referenced but don't exist in the repo. The actual file is `bashrc_linux_wsl`. This script is probably broken.
- **Two competing symlink scripts**: `install_script.sh` and `link_dotfiles.sh` both handle symlinking with inconsistent and overlapping behavior.

---

## `configuration/functions.sh`

- **Stub/empty functions**: The following functions contain no real implementation: `install-dropbox`, `install-vagrant`, `install-docker`, `install-android-emulation`, `install-browser-extensions`, `python-tools`, `node-tools`, `install-go`, `install-node`, `install-java`. They should either be implemented or removed from `main()`.
- **`install-slack` calls `$si` with no arguments** (line 183): broken, will fail silently.
- **`ai`, `ar`, `si`, `update` are global variable strings**: They hold command strings but are used as if they are functions (e.g., `$ai foo`). This is a fragile pattern — should use functions or arrays.
- **Deprecated `apt-key adv`** in `install-etcher`: Deprecated and insecure, should use `/etc/apt/keyrings/` approach.
- **`install-chromium` and `install-vscode` use snap** despite a TODO saying snaps cause kernel panics.
- **`install-jetbrains-toolbox` has a hardcoded old version**: `1.17.6856` is ancient; should use the API or be updated.
- **`install-timeshift` uses deprecated PPA**: `ppa:teejee2008/ppa` is the old location.
- **`install-dev-packages` tries to `apt install code`**: `code` is not available via apt without the Microsoft repo being configured first.
- **`error()` logging to file is commented out** (line 23): Either implement it or remove the comment.
- **`install-react-native` calls `install-android-emulation`** which is a stub — cascading dead code.

---

## `configuration/Dockerfile`

- **Ubuntu 20.04 is EOL** (April 2025): Should be updated to Ubuntu 22.04 or 24.04 LTS.
- **Hardcoded plaintext password**: `echo kevin:12345 | chpasswd` — fine for local Docker testing, but worth a comment explaining why it's acceptable here.
- **Dead commented-out `FROM ubuntu:18.04` block**: Should be removed, it's just noise.

---

## `configuration/Makefile`

- **Typo in variable name**: `post-instal-tasks.sh` (missing second 'l') on line 8 — will cause the referenced file to never be found.
- **`test-full` runs `post-install-tasks` outside Docker**: `&& /bin/bash ${post-install-tasks}` runs locally, not in the container, probably unintentionally.
- **Inconsistent indentation**: `shell:` and `test-single:` targets use spaces; `build:` and `test-full:` use tabs. Make requires tabs.

---

## `configuration/mac-install.sh`

- **`brew cask install` is deprecated**: Modern Homebrew uses `brew install --cask`. The `bci()` function uses the old command.
- **Old Homebrew install method**: Uses `/usr/bin/ruby -e "$(curl ...)"` — Ruby-based install is long gone; modern install is a bash script.
- **`bi()` and `bci()` use `command -v` to check if already installed**: This fails for GUI/cask apps that don't have a CLI binary. Silent false positives.
- **Hardcoded Python 3.7.1**: Ancient version, should be removed or replaced with a current version or delegated to mise.
- **Pyenv referenced** but Linux side has moved to Mise — the two platforms are now inconsistent.
- **Node and Go setup are empty TODOs**.

---

## `bashrc`

- **`~/.local/bin` added to PATH twice**: Lines 15 and 125 both add it, causing duplicate PATH entries.
- **Poetry PATH exported** (`$HOME/.poetry/bin`): Poetry has been superseded by uv/mise in current setup. This is stale.
- **NVM loaded at bottom of `bashrc`** (lines 175-177) AND also in `bashrc_linux` (lines 30-32): Duplicate loading on Linux.
- **Interactive-only guard (`case $- in *i*`) is placed near the bottom** (line 164) instead of near the top — PATH exports and other setup above it run for non-interactive shells unnecessarily.
- **Debug `echo "using bashrc"` at top**: Noisy, prints on every shell open.

---

## `bashrc_linux`

- **Pyenv still configured** even though Mise has been adopted: `PYENV_ROOT`, `pyenv init` calls, and the `echo "pyenv init going.."` debug message are all still present. If pyenv isn't installed, this silently no-ops but is confusing.
- **NVM duplicated** from `bashrc` — loads twice on Linux.
- **`FLYCTL_INSTALL` path construction is overly complex**: `$(dirname ~/)/$(basename ~/)` is just `$HOME`. Should be `export FLYCTL_INSTALL="$HOME/.fly"`.
- **MSSQL tools PATH** (`/opt/mssql-tools18/bin`) added unconditionally: Very machine-specific, should guard with `[ -d ... ]`.
- **Multiple debug echo statements**: `echo "Using Linux bashrc extras..."`, `echo "non-wsl linux variant"`, `echo "Adding any WSL-specific Linux things..."` — noisy.

---

## `profile`

- **Stale PATH entries**: GOPATH/GOBIN, Android SDK (`$ANDROID_HOME`), Yarn global bin, and Poetry are all exported. Most of these are now managed by Mise or not used. Android paths in particular are almost certainly irrelevant.
- **Debug `echo "Running .profile"`**: Prints on every login shell.
- **Duplicates with `bashrc`**: PATH manipulation in both `profile` and `bashrc` creates ordering confusion.

---

## `scripts/gitcheck.sh`

- **Sources non-existent file**: `~/dotfiles/boilerplate/bash_functions.sh` is sourced on line 13, but `boilerplate/` does not exist in the repo. Script will fail to run.
- **Hardcoded `master` branch**: `git log HEAD.."$remote"/master` — should handle `main` or detect the default branch dynamically.
- **`cowsay` as a hard runtime dependency**: The script ends with `cowsay " All Done! "`, making it fail if cowsay isn't installed.
- **`greadlink` required on macOS**: Comment on line 101 admits this, but there's no install check or helpful error.

---

## `ssh-config`

- **Stale entries**: `cae` (UW-Madison CAE lab) and `cs` (UW-Madison CS lab) entries are presumably unused since graduation. `mrzero` (Raspberry Pi) and `server` are LAN-only hosts that may no longer exist.
- **No identity file or security config**: No `IdentityFile`, `ServerAliveInterval`, or other common hardening options are configured.

---

## Repo Structure

- **`agent-docs/` referenced in CLAUDE.md but didn't exist**: Now created (this file lives there).
- **`.gitmodules` is effectively empty**: One line stub, probably a leftover from when `log4bash` was a submodule.
- **`log4bash.sh` and `spinners.sh` at repo root**: Appear to be vendored utility scripts. Not referenced anywhere currently visible (gitcheck.sh references log4bash but via a non-existent submodule path). Either properly integrate or remove.
- **`scripts_deprecated/` still exists**: README is written in raw HTML (not Markdown). Scripts are clearly unused. Should probably just be deleted or archived in a git note.
- **`boilerplate/` directory referenced but absent**: `gitcheck.sh` sources from it, but it doesn't exist.
- **`configuration/README.md` references `post-install.sh`** in its usage section, but no such file exists in the repo.
- **`scripts/disk-usage`** has no extension and its contents haven't been checked for correctness.
