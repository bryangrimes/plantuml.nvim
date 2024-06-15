local job = require('plantuml.job')

local M = {}

---@type { [number]: boolean }
local success_exit_codes = { [0] = true, [200] = true }

---@param file string
---@param tmp_file string
---@param dark_mode boolean
---@param format? string
---@return job.Runner
function M.create_image_runner(file, tmp_file, dark_mode, format)
  return job.Runner:new(
    string.format(
      'plantuml %s %s -pipe < %s > %s',
      dark_mode and '-darkmode' or '',
      format and '-t' .. format or '',
      vim.fn.shellescape(file),
      tmp_file
    ),
    success_exit_codes
  )
end

---@param file string
---@return job.Runner
function M.create_text_runner(file)
  return job.Runner:new(
    string.format(
      'plantuml -pipe -tutxt < %s',
      vim.fn.shellescape(file)
    ),
    success_exit_codes
  )
end

return M
