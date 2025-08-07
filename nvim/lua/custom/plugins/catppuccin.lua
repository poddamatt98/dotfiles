return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    custom_highlights = {
      -- Force background to full black (#000000)
      Normal = { bg = "#000000" },
      NormalFloat = { bg = "#000000" },
      FloatBorder = { bg = "#000000" },
      -- You can add more groups as necessary
    },
    styles = {
      comments = { "italic" }, -- Change the style of comments
      conditionals = { "italic" },
      loops = { "italic" },
      functions = { "italic" },
      keywords = { "italic" },
      strings = {},
      variables = { "bold" },
      numbers = {},
      booleans = {},
      properties = {},
      types = { "italic" },
      operators = { "bold" },
      -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      notify = true,
      mini = {
        enabled = true,
        indentscope_color = "",
      },
      fzf = true,
      mason = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd "colorscheme catppuccin"
  end,
}
