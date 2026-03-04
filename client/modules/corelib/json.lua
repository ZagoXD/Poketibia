local dkjson = dkjson or dofile('dkjson')

json = json or {}

function json.encode(t)
  return dkjson.encode(t)
end

function json.decode(s)
  local obj, pos, err = dkjson.decode(s, 1, nil)
  if err then return nil, err end
  return obj
end

return json
