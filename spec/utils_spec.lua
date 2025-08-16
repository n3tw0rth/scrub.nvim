local utils = require("lua.utils")
local assert = require("luassert")
local stub = require("luassert.stub")


describe("utils: test get_ls_lines", function()
  stub(utils, "get_ls_lines").returns({ ' 4 #h   "lua/utils.lua"                line 91\n',
    '  8  h   "spec/extract_filename_spec.lua" line 10\n' })

  assert.are.equal(4, utils.find_buffer_from_ls(1))
  assert.are.equal(8, utils.find_buffer_from_ls(2))
end)
