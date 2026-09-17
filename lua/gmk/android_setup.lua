-- Offers to install the machine-local pieces the Kotlin/Android setup needs.
--
-- The plugins come from lazy, but kotlin-lsp, ktlint, the compose ruleset jar
-- and the Gradle init script are all outside its reach, and the config degrades
-- quietly without them (see scripts/setup-kotlin-android.sh). So when a Kotlin
-- file is opened in a Gradle project, ask once, and only then install.
--
--   :KotlinAndroidSetup        check and offer, even if previously declined
--   :KotlinAndroidSetup!       install everything missing without asking

local M = {}

local script = vim.fn.stdpath('config') .. '/scripts/setup-kotlin-android.sh'
local skip_marker = vim.fn.stdpath('state') .. '/gmk-kotlin-setup-skipped'

local function exists(path)
  return path ~= nil and path ~= '' and vim.uv.fs_stat(path) ~= nil
end

--- Each component: the setup step that installs it, and how to tell it is there.
local components = {
  {
    step = 'kotlin-lsp',
    label = 'kotlin-lsp (the Kotlin language server)',
    present = function() return vim.fn.executable('kotlin-lsp') == 1 end,
  },
  {
    step = 'ktlint',
    label = 'ktlint (Kotlin lint + gq formatting)',
    present = function() return vim.fn.executable('ktlint') == 1 end,
  },
  {
    step = 'ruleset',
    label = 'compose-rules ruleset (so @Composable names are judged correctly)',
    present = function()
      return require('gmk.tools').ktlint_compose_ruleset(vim.api.nvim_buf_get_name(0)) ~= nil
    end,
  },
  {
    step = 'initd',
    label = 'Gradle init script (Android imports with KSP/kapt fail without it)',
    present = function()
      local home = vim.env.GRADLE_USER_HOME or (vim.env.HOME .. '/.gradle')
      return exists(home .. '/init.d/kotlin-lsp-android-ksp-inputs.init.gradle.kts')
    end,
  },
}

---@return table[] components that are not installed
function M.missing()
  return vim.tbl_filter(function(c) return not c.present() end, components)
end

--- Run the setup script for the given steps, reporting through notifications.
---@param steps string[]
function M.install(steps)
  if not exists(script) then
    vim.notify('Setup script missing: ' .. script, vim.log.levels.ERROR)
    return
  end

  vim.notify('Installing: ' .. table.concat(steps, ', '), vim.log.levels.INFO)
  vim.system(vim.list_extend({ 'bash', script }, steps), { text = true }, function(res)
    vim.schedule(function()
      local output = (res.stdout or '') .. (res.stderr or '')
      if res.code == 0 then
        vim.notify('Kotlin/Android setup done:\n' .. vim.trim(output), vim.log.levels.INFO)
      else
        vim.notify('Kotlin/Android setup failed:\n' .. vim.trim(output), vim.log.levels.ERROR)
      end
    end)
  end)
end

--- Ask, then install what the user agreed to.
---@param opts? { force?: boolean }  force skips the question
function M.offer(opts)
  opts = opts or {}
  local missing = M.missing()
  if #missing == 0 then
    if opts.announce_ok then vim.notify('Kotlin/Android setup: nothing missing', vim.log.levels.INFO) end
    return
  end

  local steps = vim.tbl_map(function(c) return c.step end, missing)
  if opts.force then
    M.install(steps)
    return
  end

  local lines = { 'You need these for the Kotlin/Android features to work:', '' }
  for _, c in ipairs(missing) do
    table.insert(lines, '  - ' .. c.label)
  end
  table.insert(lines, '')
  table.insert(lines, 'Proceed with setup?')

  local choice = vim.fn.confirm(table.concat(lines, '\n'), '&Yes\n&No\n&Never on this machine', 2)
  if choice == 1 then
    M.install(steps)
  elseif choice == 3 then
    vim.fn.writefile({ 'Delete this file to be asked again.' }, skip_marker)
    vim.notify('Skipping Kotlin/Android setup on this machine (' .. skip_marker .. ')', vim.log.levels.INFO)
  end
end

local asked = false

--- Ask at most once per session, and only where it matters: a Kotlin buffer in
--- a Gradle project, with a UI attached to answer the prompt (never in CI).
function M.setup()
  vim.api.nvim_create_user_command('KotlinAndroidSetup', function(cmd)
    M.offer({ force = cmd.bang, announce_ok = true })
  end, { bang = true, desc = 'Install the Kotlin/Android tooling this config expects' })

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('KotlinAndroidSetup', { clear = true }),
    pattern = 'kotlin',
    desc = 'Offer to install missing Kotlin/Android tooling',
    callback = function(ev)
      if asked or exists(skip_marker) or #vim.api.nvim_list_uis() == 0 then return end
      local name = vim.api.nvim_buf_get_name(ev.buf)
      if not vim.fs.root(name ~= '' and name or vim.fn.getcwd(), {
        'settings.gradle.kts', 'settings.gradle', 'build.gradle.kts', 'build.gradle',
      }) then
        return
      end
      asked = true
      -- Defer so the prompt lands after the file is on screen.
      vim.defer_fn(function() M.offer() end, 200)
    end,
  })
end

return M
