require("gmk")
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4        -- Number of spaces a <Tab> counts for
vim.opt.shiftwidth = 4     -- Number of spaces for each indentation level
vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.softtabstop = 4    -- Number of spaces for <Tab> in insert mode
vim.opt.ignorecase = true  -- Ignore case in searches
vim.opt.smartcase = true   -- Override ignorecase if search contains uppercase

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c3' },
  callback = function() vim.treesitter.start() end,
})
