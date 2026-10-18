return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require "lint"
    lint.linters_by_ft = require("config.tools").linters

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("lint", { clear = true }),
      callback = function()
        -- ignore_errors: don't spam when a linter isn't installed (yet) by Mason.
        if vim.bo.modifiable then
          lint.try_lint(nil, { ignore_errors = true })
        end
      end,
    })
  end,
}
