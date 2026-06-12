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

local function show_error(err) deck.api.set_preview(nil, ('Error: ' .. tostring(err)):fg 'red') end

local function show_preview(tool, result, opt)
  tool._preview_text = result

  if opt and opt.language then
    deck.api.set_preview(nil, deck.style.highlight(result, opt.language))
  else
    deck.api.set_preview(nil, result)
  end
end

local function read_clipboard(cb)
  local ok, content = pcall(deck.clipboard.get)
  if not ok then
    show_error(content)
  elseif #content == 0 then
    show_error 'Clipboard is empty'
  else
    cb(content)
  end
end

local function write_clipboard(text)
  local ok, err = pcall(deck.clipboard.set, text)
  if ok then
    deck.notify 'Copied to clipboard'
  else
    show_error('Failed to copy to clipboard: ' .. tostring(err))
  end
  return ok, err
end

function M.setup()
  local modules = {
    'formatter',
    'date',
  }

  for _, module in ipairs(modules) do
    local tools = require('quick-access-tools.' .. module)
    deck.list_extend(all_tools, tools)
  end

  local path = { 'quick-access-tools' }

  -- Keymap: y to copy result
  deck.keymap.set('main', 'y', function()
    local entry = deck.api.get_hovered()
    if not entry or not entry.converter then return end

    if entry._preview_text ~= nil then
      write_clipboard(entry._preview_text)
    else
      show_error 'No preview result to copy; press Enter first'
    end
  end, { path = path, desc = 'copy result' })

  -- Keymap: <enter> to execute tool
  deck.keymap.set('main', '<enter>', function()
    local entry = deck.api.get_hovered()
    if not entry or not entry.converter then return end

    entry._preview_text = nil
    read_clipboard(function(content)
      local ok, err = pcall(entry.converter, content, function(result, opt, callback_err)
        if callback_err ~= nil then
          show_error(callback_err)
        else
          show_preview(entry, result, opt)
        end
      end)
      if not ok then show_error(err) end
    end)
  end, { path = path, desc = 'execute tool' })
end

function M.list(_, cb) cb(all_tools) end

function M.preview(entry, cb)
  if entry then entry._preview_text = nil end

  cb(deck.style.text {
    (entry.description or 'No description'):fg 'green',
    ' ',
    entry.converter and ('Press Enter to execute'):fg 'darkgray',
    entry.converter and ('Press y to copy result to clipboard'):fg 'darkgray',
  })
end

return M
