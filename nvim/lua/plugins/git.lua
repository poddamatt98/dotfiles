return {
  { "tpope/vim-fugitive" },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = require "gitsigns"
        local function map(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
        end
        local function selection()
          return { vim.fn.line ".", vim.fn.line "v" }
        end

        -- In diff mode keep the native ]c / [c behaviour.
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gs.nav_hunk "next"
          end
        end, "Jump to next git [c]hange")
        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gs.nav_hunk "prev"
          end
        end, "Jump to previous git [c]hange")

        map("n", "<leader>hs", gs.stage_hunk, "git [s]tage/unstage hunk")
        map("v", "<leader>hs", function()
          gs.stage_hunk(selection())
        end, "git [s]tage/unstage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "git [r]eset hunk")
        map("v", "<leader>hr", function()
          gs.reset_hunk(selection())
        end, "git [r]eset hunk")
        map("n", "<leader>hS", gs.stage_buffer, "git [S]tage buffer")
        map("n", "<leader>hR", gs.reset_buffer, "git [R]eset buffer")
        map("n", "<leader>hp", gs.preview_hunk, "git [p]review hunk")
        map("n", "<leader>hb", gs.blame_line, "git [b]lame line")
        map("n", "<leader>hd", gs.diffthis, "git [d]iff against index")
        map("n", "<leader>hD", function()
          gs.diffthis "@"
        end, "git [D]iff against last commit")
        map("n", "<leader>tb", gs.toggle_current_line_blame, "[T]oggle git [b]lame line")
        map("n", "<leader>tD", gs.preview_hunk_inline, "[T]oggle git show [D]eleted")
      end,
    },
  },
}
