# Brewfile for this Neovim config — `brew bundle` from ~/.config/nvim
#
# Each entry notes which part of the config needs it. Anything Homebrew cannot
# provide is listed under "Not available via Homebrew" at the bottom.

# --- Base ------------------------------------------------------------------
brew "neovim"          # >= 0.12: nvim-treesitter `main` branch + vim.lsp.config
brew "git"             # lazy.nvim bootstrap (lua/gmk/lazy.lua), lazygit, octo
# `make` and a C compiler are also required (telescope-fzf-native's
# `build = "make"`, plus treesitter parser compilation). Both come from the
# Xcode Command Line Tools, which Homebrew cannot install:
#   xcode-select --install
# Do not use `brew "make"` for this — it installs GNU make as `gmake` and
# leaves `make` unchanged.

# --- Search ----------------------------------------------------------------
brew "ripgrep"         # hard-coded as `rg` in lua/plugins/telescope_spec.lua

# --- Treesitter ------------------------------------------------------------
brew "tree-sitter-cli" # required by the `main` branch; must NOT come from npm

# --- LSP servers (lua/gmk/lsp.lua) -----------------------------------------
brew "lua-language-server"
brew "llvm"            # clangd is hard-coded to /opt/homebrew/opt/llvm/bin/clangd
                       # (Apple's /usr/bin/clangd is deliberately not used);
                       # also provides clang-format for conform.nvim
brew "go"              # toolchain for gopls (see manual steps below)
brew "rbenv"           # ruby_lsp cmd is hard-coded to ~/.rbenv/shims/ruby-lsp
brew "ruby-build"

# kotlin_lsp connects to 127.0.0.1:9999 and expects a server you start yourself.
# Left commented: as of 2026-08-06 the standalone JetBrains servers could not
# handle the AGP 9 Android project, and that integration was reverted.
# brew "kotlin-lsp"

# --- Terminal integrations (lua/plugins/toggleterm.lua) --------------------
brew "lazygit"                 # <leader>lz
cask "copilot-cli"             # <leader>co
cask "claude-code"             # <leader>cl — skip if you use the native
                               # installer at ~/.local/bin/claude

# --- GitHub (octo.nvim, pr.nvim) -------------------------------------------
brew "gh"                      # run `gh auth login` afterwards

# --- Mason -------------------------------------------------------------------
# mason.nvim has no `ensure_installed`, so it installs nothing on its own.
# Packages it fetches on demand may need node/npm or python3.
brew "node"

# --- Fonts / GUI -----------------------------------------------------------
cask "font-fira-code-nerd-font" # glyphs for mini.icons / nvim-web-devicons
cask "neovide"                  # optional GUI

# --- Not available via Homebrew --------------------------------------------
# After `brew bundle`, finish with:
#
#   xcode-select --install                              # C compiler
#   go install golang.org/x/tools/gopls@latest          # gopls (lsp.lua)
#   gem install ruby-lsp                                # once per rbenv ruby
#   gh auth login                                       # octo.nvim / pr.nvim
#
#   c3lsp    — https://github.com/pherrymason/c3-lsp (release binary on $PATH);
#              add the `c3c` compiler if you actually build C3
#   Annotation Mono — set as the Neovide guifont in init.lua:26; install the
#                     font file manually or change that line
