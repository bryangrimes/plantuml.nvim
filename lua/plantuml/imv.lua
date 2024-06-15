local common = require("plantuml.common")
local config = require("plantuml.config")
local job = require("plantuml.job")

local M = {}

---@class imv.RendererOptions
---@field dark_mode? boolean
---@field format? string

---@class imv.Renderer
---@field dark_mode boolean
---@field format? string
---@field tmp_file string
---@field pid number
M.Renderer = {}

--- Creates a new Renderer instance.
--- @param options? imv.RendererOptions The options for the renderer.
--- @return imv.Renderer The new renderer instance.
function M.Renderer:new(options)
  options = config.merge({ dark_mode = true }, options)

  self.__index = self
  return setmetatable({
    dark_mode = options.dark_mode,
    format = options.format,
    tmp_file = vim.fn.tempname(),
    pid = 0,
  }, self)
end

--- Renders the PlantUML file and refreshes the image in imv.
--- @param file string The PlantUML file to render.
function M.Renderer:render(file)
  self:start_server()
  self:refresh_image(file)
end

--- Starts the imv server if it hasn't been started already.
function M.Renderer:start_server()
  if self.pid == 0 then
    self.pid = job.Runner:new("imv", {}):run(function(_)
      self.pid = 0
    end)
  end
end

--- Refreshes the image in imv by generating a new image and sending commands to imv.
--- @param file string The PlantUML file to refresh the image from.
function M.Renderer:refresh_image(file)
  common.create_image_runner(file, self.tmp_file, self.dark_mode, self.format):run(function(_)
    local imv_close_cmd = string.format("imv-msg %d close all", self.pid)
    job.Runner:new(imv_close_cmd):run(function(_)
      local imv_open_cmd = string.format("imv-msg %d open %s", self.pid, self.tmp_file)
      job.Runner:new(imv_open_cmd):run()
    end)
  end)
end

return M
