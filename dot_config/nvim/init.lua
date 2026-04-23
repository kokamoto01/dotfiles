-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      Snacks.explorer.open()
      vim.cmd("ClaudeCodeOpen")
    end)
  end,
})
