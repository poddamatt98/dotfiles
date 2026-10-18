-- Headless smoke test. Run it with tests/run.sh, not directly.
-- Loaded via --cmd, i.e. before init.lua, so it can record every keymap and error the config produces.
local config_dir = vim.fn.stdpath "config"
local failures, notes = {}, {}

local function fail(msg, ...)
  table.insert(failures, msg:format(...))
end

local function read(path)
  return table.concat(vim.fn.readfile(path), "\n")
end

-- lazy.nvim reports plugin errors through vim.notify.
local notify = vim.notify
vim.notify = function(msg, level, opts)
  if level == vim.log.levels.ERROR then
    fail("error notification: %s", msg)
  end
  return notify(msg, level, opts)
end

-- Record keymaps set by this config: "<mode> <lhs>" -> list of { desc, source, nop }.
local maps = {}
local MODE_ALIASES = { [""] = { "n", "x", "s", "o" }, v = { "x", "s" } }

-- Every plugin loaded at startup has these on its stack; they don't own its keymaps.
local LOADER_CHAIN = { ["init.lua"] = true, ["lua/config/lazy.lua"] = true }

-- File in this config that caused the call, or "lazy keys" for `keys` in a plugin spec.
local function config_caller()
  for level = 3, 40 do
    local info = debug.getinfo(level, "S")
    if not info then
      return nil
    end
    if info.source:find("lazy/core/handler/keys", 1, true) then
      return "lazy keys"
    end
    local path = info.source:sub(2)
    local rel = vim.startswith(path, config_dir) and path:sub(#config_dir + 2)
    if rel and not LOADER_CHAIN[rel] and not vim.startswith(rel, "tests/") then
      return rel
    end
  end
end

local keymap_set = vim.keymap.set
vim.keymap.set = function(mode, lhs, rhs, opts)
  local source = config_caller()
  if source then
    local desc = opts and opts.desc
    local lhs_norm = vim.fn.keytrans(vim.keycode(lhs))
    for _, m in ipairs(type(mode) == "table" and mode or { mode }) do
      for _, resolved in ipairs(MODE_ALIASES[m] or { m }) do
        local id = resolved .. " " .. lhs_norm
        maps[id] = maps[id] or {}
        table.insert(maps[id], { desc = desc, source = source, nop = rhs == "" or rhs == "<Nop>" })
      end
    end
  end
  return keymap_set(mode, lhs, rhs, opts)
end

local function key_tokens(keys)
  local tokens, i = {}, 1
  while i <= #keys do
    local token = keys:match("^<[^>]+>", i) or keys:sub(i, i)
    table.insert(tokens, token)
    i = i + #token
  end
  return tokens
end

local function check_keymaps(lazy_plugins)
  -- Buffer-local keymaps only exist once something attaches: simulate LSP and gitsigns.
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_exec_autocmds("LspAttach", { buffer = buf, data = { client_id = -1 } })
  require("gitsigns.config").config.on_attach(buf)

  local wk_opts = require("lazy.core.plugin").values(lazy_plugins["which-key.nvim"], "opts", false)
  local groups = {}
  for _, entry in ipairs(wk_opts.spec or {}) do
    if entry.group then
      groups[vim.fn.keytrans(vim.keycode(entry[1]))] = true
    end
  end
  local leader = vim.fn.keytrans(vim.keycode "<leader>")

  for id, entries in pairs(maps) do
    local lhs = id:match "^%S+ (.+)$"
    local by_desc = {}
    for _, e in ipairs(entries) do
      if not e.desc and not e.nop then
        fail("keymap %s in %s has no desc", id, e.source)
      end
      by_desc[e.desc or "?"] = e.source
    end
    if vim.tbl_count(by_desc) > 1 then
      local owners = {}
      for desc, source in pairs(by_desc) do
        table.insert(owners, ('"%s" (%s)'):format(desc, source))
      end
      fail("keymap conflict on %s: %s", id, table.concat(owners, " vs "))
    end

    if vim.startswith(lhs, leader) then
      local tokens = key_tokens(lhs:sub(#leader + 1))
      for n = 1, #tokens - 1 do
        local prefix = leader .. table.concat(tokens, "", 1, n)
        if not groups[prefix] then
          fail("keymap %s: prefix %s has no which-key group (ui.lua)", id, prefix)
          groups[prefix] = true -- report each missing prefix once
        end
      end
    end
  end
end

local function check_tools()
  local tools = require "config.tools"

  local capabilities = require("blink.cmp").get_lsp_capabilities()
  for name, overrides in pairs(tools.servers) do
    local resolved = vim.lsp.config[name]
    if not (resolved and resolved.cmd) then
      fail("LSP %s: unknown to nvim-lspconfig (typo?)", name)
    elseif not vim.deep_equal(vim.tbl_deep_extend("force", resolved, overrides), resolved) then
      fail("LSP %s: overrides from tools.lua are not applied", name)
    elseif
      not vim.deep_equal(vim.tbl_deep_extend("force", resolved.capabilities or {}, capabilities), resolved.capabilities)
    then
      fail("LSP %s: blink.cmp capabilities are not applied", name)
    end
  end

  if not vim.deep_equal(require("conform").formatters_by_ft, tools.formatters) then
    fail "conform formatters_by_ft differs from tools.formatters"
  end
  if not vim.deep_equal(require("lint").linters_by_ft, tools.linters) then
    fail "nvim-lint linters_by_ft differs from tools.linters"
  end
  for _, formatters in pairs(tools.formatters) do
    for _, name in ipairs(formatters) do
      if not pcall(require, "conform.formatters." .. name) then
        fail("formatter %s: unknown to conform.nvim", name)
      end
    end
  end
  for _, linters in pairs(tools.linters) do
    for _, name in ipairs(linters) do
      if not pcall(require, "lint.linters." .. name) then
        fail("linter %s: unknown to nvim-lint", name)
      end
    end
  end

  -- Needs network to download the Mason registry.
  local registry = require "mason-registry"
  if not registry.refresh() then
    table.insert(notes, "skipped Mason package check: registry unavailable (offline?)")
    return
  end
  local lsp_to_pkg = require("mason-lspconfig").get_mappings().lspconfig_to_package
  local dap_to_pkg = require("mason-nvim-dap.mappings.source").nvim_dap_to_package
  for _, name in ipairs(tools.mason_packages()) do
    if not registry.has_package(lsp_to_pkg[name] or name) then
      fail("tools.lua: %s is not a Mason package", name)
    end
  end
  for _, name in ipairs(tools.debuggers) do
    if not registry.has_package(dap_to_pkg[name] or name) then
      fail("tools.lua: debugger %s is not a Mason package", name)
    end
  end
end

-- Does the highlighter's work on Markdown with injected code blocks: headless mode never redraws,
-- so query errors would otherwise only show up on screen.
local function check_treesitter()
  local ts = require "nvim-treesitter"
  local langs = { "markdown", "markdown_inline", "lua", "python" }
  -- Build failures are only printed, so check the result instead.
  local ok, err = pcall(function()
    ts.install(langs):wait(300000)
  end)
  local missing = vim.tbl_filter(function(lang)
    return not vim.tbl_contains(ts.get_installed(), lang)
  end, langs)
  if not ok or #missing > 0 then
    return fail(
      "treesitter: parsers not installed: %s (tree-sitter CLI missing?) %s",
      table.concat(missing, ", "),
      err or ""
    )
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "# T", "```lua", "local x = 1", "```", "```python", "x = 1", "```" })
  vim.bo[buf].filetype = "markdown"
  if not vim.treesitter.highlighter.active[buf] then
    fail "treesitter: highlighting did not start for markdown"
  end
  ok, err = pcall(function()
    local parser = vim.treesitter.get_parser(buf)
    parser:parse(true)
    parser:for_each_tree(function(tree, ltree)
      local query = vim.treesitter.query.get(ltree:lang(), "highlights")
      if query then
        for _ in query:iter_captures(tree:root(), buf) do
        end
      end
    end)
  end)
  if not ok then
    fail("treesitter: highlighting markdown failed: %s", err)
  end
end

local function check_readme()
  local readme = read(config_dir .. "/README.md")
  local files = vim.fn.globpath(config_dir, "lua/*/*.lua", false, true)
  vim.list_extend(files, vim.fn.globpath(config_dir, "tests/*", false, true))
  for _, path in ipairs(files) do
    local file = vim.fn.fnamemodify(path, ":t")
    if not readme:find(file, 1, true) then
      fail("README.md layout does not mention %s", file)
    end
  end
end

local function run()
  if vim.v.errmsg ~= "" then
    fail("startup error: %s", vim.v.errmsg)
  end

  local lazy_config = require "lazy.core.config"
  require("lazy").load { plugins = vim.tbl_keys(lazy_config.plugins) }

  check_keymaps(lazy_config.plugins)
  check_tools()
  check_treesitter()
  check_readme()
end

-- Scheduled so errors lazy.nvim queued during startup are delivered first.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = vim.schedule_wrap(function()
    local ok, err = xpcall(run, debug.traceback)
    if not ok then
      fail("smoke test crashed: %s", err)
    end

    io.stdout:write "\n" -- plugin output before this may not end with a newline
    for _, note in ipairs(notes) do
      io.stdout:write("note: " .. note .. "\n")
    end
    if #failures == 0 then
      io.stdout:write "smoke test passed\n"
      vim.cmd "qa!"
    end
    table.sort(failures)
    io.stderr:write(("smoke test failed (%d):\n  %s\n"):format(#failures, table.concat(failures, "\n  ")))
    vim.cmd "cquit 1"
  end),
})
