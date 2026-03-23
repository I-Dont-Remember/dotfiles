# CLAUDE.md

Extreme concision in all interactions and commits. Sacrifice grammar for brevity.

## Git

- Check `git status` before `git add -A`
- NEVER commit project `.claude/settings.local.json`

## Verification (CRITICAL)

- Always run tests after implementation; fix all failures
- For UI changes: take before/after screenshots, compare
- Never ship without passing verification

---

## Code Principles

Goal: Predictable, maintainable, testable code

### Testing

Goal: Test real behavior, not mocks.

- Red-green TDD is mandatory
- Test behavior, not implementation
- Immutability is a feature - avoid bugs from unexpected state change
