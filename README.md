## MacOS

clone into `~/.config/nvim`

Install the external tools it depends on:

```sh
xcode-select --install          # make + C compiler
brew bundle --file ~/.config/nvim/Brewfile
```

See the comments at the bottom of the `Brewfile` for the few things Homebrew
can't provide (gopls, ruby-lsp, c3lsp, `gh auth login`).

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
