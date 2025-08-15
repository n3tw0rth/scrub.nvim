local M = {}

--- @return string
M.extract_file_name = function(line)
  return line:match('"([^"]+)"')
end


return M
