local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath }
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Every file in lua/plugins/ returns a lazy.nvim spec and is loaded automatically.
require("lazy").setup({ { import = "plugins" } }, {
  install = { colorscheme = { "catppuccin" } },
  change_detection = { notify = false },
})
