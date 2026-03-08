# CLAUDE.md

This is a `dotfiles` repo to version control my developer environment and common tool configurations I want to keep track of. It is relatively bash-centric, since I have stuck with Bash for many years. Fish seems like an interesting shell, but so far I've just stuck with the classic because it's ubiquitous and good enough.

## Repo

- `configuration/` is scripts for installing common software on my machines so I can easily get back up to speed with a brand new computer, it also makes it easy to reference what stuff I like using enough to track.
- `agent-docs/` this is for Claude or other agents to store information which helps them work within the repository.
- `scripts/` was intended to be for little utilities I write for myself, but most of them don't really get used any longer, or at least not in their current state. `gitcheck` for example was more relevant when I was more prolific with active repositories.
- `install_script.sh` is meant to be used on a new machine for setting up dotfiles on a new machine - not the same as `configuration/` which installs a lot of software.
- `tests/` holds BATS unit tests for shell script logic.
- `claude/` holds tracked Claude Code settings (`settings.json`, keybindings if added) — symlinked into `~/.claude/` on install.

## Development

When making changes that aren't markdown files, follow this process:

- run `make test` (lint + unit tests) or `make lint` (static analysis only) from the repo root
- use red green TDD when changing scripts
- continue developing until they pass AND you are satisfied with the quality of your implementation

## Important

- I care about simplicity and ease of maintenance, I don't like adding too much complexity because I want to make it easy to choose.
- The testing setup in this repo before I brought Claude into the mix (March 2026) started off very brittle and likely not idempotent. It could use some work at some point.
