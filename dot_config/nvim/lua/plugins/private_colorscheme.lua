return {
  -- Auto dark-mode detection plugin
  {
    "cormacrelf/dark-notify",
    lazy = false,
    priority = 1001,
    config = function()
      require("dark_notify").run()
    end,
  },

  -- Mini.base16 for custom themes matching Ghostty
  {
    "nvim-mini/mini.base16",
    lazy = false,
    priority = 1000,
    config = function()
      local mini_base16 = require("mini.base16")

      -- Afterglow theme (dark mode) - matching Ghostty Afterglow exactly
      local afterglow_palette = {
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
      }

      -- Belafonte Day theme (light mode) - matching Ghostty Belafonte Day exactly
      local belafonte_palette = {
        base00 = "#D4CCC4", -- background
        base01 = "#C8BFB7", -- lighter background (status bars, line numbers)
        base02 = "#E0DBD5", -- selection/cursorline background (light highlight)
        base03 = "#968D94", -- comments
        base04 = "#525252", -- dark foreground
        base05 = "#45363F", -- foreground
        base06 = "#201011", -- darker foreground
        base07 = "#201011", -- darkest foreground
        base08 = "#BE1010", -- red
        base09 = "#EAA64B", -- orange
        base0A = "#EAA64B", -- yellow
        base0B = "#858162", -- green
        base0C = "#989B9C", -- cyan
        base0D = "#3182BD", -- blue
        base0E = "#975952", -- magenta
        base0F = "#BE1010", -- dark red
      }

      -- Function to apply theme based on mode
      local function apply_theme()
        if vim.o.background == "dark" then
          mini_base16.setup({ palette = afterglow_palette, use_cterm = true })
        else
          mini_base16.setup({ palette = belafonte_palette, use_cterm = true })
        end
      end

      -- Apply initial theme
      apply_theme()

      -- Update theme when background changes (triggered by dark-notify)
      vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "background",
        callback = apply_theme,
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
