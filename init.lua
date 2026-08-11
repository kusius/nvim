require("gmk")
vim.o.exrc = true -- Allow per project settings override with .nvim.lua
vim.o.wrap = false
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4        -- Number of spaces a <Tab> counts for
vim.opt.shiftwidth = 4     -- Number of spaces for each indentation level
vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.softtabstop = 4    -- Number of spaces for <Tab> in insert mode
vim.opt.ignorecase = true  -- Ignore case in searches
vim.opt.smartcase = true   -- Override ignorecase if search contains uppercase

-- Automatically go to the last cursor position when reopening a closed buf
-- FYI: double quotes (") is the special marker denoting the last cursor position
-- before the buffer was closed.
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('RestoreCursorPosition', { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c3', 'ruby', 'eruby', 'scss', 'css', 'html',
              'javascript', 'javascriptreact', 'yaml', 'kotlin', 'java' },
  callback = function() vim.treesitter.start() end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('TreesitterFolding', { clear = true }),
  callback = function(args)
    if not pcall(vim.treesitter.get_parser, args.buf) then return end
    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt_local.foldlevel = 99
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('FoldImports', { clear = true }),
  pattern = { 'kotlin', 'java' },
  callback = function(args)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then return end
      for i, line in ipairs(vim.api.nvim_buf_get_lines(args.buf, 0, 300, false)) do
        if line:match('^import%s') then
          pcall(vim.api.nvim_buf_call, args.buf, function()
            vim.cmd('normal! zx')
            vim.cmd(i .. 'foldclose')
          end)
          return
        end
      end
    end)
  end,
})

vim.filetype.add({
  extension = { thor = "ruby", jbuilder = "ruby" },
  filename  = { Guardfile = "ruby", Capfile = "ruby", ["packwerk.yml"] = "yaml" },
})

if vim.g.neovide then
    vim.o.guifont = "Annotation Mono Medium:h15"
end


