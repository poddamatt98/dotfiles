# Neovim config

Requires Neovim ≥ 0.11, git, make, ripgrep and a Nerd Font. Mason needs npm and Python to install some tools.

## Layout

```
init.lua              loads lua/config/* in order
lua/config/
  options.lua         leader + editor options
  keymaps.lua         global keymaps (not tied to a plugin)
  autocmds.lua        global autocommands
  lazy.lua            bootstraps lazy.nvim, imports lua/plugins/
  tools.lua           LSP servers, formatters, linters, debuggers
lua/plugins/          one lazy.nvim spec (or list of specs) per file, auto-imported
  colorscheme.lua     catppuccin with black background
  completion.lua      blink.cmp + LuaSnip
  debug.lua           nvim-dap + dap-ui (Go via delve)
  editor.lua          mini.ai/surround/comment, autopairs, guess-indent, todo-comments
  formatting.lua      conform, format on save
  git.lua             gitsigns (hunk keymaps), fugitive
  harpoon.lua         harpoon2, list shown in Telescope
  linting.lua         nvim-lint
  lsp.lua             mason + LSP setup, LspAttach keymaps, diagnostics, lazydev
  telescope.lua       pickers and search keymaps
  tmux.lua            vim-tmux-navigator
  treesitter.lua      nvim-treesitter (pinned to master branch)
  ui.lua              lualine, neo-tree, which-key, toggleterm
tests/
  smoke.lua           headless checks (see "Verifying changes")
  run.sh              installs pinned plugins, runs smoke.lua
lazy-lock.json        pinned plugin commits
```

## Conventions

- **Language tooling lives only in `config/tools.lua`.** Mason installs everything listed there; `lsp.lua`, `formatting.lua`, `linting.lua` and `debug.lua` read from it. Server entries are passed to `vim.lsp.config()` and merged over nvim-lspconfig defaults.
- **Plugins**: add to the `lua/plugins/` file whose theme fits, or a new file. Prefer `opts` over `config`, and lazy-load (`event`/`keys`/`cmd`/`ft`) when it is free.
- **Keymaps**: plugin keymaps go in that plugin's file, global ones in `config/keymaps.lua`. Every mapping has a `desc`. A new `<leader>` prefix must be registered in the which-key `spec` in `ui.lua`.
- **Colorscheme**: when adding a plugin catppuccin supports, enable its integration in `colorscheme.lua`.
- **Style**: `stylua` with `.stylua.toml` (2 spaces, double quotes, `require "x"` without parens). Comments only for non-obvious reasons.

## Keymaps

Leader is `<Space>`. Check for conflicts (`grep -rn '"<leader>x' lua/`) before adding one.

| Keys | Defined in | Purpose |
| --- | --- | --- |
| `<leader>s…` | telescope.lua | search (files, grep, help, keymaps, …) |
| `<leader>mc…` / `<leader>mn…` | telescope.lua | search `~/.config` / notes vault |
| `<leader><leader>`, `<leader>/` | telescope.lua | buffers, fuzzy search in buffer |
| `gr…`, `gO` | lsp.lua | LSP navigation and actions |
| `<leader>l…` | lsp.lua | workspace symbols |
| `<leader>h…`, `]c` / `[c` | git.lua | git hunks |
| `<leader>t…` | lsp.lua, git.lua | toggles |
| `<leader>a/e/n/p` | harpoon.lua | add / list / prev / next |
| `<leader>f` | formatting.lua | format buffer |
| `<leader>d`, `<leader>q` | config/keymaps.lua | diagnostics float / loclist |
| `<leader>;` | ui.lua | floating terminal |
| `\` | ui.lua | neo-tree |
| `<C-h/j/k/l>` | tmux.lua | move between splits and tmux panes |
| `<F1-3,5,7>`, `<leader>b/B` | debug.lua | debugger |

## Common tasks

- **Add a language**: add its server to `servers`, formatter to `formatters`, linter to `linters` in `tools.lua`. Treesitter parsers auto-install on first open.
- **Update plugins**: `:Lazy sync`, then commit `lazy-lock.json`.

## Verifying changes

Run after every change; CI (`.github/workflows/nvim.yml`) runs the same on every push touching `nvim/`.

```sh
tests/run.sh       # exits non-zero and lists failures
stylua --check .   # formatting
```

`tests/run.sh` tests the checkout it lives in. Installing plugins rewrites `lazy-lock.json`, so commit it whenever it changes (CI fails otherwise). The test fails on:
- errors while loading any plugin
- keymap conflicts (same keys, different `desc`, including LSP/gitsigns buffer maps) and keymaps without `desc`
- `<leader>` prefixes without a which-key group
- `tools.lua` entries that are typos (unknown to lspconfig/conform/nvim-lint/Mason) or not wired into their plugin
- files under `lua/` or `tests/` missing from the layout above

Runtime problems (missing tools, LSP issues) show in `:checkhealth`, `:Mason` and `:LspInfo`.
