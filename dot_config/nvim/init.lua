-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Workaround: coalesce streamed paste phases into a single call for terminal buffers.
-- Fixes long text paste truncation/garbling in claudecode.nvim.
-- See: https://github.com/coder/claudecode.nvim/issues/161#issuecomment-4258224698
do
  local chunks = {}
  local orig_paste = vim.paste
  vim.paste = function(lines, phase)
    if vim.bo.buftype ~= "terminal" or phase == -1 then
      return orig_paste(lines, phase)
    end
    if phase == 1 then chunks = {} end
    for _, line in ipairs(lines) do chunks[#chunks + 1] = line end
    if phase == 3 then
      local buffered = chunks
      chunks = {}
      return orig_paste(buffered, -1)
    end
    return true
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      Snacks.explorer.open()
      vim.cmd("ClaudeCode --continue")
    end)
  end,
})
