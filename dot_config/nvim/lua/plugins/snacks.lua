return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>ld",
      function()
        Snacks.terminal("lazydocker", { win = { style = "lazydocker" } })
      end,
      desc = "Lazydocker",
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    -- Center images in the buffer viewer (non-inline image files)
    local buf_mod = require("snacks.image.buf")
    local orig_attach = buf_mod._attach
    buf_mod._attach = function(buf, o)
      o = o or {}
      o.on_update_pre = function(self)
        if self.opts.inline then return end
        local wins = self:wins()
        if #wins == 0 then return end
        local win = wins[1]
        local win_w = vim.api.nvim_win_get_width(win)
        local win_h = vim.api.nvim_win_get_height(win)
        local size = Snacks.image.util.fit(
          self.img.file,
          { width = win_w, height = win_h },
          { info = self.img.info }
        )
        local col = math.max(0, math.floor((win_w - size.width) / 2))
        local padding_top = math.max(0, math.floor((win_h - size.height) / 2))
        local row = padding_top + 1
        local line_count = vim.api.nvim_buf_line_count(self.buf)
        if line_count < row then
          vim.bo[self.buf].modifiable = true
          local lines = {}
          for i = 1, row - line_count do lines[i] = "" end
          vim.api.nvim_buf_set_lines(self.buf, line_count, line_count, false, lines)
          vim.bo[self.buf].modifiable = false
          vim.bo[self.buf].modified = false
        end
        self.opts.pos = { row, col }
      end
      return orig_attach(buf, o)
    end
  end,
  opts = {
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = true,
        float = true,
        max_width = 80,
        max_height = 40,
      },
    },
    styles = {
      lazydocker = {
        wo = { winhighlight = "Normal:Normal" },
        width = 0,
        height = 0,
      },
    },
    picker = {
      sources = {
        explorer = {
          hidden = true,
          -- .env 系は gitignore 対象でも常に表示する (include は hidden/ignored より優先)
          include = { "**/.env*" },
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
