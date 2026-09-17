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
brew "llvm"            # preferred clangd + lldb-dap (gmk.tools falls back to
                       # $PATH, so Apple's /usr/bin/clangd is only used if this
                       # is absent); also provides clang-format for conform.nvim
brew "go"              # toolchain for gopls (see manual steps below)
brew "rbenv"           # ruby_lsp cmd is hard-coded to ~/.rbenv/shims/ruby-lsp
brew "ruby-build"

cask "kotlin-lsp"      # JetBrains Kotlin LSP, started over stdio (lua/gmk/lsp.lua).
                       # Needs 263+ for the jar:// decompile handler in lsp.lua;
                       # if the cask is older, install the release manually and
                       # put `kotlin-lsp` earlier on $PATH.
brew "ktlint"          # nvim-lint diagnostics + conform `gq` formatting for Kotlin.
                       # The compose ruleset jar it loads is fetched separately:
                       # scripts/setup-kotlin-android.sh (offered automatically the
                       # first time a Kotlin file is opened in a Gradle project).

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
