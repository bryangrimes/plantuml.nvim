local common = require('plantuml.common')
local config = require('plantuml.config')

local M = {}

---@class text.RendererOptions
---@field split_cmd? string

---@class text.Renderer
---@field buf number
---@field win number
---@field split_cmd string
M.Renderer = {}

---@param options? text.RendererOptions
---@return text.Renderer
function M.Renderer:new(options)
  options = config.merge({ split_cmd = 'vsplit' }, options)

  local buf = vim.api.nvim_create_buf(false, true)
  assert(buf ~= 0, string.format('create buffer'))

  self.__index = self
  return setmetatable({ buf = buf, win = nil, split_cmd = options.split_cmd }, self)
end

---@param file string
---@return nil
function M.Renderer:render(file)
  common.create_text_runner(file):run(function(output)
    self:write_output(output)
    self:create_split()
  end)
end

---@private
---@param output string[]
---@return nil
function M.Renderer:write_output(output)
  vim.api.nvim_buf_set_lines(self.buf, 0, -1, true, output)
end

---@private
---@return nil
function M.Renderer:create_split()
  -- Only create the window if it wasn't already created.
  if not (self.win and vim.api.nvim_win_is_valid(self.win)) then
    vim.api.nvim_command(self.split_cmd)
    self.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(self.win, self.buf)
  end
end

return M
