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
