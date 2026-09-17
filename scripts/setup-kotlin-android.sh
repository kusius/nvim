#!/usr/bin/env bash
# Machine-local pieces the Kotlin/Android setup needs, none of which a plugin
# manager can provide. Safe to re-run: every step checks before it acts.
#
#   ./scripts/setup-kotlin-android.sh              # everything missing
#   ./scripts/setup-kotlin-android.sh ruleset initd
#
# lua/gmk/android_setup.lua runs this after asking, when a Kotlin file is opened
# in a Gradle project.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# mrmans0n/compose-rules. Pinned so a run is reproducible; override to move.
COMPOSE_RULES_VERSION="${COMPOSE_RULES_VERSION:-0.6.6}"
ruleset_dir="${KTLINT_RULESET_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/nvim/ktlint}"
ruleset_jar="$ruleset_dir/ktlint-compose.jar"

init_script="kotlin-lsp-android-ksp-inputs.init.gradle.kts"
init_src="$repo/gradle/init.d/$init_script"
init_dst="${GRADLE_USER_HOME:-$HOME/.gradle}/init.d/$init_script"

say() { printf '==> %s\n' "$1"; }
ok()  { printf '    %s\n' "$1"; }

need_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "error: Homebrew not found; install $1 yourself and re-run" >&2
    return 1
  fi
}

step_kotlin_lsp() {
  say "kotlin-lsp"
  if command -v kotlin-lsp >/dev/null 2>&1; then
    ok "already on PATH: $(command -v kotlin-lsp)"
    return 0
  fi
  need_brew kotlin-lsp || return 1
  brew install --cask kotlin-lsp
}

step_ktlint() {
  say "ktlint"
  if command -v ktlint >/dev/null 2>&1; then
    ok "already on PATH: $(command -v ktlint)"
    return 0
  fi
  need_brew ktlint || return 1
  brew install ktlint
}

# The compose ruleset teaches ktlint that @Composable functions are PascalCase
# (and adds the compose:* rules). Without it, ktlint reports every composable as
# a naming violation -- and the equivalent kotlin-lsp warning is filtered out in
# gmk/lsp.lua, so nothing would catch real naming mistakes.
step_ruleset() {
  say "compose-rules ktlint ruleset ($COMPOSE_RULES_VERSION)"
  if [ -f "$ruleset_jar" ]; then
    ok "already present: $ruleset_jar"
    return 0
  fi
  local url="https://github.com/mrmans0n/compose-rules/releases/download/v${COMPOSE_RULES_VERSION}/ktlint-compose-${COMPOSE_RULES_VERSION}-all.jar"
  mkdir -p "$ruleset_dir"
  ok "downloading $url"
  curl -fsSL --retry 2 -o "$ruleset_jar.part" "$url"
  mv "$ruleset_jar.part" "$ruleset_jar"
  ok "installed: $ruleset_jar"
}

# Gradle runs every script in ~/.gradle/init.d. This one is inert unless
# kotlin-lsp is the one importing (Kotlin/kotlin-lsp#225); see the file header.
step_initd() {
  say "Gradle init script"
  if [ ! -f "$init_src" ]; then
    echo "error: $init_src missing from the repo" >&2
    return 1
  fi
  if [ -L "$init_dst" ] && [ "$(readlink "$init_dst")" = "$init_src" ]; then
    ok "already linked: $init_dst"
    return 0
  fi
  mkdir -p "$(dirname "$init_dst")"
  if [ -e "$init_dst" ] && [ ! -L "$init_dst" ]; then
    mv "$init_dst" "$init_dst.bak"
    ok "kept existing file as $init_dst.bak"
  fi
  ln -sfn "$init_src" "$init_dst"
  ok "linked: $init_dst -> $init_src"
}

steps=("$@")
if [ ${#steps[@]} -eq 0 ]; then
  steps=(kotlin-lsp ktlint ruleset initd)
fi

failed=0
for step in "${steps[@]}"; do
  case "$step" in
    kotlin-lsp) step_kotlin_lsp || failed=1 ;;
    ktlint)     step_ktlint || failed=1 ;;
    ruleset)    step_ruleset || failed=1 ;;
    initd)      step_initd || failed=1 ;;
    *) echo "unknown step: $step" >&2; failed=1 ;;
  esac
done

[ "$failed" -eq 0 ] && say "done" || say "finished with errors"
exit "$failed"
