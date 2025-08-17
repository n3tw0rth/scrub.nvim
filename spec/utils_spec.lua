local utils = require("lua.utils")
local constants = require("lua.constants")
local assert = require("luassert")
local stub = require("luassert.stub")


describe("utils: test get_ls_lines", function()
  stub(utils, "get_ls_lines").returns({ ' 4 #h   "lua/utils.lua"                line 91\n',
    '  8  h   "spec/extract_filename_spec.lua" line 10\n' })

  assert.are.equal(4, utils.find_buffer_from_ls(1))
  assert.are.equal(8, utils.find_buffer_from_ls(2))
end)


describe("utils: test find_buffer_from_ls_by_name", function()
  stub(utils, "get_ls_all_lines").returns({
    '1u a - "NvimTree_1"                   line 1',
    '2u h - "[Scratch]"                    line 1',
    '3u     "~/projects/scrub.nvim"        line 1',
    '4  h ".editorconfig"                line 1',
    '5 #h ".luacheckrc"                  line 1',
    '6u%a   "scrub_scratch_buffer"         line 1'
  })
  assert.are.equal(6, utils.find_buffer_from_ls_by_name(constants.SCRATCH_BUFFER_NAME))
end)
