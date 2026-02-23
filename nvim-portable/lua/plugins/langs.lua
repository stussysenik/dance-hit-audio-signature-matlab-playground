return {
  -- Language extras are managed via lazyvim.json (use :LazyExtras to toggle)

  -- ── Mason: auto-install LSPs, formatters, linters ──
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Formatters
        "prettier",        -- JS/TS/HTML/CSS/JSON/MD
        "black",           -- Python
        "ruff",            -- Python (fast linter + formatter)
        "stylua",          -- Lua
        "clang-format",    -- C/C++
        "shfmt",           -- Shell

        -- Linters
        "eslint_d",        -- JS/TS (fast)
        "shellcheck",      -- Shell
        "rubocop",         -- Ruby
      },
    },
  },

  -- ── Formatting (conform.nvim) ──
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },
        python = { "ruff_format", "black", stop_after_first = true },
        lua = { "stylua" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        zig = { "zigfmt" },
        elixir = { "mix" },
        ruby = { "rubocop" },
        kotlin = { "ktlint" },
        swift = { "swiftformat" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        ocaml = { "ocamlformat" },
        matlab = { "mh_style" },
      },
      formatters = {
        mh_style = {
          command = "mh_style",
          args = { "--fix", "$FILENAME" },
          stdin = false,
        },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
    },
  },

  -- ── Linting (nvim-lint) ──
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        python = { "ruff" },
        ruby = { "rubocop" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        matlab = { "mh_lint" },
      },
    },
    config = function(_, opts)
      local lint = require("lint")
      -- Register custom MATLAB linter (MISS_HIT mh_lint, installed via pip)
      lint.linters.mh_lint = {
        cmd = "mh_lint",
        args = {},
        stdin = false,
        stream = "stdout",
        ignore_exitcode = true,
        parser = function(output)
          local diagnostics = {}
          for line in output:gmatch("[^\n]+") do
            local lnum, col, msg = line:match(":(%d+):(%d+): %w+: (.+)")
            if lnum then
              table.insert(diagnostics, {
                lnum = tonumber(lnum) - 1,
                col = tonumber(col) - 1,
                severity = line:match(": error:") and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
                message = msg,
                source = "mh_lint",
              })
            end
          end
          return diagnostics
        end,
      }
      lint.linters_by_ft = opts.linters_by_ft
    end,
  },

  -- ── Extra LSP servers (for languages without LazyVim extras) ──
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ocamllsp = {},         -- OCaml (install via: opam install ocaml-lsp-server)
        matlab_ls = {},        -- MATLAB (install via Mason if available)
      },
    },
  },

  -- ── Treesitter: syntax highlighting for all languages ──
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "typescript",
        "tsx",
        "javascript",
        "python",
        "elixir",
        "heex",
        "ruby",
        "c",
        "cpp",
        "zig",
        "kotlin",
        "swift",
        "ocaml",
        "lua",
        "bash",
        "html",
        "css",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
        "regex",
        "vim",
        "commonlisp",
        "matlab",
      },
    },
  },
}
