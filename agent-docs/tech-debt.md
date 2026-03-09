# Tech Debt

This document tracks known tech debt in the dotfiles repo. Items are grouped by file/area.
Each item is independently actionable — agents can be given a single item to fix.

---

## `install_script.sh`

- ~~**Not idempotent**: Re-running the script overwrites symlinks and moves existing dotfiles to `$olddir` repeatedly. TODOed in the file itself. `$olddir` (`~/old_dotfiles`) is also never created before `mv` attempts to use it, which will cause failures.~~ **RESOLVED** (March 2026 refactor)
- ~~**Unquoted variables in mock loop**: `for entry in $dir/*` and `fname=$(basename $entry)` are unquoted, breaking on paths with spaces.~~ **RESOLVED**
- ~~**SSH symlink uses relative path**: `ln -s ssh-config ~/.ssh/config` uses a bare filename, not the absolute path `$entry`. This will create a broken symlink unless CWD happens to be `$dir`.~~ **RESOLVED**
- **Only links `gitcheck.sh`** from `scripts/`: `eye_saver.sh` and `disk-usage` are not linked.
- **Duplicate logic between mock/real modes**: The mock and real loops are nearly identical copy-paste; could be DRYed with a `--dry-run` flag pattern.
- ~~**`link_dotfiles.sh` references non-existent files**: deleted.~~ **RESOLVED**
- ~~**Two competing symlink scripts**: `install_script.sh` and `link_dotfiles.sh` both handle symlinking.~~ **RESOLVED** (`link_dotfiles.sh` deleted)

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

- ~~**Typo in variable name**: `post-instal-tasks.sh` (missing second 'l') — already removed from file.~~ **RESOLVED** (pre-existing)
- ~~**Inconsistent indentation**: All targets already use tabs.~~ **NOT AN ISSUE**

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

- ~~**`~/.local/bin` added to PATH twice**~~ **RESOLVED** (duplicate removed)
- ~~**Poetry PATH exported**~~ **RESOLVED** (removed)
- ~~**NVM loaded at bottom of `bashrc`** AND also in `bashrc_linux`: Duplicate loading on Linux.~~ **RESOLVED** (NVM removed from bashrc, kept in bashrc_linux)
- ~~**Interactive-only guard placed near the bottom** instead of near the top.~~ **RESOLVED** (guard moved to after PATH/env setup, before interactive-only sections)
- ~~**Debug `echo "using bashrc"` at top**~~ **RESOLVED** (removed)

---

## `bashrc_linux`

- ~~**Pyenv still configured** even though Mise has been adopted.~~ **RESOLVED** (pyenv block removed)
- ~~**NVM duplicated** from `bashrc` — loads twice on Linux.~~ **RESOLVED** (removed from bashrc)
- **`FLYCTL_INSTALL` path construction is overly complex**: `$(dirname ~/)/$(basename ~/)` simplified to `$HOME/.fly`. **RESOLVED**
- ~~**MSSQL tools PATH** added unconditionally: Very machine-specific.~~ **RESOLVED** (guarded with `[ -d ... ]`)
- ~~**Multiple debug echo statements**~~ **RESOLVED** (all removed)

---

## `profile`

- ~~**Stale PATH entries**: GOPATH/GOBIN, Android SDK, Yarn global bin, and Poetry are all exported.~~ **RESOLVED** (all removed)
- ~~**Debug `echo "Running .profile"`**~~ **RESOLVED** (removed)
- **Duplicates with `bashrc`**: PATH manipulation in both `profile` and `bashrc` creates ordering confusion. (Partially reduced — both still add `~/.local/bin`)

---

## `scripts/gitcheck.sh`

- ~~**Sources non-existent file**: `~/dotfiles/boilerplate/bash_functions.sh` is sourced but `boilerplate/` does not exist.~~ **RESOLVED** (source line removed)
- ~~**Hardcoded `master` branch**: `git log HEAD.."$remote"/master` — should handle `main` or detect default branch dynamically.~~ **RESOLVED** (detects default branch via `git symbolic-ref`)
- **`cowsay` as a hard runtime dependency**: The script ends with `cowsay " All Done! "`, making it fail if cowsay isn't installed.
- **`greadlink` required on macOS**: Comment on line 101 admits this, but there's no install check or helpful error.

---

## `ssh-config`

- ~~**Stale entries**: `cae` (UW-Madison CAE lab) and `cs` (UW-Madison CS lab) entries removed.~~ **RESOLVED**
- **No identity file or security config**: No `IdentityFile`, `ServerAliveInterval`, or other common hardening options are configured.

---

## Repo Structure

- ~~**`scripts_deprecated/` still exists**~~ **RESOLVED** (deleted)
- ~~**`log4bash.sh` and `spinners.sh` at repo root**: vendored utility scripts, unreferenced.~~ **RESOLVED** (deleted)
- ~~**`link_dotfiles.sh`**: broken and superseded.~~ **RESOLVED** (deleted)
- **`.gitmodules` is effectively empty**: One line stub, probably a leftover from when `log4bash` was a submodule.
- **`boilerplate/` directory referenced but absent**: `gitcheck.sh` sourced from it — now fixed, but the directory is still absent (expected).
- **`configuration/README.md` references `post-install.sh`** in its usage section, but no such file exists in the repo.
- **`scripts/disk-usage`** has no extension and its contents haven't been checked for correctness.
