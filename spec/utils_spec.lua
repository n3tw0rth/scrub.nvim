local command = require("scrub.commands")
local helpers = require("scrub.helpers")
local utils   = require("scrub.utils")

local mock    = require('luassert.mock')
local stub    = require('luassert.stub')


-- M.save_buffers = function(config)
--   local save_file_path = "/tmp/" .. "scrub.lua"
--   local cwd = vim.fn.getcwd()
--   local ls = commands.ls()
--   local file = io.open(save_file_path, 'a')
--   local data = dofile(save_file_path)
--
--   data["c"] = vim.inspect(data)
--
--   if file ~= nil then
--     file:write("return " .. vim.inspect(data))
--     file:close()
--   end
-- end

describe('utils module', function()
  local testModule = require("scrub.utils")
  os.execute("mkdir /tmp/scrub_tests")

  local save_file_path = "/tmp/scrub_tests/" .. "scrub.lua"

  ---@type  DefaultConfig
  local config = {
    enabled = true,
    save_n_restore = {
      enabled = true,
      temp = true
    }
  }

  stub(command, "ls").returns(
    '33 %a   "lua/scrub/view.lua"           line 51\n' ..
    '63  h + "spec/view_spec.lua"           line 9')


  describe("save_buffers", function()
    stub(vim.fn, "getcwd").returns("/tmp/scrub_tests")
    testModule.save_buffers(config, save_file_path)

    stub(vim.fn, "getcwd").returns("/tmp/")
    testModule.save_buffers(config, save_file_path)
  end)

  describe("restore_buffers", function()
    stub(vim.fn, "getcwd").returns("/tmp/scrub_tests")
    testModule.restore_buffers(config, save_file_path)
  end)
end)
