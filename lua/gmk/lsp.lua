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

local clangd_cmd = '/opt/homebrew/opt/llvm/bin/clangd'
if (vim.fn.has('bsd') == 1) then clangd_cmd = '/usr/local/bin/clangd' end
vim.lsp.config('clangd', {
	cmd = { clangd_cmd },
	root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
	filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
})

vim.lsp.enable('clangd')

-- JetBrains kotlin-lsp. Install: brew install JetBrains/utils/kotlin-lsp
vim.lsp.config('kotlin_lsp', {
    -- Without --system-path, indexes live in a temp dir that is wiped on exit.
    cmd = { 'kotlin-lsp', '--stdio', '--system-path=' .. vim.fn.stdpath('cache') .. '/kotlin-lsp' },
    filetypes = { 'kotlin' },
    -- workspace.json: the build-tool-free project model nob.kt writes (writeWorkspace), before .git so that
    -- an example inside a repository is its own root.
    root_markers = { 'settings.gradle.kts', 'settings.gradle', 'build.gradle.kts', 'pom.xml', 'workspace.json', '.git' },
})
vim.lsp.enable('kotlin_lsp')

-- Go-to-definition into a library returns jar:///path/to.jar!/pkg/Class.class, which
-- Neovim cannot read: it opens an empty buffer and then errors on the cursor position
-- (Kotlin/kotlin-lsp#44). Fill such buffers with the server's own decompiled source.
vim.api.nvim_create_autocmd('BufReadCmd', {
  group = vim.api.nvim_create_augroup('KotlinDecompile', { clear = true }),
  pattern = { 'jar://*', 'jrt://*' },
  desc = 'Decompile jar:/jrt: class files via kotlin-lsp',
  callback = function(args)
    local uri = vim.fn.expand('<amatch>')
    local client = vim.lsp.get_clients({ name = 'kotlin_lsp' })[1]
    if not client then
      vim.notify('kotlin-lsp is not running: cannot decompile ' .. uri, vim.log.levels.ERROR)
      return
    end

    vim.bo[args.buf].buftype = 'nofile'
    vim.bo[args.buf].swapfile = false
    vim.bo[args.buf].modifiable = true

    -- Synchronous: the jump sets the cursor as soon as this returns, and a line
    -- past the end of a still-empty buffer is exactly the #44 error.
    local res = client:request_sync('workspace/executeCommand',
      { command = 'decompile', arguments = { uri } }, 10000, args.buf)
    local code = res and not res.err and res.result and res.result.code
    if not code then
      vim.notify('Decompiling failed: ' .. vim.inspect(res and res.err or 'no result'), vim.log.levels.ERROR)
      return
    end

    vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, vim.split(code:gsub('\r\n', '\n'), '\n', { plain = true }))
    vim.bo[args.buf].filetype = res.result.language and res.result.language:lower() or 'kotlin'
    vim.bo[args.buf].modifiable = false
    vim.bo[args.buf].modified = false
  end,
})

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
