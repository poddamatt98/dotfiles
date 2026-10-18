return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    custom_highlights = {
      Normal = { bg = "#000000" },
      NormalFloat = { bg = "#000000" },
      FloatBorder = { bg = "#000000" },
    },
    styles = {
      comments = { "italic" },
      conditionals = { "italic" },
      loops = { "italic" },
      functions = { "italic" },
      keywords = { "italic" },
      types = { "italic" },
      variables = { "bold" },
      operators = { "bold" },
    },
    integrations = {
      blink_cmp = true,
      fidget = true,
      gitsigns = true,
      harpoon = true,
      mason = true,
      mini = { enabled = true },
      neotree = true,
      telescope = { enabled = true },
      treesitter = true,
      which_key = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme "catppuccin"
  end,
}
