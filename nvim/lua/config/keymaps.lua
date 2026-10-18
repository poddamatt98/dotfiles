-- Global keymaps. Plugin keymaps live in their plugin file (see README.md).
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show line [D]iagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

for arrow, key in pairs { left = "h", right = "l", up = "k", down = "j" } do
  map("n", "<" .. arrow .. ">", ('<cmd>echo "Use %s to move!!"<CR>'):format(key), { desc = "Disabled: use " .. key })
end
