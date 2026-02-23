return {
  {
    "LazyVim/LazyVim",
    opts = function()
      vim.o.foldmethod = "expr"
      vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.o.foldlevel = 99
    end,
  },
}
