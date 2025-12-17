return {
  -- Use mini.base16 to create a colorscheme matching Ghostty's Afterglow
  {
    "nvim-mini/mini.base16",
    lazy = false,
    priority = 1000,
    config = function()
      require("mini.base16").setup({
        -- Palette matching Ghostty's Afterglow theme exactly
        palette = {
          base00 = "#212121", -- background
          base01 = "#303030", -- lighter background (status bars, line numbers)
          base02 = "#505050", -- selection background
          base03 = "#505050", -- comments, invisibles
          base04 = "#b0b0b0", -- dark foreground
          base05 = "#d0d0d0", -- foreground
          base06 = "#e0e0e0", -- light foreground
          base07 = "#f5f5f5", -- lightest foreground
          base08 = "#ac4142", -- red (variables)
          base09 = "#e87d3e", -- orange (integers, booleans)
          base0A = "#e5b567", -- yellow (classes)
          base0B = "#7e8e50", -- green (strings)
          base0C = "#7dd6cf", -- cyan (support, regex)
          base0D = "#6c99bb", -- blue (functions)
          base0E = "#9f4e85", -- purple (keywords)
          base0F = "#ac4142", -- dark red (deprecated)
        },
        use_cterm = true,
      })
    end,
  },

  -- Disable LazyVim's default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() end, -- mini.base16 handles it
    },
  },
}
