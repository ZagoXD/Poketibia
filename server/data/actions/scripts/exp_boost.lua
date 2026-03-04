local ITEMID_EXP_BOOST     = 14154
local EXPBOOST_STOR_REMAIN = 92020
local EXPBOOST_STOR_LAST   = 92021
local DURATION_SECONDS     = 2 * 24 * 60 * 60

local EFFECT_USE = CONST_ME_MAGIC_GREEN

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

function onUse(cid, item, fromPosition, itemEx, toPosition)
  if item.itemid ~= ITEMID_EXP_BOOST then return false end

  local now    = os.time()
  local remain = getPlayerStorageValue(cid, EXPBOOST_STOR_REMAIN); if remain == -1 then remain = 0 end
  remain = remain + DURATION_SECONDS

  setPlayerStorageValue(cid, EXPBOOST_STOR_REMAIN, remain)
  setPlayerStorageValue(cid, EXPBOOST_STOR_LAST,   now)

  doSendMagicEffect(getThingPos(cid), EFFECT_USE)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
    "Exp Boost ativado! XP em dobro por " .. fmtRemaining(remain) .. ".")

  doRemoveItem(item.uid, 1)
  return true
end
