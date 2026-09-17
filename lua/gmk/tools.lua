-- Locating external tools without hardcoding machine-specific paths.
--
-- Everything here degrades to nil rather than guessing, so a config that lands
-- on a machine without the tool keeps working instead of pointing at a path
-- that does not exist.

local M = {}

local function readable(path)
  return path and path ~= '' and vim.uv.fs_stat(path) ~= nil and path or nil
end

--- First existing path, else the executable found on PATH, else the bare name
--- (letting the caller's tool report a normal "not found").
---@param name string
---@param ... string preferred absolute paths, tried in order
---@return string
function M.executable(name, ...)
  for _, path in ipairs({ ... }) do
    if readable(path) then return path end
  end
  local found = vim.fn.exepath(name)
  return found ~= '' and found or name
end

--- Major version of the JDK at `home`, plus a comparable number that orders
--- patch releases too (21.0.7 above 21.0.5). Read from the JDK's own release
--- file, so the answer does not depend on how the directory happens to be named.
---@return integer|nil major, integer|nil order
local function java_version(home)
  local release = home and io.open(home .. '/release')
  if not release then return nil end

  local version
  for line in release:lines() do
    version = line:match('^JAVA_VERSION="([^"]+)"')
    if version then break end
  end
  release:close()

  local major, minor, patch = (version or ''):match('^(%d+)%.?(%d*)%.?(%d*)')
  major = tonumber(major)
  if not major then return nil end
  return major, major * 1000000 + (tonumber(minor) or 0) * 1000 + (tonumber(patch) or 0)
end

--- JDKs on this machine, newest first, as { version = <major>, path = <string> }.
--- macOS keeps them in several places, so java_home is the only reliable index;
--- elsewhere the conventional directories are scanned.
local function java_homes()
  local seen, homes = {}, {}

  local function add(path)
    if not path or seen[path] or not readable(path .. '/bin/java') then return end
    seen[path] = true
    local major, order = java_version(path)
    if not major then
      -- No release file: fall back to digits in the directory name.
      major = tonumber(path:match('(%d+)')) or 0
      order = major * 1000000
    end
    table.insert(homes, { version = major, order = order, path = path })
  end

  if vim.fn.executable('/usr/libexec/java_home') == 1 then
    -- -V writes the table to stderr: '    21.0.7 (arm64) "Vendor" - "Name" /path'
    local out = vim.system({ '/usr/libexec/java_home', '-V' }, { text = true }):wait()
    for line in ((out.stderr or '') .. (out.stdout or '')):gmatch('[^\n]+') do
      add(line:match('%s(/.+)$'))
    end
  end

  for _, dir in ipairs({ '/usr/lib/jvm', vim.fn.expand('~/.sdkman/candidates/java') }) do
    for name, type_ in vim.fs.dir(dir) do
      if type_ == 'directory' or type_ == 'link' then add(dir .. '/' .. name) end
    end
  end

  table.sort(homes, function(a, b) return a.order > b.order end)
  return homes
end

--- A JDK for kotlin-lsp's Gradle import.
---
--- The server's own bundled runtime is a 'nomod' build with no jlink, so AGP's
--- JdkImageTransform dies during an Android import (Kotlin/kotlin-lsp#240). Any
--- real JDK works; AGP wants 17+, and 21 is the newest LTS that older AGP
--- versions accept, hence the range. Vendor is irrelevant -- whatever is
--- installed is fine.
---
--- Override with $KOTLIN_LSP_GRADLE_JAVA_HOME when a specific JDK is wanted.
---@param opts? { min?: integer, max?: integer }
---@return string|nil
function M.jdk_for_gradle_import(opts)
  opts = opts or {}
  local min, max = opts.min or 17, opts.max or 21

  -- Asked for explicitly: use it, whatever version it is.
  local explicit = vim.env.KOTLIN_LSP_GRADLE_JAVA_HOME
  if explicit and readable(explicit .. '/bin/jlink') then return explicit end

  -- JAVA_HOME only counts when it is in range. A too-new JDK is precisely what
  -- breaks the import, so inheriting one silently would defeat the purpose.
  local java_home = vim.env.JAVA_HOME
  if java_home and readable(java_home .. '/bin/jlink') then
    local major = java_version(java_home)
    if major and major >= min and major <= max then return java_home end
  end

  for _, home in ipairs(java_homes()) do
    if home.version >= min and home.version <= max and readable(home.path .. '/bin/jlink') then
      return home.path
    end
  end
end

--- The compose-rules ruleset jar for ktlint (mrmans0n/compose-rules).
---
--- Projects that vendor their own copy win, so a project pinned to a specific
--- ruleset version keeps using it; otherwise the shared copy is used.
--- Override with $KTLINT_COMPOSE_RULESET.
---@param fname string a file in the project
---@return string|nil
function M.ktlint_compose_ruleset(fname)
  local root = fname
    and vim.fs.root(fname, { 'settings.gradle.kts', 'settings.gradle', 'pom.xml', '.git' })

  return readable(vim.env.KTLINT_COMPOSE_RULESET)
    or readable(root and (root .. '/.ktlint/ktlint-compose.jar'))
    or readable(vim.fn.expand('~/.ktlint/ktlint-compose.jar'))
    or readable(vim.fn.stdpath('data') .. '/ktlint/ktlint-compose.jar')
end

return M
