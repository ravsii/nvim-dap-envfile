local M = require("nvim-dap-envfile")
local path = M.expand_path_vars("${fileDirname}/tests/nvim-dap-envfile/test.env")

describe("load_env_file", function()
  it("loads basic values", function()
    local got = M.load_env_file(path)
    assert.equal(got.basic, "value")
  end)

  it("trims spaces", function()
    local got = M.load_env_file(path)
    assert.equal(got.with_spaces, "value")
  end)

  it("trims double quotes", function()
    local got = M.load_env_file(path)
    assert.equal(got.double_quotes, "value")
  end)

  it("trims spaces, then double quotes", function()
    local got = M.load_env_file(path)
    assert.equal(got.double_quotes_spaces, "value")
  end)

  it("trims single quotes", function()
    local got = M.load_env_file(path)
    assert.equal(got.single_quotes, "value")
  end)

  it("handles double escape", function()
    local got = M.load_env_file(path)
    assert.equal(got.double_escape, '"value"')
  end)

  it("handles single escape", function()
    local got = M.load_env_file(path)
    assert.equal(got.single_escape, "'value'")
  end)

  it("handles special characters", function()
    local got = M.load_env_file(path)
    assert.equal(got.double_special, '\n\t"\\')
  end)
end)
