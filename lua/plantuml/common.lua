local job = require("plantuml.job")

local M = {}

---@type { [number]: boolean }
local success_exit_codes = { [0] = true, [200] = true }

--- Creates a job runner to generate an image from a PlantUML file.
--- @param file string The source PlantUML file.
--- @param tmp_file string The temporary output file.
--- @param dark_mode boolean Whether to enable dark mode.
--- @param format? string The output format (optional).
--- @return job.Runner The job runner for generating the image.
function M.create_image_runner(file, tmp_file, dark_mode, format)
  local command = string.format(
    "plantuml %s %s -pipe < %s > %s",
    dark_mode and "-darkmode" or "",
    format and "-t" .. format or "",
    vim.fn.shellescape(file),
    tmp_file
  )
  return job.Runner:new(command, success_exit_codes)
end

--- Creates a job runner to generate a text diagram from a PlantUML file.
--- @param file string The source PlantUML file.
--- @return job.Runner The job runner for generating the text diagram.
function M.create_text_runner(file)
  local command = string.format("plantuml -pipe -tutxt < %s", vim.fn.shellescape(file))
  return job.Runner:new(command, success_exit_codes)
end

return M
