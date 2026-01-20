vim.lsp.config('luals', {
  cmd = {'lua-language-server'},
  filetypes = {'lua'},
  root_markers = {'.luarc.json', '.luarc.jsonc'},
})

vim.lsp.enable('luals')

vim.lsp.config('clangd', {
	cmd = { 'clangd' },
	root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
	filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
})

vim.lsp.enable('clangd')

vim.lsp.config('kotlin_lsp', {
    cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(9999)),
    filetypes = { "kotlin" },
    root_markers = { "build.gradle", "build.gradle.kts", "pom.xml" },
    single_file_support = true,
})
vim.lsp.enable('kotlin_lsp')
