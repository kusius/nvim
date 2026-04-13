return {
    {
        "ellisonleao/gruvbox.nvim" ,
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            require("gruvbox").setup(
                {
                    contrast = "soft" -- can be "soft", "hard" or ""
                }
            )
            vim.cmd([[colorscheme gruvbox]])
            vim.o.background = "dark"
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ':TSUpdate',
        config = function()
            require("nvim-treesitter").install {
                "kotlin",
                "c",
                "lua",
                "go",
                "c3",
                "json"
            }
        end,
    },

    {
        "https://git.sr.ht/~foosoft/argonaut.nvim"
    },

    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,

    },


}
