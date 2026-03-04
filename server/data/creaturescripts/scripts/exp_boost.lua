local EXPBOOST_STOR_REMAIN = 92020
local EXPBOOST_STOR_LAST   = 92021
local MULT = 2
local TICK_MS = 30000

local function fmtRemaining(seconds)
  if seconds < 0 then seconds = 0 end
  local d = math.floor(seconds / 86400); seconds = seconds % 86400
  local h = math.floor(seconds / 3600);  seconds = seconds % 3600
  local m = math.floor(seconds / 60)
  local s = seconds % 60
  local parts = {}
  if d > 0 then table.insert(parts, d .. (d==1 and " dia" or " dias")) end
  if h > 0 then table.insert(parts, h .. (h==1 and " hora" or " horas")) end
  if m > 0 then table.insert(parts, m .. (m==1 and " minuto" or " minutos")) end
  if s > 0 and d == 0 then table.insert(parts, s .. (s==1 and " segundo" or " segundos")) end
  if #parts == 0 then return "menos de 1 segundo" end
  return table.concat(parts, ", ")
end

function expBoostGetRemaining(cid)
  local r = getPlayerStorageValue(cid, EXPBOOST_STOR_REMAIN)
  if r == -1 then r = 0 end
  return r
end
function expBoostPrettyRemaining(cid) return fmtRemaining(expBoostGetRemaining(cid)) end
function expBoostIsActive(cid) return expBoostGetRemaining(cid) > 0 end
function expBoostMult() return MULT end

local function expBoostTick(cid)
  if not isPlayer(cid) then return end
  local now    = os.time()
  local last   = getPlayerStorageValue(cid, EXPBOOST_STOR_LAST)
  local remain = expBoostGetRemaining(cid)
  if last == -1 then last = now end

  local elapsed = math.max(0, now - last)
  if remain > 0 and elapsed > 0 then
    remain = math.max(0, remain - elapsed)
    setPlayerStorageValue(cid, EXPBOOST_STOR_REMAIN, remain)
  end
  setPlayerStorageValue(cid, EXPBOOST_STOR_LAST, now)

  if remain > 0 then addEvent(expBoostTick, TICK_MS, cid) end
end

function onLogin(cid)
  setPlayerStorageValue(cid, EXPBOOST_STOR_LAST, os.time())
  if expBoostIsActive(cid) then
    addEvent(expBoostTick, 1000, cid)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
      "Voce tem um Exp Boost ativo por " .. expBoostPrettyRemaining(cid) .. ".")
  end
  registerCreatureEvent(cid, "ExpBoostLogout")
  return true
end

function onLogout(cid)
  local now    = os.time()
  local last   = getPlayerStorageValue(cid, EXPBOOST_STOR_LAST)
  local remain = expBoostGetRemaining(cid)
  if last ~= -1 and remain > 0 then
    local elapsed = math.max(0, now - last)
    remain = math.max(0, remain - elapsed)
    setPlayerStorageValue(cid, EXPBOOST_STOR_REMAIN, remain)
  end
  setPlayerStorageValue(cid, EXPBOOST_STOR_LAST, -1)
  return true
end
