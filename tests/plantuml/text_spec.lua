local assert = require('luassert.assert')
local mock = require('luassert.mock')

local job = require('plantuml.job')
local text = require('plantuml.text')

describe('text.Renderer', function()
  local test_buf = 1
  local test_win = 2
  local test_lines = { 'data' }

  describe('new', function()
    local vim_api_mock

    before_each(function()
      vim_api_mock = mock(vim.api, true)
      vim_api_mock.nvim_create_buf.returns(test_buf)
    end)

    after_each(function()
      mock.revert(vim_api_mock)
    end)

    it('should create the instance with default settings', function()
      local renderer = text.Renderer:new()

      assert.equals(1, renderer.buf)
      assert.equals(nil, renderer.win)
      assert.equals('vsplit', renderer.split_cmd)
    end)

    it('should create the instance with custom settings', function()
      local renderer = text.Renderer:new({ split_cmd = 'split' })

      assert.equals(1, renderer.buf)
      assert.equals(nil, renderer.win)
      assert.equals('split', renderer.split_cmd)
    end)
  end)

  describe('render', function()
    local error_msg = 'test error'
    local plantuml_cmd = "plantuml -pipe -tutxt < 'filename'"

    local runner_mock
    local vim_api_mock
    local renderer

    before_each(function()
      runner_mock = mock(job.Runner, true)
      runner_mock.new.returns(runner_mock)

      vim_api_mock = mock(vim.api, true)
      vim_api_mock.nvim_create_buf.returns(test_buf)

      renderer = text.Renderer:new()
    end)

    after_each(function()
      mock.revert(runner_mock)
      mock.revert(vim_api_mock)
    end)

    it('should forward plantuml run error', function()
      runner_mock.run.invokes(function(_, _) error(error_msg) end)

      assert.has_error(function() renderer:render('filename') end, error_msg)
      assert.equals(runner_mock.new.calls[1].vals[2], plantuml_cmd)
    end)

    it('should forward invalid split command error', function()
      runner_mock.run.invokes(function(_, on_success) on_success(test_lines) end)
      vim_api_mock.nvim_get_current_win.returns(test_win)
      vim_api_mock.nvim_command.invokes(function(_) error(error_msg) end)

      assert.has_error(function() renderer:render('filename') end, error_msg)
      assert.equals(runner_mock.new.calls[1].vals[2], plantuml_cmd)
    end)

    it('should render succesfully', function()
      runner_mock.run.invokes(function(_, on_success) on_success(test_lines) end)
      vim_api_mock.nvim_get_current_win.returns(test_win)

      renderer:render('filename')

      assert.equals(runner_mock.new.calls[1].vals[2], plantuml_cmd)

      assert
        .stub(vim_api_mock.nvim_buf_set_lines)
        .was_called_with(test_buf, 0, -1, true, test_lines)

      assert.stub(vim_api_mock.nvim_command).was_called_with(renderer.split_cmd)
      assert.equals(test_win, renderer.win)
      assert.stub(vim_api_mock.nvim_win_set_buf).was_called_with(test_win, test_buf)
    end)

    it('should render twice succesfully', function()
      runner_mock.run.invokes(function(_, on_success) on_success(test_lines) end)
      vim_api_mock.nvim_win_is_valid.returns(true)
      vim_api_mock.nvim_get_current_win.returns(test_win)

      renderer:render('filename')
      renderer:render('filename')

      assert.equals(runner_mock.new.calls[1].vals[2], plantuml_cmd)
      assert.equals(runner_mock.new.calls[2].vals[2], plantuml_cmd)

      assert
        .stub(vim_api_mock.nvim_buf_set_lines)
        .was_called_with(test_buf, 0, -1, true, test_lines)

      assert.stub(vim_api_mock.nvim_win_is_valid).was_called_with(test_win)
      assert.stub(vim_api_mock.nvim_command).was_called_with(renderer.split_cmd)
      assert.equals(test_win, renderer.win)
      assert.stub(vim_api_mock.nvim_win_set_buf).was_called_with(test_win, test_buf)
    end)
  end)
end)
