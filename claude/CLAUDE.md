# CLAUDE.md

Extreme concision in all interactions and commits. Sacrifice grammar for brevity.

## Git

- Check `git status` before `git add -A`
- NEVER commit project `.claude/settings.local.json`
- Use atomic commits

## Verification (CRITICAL)

- Always run tests after implementation; fix all failures
- For UI changes: take before/after screenshots, compare
- Never ship without passing verification

## Development processes

- Prefer writing utility scripts & Makefile commands if you frequently chain steps together. Make it easy to call automations.

---

## Code Principles

Goal: Predictable, maintainable, testable code

### Testing

Goal: Test real behavior, not mocks.

- Red-green TDD is mandatory
- Test behavior, not implementation
- Immutability is a feature - avoid bugs from unexpected state change
