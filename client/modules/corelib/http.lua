HTTP = HTTP or {}

local function parseStatusAndHeaders(rawHeader)
  local status = tonumber(rawHeader:match("^HTTP/%d%.%d%s+(%d+)")) or 0
  local headers = {}

  for line in rawHeader:gmatch("([^\r\n]+)\r\n") do
    local k, v = line:match("^([^:]+):%s*(.*)$")
    if k and v then
      headers[k:lower()] = v
    end
  end

  return status, headers
end

function HTTP.postJSON(url, payload, cb)
  local host, port, path = url:match("^http://([^/:]+):?(%d*)(/.*)$")
  if not host then
    cb(nil, "URL invalida: " .. tostring(url))
    return
  end
  port = tonumber(port) or 80
  path = path or "/"

  local body = json.encode(payload)
  local req =
    "POST " .. path .. " HTTP/1.1\r\n" ..
    "Host: " .. host .. "\r\n" ..
    "Content-Type: application/json\r\n" ..
    "Accept: application/json\r\n" ..
    "Content-Length: " .. tostring(#body) .. "\r\n" ..
    "Connection: close\r\n" ..
    "\r\n" ..
    body

  local proto = ProtocolHttp.create()

  local state = {
    headerBuf = "",
    headerDone = false,
    status = 0,
    headers = {},
    bodyBuf = "",
    contentLength = nil,
    done = false,
  }

  local function finish(obj, err)
    if state.done then return end
    state.done = true
    proto:disconnect()
    cb(obj, err, state.status)
  end

  local function tryDecodeAndFinish()
    if not state.bodyBuf or #state.bodyBuf == 0 then
      finish(nil, "Resposta vazia do servidor.")
      return
    end

    local obj, derr = json.decode(state.bodyBuf)
    if obj then
      finish(obj, nil)
    else
      finish(nil, "Falha ao decodificar JSON: " .. tostring(derr or "") .. "\nBody: " .. tostring(state.bodyBuf))
    end
  end

  local function maybeCompleteOrReadMore()
    if state.contentLength ~= nil then
      if #state.bodyBuf >= state.contentLength then
        state.bodyBuf = state.bodyBuf:sub(1, state.contentLength)
        tryDecodeAndFinish()
        return
      end
      proto:recv()
      return
    end

    proto:recv()
  end

  proto.onConnect = function()
    proto:send(req)
    proto:recv()
  end

  proto.onRecv = function(_, chunk)
    if state.done then return end

    if not state.headerDone then
      state.headerBuf = state.headerBuf .. chunk
      local headerPart, rest = state.headerBuf:match("^(.-\r\n\r\n)(.*)$")
      if not headerPart then
        proto:recv()
        return
      end

      state.headerDone = true
      state.status, state.headers = parseStatusAndHeaders(headerPart)

      if state.headers["transfer-encoding"] and state.headers["transfer-encoding"]:lower():find("chunked") then
        finish(nil, "Resposta HTTP chunked nao suportada (desative chunked / use Content-Length).")
        return
      end

      local cl = tonumber(state.headers["content-length"] or "")
      state.contentLength = cl
      if rest and #rest > 0 then
        state.bodyBuf = state.bodyBuf .. rest
      end

      maybeCompleteOrReadMore()
      return
    end

    state.bodyBuf = state.bodyBuf .. chunk
    maybeCompleteOrReadMore()
  end

  proto.onError = function(_, a, b)
    if state.done then return end

    local code, message
    if type(a) == "string" and type(b) == "number" then
      message, code = a, b
    elseif type(a) == "number" and type(b) == "string" then
      code, message = a, b
    else
      message = tostring(a or "")
      code = tonumber(b) or tonumber(a) or 0
    end

    local msgLower = tostring(message or ""):lower()
    local isEof = (code == 2) or msgLower:find("end of file", 1, true)

    if isEof and state.headerDone then
      if state.contentLength ~= nil and #state.bodyBuf < state.contentLength then
        tryDecodeAndFinish()
        return
      end

      tryDecodeAndFinish()
      return
    end

    finish(nil, (message or "HTTP error") .. (code and (" (" .. tostring(code) .. ")") or ""))
  end

  proto:connect(host, port)
end

return HTTP
