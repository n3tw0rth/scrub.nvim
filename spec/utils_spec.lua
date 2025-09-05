local command = require("scrub.commands")
local helpers = require("scrub.helpers")
local utils   = require("scrub.utils")

local mock    = require('luassert.mock')
local stub    = require('luassert.stub')
local assert  = require('luassert.assert')

describe('utils module', function()
  local testModule = require("scrub.utils")
  local tmp_dir = "/tmp/scrub_tests"
  local save_file_path = tmp_dir .. "/scrub.lua"

  -- Setup temp directory
  before_each(function()
    os.remove(save_file_path) -- remove previous file if exists
    os.execute("mkdir -p " .. tmp_dir)
  end)

  -- Cleanup temp files
  after_each(function()
    os.remove(save_file_path)
  end)

  stub(command, "ls").returns(
    '33 %a   "lua/scrub/view.lua"           line 51\n' ..
    '5 %a   "polybar.log"                  line 1')

  stub(command, "ls_all").returns(
    '33 %a   "lua/scrub/view.lua"           line 51\n' ..
    '5 %a   "polybar.log"                  line 1')

  describe("extract_file_name_from_ls", function()
    it("extracts filename from a ls line", function()
      local line = '33 %a   "lua/scrub/view.lua"           line 51'
      local filename = testModule.extract_file_name_from_ls(line)
      assert.equals("lua/scrub/view.lua", filename)
    end)
  end)

  describe("extract_all_from_ls", function()
    it("extracts all indicators from a ls line", function()
      local line = '33 %a   "lua/scrub/view.lua"           line 51'
      local indicators = testModule.extract_all_from_ls(line)
      assert.equals(33, indicators.bufnr)
      assert.equals("%a", indicators.flags)
      assert.equals("lua/scrub/view.lua", indicators.file)
      assert.equals(51, indicators.line)
    end)
  end)

  describe("get_listed_buffers", function()
    it("returns a table of filenames", function()
      local buffers = testModule.get_listed_buffers()
      assert.same({ "lua/scrub/view.lua", "polybar.log" }, buffers)
    end)
  end)

  describe("find_buffer_from_ls and find_buffer_from_ls_by_name", function()
    it("finds buffer number by index", function()
      local bufnr = testModule.find_buffer_from_ls(1)
      assert.equals(33, bufnr)
    end)

    it("finds buffer number by name", function()
      local bufnr = testModule.find_buffer_from_ls_by_name("polybar.log")
      assert.equals(5, bufnr)
    end)
  end)

  describe("remove_last_line", function()
    it("removes last line of buffer", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "line1", "line2" })
      testModule.remove_last_line(buf)
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.same({ "line1" }, lines)
    end)
  end)

  describe("unload_buffer_if_empty", function()
    it("closes window if buffer is empty", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })

      -- stub win_close to verify call
      local closed = false
      stub(vim.api, "nvim_win_close", function(_, _)
        closed = true
      end)

      testModule.unload_buffer_if_empty(buf)
      assert.is_true(closed)
    end)
  end)

  describe("save_buffers and restore_buffers", function()
    stub(vim.fn, "getcwd").returns(tmp_dir)

    -- it("saves buffer ls output to file", function()
    --   testModule.save_buffers({ enabled = true }, save_file_path)
    --
    --   print(
    --     "debug::: testing the saved file"
    --   )
    --   local f = io.open(save_file_path, "r")
    --   local content = f:read("*a")
    --   f:close()
    --   assert.matches("33 %%a", content, 1, true)
    --   -- assert.matches("polybar.log", content, 1, true)
    -- end)

    -- it("restores buffers from saved file", function()
    --   -- first save
    --   testModule.save_buffers({ enabled = true }, save_file_path)
    --   -- stub create buffer to track calls
    --   local created_files = {}
    --   stub(vim.api, "nvim_create_buf", function(_, _)
    --     local buf = 1
    --     table.insert(created_files, buf)
    --     return buf
    --   end)
    --   stub(vim.api, "nvim_buf_set_name", function(_, name)
    --     table.insert(created_files, name)
    --   end)
    --   stub(vim.api, "nvim_buf_call", function(_, fn) fn() end)
    --
    --   testModule.restore_buffers({ enabled = true }, save_file_path)
    --   assert.equals("lua/scrub/view.lua", created_files[2])
    --   assert.equals("polybar.log", created_files[4])
    -- end)
  end)
end)
