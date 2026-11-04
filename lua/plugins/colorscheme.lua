return {
  -- Configuração do tema Gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      transparent_mode = true, -- Ativa o fundo transparente
    },
  },

  -- Garante que o Gruvbox seja o tema padrão do LazyVim
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
