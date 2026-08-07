return {
    {
        "tpope/vim-rails",
        dependencies = { "tpope/vim-projectionist" },
        ft = { "ruby", "eruby", "haml", "slim" },
        cmd = { "Rails", "A", "AV", "Emodel", "Eview", "Econtroller" },
        init = function()
            -- yogurt-specific dirs vim-rails doesn't know about
            vim.g.rails_projections = {
                ["app/services/*.rb"]    = { command = "service",   alternate = "spec/services/{}_spec.rb" },
                ["app/facades/*.rb"]     = { command = "facade",    alternate = "spec/facades/{}_spec.rb" },
                ["app/presenters/*.rb"]  = { command = "presenter", alternate = "spec/presenters/{}_spec.rb" },
                ["app/decorators/*.rb"]  = { command = "decorator", alternate = "spec/decorators/{}_spec.rb" },
                ["app/components/*.rb"]  = { command = "component", alternate = "spec/components/{}_spec.rb" },
                ["app/maestros/*.rb"]    = { command = "maestro",   alternate = "spec/maestros/{}_spec.rb" },
                ["lib/*.rb"]             = { command = "lib",       alternate = "spec/lib/{}_spec.rb" },
                ["packs/*/app/**/*.rb"]  = { command = "pack" },
            }
        end,
    },
}
