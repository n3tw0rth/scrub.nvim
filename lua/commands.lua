local M = {}

--- @return string
M.ls = function()
  return vim.fn.execute("ls")
end

--- @return string
M.ls_all = function()
  return vim.fn.execute("ls!")
end


return M
