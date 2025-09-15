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
  local indicators = {}

  -- split into: [bufnr] [flags...] "name" line [num]
  local bufnr, rest, name, lnum =
      line:match('^%s*(%d+)%s*(.-)%s+"([^"]+)"%s+line%s+(%d+)')

  if bufnr then
    -- clean flags (remove extra spaces)
    local flags = rest:gsub("%s+", "")
    indicators = {
      bufnr = tonumber(bufnr),
      flags = flags, -- e.g. "u%a+", "%a+", "%a", etc.
      file  = name,
      line  = tonumber(lnum),
    }
  end

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
  return tonumber(M.extract_all_from_ls(ls[index])["bufnr"])
end

--- find the buffer number from the :ls! output line by the provided index
--- @return number?
M.find_buffer_from_ls_by_name = function(name)
  local ls = M.get_ls_all_lines()
  for _, value in ipairs(ls) do
    if string.find(value, name, 1, true) then
      local indicators = M.extract_all_from_ls(value)
      local bufnr = indicators["bufnr"]
      return bufnr
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
  local file_exists = helpers.ensure_file(save_file_path)

  if file_exists then
    local data = dofile(save_file_path) or {}
    local file = io.open(save_file_path, 'w')

    data[cwd] = vim.inspect(ls)

    if file ~= nil then
      file:write("return " .. vim.inspect(data))
      file:close()
    end
  end
end

---Create a new buffer from the indicators
---@param indicators table
M.create_buf_from_indicators = function(indicators)
  --- NOTE: buffers will be always  listed as we only want to restore the buffers shown on :ls
  --- and also not scratch buffers, as chagnes on those are not saved and cannot recover again
  if (indicators["file"] ~= nil) then
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(buf, indicators["file"])
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent edit")
    end)
  end
end

---@param config DefaultConfig
---@param save_file_path? string
M.restore_buffers = function(config, save_file_path)
  save_file_path = save_file_path or ("/tmp/" .. "scrub.lua")

  if not helpers.ensure_file(save_file_path) then
    return
  end

  local data = dofile(save_file_path)

  local cwd = vim.fn.getcwd()

  local cur_data = nil
  if data and data[cwd] then
    cur_data = data[cwd]
  end

  if cur_data ~= nil then
    cur_data = cur_data:gsub("^'(.*)'$", "%1")

    local lines = vim.split(cur_data, "\\n")

    for _, line in ipairs(lines) do
      local indicators = M.extract_all_from_ls(line)
      if indicators["file"] ~= nil then
        M.create_buf_from_indicators(indicators)
      end
    end
  end
end

return M
