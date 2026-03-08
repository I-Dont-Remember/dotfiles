#!/usr/bin/env bats
#
# Tests for shell configuration files.
# Validates that configs have valid syntax and source cleanly without errors.
#
# The sourcing tests use env -i to get a clean environment, preventing
# local machine state from masking broken config.

REPO_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# Minimal PATH needed for sourced scripts to find system commands.
CLEAN_PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# ---------------------------------------------------------------------------
# Syntax checks (bash -n) — fast, no side effects
# ---------------------------------------------------------------------------

@test "bashrc: valid bash syntax" {
    run bash -n "$REPO_DIR/bashrc"
    [ "$status" -eq 0 ]
}

@test "bashrc_linux: valid bash syntax" {
    run bash -n "$REPO_DIR/bashrc_linux"
    [ "$status" -eq 0 ]
}

@test "bashrc_macos: valid bash syntax" {
    run bash -n "$REPO_DIR/bashrc_macos"
    [ "$status" -eq 0 ]
}

@test "bash_profile: valid bash syntax" {
    run bash -n "$REPO_DIR/bash_profile"
    [ "$status" -eq 0 ]
}

@test "profile: valid bash syntax" {
    run bash -n "$REPO_DIR/profile"
    [ "$status" -eq 0 ]
}

@test "bashrc_linux_wsl: valid bash syntax" {
    run bash -n "$REPO_DIR/bashrc_linux_wsl"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Sourcing tests for bashrc (core config, most frequently edited)
#
# Uses OSTYPE=unknown-test so no OS-specific file is sourced, isolating
# the core bashrc logic.
# ---------------------------------------------------------------------------

@test "bashrc: sources without error" {
    run env -i \
        HOME="$BATS_TMPDIR" \
        PATH="$CLEAN_PATH" \
        TERM="xterm-256color" \
        OSTYPE="unknown-test" \
        bash --norc --noprofile -c "source '$REPO_DIR/bashrc' 2>&1; echo 'DONE'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"DONE"* ]]
}

@test "bashrc: sets EDITOR to vim" {
    # source >/dev/null suppresses the echo statements inside bashrc so only
    # our own echo captures the variable value.
    result=$(env -i \
        HOME="$BATS_TMPDIR" \
        PATH="$CLEAN_PATH" \
        TERM="xterm-256color" \
        OSTYPE="unknown-test" \
        bash --norc --noprofile -c "source '$REPO_DIR/bashrc' >/dev/null 2>&1; echo \$EDITOR")
    [ "$result" = "vim" ]
}

@test "bashrc: adds HOME/bin to PATH" {
    result=$(env -i \
        HOME="$BATS_TMPDIR" \
        PATH="$CLEAN_PATH" \
        TERM="xterm-256color" \
        OSTYPE="unknown-test" \
        bash --norc --noprofile -c "source '$REPO_DIR/bashrc' >/dev/null 2>&1; echo \$PATH")
    [[ "$result" == *"$BATS_TMPDIR/bin"* ]]
}

# ---------------------------------------------------------------------------
# Sourcing test for bashrc_linux
#
# Mocks tools (mise, uv, pyenv) that may not be installed everywhere so
# the test is portable across machines.
# ---------------------------------------------------------------------------

@test "bashrc_linux: sources without error (with mocked tools)" {
    run env -i \
        HOME="$BATS_TMPDIR" \
        PATH="$CLEAN_PATH" \
        TERM="xterm-256color" \
        bash --norc --noprofile -c "
            # Mock version managers so eval \"\$(tool activate bash)\" becomes eval ''
            mise() { :; }
            uv() { :; }
            pyenv() { :; }
            source '$REPO_DIR/bashrc_linux' 2>&1
            echo 'DONE'
        "
    [ "$status" -eq 0 ]
    [[ "$output" == *"DONE"* ]]
}
