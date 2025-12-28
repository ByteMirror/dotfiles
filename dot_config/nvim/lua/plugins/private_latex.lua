return {
  -- VimTeX: Main LaTeX plugin for compilation, syntax, motions
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      -- Use latexmk for compilation
      vim.g.vimtex_compiler_method = "latexmk"

      -- Enable notifications (1 = echo, 2 = vim.notify)
      vim.g.vimtex_notify_mode = 2

      -- Compiler options for latexmk
      vim.g.vimtex_compiler_latexmk = {
        aux_dir = "",
        out_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-pdf",
          "-shell-escape",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }

      -- PDF viewer - generic (works with evince, okular, zathura)
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "xdg-open"

      -- Quickfix settings - show errors
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_quickfix_open_on_warning = 0

      -- Enable folding
      vim.g.vimtex_fold_enabled = 0

      -- Set the flavor to LaTeX (not plain TeX)
      vim.g.tex_flavor = "latex"

      -- Callback for inverse search
      vim.g.vimtex_compiler_progname = "nvr"
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "latex", "bibtex" })
    end,
  },

  -- texlab LSP for completions, diagnostics, and more
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          settings = {
            texlab = {
              build = {
                executable = "latexmk",
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                onSave = true,
              },
              forwardSearch = {
                executable = "xdg-open",
                args = { "%p" },
              },
              chktex = {
                onOpenAndSave = true,
                onEdit = false,
              },
              diagnosticsDelay = 300,
              latexFormatter = "latexindent",
              latexindent = {
                modifyLineBreaks = false,
              },
              bibtexFormatter = "texlab",
            },
          },
        },
      },
    },
  },

  -- Mason: ensure texlab is installed
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "texlab", "latexindent" })
    end,
  },

  -- Completion source for LaTeX symbols
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "kdheepak/cmp-latex-symbols",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources or {}, {
        { name = "latex_symbols", priority = 700 },
      }))
    end,
  },
}
