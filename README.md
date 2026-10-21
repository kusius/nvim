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

kotlin-lsp's Gradle import fails on Android modules that use KSP: it reads the
test components' generated sources before their KSP tasks have run, and Gradle
rejects that, which empties the whole import (Kotlin/kotlin-lsp#225).
`gradle/init.d/kotlin-lsp-android-ksp-inputs.init.gradle.kts` works around it
without touching the project. It only acts while kotlin-lsp imports, so
ordinary builds, Android Studio and CI are untouched. Remove it once the fix
proposed in Kotlin/kotlin-lsp#233 ships.

On a new machine, or after pulling changes to it:

```sh
git -C ~/.config/nvim pull

# kotlin-lsp: upgrade, clear quarantine, check the version
brew upgrade --cask kotlin-lsp      # or: brew install JetBrains/utils/kotlin-lsp
xattr -dr com.apple.quarantine "$(brew --prefix)/Caskroom/kotlin-lsp"
which -a kotlin-lsp                 # only the Homebrew one: a stale copy earlier on PATH wins
kotlin-lsp --version

# init script: symlink, so a pull keeps it current
mkdir -p ~/.gradle/init.d
ln -sf ~/.config/nvim/gradle/init.d/kotlin-lsp-android-ksp-inputs.init.gradle.kts ~/.gradle/init.d/
```

Then `:restart` Neovim. A working import logs
`[kotlin-lsp workaround] test component sources wired into prepareKotlinIdeaImport`
in `~/.cache/nvim/kotlin-lsp/system/log/intellij-server.log`.

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
