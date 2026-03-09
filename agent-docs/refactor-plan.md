# Dotfiles Refactor Plan

## Context

This repo has accumulated tech debt: broken scripts, stale tool paths, duplicated logic, and dead files. The goal of the **debt-first cleanup** was to fix what's broken/stale, remove what's dead, consolidate duplicate logic, and leave the repo in a state that's simpler and easier to maintain.

**Status:** Refactor complete (all phases ✓). An **enhancement pass** was subsequently run in March 2026 — see `agent-docs/enhancements.md` for what was implemented (mise.toml, gitignore_global, gitconfig additions, modern CLI aliases, fzf integration, tmux.conf, WSL improvements, scripts/check-tools.sh).

**User preferences confirmed:**
- Scope: debt-first only (no Starship, fzf, bat, etc.)
- Install scripts: consolidate into install_script.sh, delete link_dotfiles.sh
- bash_aliases: keep Happybara/serverless aliases
- Delete: scripts_deprecated/, log4bash.sh, spinners.sh, UW SSH entries

---

## Phase 0: Write tracked plan into agent-docs/

- [x] Create `agent-docs/refactor-plan.md` as a checkboxed task list
- [x] Update `agent-docs/CLAUDE.md` to reference the refactor plan
- [x] Update `CLAUDE.md` to reference `agent-docs/refactor-plan.md`

---

## Phase 1: Remove dead artifacts

### 1.1 Delete scripts_deprecated/
- [x] Remove entire `scripts_deprecated/` directory

### 1.2 Delete vendored utility scripts at root
- [x] Delete `log4bash.sh`
- [x] Delete `spinners.sh`

### 1.3 Delete link_dotfiles.sh
- [x] Delete `link_dotfiles.sh`

### 1.4 Remove stale SSH config entries
- [x] Remove `cae` host block from `ssh-config`
- [x] Remove `cs` host block from `ssh-config`

---

## Phase 2: Shell config cleanup

### 2.1 bashrc
- [x] Remove debug echo at top (`echo "using bashrc"`)
- [x] Move interactive guard (`case $- in *i*`) to top of file (before PATH/env changes)
- [x] Remove stale `~/.poetry/bin` from PATH
- [x] Remove NVM block at bottom (keep in bashrc_linux, remove from bashrc)

### 2.2 bashrc_linux
- [x] Remove pyenv config block
- [x] Remove debug echo statements
- [x] Guard MSSQL tools PATH with `[ -d /opt/mssql-tools18/bin ]`

### 2.3 profile
- [x] Remove debug echo (`echo "Running .profile"`)
- [x] Remove stale Android SDK PATH entries and `ANDROID_HOME` export
- [x] Remove stale `GOPATH`/`GOBIN` exports and Go bin PATH
- [x] Remove stale `~/.poetry/bin` PATH addition
- [x] Keep `~/bin` and `~/.local/bin` PATH additions

---

## Phase 3: Fix install_script.sh

- [x] Quote all variables (`$file`, `$dir`, `$olddir`, `$fname`, etc.)
- [x] Create `$olddir` before `mv` attempts
- [x] Make idempotent (skip if symlink already points to correct target)
- [x] Fix SSH symlink to use absolute path and ensure `~/.ssh/` exists
- [x] Add idempotency tests to `tests/test_install_script.bats`

---

## Phase 4: Fix scripts/gitcheck.sh

- [x] Remove broken `source ~/dotfiles/boilerplate/bash_functions.sh` line
- [x] Fix hardcoded `master` branch — detect default branch dynamically

---

## Phase 5: Fix configuration/Makefile

- [x] Fix typo in variable name
- [x] Fix inconsistent indentation (spaces vs tabs — tabs required)

---

## Phase 6: Update tech-debt and enhancements docs

- [x] Mark resolved items in `agent-docs/tech-debt.md`
- [x] Update `agent-docs/enhancements.md` to reflect current state

---

## Verification Checklist

- [ ] `make test` passes (lint + BATS)
- [ ] `bash -n` passes on: bashrc, bashrc_linux, bashrc_macos, bash_profile, profile, bashrc_linux_wsl
- [ ] `shellcheck` clean on all .sh files (excluding configuration/ stubs)
- [ ] `install_script.sh` mock mode runs without errors
- [ ] `install_script.sh` mock mode is idempotent (second run shows "already linked" for all)
- [ ] `scripts/gitcheck.sh` no longer references non-existent file
- [ ] `scripts_deprecated/`, `log4bash.sh`, `spinners.sh`, `link_dotfiles.sh` are gone
- [ ] UW-Madison SSH entries removed from ssh-config
- [ ] `agent-docs/refactor-plan.md` exists and has checkboxes for tracking progress
