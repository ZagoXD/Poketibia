dofile('data/lib/mega_config.lua')

local function msg(cid, t) doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, t) end

local MIN_MEGA_LEVEL = 150

function onSay(cid, words, param)
  if not isCreature(cid) then return true end

  if getPlayerLevel(cid) < MIN_MEGA_LEVEL then
    msg(cid, "Voce precisa ser nivel " .. MIN_MEGA_LEVEL .. " ou superior para usar Mega Evolucao.")
    return true
  end

  local summon = getCreatureSummons(cid)[1]
  if not summon then
    msg(cid, "Voce precisa ter seu Pokemon invocado.")
    return true
  end

  local ball = getPlayerSlotItem(cid, 8)
  if not ball or ball.uid <= 0 then
    msg(cid, "Coloque a pokebola no slot 8 (ball slot).")
    return true
  end

  if not megaIsEligible(summon, ball) then
    msg(cid, "Este Pokemon nao está elegivel para mega evoluir.")
    return true
  end

  local active = tonumber(getItemAttribute(ball.uid, "mega_active") or 0) or 0

  if active == 0 then
    if getPlayerLevel(cid) < MIN_MEGA_LEVEL then
      msg(cid, "Voce precisa ser nivel " .. MIN_MEGA_LEVEL .. " ou superior para usar Mega Evolucao.")
      return true
    end
  end

  local nowActive = (active == 0) and 1 or 0
  doItemSetAttribute(ball.uid, "mega_active", nowActive)

  adjustStatus(summon, ball.uid, true, true, true)
  megaApplyVisuals(summon, ball.uid, nowActive == 1)

  if nowActive == 1 then
    doSendMagicEffect(getThingPos(summon), 173)
    doCreatureSay(cid, getPokeName(summon) .. ", MEGA EVOLVE!", TALKTYPE_SAY)
  else
    doSendMagicEffect(getThingPos(summon), 173)
    doCreatureSay(cid, getPokeName(summon) .. " voltou ao normal.", TALKTYPE_SAY)
  end

  return true
end
