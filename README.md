## MacOS

clone into `~/.config/nvim`

Install the external tools it depends on:

```sh
xcode-select --install          # make + C compiler
brew bundle --file ~/.config/nvim/Brewfile
```

See the comments at the bottom of the `Brewfile` for the few things Homebrew
can't provide (gopls, ruby-lsp, c3lsp, `gh auth login`).

## Kotlin / Android

Four things live outside this repo, and the config degrades quietly without
them: `kotlin-lsp`, `ktlint`, the compose-rules ruleset jar that teaches ktlint
about `@Composable` naming, and a Gradle init script that keeps kotlin-lsp's
Android import from coming back empty (Kotlin/kotlin-lsp#225).

Opening a Kotlin file in a Gradle project offers to install whatever is
missing, once per machine. To do it by hand:

```sh
./scripts/setup-kotlin-android.sh            # everything missing
./scripts/setup-kotlin-android.sh ruleset    # or single steps
```

or from inside Neovim: `:KotlinAndroidSetup` (`:KotlinAndroidSetup!` skips the
question). Answering "Never on this machine" writes a marker into
`stdpath('state')`; delete it to be asked again.

The init script is symlinked from `gradle/init.d/` into `~/.gradle/init.d/`, so
it is inert for ordinary builds and CI — it only acts while kotlin-lsp imports.
`$KOTLIN_LSP_GRADLE_JAVA_HOME` overrides the JDK picked for that import, and
`$KTLINT_COMPOSE_RULESET` overrides the ruleset jar.

## Tests

`./tests/run.sh` starts Neovim with this repo as the config in a throwaway XDG
home, installs the plugins at their `lazy-lock.json` revisions, and runs
`tests/test_config.lua` against the live editor. It never touches your real
plugin checkouts. GitHub Actions runs it on every push and pull request against
stable Neovim.

Tests are written with [mini.test](https://github.com/echasnovski/mini.test)
(`:h mini.test`), which is in the plugin list but lazy-loaded, so it costs
nothing at startup. To add a case, drop another function into
`tests/test_config.lua`.

```sh
./tests/run.sh

# reuse plugin checkouts between runs instead of cloning each time
NVIM_TEST_DATA_HOME=/tmp/nvim-test-data ./tests/run.sh

# test against current upstream plugins rather than the lockfile
LAZY_CMD=sync ./tests/run.sh
```
