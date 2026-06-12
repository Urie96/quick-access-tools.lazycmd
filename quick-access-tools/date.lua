-- Date and time related tools

local function unix_to_date(input, cb)
  input = string.gsub(input, '%s+', '')
  local len = #input

  local unix_time
  if len == 13 then
    unix_time = tonumber(input) / 1000
  elseif len == 10 then
    unix_time = tonumber(input)
  else
    error 'Invalid Unix timestamp length'
  end

  if not unix_time then error 'Invalid Unix timestamp' end

  -- Use deck.time.format to get readable date
  local readable = deck.time.format(unix_time, '%Y-%m-%d %H:%M:%S')

  -- Use deck.time.now to get current time
  local current_time = deck.time.now()
  local diff = unix_time - current_time

  local suffix
  local time_since
  if diff < 0 then
    suffix = ' ago'
    time_since = -diff
  else
    suffix = ' later'
    time_since = diff
  end

  local secs = time_since
  local mins = math.floor(secs / 60)
  local hours = math.floor(mins / 60)
  local days = math.floor(hours / 24)
  local months = math.floor(days / 30)
  local years = math.floor(days / 365)

  local since_str
  if years > 0 then
    since_str = years .. ' year'
  elseif months > 0 then
    since_str = months .. ' month'
  elseif days > 0 then
    since_str = days .. ' day'
  elseif hours > 0 then
    since_str = hours .. ' hour'
  elseif mins > 0 then
    since_str = mins .. ' minute'
  else
    since_str = secs .. ' second'
  end

  local result_str = readable .. ' - ' .. since_str .. suffix
  cb(result_str)
end

return {
  {
    key = 'unix_to_date',
    display = 'Unix Timestamp To Date',
    description = 'Convert Unix timestamp to human readable date',
    converter = unix_to_date,
  },
}
