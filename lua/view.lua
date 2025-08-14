local M = {}

M.view_buffer = function()
  local buf = vim.api.nvim_create_buf(true, true)

  vim.api.nvim_buf_set_name(buf, "scrub buffer")
  vim.api.nvim_win_set_buf(0, buf)

  M.populate_buffer(buf)
  return buf
end


M.populate_buffer = function(buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Hello from our plugin" })
  local buffers = vim.api.nvim_list_bufs()
end

return M
