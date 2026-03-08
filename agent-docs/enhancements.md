# Enhancements & Improvements

This document tracks desired additions or improvements that are not strictly tech debt —
things that would make the setup better, more complete, or easier to use going forward.
Each item is independently actionable.

---

## Claude / Agent Settings Tracking

- **Track `~/.claude/settings.json`**: Claude Code user settings live at `~/.claude/settings.json`. This file controls things like permission modes, hooks, model preferences, and other Claude Code behavior. It should be symlinked into the dotfiles repo so changes are versioned.
- **Track `~/.claude/CLAUDE.md`**: The global Claude instructions file (if used) should be versioned.
- **Track Claude keybindings**: If `~/.claude/keybindings.json` is customized, it should be tracked.
- **Document agent preferences**: Add a section to `agent-docs/` or CLAUDE.md summarizing preferences for how agents should work in this repo (already partially started in CLAUDE.md — could be expanded).

---

## Git Configuration

- **Add `gitconfig` to dotfiles**: No global git config is tracked. Should include: name/email stubs (or placeholders), default branch name (`main`), preferred diff tool, useful aliases (e.g., `git lg` for pretty log), and `pull.rebase = true`.
- **Add global `gitignore`**: A `gitignore_global` file for things like `.DS_Store`, `*.swp`, `.env`, `__pycache__/`, `.idea/`, `.vscode/` etc. should be tracked and configured via `core.excludesFile`.

---

## Shell / Prompt Modernization

- **Adopt Starship prompt**: The hand-rolled PS1 in `bashrc` is complex and hard to maintain. Starship (`starship.rs`) is cross-shell, fast, and highly configurable. A `starship.toml` could be tracked in dotfiles.
- **Add `fzf` integration**: `fzf` for fuzzy history search (`Ctrl+R`), file finding, and `cd` navigation would be a significant quality-of-life improvement. Config/keybindings should be tracked.
- **Clean up shell startup output**: Remove all the `echo "using bashrc"` / `echo "Running .profile"` debug prints for a clean terminal open experience.

---

## Modern CLI Tool Additions

Add the following tools to `install-dev-packages` / `mac-install.sh` and document them:

- `bat` — better `cat` with syntax highlighting
- `ripgrep` (`rg`) — better `grep`, already used by Claude Code
- `fd` — better `find`
- `eza` (or `lsd`) — better `ls` with icons/colors
- `delta` — better git diff pager
- `zoxide` — smarter `cd` (learns frequent directories)
- `jq` — JSON processing (already likely used but not tracked)
- `mise` — already adopted on Linux, should be in both Linux and Mac install scripts

---

## Mise / Language Management

- **Add `mise.toml` (global config)**: Track a `~/.config/mise/config.toml` (or global `mise.toml`) in dotfiles to pin global tool versions (e.g., default Python, Node, Go versions). This replaces the fragmented pyenv/nvm/goenv history.
- **Mac install script should use Mise**: Currently `mac-install.sh` uses pyenv. Should align with the Linux setup and delegate language version management to Mise.
- **Remove pyenv from `bashrc_linux`**: Mise has replaced it; pyenv config is dead weight.

---

## Tmux Configuration

- **Add `tmux.conf`**: No tmux configuration is tracked. A reasonable config should cover: prefix key rebind (e.g., `Ctrl+a`), mouse support, sane split keybindings, status bar config, and copy-mode behavior.

---

## Symlink / Install Script

- **Consolidate `install_script.sh` and `link_dotfiles.sh`**: There are two scripts doing overlapping jobs. Consolidate into one clean, idempotent script with a `--dry-run` flag.
- **Add `CLAUDE.md` files to ignore list**: `install_script.sh`'s `ignorefiles` list should include `CLAUDE.md` and `agent-docs/` so they don't get symlinked into `$HOME`.
- **Track newly added files automatically**: Consider a manifest-style list of which files get symlinked, rather than a blocklist — it's easier to reason about as the repo grows.

---

## Configuration Script Modernization

- **Update Dockerfile to Ubuntu 24.04 LTS**: Current base (20.04) is EOL. Upgrading would allow testing against a current environment.
- **Fill in stub install functions**: `install-docker`, `install-node`, `install-go`, `install-python` (in functions.sh) are stubs. Docker and the language runtimes are core tools worth implementing properly, probably deferring to Mise for languages.
- **Mac and Linux installs should install the same core dev tools**: There's no shared list. A shared config (e.g., a `tools.txt` or mise config) would make the two platforms consistent.

---

## Missing Dotfiles

Several useful config files are referenced or implied but not yet tracked:

- **`~/.editorconfig`**: Defines indent style, charset, EOL per file type — useful for editors and CI.
- **`~/.gitconfig`**: See Git Configuration section above.
- **`~/.config/starship.toml`**: If Starship is adopted.
- **`~/.tmux.conf`**: See Tmux section above.
- **`~/.ssh/config`**: Already tracked! But could use a cleanup pass (see tech-debt.md).
- **`~/.config/mise/config.toml`**: Global mise config.

---

## Documentation

- **Update `README.md`**: Still references the old install flow. Should reflect the current state: what's symlinked, how `configuration/` works, and how to use Mise for language setup.
- **Update `configuration/README.md`**: References a non-existent `post-install.sh` and describes the Ansible-to-shell-script migration as current, even though it's now old history.
- **Document the WSL-specific setup**: `bashrc_linux_wsl` is thin. A `windows.md` update or a WSL-specific README section would help for future new machine setup.
- **Clean up `windows.md`**: Still references goenv/pyenv; should be updated to reflect Mise. Some software entries are employer-specific (Happybara) and could be generalized or moved to a private notes file.

---

## Security / Hygiene

- **SSH config hardening**: Add `ServerAliveInterval`, `ServerAliveCountMax`, and consider `IdentityFile` stubs with comments so they're easy to fill in on a new machine.
- **`install_script.sh` should not `rm` files without backup**: The `rm ~/.bashrc` pattern in `link_dotfiles.sh` is destructive. Should at least `mv` to a backup first.
- **Audit PATH entries**: Multiple files add to PATH in various orders. A single, well-ordered PATH construction would reduce confusion and potential for shadowing issues.
