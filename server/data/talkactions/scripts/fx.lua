local function intval(x, default)
  x = tonumber(x)
  if not x then return default end
  return math.max(0, math.floor(x))
end

local function playFxTimes(pos, effectId, times, delay)
  local function tick(left)
    if left <= 0 then return end
    doSendMagicEffect(pos, effectId)
    if left > 1 then
      addEvent(tick, delay, left - 1)
    end
  end
  tick(times)
end

function onSay(cid, words, param, channel)
  local parts = {}
  for w in tostring(param or ""):gmatch("%S+") do table.insert(parts, w) end

  if words == "/fx" then
    local id      = tonumber(parts[1] or "")
    local vezes   = intval(parts[2], 1)
    local delayms = intval(parts[3], 150)

    if not id then
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Uso: /fx <id> [vezes] [intervalo_ms]")
      return true
    end

    local pos = getThingPos(cid)
    playFxTimes(pos, id, math.max(1, vezes), math.max(1, delayms))
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
      string.format("FX %d enviado em (%d,%d,%d) x%d a cada %dms.",
        id, pos.x, pos.y, pos.z, math.max(1, vezes), math.max(1, delayms)))
    return true
  end

  if words == "/fxsum" then
    local id = tonumber(parts[1] or "")
    if not id then
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Uso: /fxsum <id>")
      return true
    end

    local sums = getCreatureSummons(cid)
    if #sums == 0 then
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você não tem summons no momento.")
      return true
    end

    for _, s in ipairs(sums) do
      doSendMagicEffect(getThingPos(s), id)
    end

    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
      string.format("FX %d enviado em %d summon(s).", id, #sums))
    return true
  end

  return true
end
