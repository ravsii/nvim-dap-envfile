local M = {}

--- Splits a string into two parts at the first occurrence of a separator.
---
--- @param str string The input string to split.
--- @param sep string The separator to split on, plain text.
--- @return string left The part before the first separator
--- @return string|nil right The part after the first separator, or nil if not found.
function M.str_split_once(str, sep)
  local pos = string.find(str, sep, 1, true) -- plain search
  if not pos then
    return str, nil
  end
  return str:sub(1, pos - 1), str:sub(pos + #sep)
end

---@param str string String in double quotes to parse.
---@return string
function M.parse_double(str)
  if not vim.startswith(str, '"') or not vim.endswith(str, '"') then
    return str
  end

  str = vim.fn.strcharpart(str, 1, #str - 2)
  str = str:gsub('\\"', '"'):gsub("\\n", "\n"):gsub("\\\\", "\\"):gsub("\\t", "\t")

  return str
end

---@param str string String in single quotes to parse.
---@return string
function M.parse_single(str)
  if not vim.startswith(str, "'") or not vim.endswith(str, "'") then
    return str
  end

  str = vim.fn.strcharpart(str, 1, #str - 2)
  str = str:gsub("\\'", "'")

  return str
end

return M
