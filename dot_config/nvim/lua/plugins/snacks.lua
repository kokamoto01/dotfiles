return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true,
          toggles = {
            hidden = false,
          },
          layout = {
            preset = "sidebar",
            layout = { width = 30 },
          },
          win = {
            list = {
              keys = {
                ["<BS>"] = false,
              },
            },
          },
        },
      },
    },
  },
}
