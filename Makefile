.PHONY: lint test test-unit help

help:
	@echo "Targets:"
	@echo "  lint       - Check all shell scripts for syntax errors and common issues"
	@echo "  test-unit  - Run BATS unit tests (requires: bats-core)"
	@echo "  test       - Run lint + test-unit"
	@echo ""
	@echo "For install-function smoke tests, see configuration/Makefile"

lint:
	@echo "[*] bash -n syntax check..."
	@find . -name "*.sh" -not -path "./.git/*" -not -path "./scripts_deprecated/*" -not -name "*-template.sh" | xargs -I{} bash -n {} && echo "[*] Syntax OK"
	@echo "[*] shellcheck (errors only)..."
	@find . -name "*.sh" -not -path "./.git/*" -not -path "./scripts_deprecated/*" -not -name "*-template.sh" | xargs shellcheck --severity=error
	@echo "[*] All lint checks passed"

test-unit:
	@bats tests/

test: lint test-unit
