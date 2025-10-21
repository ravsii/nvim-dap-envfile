# nvim-dap-envfile

A lightweight helper for
[**nvim-dap**](https://github.com/mfussenegger/nvim-dap) that automatically
loads `.env` files into your DAP configuration - with support for VSCode -
style variable expansion like `${workspaceFolder}`, and `${env:HOME}`.

Handling of the `envFile` field is, apparently, VS Code-specific. nvim-dap
[doesn't support it by default](https://github.com/mfussenegger/nvim-dap/discussions/548),
so this plugin provides that functionality. It’s simple but removes the need to
repeat the same code across multiple projects.

## 📦 Installation

### Requirements

- Neovim >= `10.4`
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "ravsii/nvim-dap-envfile",
  dependencies = { "mfussenegger/nvim-dap" },
  opts = {},
}
```

## ⚙️ Configuration

Default configuration, for reference:

```lua
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
```

You can disable adding dap listener on startup, if you want to handle it
manually.

## 🧩 Examples

### Using `envFile`

Your project-local `.nvim.lua` or any other per-project configuration file.

```lua
local dap = require("dap")

table.insert(dap.configurations.go, {
  name = "some project",
  type = "go",
  request = "launch",
  timeout = 10000,
  outputMode = "remote",
  program = "main.go",
  envFile = "${workspaceFolder}/.env", -- will be read, parsed, and passed as "env" table.
})
```

### Using manual parsing

```lua
local dap = require("dap")
local envfile = require("nvim-dap-envfile")

table.insert(dap.configurations.go, {
  name = "some project",
  type = "go",
  request = "launch",
  program = "main.go",
  env = envfile.load_env_file("${workspaceFolder}/.env"),
})
```

## 🔧 API Reference

In case you don't want to use built-in dap listener (or you want to build a
custom one), you can still use our helper functions

```lua
local envfile = require("nvim-dap-envfile")
```

### `envfile.eval_vars(str: string) -> string`

Expands VS Code–style variables inside a string. For available variables see
below.

```lua
local resolved = envfile.eval_vars("${workspaceFolder}/.env")
-- e.g. "/home/user/project/.env"
```

### `envfile.load_env_file(path: string) -> table`

Parses a `.env` file and returns a Lua table of key/value pairs. Path is
evaluated using `eval_vars`.

```lua
local env = envfile.load_env_file("${workspaceFolder}/.env")
vim.print(env)
-- { DB_HOST = "localhost", PORT = "8080" }
```

Quotes around values (`"foo"` or `'foo'`) are stripped automatically.

### Variable Expansion

| Variable                     | Example Result               |
| ---------------------------- | ---------------------------- |
| `${file}`                    | `/home/user/project/main.go` |
| `${fileBasename}`            | `main.go`                    |
| `${fileBasenameNoExtension}` | `main`                       |
| `${fileDirname}`             | `/home/user/project`         |
| `${fileExtname}`             | `go`                         |
| `${relativeFile}`            | `main.go`                    |
| `${relativeFileDirname}`     | `.`                          |
| `${workspaceFolder}`         | `/home/user/project`         |
| `${workspaceFolderBasename}` | `project`                    |
| `${env:HOME}`                | `/home/user`                 |
