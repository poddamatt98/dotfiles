local CONFIG_DIR = "~/.config"
local NOTES_DIR = "~/Documents/Matteo's Vault/"

return {
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable "make" == 1
      end,
    },
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require "telescope"
    local themes = require "telescope.themes"
    local builtin = require "telescope.builtin"

    telescope.setup {
      extensions = { ["ui-select"] = { themes.get_dropdown() } },
    }
    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")

    local function map(keys, func, desc)
      vim.keymap.set("n", keys, func, { desc = desc })
    end

    map("<leader>sh", builtin.help_tags, "[S]earch [H]elp")
    map("<leader>sk", builtin.keymaps, "[S]earch [K]eymaps")
    map("<leader>sf", builtin.find_files, "[S]earch [F]iles")
    map("<leader>ss", builtin.builtin, "[S]earch [S]elect Telescope")
    map("<leader>sw", builtin.grep_string, "[S]earch current [W]ord")
    map("<leader>sg", builtin.live_grep, "[S]earch by [G]rep")
    map("<leader>sd", builtin.diagnostics, "[S]earch [D]iagnostics")
    map("<leader>sr", builtin.resume, "[S]earch [R]esume")
    map("<leader>s.", builtin.oldfiles, "[S]earch Recent Files")
    map("<leader><leader>", builtin.buffers, "Find existing buffers")
    map("<leader>/", function()
      builtin.current_buffer_fuzzy_find(themes.get_dropdown { winblend = 10, previewer = false })
    end, "Fuzzy search in current buffer")
    map("<leader>s/", function()
      builtin.live_grep { grep_open_files = true, prompt_title = "Live Grep in Open Files" }
    end, "[S]earch [/] in Open Files")

    map("<leader>mcs", function()
      builtin.find_files { cwd = CONFIG_DIR }
    end, "[M]y [C]onfig files - [S]earch")
    map("<leader>mcg", function()
      builtin.live_grep { cwd = CONFIG_DIR }
    end, "[M]y [C]onfig files - [G]rep")
    map("<leader>mns", function()
      builtin.find_files { cwd = NOTES_DIR }
    end, "[M]y [N]otes - [S]earch")
    map("<leader>mng", function()
      builtin.live_grep { cwd = NOTES_DIR }
    end, "[M]y [N]otes - [G]rep")
  end,
}
