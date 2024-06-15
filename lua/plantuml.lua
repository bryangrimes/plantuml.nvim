local image = require('plantuml.image')
local imv = require('plantuml.imv')
local merge_config = require('plantuml.config').merge
local text = require('plantuml.text')

local M = {}

local file_extensions = {
  'iuml',
  'plantuml',
  'pu',
  'puml',
  'wsd',
}

---@class plantuml.Options
---@field renderer? plantuml.RendererOptions
---@field render_on_write? boolean

---@class plantuml.RendererOptions
---@field type? string
---@field options? text.RendererOptions|image.RendererOptions|imv.RendererOptions

---@alias plantuml.Renderer { render: fun(file: string): nil }

---@param renderer plantuml.Renderer
---@param file string
---@return nil
local function render_file(renderer, file)
  local status, result = pcall(renderer.render, renderer, file)
  if not status then
    print(string.format('[plantuml.nvim] Failed to render file "%s"\n%s', file, result))
  end
end

---@param renderer_config table
---@return plantuml.Renderer?
local function create_renderer(renderer_config)
  local type = renderer_config.type
  local options = renderer_config.options

  local renderer
  if type == 'text' then
    renderer = text.Renderer:new(options)
  elseif type == 'image' then
    renderer = image.Renderer:new(options)
  elseif type == 'imv' then
    renderer = imv.Renderer:new(options)
  else
    print(string.format('[plantuml.nvim] Invalid renderer type "%s"', type))
  end

  return renderer
end

---@param renderer plantuml.Renderer
---@return nil
local function create_user_command(renderer)
  vim.api.nvim_create_user_command('PlantUML', function(_)
    local file = vim.api.nvim_buf_get_name(0)

    for _, ext in ipairs(file_extensions) do
      if file:find(string.format('^(.+).%s$', ext)) then
        render_file(renderer, file)
        break
      end
    end
  end, {})
end

---@param group number
---@param renderer plantuml.Renderer
---@return nil
local function create_autocmd(group, renderer)
  local pattern = {}
  for _, ext in ipairs(file_extensions) do
    table.insert(pattern, '*' .. ext)
  end

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    pattern = pattern,
    callback = function(args)
      render_file(renderer, args.file)
    end,
  })
end

---@param config? plantuml.Options
---@return nil
function M.setup(config)
  local default_config = {
    renderer = { type = 'text' },
    render_on_write = true,
  }

  config = merge_config(default_config, config)

  local renderer = create_renderer(config.renderer)
  if renderer then
    create_user_command(renderer)

    if config.render_on_write then
      local group = vim.api.nvim_create_augroup('PlantUMLGroup', {})
      create_autocmd(group, renderer)
    end
  end
end

return M
