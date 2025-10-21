local M = require("nvim-dap-envfile")

describe("eval_vars()", function()
  before_each(function()
    vim.fn = {
      expand = function(expr)
        local map = {
          ["%:p"] = "/home/user/project/file.lua",
          ["%:t"] = "file.lua",
          ["%:p:h"] = "/home/user/project",
          ["%:e"] = "lua",
          ["%:."] = "file.lua",
          ["%:.:h"] = ".",
        }
        return map[expr]
      end,
      fnamemodify = function(path, mod)
        if mod == ":r" then
          return path:gsub("%.lua$", "")
        elseif mod == ":t" then
          return "project"
        else
          return path
        end
      end,
      getcwd = function()
        return "/home/user/project"
      end,
    }
    os.getenv = function(_)
      return "test"
    end
  end)

  it("replaces ${fileBasename}", function()
    local result = M.eval_vars("File: ${fileBasename}")
    assert.are.equal("File: file.lua", result)
  end)

  it("replaces ${fileBasenameNoExtension}", function()
    local result = M.eval_vars("Name: ${fileBasenameNoExtension}")
    assert.are.equal("Name: file", result)
  end)

  it("replaces ${workspaceFolderBasename}", function()
    local result = M.eval_vars("Project: ${workspaceFolderBasename}")
    assert.are.equal("Project: project", result)
  end)

  it("replaces ${env:TEST_ENV}", function()
    local result = M.eval_vars("${env:TEST_ENV}")
    assert.are.equal("test", result)
  end)

  it("handles multiple replacements", function()
    local input = "Dir: ${workspaceFolder}, File: ${fileBasename}"
    local expected = "Dir: /home/user/project, File: file.lua"
    assert.are.equal(expected, M.eval_vars(input))
  end)

  it("returns same string if no variables", function()
    local input = "no variables here"
    assert.are.equal(input, M.eval_vars(input))
  end)
end)
