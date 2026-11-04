return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "biome", "prettier", stop_after_first = true },
        typescript = { "biome", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "prettier", stop_after_first = true },
        json = { "biome", "prettier", stop_after_first = true },
        jsonc = { "biome", "prettier", stop_after_first = true },
      },
      formatters = {
        -- Biome só será executado se houver um arquivo 'biome.json' ou 'biome.jsonc' no projeto
        biome = {
          condition = function(ctx)
            return vim.fs.find({ "biome.json", "biome.jsonc" }, { path = ctx.filename, upward = true })[1] ~= nil
          end,
        },
        -- Prettier só será executado se o projeto NÃO estiver usando o Biome
        prettier = {
          condition = function(ctx)
            local has_biome = vim.fs.find({ "biome.json", "biome.jsonc" }, { path = ctx.filename, upward = true })[1] ~= nil
            return not has_biome
          end,
        },
      },
    },
  },
}
