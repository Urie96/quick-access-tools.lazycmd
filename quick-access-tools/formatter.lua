-- Formatter and data conversion tools

-- Check if a command is available
local function check_has(cmd)
  if not deck.system.executable(cmd) then error(cmd .. ' not found') end
end

local tools = {
  {
    key = 'json_format',
    display = 'JSON Format',
    description = 'Format JSON with indentation',
    converter = function(input, cb)
      local decoded = deck.json.decode(input)
      local encoded = deck.json.encode(decoded, { indent = 2 })
      cb(encoded, { language = 'json' })
    end,
  },
  {
    key = 'json_minify',
    display = 'JSON Minify',
    description = 'Minify JSON (remove whitespace)',
    converter = function(input, cb)
      deck.log('info', input)
      local decoded = deck.json.decode(input)
      local encoded = deck.json.encode(decoded)
      cb(encoded, { language = 'json' })
    end,
  },
  {
    key = 'stringify',
    display = 'Stringify',
    description = 'Convert text to JSON string',
    converter = function(input, cb)
      local encoded = deck.json.encode(input:trim())
      cb(encoded)
    end,
  },
  {
    key = 'unstringify',
    display = 'Unstringify',
    description = 'Convert JSON string to text',
    converter = function(input, cb)
      local decoded = deck.json.decode(input:trim())
      cb(decoded)
    end,
  },

  {
    key = 'base64_decode',
    display = 'Base64 Decode',
    description = 'Decode Base64 string',
    converter = function(input, cb)
      local decoded = deck.base64.decode(input:trim())
      cb(decoded)
    end,
  },
  {
    key = 'base64_encode',
    display = 'Base64 Encode',
    description = 'Encode string to Base64',
    converter = function(input, cb)
      local encoded = deck.base64.encode(input:trim())
      cb(encoded)
    end,
  },
  {
    key = 'url_encode',
    display = 'URL Encode',
    description = 'URL encode string',
    converter = function(input, cb) cb(deck.url.encode(input)) end,
  },
  {
    key = 'url_decode',
    display = 'URL Decode',
    description = 'URL decode string',
    converter = function(input, cb) cb(deck.url.decode(input)) end,
  },
  {
    key = 'json_to_nix',
    display = 'Convert JSON To Nix',
    description = 'Convert JSON to Nix expression',
    converter = function(input, cb)
      check_has 'nix'
      local tmp = deck.fs.tempfile { suffix = '.json', content = input }

      local expr = 'builtins.fromJSON (builtins.readFile "' .. tmp .. '")'
      deck.system({ 'nix-instantiate', '--eval', '--expr', expr }, function(out)
        deck.fs.remove(tmp)

        if out.code == 0 then
          cb(out.stdout, { language = 'nix' })
        else
          cb(nil, nil, out.stderr)
        end
      end)
    end,
  },
  {
    key = 'yaml_to_json',
    display = 'Convert YAML To JSON',
    description = 'Convert YAML to JSON',
    converter = function(input, cb)
      local decoded = deck.yaml.decode(input)
      local json = deck.json.encode(decoded)
      cb(json, { language = 'json' })
    end,
  },
  {
    key = 'json_to_yaml',
    display = 'Convert JSON To YAML',
    description = 'Convert JSON to YAML',
    converter = function(input, cb)
      local decoded = deck.json.decode(input)
      local yaml = deck.yaml.encode(decoded)
      cb(yaml, { language = 'yaml' })
    end,
  },
}

return tools
