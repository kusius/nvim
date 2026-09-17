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
	cmd = { require('gmk.tools').executable('clangd', '/opt/homebrew/opt/llvm/bin/clangd') },
	root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
	filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
})

vim.lsp.enable('clangd')

-- kmp-lsp: Rust/tree-sitter Kotlin+Java server (github.com/Hessesian/kmp-lsp).
-- vim.lsp.config('kmp_lsp', {
--     cmd = { vim.fn.expand('~/.local/bin/kmp-lsp') },
--     filetypes = { 'kotlin', 'java' },
--     -- Open the project as ~/work/... (its real case). Via ~/Work, find-references
--     -- silently returns nothing.
--     root_markers = { 'settings.gradle.kts', 'settings.gradle', 'pom.xml', '.git' },
-- })
-- vim.lsp.enable('kmp_lsp')

-- JetBrains kotlin-lsp -- kept for pure-Kotlin/JVM projects, where it is the
-- stronger tool (real FIR diagnostics). Useless on Android: see above.
-- Install: brew install JetBrains/utils/kotlin-lsp
-- The -D property is required or the Gradle import dies outright -- the bundled
-- JBR is a 'nomod' build with no jlink, so AGP's JdkImageTransform fails
-- (Kotlin/kotlin-lsp#240, still open in 263.4702.0). JAVA_HOME is ignored.
-- Any installed JDK will do; gmk.tools finds one (see $KOTLIN_LSP_GRADLE_JAVA_HOME).
local gradle_import_jdk = require('gmk.tools').jdk_for_gradle_import()
-- IntelliJ inspections with no server-side off switch (Kotlin/kotlin-lsp#52). FunctionName
-- fires on every @Composable, since the server has no Compose awareness (#191). ktlint with
-- the compose ruleset reports naming correctly instead -- see nvim-lint in plugins/spec.lua.
-- The server uses pull diagnostics, so publishDiagnostics is never called: filter here.
local ignored_kotlin_diagnostics = { FunctionName = true }

local function drop_ignored_diagnostics(result)
    if result and result.items then
        local kept = {}
        for _, d in ipairs(result.items) do
            if not ignored_kotlin_diagnostics[d.code] then kept[#kept + 1] = d end
        end
        result.items = kept
    end
    return result
end

vim.lsp.config('kotlin_lsp', {
    -- Without --system-path, indexes live in a temp dir that is wiped on exit.
    cmd = { 'kotlin-lsp', '--stdio', '--system-path=' .. vim.fn.stdpath('cache') .. '/kotlin-lsp' },
    filetypes = { 'kotlin' },
    handlers = {
        ['textDocument/diagnostic'] = function(err, result, ctx, config)
            return vim.lsp.handlers['textDocument/diagnostic'](err, drop_ignored_diagnostics(result), ctx, config)
        end,
    },
    cmd_env = gradle_import_jdk and {
        IJ_JAVA_OPTIONS = '-Dcom.jetbrains.ls.imports.gradle.java.home=' .. gradle_import_jdk,
    } or nil,
    root_markers = { 'settings.gradle.kts', 'settings.gradle', 'build.gradle.kts', 'pom.xml', '.git' },
})
vim.lsp.enable('kotlin_lsp')

-- kotlin-lsp, ktlint, the compose ruleset and the Gradle init script all live
-- outside this repo. Offer to install whatever is missing, once, when a Kotlin
-- file in a Gradle project is opened.
require('gmk.android_setup').setup()

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
