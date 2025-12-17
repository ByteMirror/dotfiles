return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    -- Point to local Claude installation
    terminal_cmd = "/Users/fabian/.claude/local/claude",

    -- Auto-start the WebSocket server
    auto_start = true,

    -- Terminal settings
    terminal = {
      split_side = "right",
      split_width_percentage = 0.40,
      provider = "snacks",
      auto_close = true,
    },

    -- Use git root as working directory
    git_repo_cwd = true,

    -- Diff handling
    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
    },
  },
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    { "<leader>aa", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current file to Claude" },
    -- Terminal mode: easy escape and split navigation
    { "<Esc><Esc>", "<C-\\><C-n>", mode = "t", desc = "Exit terminal mode" },
    { "<C-h>", "<C-\\><C-n><C-w>h", mode = "t", desc = "Go to left split" },
    { "<C-l>", "<C-\\><C-n><C-w>l", mode = "t", desc = "Go to right split" },
  },
}
