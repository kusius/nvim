#!/usr/bin/env bash
# Run tests/test_config.lua against this repo, in a throwaway XDG home.
#
# Safe to run locally: your real ~/.local/share/nvim, your plugin checkouts and
# your working tree are all left alone. Reporting and exit codes come from
# mini.test; this script only builds the isolated environment to run it in.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sandbox="$(mktemp -d)"

# Cleanup is best effort. nvim-treesitter installs parsers in background
# processes that outlive Neovim, so they can still be writing into the sandbox
# when this runs and make `rm -rf` fail with "Directory not empty". A failing
# EXIT trap would replace the script's real exit status (turning a green run
# red), so errors here are swallowed deliberately.
cleanup() {
  if ! rm -rf "$sandbox" 2>/dev/null; then
    echo "note: could not fully remove $sandbox (background parser install still writing); leaving it to the OS" >&2
  fi
  return 0
}
trap cleanup EXIT

real_data="${XDG_DATA_HOME:-$HOME/.local/share}"

export XDG_CONFIG_HOME="$sandbox/config"
export XDG_STATE_HOME="$sandbox/state"
export XDG_CACHE_HOME="$sandbox/cache"

# Plugin checkouts live under XDG_DATA_HOME. Point NVIM_TEST_DATA_HOME at a
# persistent directory to reuse them across runs (fast local iteration, and
# something CI can cache); otherwise every run clones from scratch.
if [ -n "${NVIM_TEST_DATA_HOME:-}" ]; then
  mkdir -p "$NVIM_TEST_DATA_HOME"
  # This is the one path that can escape the sandbox, and 'lazy restore' would
  # happily check out lockfile revisions over a real plugin install. Refuse.
  if [ "$(cd "$NVIM_TEST_DATA_HOME" && pwd -P)" = "$(cd "$real_data" 2>/dev/null && pwd -P || echo /nonexistent)" ]; then
    echo "error: NVIM_TEST_DATA_HOME points at your real data dir ($real_data)." >&2
    echo "       That would let the test overwrite your live plugin checkouts." >&2
    exit 1
  fi
  export XDG_DATA_HOME="$NVIM_TEST_DATA_HOME"
else
  export XDG_DATA_HOME="$sandbox/data"
fi

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

# Copy the working tree in rather than symlinking it: lazy.nvim writes
# lazy-lock.json into the config directory, and a test run must not dirty the
# repo. (With LAZY_CMD=sync the updated lockfile is discarded with the sandbox.)
config="$XDG_CONFIG_HOME/nvim"
mkdir -p "$config"
tar -cf - -C "$repo" --exclude .git . | tar -xf - -C "$config"

# Never let git stop to ask for credentials on a plugin clone.
export GIT_TERMINAL_PROMPT=0

# A config that stops for input has nothing to answer it in headless mode, so
# every invocation gets an empty stdin and a hard wall clock limit. timeout(1)
# is not on macOS, hence perl. SIGALRM surfaces as exit code 142.
LAZY_TIMEOUT="${LAZY_TIMEOUT:-600}"
TEST_TIMEOUT="${TEST_TIMEOUT:-120}"

run_nvim() {
  local limit="$1"
  shift
  perl -e 'alarm shift; exec @ARGV' "$limit" nvim "$@" </dev/null
}

# cd somewhere neutral so 'exrc' cannot pick up a project-local .nvim.lua.
cd "$sandbox"

# 'restore' installs missing plugins and pins every one to the revision in
# lazy-lock.json, so a run tests the config you actually use and does not break
# because some upstream plugin changed today. Set LAZY_CMD=sync to test against
# current upstream instead.
LAZY_CMD="${LAZY_CMD:-restore}"

echo "==> installing plugins (lazy $LAZY_CMD, ${LAZY_TIMEOUT}s limit)"
set +e
run_nvim "$LAZY_TIMEOUT" --headless "+Lazy! $LAZY_CMD" +qa
status=$?
set -e
if [ "$status" -ne 0 ]; then
  [ "$status" -eq 142 ] && echo "==> lazy $LAZY_CMD timed out after ${LAZY_TIMEOUT}s"
  exit "$status"
fi

# The tests run inside a Neovim that has sourced the config normally, so they
# see the real editor. mini.test exits 1 on failure and 0 on success.
echo "==> running tests (${TEST_TIMEOUT}s limit)"
stderr="$sandbox/stderr.log"
set +e
run_nvim "$TEST_TIMEOUT" --headless \
  -c "lua require('mini.test').run_file('$config/tests/test_config.lua')" 2>"$stderr"
status=$?
set -e

if [ "$status" -eq 142 ]; then
  echo "==> tests timed out after ${TEST_TIMEOUT}s (headless Neovim never exited)"
  cat "$stderr"
  exit 1
fi

# Headless Neovim reports startup errors on stderr and nowhere else, so scan it
# even when the tests themselves passed. Plugins also use stderr for ordinary
# progress notifications (nvim-treesitter parser downloads, lazy tasks), hence
# matching on error-shaped lines rather than treating any output as a failure.
if [ -s "$stderr" ]; then
  echo "==> Neovim stderr:"
  cat "$stderr"
  if grep -qE 'E[0-9]{3,}:|[Ee]rror|[Ff]ailed|stack traceback' "$stderr"; then
    echo "==> stderr contains errors"
    exit 1
  fi
fi

exit "$status"
