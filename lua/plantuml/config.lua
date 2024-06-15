local M = {}

--- Merges two tables, extending the destination table with values from the source table.
--- @param dst table The destination table to be extended.
--- @param src? table The source table from which values are copied (optional).
--- @return table The extended destination table.
function M.merge(dst, src)
  return vim.tbl_extend("force", dst, src or {})
end

return M
