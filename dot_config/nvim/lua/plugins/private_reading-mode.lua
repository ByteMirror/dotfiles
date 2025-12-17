-- Simple reading mode using native Neovim features
-- No external plugin needed
return {
  {
    "folke/snacks.nvim",
    optional = true,
    opts = {
      zen = {
        toggles = {
          dim = false,
          git_signs = false,
          diagnostics = false,
        },
        show = {
          statusline = true,
          tabline = false,
        },
        win = {
          width = 100,
        },
      },
    },
    keys = {
      { "<leader>zz", function() Snacks.zen() end, desc = "Toggle Reading Mode" },
    },
  },
}
