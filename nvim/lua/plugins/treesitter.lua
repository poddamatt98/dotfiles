-- Parsers installed up front; any other supported language is installed the first time it is opened.
local ensure_installed = {
  "bash",
  "c",
  "diff",
  "html",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "vim",
  "vimdoc",
}

-- Highlighting comes from Neovim itself; indentation from nvim-treesitter (experimental).
local function start(buf, lang)
  if vim.api.nvim_buf_is_valid(buf) and pcall(vim.treesitter.start, buf, lang) then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

return {
  "nvim-treesitter/nvim-treesitter",
  -- Requires the tree-sitter CLI and a C compiler to build parsers. Does not support lazy-loading.
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require "nvim-treesitter"
    ts.install(ensure_installed)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then
          return
        end
        if vim.tbl_contains(ts.get_installed(), lang) or not vim.tbl_contains(ts.get_available(), lang) then
          start(args.buf, lang) -- also covers parsers bundled with Neovim
        else
          ts.install(lang):await(vim.schedule_wrap(function()
            start(args.buf, lang)
          end))
        end
      end,
    })
  end,
}
