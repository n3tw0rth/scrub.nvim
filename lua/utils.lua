local commands = require("lua.commands")
local M = {}

--- extracts the file name from the :ls output line
--- @param line string
--- @return string
M.extract_file_name_from_ls = function(line)
  return line:match('"([^"]+)"')
end

--- extract all information from the :ls output line
--- @param line string
--- @return table
M.extract_all_from_ls = function(line)
  local tokens = {}
  local indicators = {}
  --- split by whitespaces to get the tokens
  --- then parse the token according to :help :ls
  for token in string.gmatch(line, "%S+") do
    table.insert(tokens, token)
  end

  --- sets the default to prevent nil
  indicators["modifiable_off"] = false
  indicators["is_terminal"] = false
  indicators["modified"] = true
  indicators["has_errors"] = false
  indicators["line"] = "1"

  --- sometimes the block to indicate modifiable/readonly/terminal is missing
  --- to make the logic aware of it check the tokens length and branch to a
  --- different check with that additional block
  if #tokens == 5 then
    --- eg:  4 %a   ".editorconfig"                line 5
    for index, token in ipairs(tokens) do
      if index == 1 then
        indicators["buf_number"] = token
      elseif index == 2 then
        indicators["is_cur_window"] = string.sub(token, 1, 1) == "%" and true or false
        indicators["is_active"] = string.sub(token, 2, 2) == "a" and true or false
      elseif index == 3 then
        indicators["file"] = token:gsub('"', '')
      elseif index == 5 then
        indicators["line"] = token
      end
    end
  elseif #tokens == 6 then
    --- eg:  4 %a - ".editorconfig"                line 5
    for index, token in ipairs(tokens) do
      if index == 1 then
        indicators["buf_number"] = token
      elseif index == 2 then
        indicators["is_cur_window"] = string.sub(token, 1, 1) == "%" and true or false
        indicators["is_active"] = string.sub(token, 2, 2) == "a" and true or false
      elseif index == 3 then
        local char_1 = string.sub(token, 1, 1)
        local char_2 = string.sub(token, 2, 2)
        if char_1 == "-" then
          indicators["modifiable_off"] = true
        elseif char_1 == "=" then
          indicators["readonly"] = true
        elseif char_1 == "R" then
          indicators["is_terminal"] = true
          indicators["job_state"] = "running"
        elseif char_1 == "F" then
          indicators["is_terminal"] = true
          indicators["job_state"] = "finished"
        elseif char_1 == "F" then
          indicators["is_terminal"] = true
          indicators["job_state"] = "none"
        end

        if char_2 == "+" then
          indicators["modified"] = true
        elseif char_2 == "x" then
          indicators["has_errors"] = true
        end
      elseif index == 4 then
        indicators["file"] = token:gsub('"', '')
      elseif index == 6 then
        indicators["line"] = token
      end
    end
  end

  return indicators
end

--- Get a table of lines from the :ls output
--- @return table
M.get_ls_lines = function()
  return vim.split(commands.ls(), "\n")
end

--- find the buffer number from the :ls output line by the provided index
--- @return number
M.find_buffer_from_ls = function(index)
  local ls = M.get_ls_lines()
  return tonumber(M.extract_all_from_ls(ls[index])["buf_number"])
end


return M
