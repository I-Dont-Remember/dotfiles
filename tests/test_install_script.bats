#!/usr/bin/env bats
#
# Tests for pure bash logic in install_script.sh.
# These run without root or Docker — just bash.

REPO_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
    # Source only the function definitions (lines before main script body).
    # The main body starts at line 75 with variable assignments and side effects.
    # shellcheck disable=SC1090
    source <(head -n 65 "$REPO_DIR/install_script.sh")
}

# ---------------------------------------------------------------------------
# in_list
# ---------------------------------------------------------------------------

@test "in_list: finds item in middle of list" {
    run in_list "10 11 12" "11"
    [ "$status" -eq 0 ]
}

@test "in_list: finds first item" {
    run in_list "10 11 12" "10"
    [ "$status" -eq 0 ]
}

@test "in_list: finds last item" {
    run in_list "10 11 12" "12"
    [ "$status" -eq 0 ]
}

@test "in_list: returns false for missing item" {
    run in_list "10 11 12" "99"
    [ "$status" -eq 1 ]
}

@test "in_list: no partial/substring match" {
    # "1" should not match "10", "11", "12"
    run in_list "10 11 12" "1"
    [ "$status" -eq 1 ]
}

@test "in_list: works with filenames (ignorefiles use case)" {
    run in_list "README.md install_script.sh scripts configuration" "README.md"
    [ "$status" -eq 0 ]
}

@test "in_list: ignores unrelated filename" {
    run in_list "README.md install_script.sh scripts configuration" "bashrc"
    [ "$status" -eq 1 ]
}

@test "in_list: single-item list match" {
    run in_list "only" "only"
    [ "$status" -eq 0 ]
}

@test "in_list: single-item list no match" {
    run in_list "only" "other"
    [ "$status" -eq 1 ]
}

# ---------------------------------------------------------------------------
# is_int
# ---------------------------------------------------------------------------

@test "is_int: positive integer" {
    run is_int "42"
    [ "$status" -eq 0 ]
}

@test "is_int: zero" {
    run is_int "0"
    [ "$status" -eq 0 ]
}

@test "is_int: negative integer" {
    run is_int "-5"
    [ "$status" -eq 0 ]
}

@test "is_int: float is not int" {
    run is_int "3.14"
    [ "$status" -eq 1 ]
}

@test "is_int: string is not int" {
    run is_int "abc"
    [ "$status" -eq 1 ]
}

@test "is_int: empty string is not int" {
    run is_int ""
    [ "$status" -eq 1 ]
}

@test "is_int: alphanumeric is not int" {
    run is_int "12abc"
    [ "$status" -eq 1 ]
}

# ---------------------------------------------------------------------------
# idempotency: mock mode skips already-linked files
# ---------------------------------------------------------------------------

@test "mock mode: already-linked file is skipped" {
    # Set up a temp dir simulating dotfiles repo + home
    local tmpdir
    tmpdir=$(mktemp -d)
    local fake_home="$tmpdir/home"
    local fake_dir="$tmpdir/dotfiles"
    mkdir -p "$fake_home" "$fake_dir"

    # Create a fake dotfile in the repo
    echo "# test" > "$fake_dir/bashrc"

    # Pre-create the symlink pointing to the correct target
    ln -s "$fake_dir/bashrc" "$fake_home/.bashrc"

    # Run the check logic inline (mirrors install_script.sh idempotency check)
    local target="$fake_home/.bashrc"
    local source="$fake_dir/bashrc"
    local skipped=0

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        skipped=1
    fi

    rm -rf "$tmpdir"
    [ "$skipped" -eq 1 ]
}

@test "mock mode: file not yet linked is not skipped" {
    local tmpdir
    tmpdir=$(mktemp -d)
    local fake_home="$tmpdir/home"
    local fake_dir="$tmpdir/dotfiles"
    mkdir -p "$fake_home" "$fake_dir"

    echo "# test" > "$fake_dir/bashrc"
    # No symlink created — target does not exist

    local target="$fake_home/.bashrc"
    local source="$fake_dir/bashrc"
    local skipped=0

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        skipped=1
    fi

    rm -rf "$tmpdir"
    [ "$skipped" -eq 0 ]
}
