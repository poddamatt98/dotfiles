-- Statusline, file explorer, key hints, terminal.
return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      sections = {
        lualine_x = { "lsp_status", "encoding", "fileformat", "filetype" },
      },
      extensions = { "fugitive", "lazy", "mason", "neo-tree", "nvim-dap-ui", "quickfix", "toggleterm" },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "\\", "<cmd>Neotree reveal<CR>", desc = "NeoTree reveal", silent = true },
    },
    opts = {
      filesystem = {
        window = { mappings = { ["\\"] = "close_window" } },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      delay = 0,
      -- Keep in sync with the leader prefixes documented in README.md.
      spec = {
        { "<leader>s", group = "[S]earch" },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
        { "<leader>l", group = "[L]SP workspace symbols" },
        { "<leader>m", group = "[M]y files" },
        { "<leader>mc", group = "[C]onfig" },
        { "<leader>mn", group = "[N]otes" },
      },
    },
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      open_mapping = [[<leader>;]],
      insert_mappings = false, -- otherwise typing "<space>;" in insert mode opens the terminal
      direction = "float",
      shade_terminals = false,
    },
  },
}
