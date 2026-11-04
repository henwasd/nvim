return {
  -- Suporte a múltiplos cursores (vim-visual-multi)
  {
    "mg979/vim-visual-multi",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      -- Você pode adicionar configurações para o vim-visual-multi aqui se desejar no futuro, ex:
      -- vim.g.VM_maps = {}
    end,
  },
}
