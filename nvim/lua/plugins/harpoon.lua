local function harpoon_list()
  return require("harpoon"):list()
end

-- Shows the harpoon list in a Telescope picker (with preview).
local function telescope_list()
  local conf = require("telescope.config").values
  local paths = vim.tbl_map(function(item)
    return item.value
  end, harpoon_list().items)

  require("telescope.pickers")
    .new({}, {
      prompt_title = "Harpoon",
      finder = require("telescope.finders").new_table { results = paths },
      previewer = conf.file_previewer {},
      sorter = conf.generic_sorter {},
    })
    :find()
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    require("harpoon"):setup()
  end,
  keys = {
    { "<leader>e", telescope_list, desc = "Harpoon: list files" },
    {
      "<leader>a",
      function()
        harpoon_list():add()
      end,
      desc = "Harpoon: add file",
    },
    {
      "<leader>p",
      function()
        harpoon_list():prev()
      end,
      desc = "Harpoon: previous file",
    },
    {
      "<leader>n",
      function()
        harpoon_list():next()
      end,
      desc = "Harpoon: next file",
    },
  },
}
