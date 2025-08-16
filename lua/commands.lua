local M = {}

--- @return string
M.ls = function()
  return vim.fn.execute("ls")
end


return M
