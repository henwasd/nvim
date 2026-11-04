return {
  -- Mostrar diagnósticos inline elegantes de forma nativa
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach", -- Carrega assim que um servidor LSP for anexado
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup()
      
      -- Desativa o virtual text padrão do Neovim para não duplicar com o tiny-inline-diagnostic
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
}
