vim.lsp.config('ruby_lsp', {
    cmd = { vim.fn.expand('~/.rbenv/shims/ruby-lsp') },
    filetypes = { 'ruby', 'eruby' },
    root_markers = { 'Gemfile', '.git' },
})
vim.lsp.enable('ruby_lsp')

vim.lsp.config('luals', {
  cmd = {'lua-language-server'},
  filetypes = {'lua'},
  root_markers = {'.luarc.json', '.luarc.jsonc'},
})

vim.lsp.enable('luals')

vim.lsp.config('clangd', {
	cmd = { '/opt/homebrew/opt/llvm/bin/clangd' },
	root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
	filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
})

vim.lsp.enable('clangd')

vim.lsp.config('kotlin_lsp', {
    -- cmd = vim.lsp.rpc.connect('127.0.0.1', 9999),
    cmd = {
        vim.fn.expand('~/.local/share/kotlin-lsp-enhanced/bin/enhanced-server'),
        '--stdio',
    },
    filetypes = { 'kotlin' },
    init_options = {
        defaultSdk = vim.fn.expand('~/Library/Java/JavaVirtualMachines/openjdk-26.0.2/Contents/Home'),
        buildTools = { ['file://' .. vim.fn.expand('~/Work/nutrichum/client')] = 'json' },
    },
    root_markers = {
        { 'settings.gradle.kts', 'settings.gradle' },  -- true project root
        { 'build.gradle.kts', 'build.gradle', 'pom.xml' },
        '.git',
    },
})
vim.lsp.enable('kotlin_lsp')

vim.lsp.config('c3lsp', {
    cmd = { 'c3lsp' },
    filetypes = { 'c3' },
    root_markers = { '.git' }
})
vim.lsp.enable('c3lsp')

vim.lsp.config('gopls', {
    cmd = { 'gopls' },
    filetypes = { 'go' },
    root_markers = { 'go.mod','.git' }
})
vim.lsp.enable('gopls')
