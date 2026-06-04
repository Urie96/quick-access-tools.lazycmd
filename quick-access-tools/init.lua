-- t: A lazydeck plugin for text transformations and utilities

local M = {}

function M.meta()
  return {
    icon = '󰆧',
    desc = 'Quick text and utility tools',
    color = 'yellow',
  }
end

local all_tools = {}

function M.setup()
  local modules = {
    'quick-access-tools.formatter',
    'quick-access-tools.date',
  }

  for _, module in ipairs(modules) do
    local tools = require(module)
    deck.list_extend(all_tools, tools)
  end

  local path = { 'quick-access-tools' }

  -- Keymap: y to copy result
  deck.keymap.set('main', 'y', function()
    local entry = deck.api.get_hovered()
    if entry and entry.on_copy then entry.on_copy(entry) end
  end, { path = path, desc = 'copy result' })

  -- Keymap: <enter> to execute tool
  deck.keymap.set('main', '<enter>', function()
    local entry = deck.api.get_hovered()
    if entry and entry.on_enter then entry.on_enter() end
  end, { path = path, desc = 'execute tool' })
end

function M.list(_, cb) cb(all_tools) end

function M.preview(entry, cb)
  cb(deck.style.text {
    (entry.description or 'No description'):fg 'green',
    ' ',
    entry.on_enter and ('Press Enter to execute'):fg 'darkgray',
    entry.on_copy and ('Press y to copy result to clipboard'):fg 'darkgray',
  })
end

return M
