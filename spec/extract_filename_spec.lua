local utils = require("lua.utils")

describe("utils.extract_file_name", function()
  it("extract the name from the :ls output line", function()
    assert.are.equal(".editorconfig", utils.extract_file_name_from_ls(' 4 %a   ".editorconfig"                line 1'))
  end)

  it("extract the name from the :ls output line", function()
    assert.are_not.equal("wrongfilename",
      utils.extract_file_name_from_ls(' 4 %a   ".editorconfig"                line 1'))
  end)
end)
