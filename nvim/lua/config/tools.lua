-- Language tooling manifest: the only place to add/remove LSP servers, formatters,
-- linters and debug adapters. Everything listed here is installed by Mason on startup.
-- Servers use nvim-lspconfig names; formatters/linters/debuggers use Mason package names.
local M = {}

-- Server name -> overrides passed to vim.lsp.config().
M.servers = {
  basedpyright = {
    settings = { basedpyright = { analysis = { typeCheckingMode = "off" } } },
  },
  ts_ls = {},
  lua_ls = {
    settings = { Lua = { completion = { callSnippet = "Replace" } } },
  },
}

local prettier = { "prettierd", "prettier", stop_after_first = true }

-- conform.nvim formatters_by_ft.
M.formatters = {
  lua = { "stylua" },
  python = { "isort", "black" },
  javascript = prettier,
  javascriptreact = prettier,
  typescript = prettier,
  typescriptreact = prettier,
}

-- Filetypes excluded from format-on-save (<leader>f still works).
M.no_format_on_save = { c = true, cpp = true }

-- nvim-lint linters_by_ft.
M.linters = {
  markdown = { "markdownlint" },
}

-- mason-nvim-dap adapters.
M.debuggers = { "delve" }

function M.mason_packages()
  local packages = vim.tbl_keys(M.servers)
  for _, by_ft in ipairs { M.formatters, M.linters } do
    for _, tools in pairs(by_ft) do
      for _, tool in ipairs(tools) do
        if not vim.tbl_contains(packages, tool) then
          table.insert(packages, tool)
        end
      end
    end
  end
  return packages
end

return M
