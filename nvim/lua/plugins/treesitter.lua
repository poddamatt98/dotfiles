return {
  "nvim-treesitter/nvim-treesitter",
  -- `main` is an incompatible rewrite; this config uses the master branch API.
  branch = "master",
  build = ":TSUpdate",
  main = "nvim-treesitter.configs",
  opts = {
    ensure_installed = {
      "bash",
      "c",
      "diff",
      "html",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "vim",
      "vimdoc",
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  },
}
