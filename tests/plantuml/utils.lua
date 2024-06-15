local M = {}

---@class utils.CallbackTracker
---@field callbacks thread[]
---@field ignore_call_nr? number
M.CallbackTracker = {}

---@param ignore_call_nr? number
---@return utils.CallbackTracker
function M.CallbackTracker:new(ignore_call_nr)
  self.__index = self
  return setmetatable({
    callbacks = {},
    ignore_call_nr = ignore_call_nr or 0,
  }, self)
end

---@param call_nr number
---@param callback function
---@return nil
function M.CallbackTracker:track(call_nr, callback)
  -- Simulate failure by not running the specified callback.
  if call_nr ~= self.ignore_call_nr then
    -- Defer the callback's execution by putting it into a coroutines array.
    table.insert(self.callbacks, coroutine.create(callback))
  end
end

---@return nil
function M.CallbackTracker:invoke_all()
  for _, callback in ipairs(self.callbacks) do
    coroutine.resume(callback)
  end
end

return M
