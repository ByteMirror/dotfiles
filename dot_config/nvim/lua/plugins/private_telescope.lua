return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      mappings = {
        i = {
          -- macOS native shortcuts for insert mode
          -- Option + Backspace: delete word before cursor
          ["<M-BS>"] = function()
            vim.api.nvim_input("<C-w>")
          end,
          -- CMD + Backspace: delete to beginning of line
          ["<D-BS>"] = function()
            vim.api.nvim_input("<C-u>")
          end,
          -- Option + Left: move word left
          ["<M-Left>"] = function()
            vim.api.nvim_input("<C-Left>")
          end,
          -- Option + Right: move word right
          ["<M-Right>"] = function()
            vim.api.nvim_input("<C-Right>")
          end,
          -- CMD + Left: move to beginning of line
          ["<D-Left>"] = function()
            vim.api.nvim_input("<Home>")
          end,
          -- CMD + Right: move to end of line
          ["<D-Right>"] = function()
            vim.api.nvim_input("<End>")
          end,
        },
      },
    },
  },
}
