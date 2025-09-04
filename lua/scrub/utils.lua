local commands = require("scrub.commands")
local constants = require("scrub.constants")
local helpers = require("scrub.helpers")
local M = {}

--- extracts the file name from the :ls output line
--- @param line string
--- @return string
M.extract_file_name_from_ls = function(line)
  return line:match('"([^"]+)"')
end

--- Return a table of file names from the :ls output line
--- @return string[]
M.get_listed_buffers = function()
  local ls = vim.split(commands.ls(), "\n")
  local lines = {}
  for _, line in ipairs(ls) do
    local name = M.extract_file_name_from_ls(line)
    if name ~= nil then
      table.insert(lines, name)
    end
  end
  return lines
end

--- extract all information from the :ls output line
--- @param line string
--- @return table
M.extract_all_from_ls = function(line)
  local tokens = {}
  local indicators = {}

  local indicator_slice = string.sub(line, 1, 6)
  local meta_slice = string.sub(line, 6, -1)
  local meta_table = {}

  --- sets the default to prevent nil
  indicators["modifiable_off"] = false
  indicators["is_terminal"] = false
  indicators["modified"] = true
  indicators["has_errors"] = false
  indicators["unlisted"] = false
  indicators["is_cur_window"] = false
  indicators["file"] = nil
  indicators["buf_number"] = nil
  indicators["line"] = nil

  indicators["buf_number"] = indicator_slice:match("%d+")

  for value in meta_slice:gmatch("%S+") do
    table.insert(meta_table, value)
  end

  indicators["file"] = meta_table[1]:gsub('"', "")
  indicators["line"] = meta_table[3]

  return indicators
end

--- Get a table of lines from the :ls output
--- @return table
M.get_ls_lines = function()
  return vim.split(commands.ls(), "\n")
end

--- Get a table of lines from the :ls! output
--- @return table
M.get_ls_all_lines = function()
  return vim.split(commands.ls_all(), "\n")
end

--- find the buffer number from the :ls output line by the provided index
--- @return number?
M.find_buffer_from_ls = function(index)
  local ls = M.get_ls_lines()
  return tonumber(M.extract_all_from_ls(ls[index])["buf_number"])
end

--- find the buffer number from the :ls! output line by the provided index
--- @return number?
M.find_buffer_from_ls_by_name = function(name)
  local ls = M.get_ls_all_lines()
  for _, value in ipairs(ls) do
    if value:match(name) then
      local buf_number = tonumber(M.extract_all_from_ls(value)["buf_number"])
      return buf_number
    end
  end
end


M.unload_buffer_if_empty = function(buf)
  local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if buf_lines[1] == "" then
    vim.api.nvim_win_close(0, true) --- we shall close the current window as all the buffers are closed
  end
end

M.exit_scrub = function()
  local scrub_buf = M.find_buffer_from_ls_by_name(constants.SCRATCH_BUFFER_NAME)
  if scrub_buf ~= nil then
    vim.api.nvim_buf_delete(scrub_buf, { force = true })
  end
end


M.remove_last_line = function(buf)
  local line_count = vim.api.nvim_buf_line_count(buf)

  -- If only one line exists, do nothing (keeps that top line as-is)
  if line_count <= 1 then
    return
  end

  -- last line index is (n - 1). nvim_buf_set_lines uses [start, end) (end exclusive).
  -- To delete the last line we delete the range (n-1, n).
  vim.api.nvim_buf_set_lines(buf, line_count - 1, line_count, false, {})
end


---@param config DefaultConfig
---@param save_file_path? string
M.save_buffers = function(config, save_file_path)
  local cwd = vim.fn.getcwd()
  local ls = commands.ls()

  save_file_path = save_file_path or ("/tmp/" .. "scrub.lua")

  local data = dofile(save_file_path) or {}
  local file = io.open(save_file_path, 'w')

  data[cwd] = vim.inspect(ls)

  if file ~= nil then
    file:write("return " .. vim.inspect(data))
    file:close()
  end
end

---@param config DefaultConfig
---@param save_file_path? string
M.restore_buffers = function(config, save_file_path)
  save_file_path = save_file_path or ("/tmp/" .. "scrub.lua")
  local data = dofile(save_file_path)

  local cwd = vim.fn.getcwd()

  local cur_data = data[cwd]

  cur_data = cur_data:gsub("^'(.*)'$", "%1")

  local lines = {}
  for line in cur_data:gmatch("(.-)\\n") do
    table.insert(lines, line)
  end
  local last = cur_data:match("\\n(.*)$")
  if last then
    table.insert(lines, last)
  end

  for _, line in ipairs(lines) do
    local indicators = M.extract_all_from_ls(line)
    print(indicators["line"])
  end
end

return M
