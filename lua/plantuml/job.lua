local M = {}

---@class job.Runner
---@field cmd string
---@field exit_codes { [number]: boolean }
M.Runner = {}

--- Creates a new Runner instance.
--- @param cmd string The command to run.
--- @param exit_codes? { [number]: boolean } The acceptable exit codes (optional).
--- @return job.Runner The new runner instance.
function M.Runner:new(cmd, exit_codes)
  self.__index = self
  return setmetatable({ cmd = cmd, exit_codes = exit_codes or { [0] = true } }, self)
end

--- Runs the command and handles the output and exit status.
--- @param on_success? fun(stdout: string[]): nil The callback function to handle success (optional).
--- @return number The PID of the started job.
function M.Runner:run(on_success)
  local stderr
  local stdout

  local id = vim.fn.jobstart(self.cmd, {
    detach = true,
    on_exit = function(_, code, _)
      if next(self.exit_codes) ~= nil and not self.exit_codes[code] then
        local msg = table.concat(stderr)
        error(string.format('exit job for command "%s"\n%s\ncode: %d', self.cmd, msg, code))
      end

      if on_success then
        on_success(stdout)
      end
    end,
    on_stderr = function(_, data, _)
      stderr = data
    end,
    on_stdout = function(_, data, _)
      stdout = data
    end,
    stderr_buffered = true,
    stdout_buffered = true,
  })
  assert(id > 0, string.format('start job for command "%s"', self.cmd))

  return vim.fn.jobpid(id)
end

return M
