local function dap_call(method)
  return function()
    require("dap")[method]()
  end
end

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "mason-org/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
    "leoluz/nvim-dap-go",
  },
  keys = {
    { "<F5>", dap_call "continue", desc = "Debug: Start/Continue" },
    { "<F1>", dap_call "step_into", desc = "Debug: Step Into" },
    { "<F2>", dap_call "step_over", desc = "Debug: Step Over" },
    { "<F3>", dap_call "step_out", desc = "Debug: Step Out" },
    { "<leader>b", dap_call "toggle_breakpoint", desc = "Debug: Toggle Breakpoint" },
    {
      "<leader>B",
      function()
        require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
      end,
      desc = "Debug: Set Conditional Breakpoint",
    },
    {
      "<F7>",
      function()
        require("dapui").toggle()
      end,
      desc = "Debug: Toggle UI",
    },
  },
  config = function()
    local dap = require "dap"
    local dapui = require "dapui"

    require("mason-nvim-dap").setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = require("config.tools").debuggers,
    }

    dapui.setup {
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
    }
    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close

    require("dap-go").setup { delve = { detached = true } }
  end,
}
