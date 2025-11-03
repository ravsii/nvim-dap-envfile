local M = require("nvim-dap-envfile")

describe("set_neovim_env", function()
  local original_env = {}

  before_each(function()
    -- Backup and clear test vars
    original_env.TEST_VAR1 = vim.env.TEST_VAR1
    original_env.TEST_VAR2 = vim.env.TEST_VAR2
    vim.env.TEST_VAR1 = nil
    vim.env.TEST_VAR2 = nil
  end)

  after_each(function()
    -- Restore environment
    vim.env.TEST_VAR1 = original_env.TEST_VAR1
    vim.env.TEST_VAR2 = original_env.TEST_VAR2
  end)

  it("sets environment variables in vim.env", function()
    local envs = {
      TEST_VAR1 = "hello",
      TEST_VAR2 = "world",
    }

    M.set_neovim_env(envs)

    assert.equal("hello", vim.env.TEST_VAR1)
    assert.equal("world", vim.env.TEST_VAR2)
  end)

  it("works with os.getenv", function()
    local envs = {
      TEST_VAR1 = "hello",
      TEST_VAR2 = "world",
    }

    M.set_neovim_env(envs)

    assert.equal("hello", os.getenv("TEST_VAR1"))
    assert.equal("world", os.getenv("TEST_VAR2"))
  end)

  it("overwrites existing environment variables", function()
    vim.env.TEST_VAR1 = "old"
    local envs = { TEST_VAR1 = "new" }

    M.set_neovim_env(envs)

    assert.equal("new", vim.env.TEST_VAR1)
  end)
end)
