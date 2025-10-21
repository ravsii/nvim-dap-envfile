local notify_opts = {
  title = "nvim-dap-envfile",
  icon = "",
}
local __plugin = "dap_envfile"

--- props to
--- https://github.com/mfussenegger/nvim-dap/blob/6782b097af2417a4c3e33849b0a26ae2188bd7ea/lua/dap.lua#L350
local replacements = {
  ["${file}"] = function(_)
    return vim.fn.expand("%:p")
  end,
  ["${fileBasename}"] = function(_)
    return vim.fn.expand("%:t")
  end,
  ["${fileBasenameNoExtension}"] = function(_)
    return vim.fn.fnamemodify(vim.fn.expand("%:t"), ":r")
  end,
  ["${fileDirname}"] = function(_)
    return vim.fn.expand("%:p:h")
  end,
  ["${fileExtname}"] = function(_)
    return vim.fn.expand("%:e")
  end,
  ["${relativeFile}"] = function(_)
    return vim.fn.expand("%:.")
  end,
  ["${relativeFileDirname}"] = function(_)
    return vim.fn.fnamemodify(vim.fn.expand("%:.:h"), ":r")
  end,
  ["${workspaceFolder}"] = function(_)
    return vim.fn.getcwd()
  end,
  ["${workspaceFolderBasename}"] = function(_)
    return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  end,
  ["${env:([%w_]+)}"] = function(match)
    return os.getenv(match) or ""
  end,
}

---@class Config
local default_config = {
  ---Automatically adds a dap on_config listener.
  ---@type boolean?
  add_dap_listener = true,
  ---Print additional debug messages. Useful to check what your inputs are
  ---evaluating to.
  ---@type boolean?
  debug = false,
}

local M = {
  config = default_config,
}

---@param str string
---@return string str String with evaluated variables (if any)
function M.eval_vars(str)
  for pattern, replace_fn in pairs(replacements) do
    str = str:gsub(pattern, replace_fn)
  end

  return str
end

---@param path string Path for .env file. Variables like ${file} are
--- automatically evaluated.
---@return table env Table with env values, read from path.
function M.load_env_file(path)
  local env = {}
  local file = io.open(path, "r")
  if not file then
    return env
  end

  for line in file:lines() do
    local key, value = line:match("^%s*([%w_]+)%s*=%s*(.+)%s*$")
    if key and value then
      -- remove quotes
      env[key] = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
    end
  end

  file:close()
  return env
end

---@param opts Config
function M.setup(opts)
  local ok, dap = pcall(require, "dap")
  if not ok then
    vim.notify("dap not found", vim.log.levels.ERROR, notify_opts)
    return
  end

  M.config = vim.tbl_deep_extend("force", M.config, opts)

  if M.config.add_dap_listener then
    dap.listeners.on_config[__plugin] = function(original_config)
      local config = vim.deepcopy(original_config)

      if config.envFile then
        local path = M.eval_vars(config.envFile)
        if M.config.debug then
          vim.print("env path: " .. path)
        end

        if vim.fn.filereadable(path) == 1 then
          local env_vars = M.load_env_file(path)
          if M.config.debug then
            vim.print("envs: " .. env_vars)
          end

          config.env = vim.tbl_extend("force", config.env or {}, env_vars)
        else
          vim.notify("No .env file found: " .. path, vim.log.levels.WARN, notify_opts)
        end
      end

      return config
    end
  end
end

return M
