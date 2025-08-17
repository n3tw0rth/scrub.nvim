local utils = require("lua.utils")

describe("utils.extract_all_from_ls", function()
  it("utils: extract all information from the :ls output line", function()
    local line = ' 4u%a   ".editorconfig"                line 5'
    local result = utils.extract_all_from_ls(line)
    assert.are.equal("4", result["buf_number"])
    assert.are.equal("5", result["line"])
    assert.are.equal(".editorconfig", result["file"])
  end)
end)
