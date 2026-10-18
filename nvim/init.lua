if vim.fn.has "nvim-0.11" == 0 then
  vim.api.nvim_echo({ { "This config needs Neovim >= 0.11 (see README.md)", "ErrorMsg" } }, true, {})
  return
end

require "config.options"
require "config.keymaps"
require "config.autocmds"
require "config.lazy"
