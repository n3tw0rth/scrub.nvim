local M = {}

local augroup = vim.api.nvim_create_augroup("Scrub", { clear = true })

M.create_buffer = function()
  local buf = vim.api.nvim_create_buf(true, true)

  vim.api.nvim_buf_set_name(buf, "*scratch*")
  vim.api.nvim_set_option_value("filetype", "lua", { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Hello from our plugin" })

  vim.api.nvim_win_set_buf(0, buf)
  return buf
end

M.main = function()
  M.create_buffer()
  print("Hello from our plugin")
end

M.register_command = function()
  vim.api.nvim_create_user_command("Scrub", M.main, {})
end

M.setup = function()
  vim.api.nvim_create_autocmd("VimEnter",
    { group = augroup, desc = "Scrub.nvim setup", once = true, callback = M.register_command })
end

return { setup = M.setup }
