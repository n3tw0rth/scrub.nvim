local utils = require("lua.utils")

describe("utils.extract_all_from_ls", function()
  it("extract all information from the :ls output line", function()
    local line = ' 4 %a   ".editorconfig"                line 5'
    local result = utils.extract_all_from_ls(line)
    assert.are.equal("4", result["buf_number"])
    assert.are.equal("5", result["line"])
    assert.are.equal(".editorconfig", result["file"])

    -- is this window active
    assert.are.equal(true, result["is_cur_window"])
  end)

  it("extract all information from the :ls output line with more additional block", function()
    local line = ' 4 %a - ".editorconfig"                line 5'
    local result = utils.extract_all_from_ls(line)
    assert.are.equal("4", result["buf_number"])
    assert.are.equal("5", result["line"])
    assert.are.equal(".editorconfig", result["file"])

    assert.are.equal(true, result["modifiable_off"])
  end)
end)
