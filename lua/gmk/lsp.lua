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

-- kmp-lsp: Rust/tree-sitter Kotlin+Java server (github.com/Hessesian/kmp-lsp).
vim.lsp.config('kmp_lsp', {
    cmd = { vim.fn.expand('~/.local/bin/kmp-lsp') },
    filetypes = { 'kotlin', 'java' },
    -- Open the project as ~/work/... (its real case). Via ~/Work, find-references
    -- silently returns nothing.
    root_markers = { 'settings.gradle.kts', 'settings.gradle', 'pom.xml', '.git' },
})
vim.lsp.enable('kmp_lsp')

-- JetBrains kotlin-lsp -- kept for pure-Kotlin/JVM projects, where it is the
-- stronger tool (real FIR diagnostics). Useless on Android: see above.
-- Install: brew install JetBrains/utils/kotlin-lsp
-- The -D property is required or the Gradle import dies outright -- the bundled
-- JBR is a 'nomod' build with no jlink, so AGP's JdkImageTransform fails
-- (Kotlin/kotlin-lsp#240). JAVA_HOME and org.gradle.java.home are both ignored.
-- vim.lsp.config('kotlin_lsp', {
--     cmd = { '/opt/homebrew/opt/kotlin-lsp/libexec/bin/intellij-server', '--stdio' },
--     filetypes = { 'kotlin' },
--     init_options = {
--         defaultSdk = '/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home',
--     },
--     cmd_env = {
--         IJ_JAVA_OPTIONS = '-Dcom.jetbrains.ls.imports.gradle.java.home='
--             .. '/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home',
--     },
--     root_markers = { 'settings.gradle.kts', 'settings.gradle', 'build.gradle.kts', 'pom.xml', '.git' },
-- })
-- vim.lsp.enable('kotlin_lsp')

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
