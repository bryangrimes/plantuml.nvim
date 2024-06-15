local common = require('plantuml.common')
local config = require('plantuml.config')
local job = require('plantuml.job')

local M = {}

---@class image.RendererOptions
---@field prog? string
---@field dark_mode? boolean
---@field format? string

---@class image.Renderer
---@field prog string
---@field dark_mode boolean
---@field format? string
---@field tmp_file string
---@field started boolean
M.Renderer = {}

---@param options? image.RendererOptions
---@return image.Renderer
function M.Renderer:new(options)
  options = config.merge({ prog = 'feh', dark_mode = true }, options)

  self.__index = self
  return setmetatable({
    prog = options.prog,
    dark_mode = options.dark_mode,
    format = options.format,
    tmp_file = vim.fn.tempname(),
    started = false,
  }, self)
end

---@param file string
---@return nil
function M.Renderer:render(file)
  common.create_image_runner(file, self.tmp_file, self.dark_mode, self.format):run(function(_)
    self:start_viewer()
  end)
end

---@private
---@return nil
function M.Renderer:start_viewer()
  -- Only start the viewer if it wasn't already started.
  if not self.started then
    local cmd = string.format('%s %s', self.prog, self.tmp_file)
    job.Runner:new(cmd, {}):run(function(_)
      self.started = false
    end)
    self.started = true
  end
end

return M
