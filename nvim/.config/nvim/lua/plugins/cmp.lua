return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")

      -- Close completion menu when leaving insert mode or when it gets stuck
      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
          if cmp.visible() then
            cmp.close()
          end
        end,
      })

      -- Ensure completion closes when moving to a line where it shouldn't show
      opts.completion = opts.completion or {}
      opts.completion.completeopt = "menu,menuone,noinsert,noselect"

      -- Keep existing mappings but ensure <Esc> and navigation always close the menu
      local existing_mapping = opts.mapping or {}

      opts.mapping = cmp.mapping.preset.insert(vim.tbl_extend("force", existing_mapping, {
        ["<Esc>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.close()
          end
          fallback()
        end, { "i", "s" }),
        ["<C-e>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.abort()
          else
            fallback()
          end
        end, { "i", "s" }),
      }))

      return opts
    end,
  },
}
