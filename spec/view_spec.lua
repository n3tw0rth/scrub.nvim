local command = require("scrub.commands")
local helpers = require("scrub.helpers")
local utils   = require("scrub.utils")

local mock    = require('luassert.mock')
local stub    = require('luassert.stub')


describe('view module', function()
  local testModule = require("scrub.view")

  describe("populate_buffer", function()
    local buf = vim.api.nvim_create_buf(false, false)
    stub(command, "ls").returns(
      '33 %a   "lua/scrub/view.lua"           line 51\n' ..
      '63  h + "spec/view_spec.lua"           line 9')

    local ls = vim.split(command.ls(), '\n')

    stub(helpers, "reset_buffer")
    stub(utils, "extract_file_name_from_ls")
        .on_call_with(ls[1]).returns("lua/scrub/view.lua")
        .on_call_with(ls[2]).returns("spec/view_spec.lua")

    testModule.populate_buffer(buf)

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    assert.are.same({
      "spec/view_spec.lua",
      "lua/scrub/view.lua",
    }, lines)

    utils.extract_file_name_from_ls:revert()
  end)
end)
