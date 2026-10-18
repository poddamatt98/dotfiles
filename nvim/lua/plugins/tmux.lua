-- <C-h/j/k/l> move between Neovim splits and tmux panes alike.
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<C-h>", "<cmd><C-U>TmuxNavigateLeft<CR>", desc = "Move to left split/pane" },
    { "<C-j>", "<cmd><C-U>TmuxNavigateDown<CR>", desc = "Move to lower split/pane" },
    { "<C-k>", "<cmd><C-U>TmuxNavigateUp<CR>", desc = "Move to upper split/pane" },
    { "<C-l>", "<cmd><C-U>TmuxNavigateRight<CR>", desc = "Move to right split/pane" },
    { "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<CR>", desc = "Move to previous split/pane" },
  },
}
