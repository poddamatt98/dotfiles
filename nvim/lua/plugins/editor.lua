-- Small editing helpers that need little or no configuration.
return {
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup { n_lines = 500 }
      require("mini.surround").setup()
      require("mini.comment").setup()
    end,
  },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "NMAC427/guess-indent.nvim", opts = {} },
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
}
