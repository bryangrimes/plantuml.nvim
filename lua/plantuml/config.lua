local M = {}

---@param dst table
---@param src? table
---@return table
function M.merge(dst, src)
  return vim.tbl_extend('force', dst, src or {})
end

return M
