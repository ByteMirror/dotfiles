-- Rounded borders for all floating windows
return {
  -- Mason UI (LSP server manager)
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.diagnostics = opts.diagnostics or {}
      opts.diagnostics.float = opts.diagnostics.float or {}
      opts.diagnostics.float.border = "rounded"
      return opts
    end,
  },

  -- Snacks.nvim (terminal and other floats)
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          border = "rounded",
        },
      },
    },
  },

  -- Noice.nvim (LSP documentation)
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        lsp_doc_border = true,
      },
    },
  },

  -- Blink.cmp (completion menu)
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      completion = {
        menu = {
          border = "rounded",
        },
        documentation = {
          window = {
            border = "rounded",
          },
        },
      },
      signature = {
        window = {
          border = "rounded",
        },
      },
    },
  },

  -- nvim-cmp (alternative completion, if using)
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.window = {
        completion = cmp.config.window.bordered({
          border = "rounded",
        }),
        documentation = cmp.config.window.bordered({
          border = "rounded",
        }),
      }
      return opts
    end,
  },
}
