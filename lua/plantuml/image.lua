local common = require("plantuml.common")
local config = require("plantuml.config")
local job = require("plantuml.job")

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

--- Creates a new Renderer instance.
--- @param options? image.RendererOptions The options for the renderer.
--- @return image.Renderer The new renderer instance.
function M.Renderer:new(options)
  options = config.merge({ prog = "feh", dark_mode = true }, options)

  self.__index = self
  return setmetatable({
    prog = options.prog,
    dark_mode = options.dark_mode,
    format = options.format,
    tmp_file = vim.fn.tempname(),
    started = false,
  }, self)
end

--- Renders the PlantUML file and starts the viewer.
--- @param file string The PlantUML file to render.
function M.Renderer:render(file)
  common.create_image_runner(file, self.tmp_file, self.dark_mode, self.format):run(function(_)
    self:start_viewer()
  end)
end

--- Starts the viewer if it hasn't been started already.
function M.Renderer:start_viewer()
  if not self.started then
    local cmd = string.format("%s %s", self.prog, self.tmp_file)
    job.Runner:new(cmd, {}):run(function(_)
      self.started = false
    end)
    self.started = true
  end
end

return M
