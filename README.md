## MacOS

clone into `~/.config/nvim`

Install the external tools it depends on:

```sh
xcode-select --install          # make + C compiler
brew bundle --file ~/.config/nvim/Brewfile
```

See the comments at the bottom of the `Brewfile` for the few things Homebrew
can't provide (gopls, ruby-lsp, c3lsp, `gh auth login`).
