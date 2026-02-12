local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  -- Packer can manage itself
  use { 'wbthomason/packer.nvim' }

  use {
	  'nvim-telescope/telescope.nvim', tag = '*',
	  requires = { { 'nvim-lua/plenary.nvim' } }
  }

  use { 'ellisonleao/gruvbox.nvim' }

  use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
  }

  use ('https://git.sr.ht/~foosoft/argonaut.nvim')

  use {
      'numToStr/Comment.nvim',
      config = function()
          require('Comment').setup()
      end
  }

  use {
      'pwntester/octo.nvim',
      cmd = 'Octo',
      requires = {{'nvim-lua/plenary.nvim'}, {'nvim-tree/nvim-web-devicons'}, {'nvim-telescope/telescope.nvim'}},
      config = function()
          -- Setup octo with the opts
          require('octo').setup({
              picker = "telescope",
              enable_builtin = true,
          })

    -- Set up the keymaps
    vim.keymap.set('n', '<leader>oi', '<CMD>Octo issue list<CR>', { desc = 'List GitHub Issues' })
    vim.keymap.set('n', '<leader>op', '<CMD>Octo pr list<CR>', { desc = 'List GitHub PullRequests' })
    vim.keymap.set('n', '<leader>od', '<CMD>Octo discussion list<CR>', { desc = 'List GitHub Discussions' })
    vim.keymap.set('n', '<leader>on', '<CMD>Octo notification list<CR>', { desc = 'List GitHub Notifications' })
    vim.keymap.set('n', '<leader>os', function()
      require('octo.utils').create_base_search_command({ include_current_repo = true })
    end, { desc = 'Search GitHub' })
  end
  }

  if packer_bootstrap then
    require('packer').sync()
  end 

end)


