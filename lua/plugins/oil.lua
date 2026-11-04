return {
  {
    "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "refractalize/oil-git-status.nvim",
      "JezerM/oil-lsp-diagnostics.nvim",
    },
    event = "VeryLazy",
    cmd = "Oil",
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "Open parent directory with Oil" },
    },
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
      },
      win_options = {
        signcolumn = "yes:2",
      },
      keymaps = {
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit", -- Garante split vertical no Ctrl+V
        ["<C-s>"] = "actions.select_split",  -- Garante split horizontal no Ctrl+S
        ["<Esc>"] = "actions.close",
      },
    },
    config = function(_, opts)
      require("oil").setup(opts)
      
      -- Inicializa extensões do Oil
      pcall(require, "oil-git-status")
      pcall(require, "oil-lsp-diagnostics")
      
      local ok_git, oil_git = pcall(require, "oil-git-status")
      if ok_git then oil_git.setup() end
      
      local ok_lsp, oil_lsp = pcall(require, "oil-lsp-diagnostics")
      if ok_lsp then oil_lsp.setup() end
    end,
  },
}
