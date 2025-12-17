return {
  -- VimTeX: Main LaTeX plugin for compilation, syntax, motions
  {
    "lervag/vimtex",
    lazy = false,
    ft = { "tex", "bib" },
    init = function()
      -- Use latexmk for compilation
      vim.g.vimtex_compiler_method = "latexmk"

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

      -- PDF viewer - Skim (with bidirectional sync)
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1 -- Auto-sync on cursor move
      vim.g.vimtex_view_skim_activate = 1 -- Activate Skim on \lv
      vim.g.vimtex_view_skim_reading_bar = 1 -- Show reading bar in Skim

      -- Quickfix settings - show errors
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_quickfix_open_on_warning = 0

      -- Enable folding
      vim.g.vimtex_fold_enabled = 0

      -- Set the flavor to LaTeX (not plain TeX)
      vim.g.tex_flavor = "latex"

      -- Callback for inverse search (Skim -> Neovim)
      vim.g.vimtex_compiler_progname = "nvr"

      -- Write servername to file for Skim backward search
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
          local servername = vim.v.servername
          if servername and servername ~= "" then
            vim.fn.system("echo " .. servername .. " > /tmp/curvimserver")
          end
        end,
      })
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
                executable = "/opt/homebrew/bin/displayline",
                args = { "%l", "%p", "%f" },
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
