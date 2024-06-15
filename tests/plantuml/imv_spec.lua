local assert = require('luassert.assert')
local mock = require('luassert.mock')

local imv = require('plantuml.imv')
local job = require('plantuml.job')
local utils = require('tests.plantuml.utils')

describe('imv.Renderer', function()
  local test_tmp_file = 'tmp-file'

  describe('new', function()
    local vim_fn

    before_each(function()
      -- Apparently, busted/luassert cannot patch vim.fn.
      vim_fn = vim.fn
      vim.fn = { tempname = function() return test_tmp_file end }
    end)

    after_each(function()
      vim.fn = vim_fn
    end)

    it('should create the instance with default settings', function()
      local renderer = imv.Renderer:new()

      assert.equals(true, renderer.dark_mode)
      assert.equals(nil, renderer.format)
      assert.equals(test_tmp_file, renderer.tmp_file)
      assert.equals(0, renderer.pid)
    end)

    it('should create the instance with some custom settings', function()
      local renderer = imv.Renderer:new({ dark_mode = false })

      assert.equals(false, renderer.dark_mode)
      assert.equals(nil, renderer.format)
      assert.equals(test_tmp_file, renderer.tmp_file)
      assert.equals(0, renderer.pid)
    end)

    it('should create the instance with all custom settings', function()
      local renderer = imv.Renderer:new({ dark_mode = false, format = 'svg' })

      assert.equals(false, renderer.dark_mode)
      assert.equals('svg', renderer.format)
      assert.equals(test_tmp_file, renderer.tmp_file)
      assert.equals(0, renderer.pid)
    end)
  end)

  describe('render', function()
    local vim_fn
    local runner_mock
    local renderer

    before_each(function()
      -- Apparently, busted/luassert cannot patch vim.fn.
      vim_fn = vim.fn
      vim.fn = {
        tempname = function() return test_tmp_file end,
        shellescape = vim.fn.shellescape,
      }

      runner_mock = mock(job.Runner, true)
      runner_mock.new.returns(runner_mock)

      renderer = imv.Renderer:new()
    end)

    after_each(function()
      mock.revert(runner_mock)
      vim.fn = vim_fn
    end)

    ---@param expected_pid number
    ---@param call_nr? number
    ---@return nil
    local function test_render_callbacks(expected_pid, call_nr)
      local tracker = utils.CallbackTracker:new(call_nr)

      runner_mock.run.invokes(function(rmock, on_success)
        tracker:track(#rmock.run.calls, on_success)
        return 1
      end)

      renderer:render('filename')

      tracker:invoke_all()

      local plantuml_cmd = "plantuml -darkmode  -pipe < 'filename' > tmp-file"
      assert.equals(runner_mock.new.calls[2].vals[2], plantuml_cmd)
      assert.equals(expected_pid, renderer.pid)
    end

    it('should forward runner run error', function()
      local msg = 'test error'
      runner_mock.run.invokes(function() error(msg) end)
      assert.has_error(function() renderer:render('filename') end, msg)
      assert.equals(0, renderer.pid)
    end)

    it('should not reset pid when imv server callback is not ran', function()
      test_render_callbacks(1, 1)
    end)

    it('should reset pid when plantuml callback is not ran', function()
      test_render_callbacks(0, 2)
    end)

    it('should reset pid when imv close callback is not ran', function()
      test_render_callbacks(0, 3)
    end)

    it('should reset pid when imv open callback is not ran', function()
      test_render_callbacks(0, 4)
    end)

    it('should reset pid when all callbacks are ran', function()
      test_render_callbacks(0)
    end)
  end)
end)
