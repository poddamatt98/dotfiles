local tools = require "config.tools"

local function on_attach(event)
  local builtin = require "telescope.builtin"
  local function map(keys, func, desc, mode)
    vim.keymap.set(mode or "n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
  end
  local function workspace_symbols(kind)
    return function()
      builtin.lsp_dynamic_workspace_symbols { symbols = { kind } }
    end
  end

  map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
  map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
  map("grr", builtin.lsp_references, "[G]oto [R]eferences")
  map("gri", builtin.lsp_implementations, "[G]oto [I]mplementation")
  map("grd", builtin.lsp_definitions, "[G]oto [D]efinition")
  map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  map("grt", builtin.lsp_type_definitions, "[G]oto [T]ype Definition")
  map("gO", builtin.lsp_document_symbols, "Open Document Symbols")
  map("<leader>lc", workspace_symbols "class", "Workspace [C]lasses")
  map("<leader>lm", workspace_symbols "method", "Workspace [M]ethods")
  map("<leader>lf", workspace_symbols "function", "Workspace [F]unctions")

  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if not client then
    return
  end

  if client:supports_method("textDocument/inlayHint", event.buf) then
    map("<leader>th", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    end, "[T]oggle Inlay [H]ints")
  end

  -- Highlight references of the symbol under the cursor.
  if client:supports_method("textDocument/documentHighlight", event.buf) then
    local group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = event.buf,
      group = group,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = event.buf,
      group = group,
      callback = vim.lsp.buf.clear_references,
    })
    vim.api.nvim_create_autocmd("LspDetach", {
      buffer = event.buf,
      group = group,
      callback = function(detach)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds { group = group, buffer = detach.buf }
      end,
    })
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
      "saghen/blink.cmp",
    },
    config = function()
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
      for name, server in pairs(tools.servers) do
        vim.lsp.config(name, server)
      end

      require("mason-tool-installer").setup { ensure_installed = tools.mason_packages() }
      require("mason-lspconfig").setup {
        ensure_installed = {},
        automatic_enable = vim.tbl_keys(tools.servers),
      }

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = on_attach,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        },
        virtual_text = { source = "if_many", spacing = 2 },
      }
    end,
  },

  -- Neovim Lua API types for lua_ls.
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
    },
  },
}
