ELITE_RUN_BASE = 9300
ELITE_CHAMPION_DONE = 9350
ELITE_RESET_POS = {x = 558, y = 1066, z = 6}
ELITE_ABORT_POS = {x = 558, y = 1066, z = 6}
ELITE_ACCOUNT_STORAGE = 9351
ELITE_RUN_ACTIVE    = 9352
ELITE_NPC_INDEX = {
  ["Lorelei"] = 1,
  ["Bruno"]   = 2,
  ["Agatha"]  = 3,
  ["Lance"]   = 4,
  ["Green"]   = 5,
}
local ELITE_NAMES = { "Lorelei", "Bruno", "Agatha", "Lance", "Green" }

ELITE_GLOBAL_LOCK      = 9354
ELITE_GLOBAL_LOCK_TIME = 9355
ELITE_GLOBAL_LOCK_TTL  = 60 * 60

local function eliteGlobalNormalizeLock()
  if type(getGlobalStorageValue) ~= "function" or type(setGlobalStorageValue) ~= "function" then
    return
  end

  local owner = getGlobalStorageValue(ELITE_GLOBAL_LOCK)
  if owner and owner > 0 then
    local t = getGlobalStorageValue(ELITE_GLOBAL_LOCK_TIME)
    if t and t > 0 and (os.time() - t) > ELITE_GLOBAL_LOCK_TTL then
      setGlobalStorageValue(ELITE_GLOBAL_LOCK, -1)
      setGlobalStorageValue(ELITE_GLOBAL_LOCK_TIME, -1)
    end
  end
end

function eliteGlobalRunTryLock(cid)
  if not isPlayer(cid) then return false, "Desafio invalido." end

  if type(getGlobalStorageValue) ~= "function" or type(setGlobalStorageValue) ~= "function" then
    return true
  end

  eliteGlobalNormalizeLock()

  local owner = getGlobalStorageValue(ELITE_GLOBAL_LOCK)
  if owner and owner > 0 and owner ~= getPlayerGUID(cid) then
    return false, "A Elite dos 4 ja esta sendo desafiada por outro jogador. Aguarde ele terminar."
  end

  setGlobalStorageValue(ELITE_GLOBAL_LOCK, getPlayerGUID(cid))
  setGlobalStorageValue(ELITE_GLOBAL_LOCK_TIME, os.time())
  return true
end

function eliteGlobalRunUnlock(cid, force)
  if type(getGlobalStorageValue) ~= "function" or type(setGlobalStorageValue) ~= "function" then
    return true
  end

  local owner = getGlobalStorageValue(ELITE_GLOBAL_LOCK)
  if not owner or owner <= 0 then
    return true
  end

  if force or (isPlayer(cid) and owner == getPlayerGUID(cid)) then
    setGlobalStorageValue(ELITE_GLOBAL_LOCK, -1)
    setGlobalStorageValue(ELITE_GLOBAL_LOCK_TIME, -1)
    return true
  end

  return false
end

function eliteRunIsActive(cid)
  return isPlayer(cid) and getPlayerStorageValue(cid, ELITE_RUN_ACTIVE) == 1
end

function eliteRunStart(cid, reset)
  if not isPlayer(cid) then return false end

  local ok, reason = eliteGlobalRunTryLock(cid)
  if not ok then
    return false, reason
  end

  if reset then eliteResetRun(cid) end
  setPlayerStorageValue(cid, ELITE_RUN_ACTIVE, 1)
  return true
end

function eliteRunEnd(cid)
  if not isPlayer(cid) then return false end
  setPlayerStorageValue(cid, ELITE_RUN_ACTIVE, -1)
  eliteGlobalRunUnlock(cid)
  return true
end

local function eliteTeleportReset(cid)
  if not isPlayer(cid) then return end
  doTeleportThing(cid, ELITE_RESET_POS)
  doSendMagicEffect(ELITE_RESET_POS, CONST_ME_TELEPORT)
end

function eliteRunFail(cid, npc)
  if not isPlayer(cid) then return false end
  if npc and isCreature(npc) and not eliteGetNpcIndex(npc) then
    return false
  end

  eliteResetRun(cid)
  eliteRunEnd(cid)
  eliteTeleportReset(cid)
  return true
end

function eliteRunAbort(cid)
  if not isPlayer(cid) then return false end

  eliteResetRun(cid)
  setPlayerStorageValue(cid, ELITE_RUN_ACTIVE, -1)
  eliteGlobalRunUnlock(cid, true)

  doTeleportThing(cid, ELITE_ABORT_POS)
  doSendMagicEffect(ELITE_ABORT_POS, CONST_ME_TELEPORT)

  return true
end


function eliteGetNpcIndex(npc)
  if not isCreature(npc) then return nil end
  return ELITE_NPC_INDEX[getCreatureName(npc)]
end

function eliteChampionLocked(cid)
  return isPlayer(cid) and getPlayerStorageValue(cid, ELITE_CHAMPION_DONE) > 0
end

function eliteRunHasDefeated(cid, idx)
  if not isPlayer(cid) or not idx then return false end
  return getPlayerStorageValue(cid, ELITE_RUN_BASE + idx) > 0
end

function eliteRunSetDefeated(cid, idx)
  if not isPlayer(cid) or not idx then return false end
  setPlayerStorageValue(cid, ELITE_RUN_BASE + idx, 1)
  return true
end

function eliteResetRun(cid)
  if not isPlayer(cid) then return false end
  for i = 1, 5 do
    setPlayerStorageValue(cid, ELITE_RUN_BASE + i, -1)
  end
  return true
end

function eliteGetNextRequiredIndex(cid)
  if not isPlayer(cid) then return 1 end
  for i = 1, 5 do
    if getPlayerStorageValue(cid, ELITE_RUN_BASE + i) <= 0 then
      return i
    end
  end
  return 6
end

function eliteCanChallenge(cid, npc)
  if not isPlayer(cid) or not isCreature(npc) then
    return false, "Desafio invalido."
  end

  if not gymHasAllBadges(cid) then
    return false, "Voce precisa conquistar as 8 Insignias antes de desafiar a Elite dos 4."
  end

  if eliteChampionLocked(cid) then
    return false, "Voce ja venceu o Campeao uma vez. Seu desafio na Elite terminou para sempre."
  end

  local idx = eliteGetNpcIndex(npc)
  if not idx then
    return false, "Este NPC nao esta configurado como Elite."
  end

  local need = eliteGetNextRequiredIndex(cid)

  if need == 6 then
    if idx == 1 then
      eliteResetRun(cid)
      need = 1
    else
      return false, "Se quiser enfrentar a Elite novamente, comece falando com Lorelei."
    end
  end

  if idx ~= need then
    return false, "Ainda nao. Seu proximo desafio deve ser: " .. ELITE_NAMES[need] .. "."
  end

  return true
end

function eliteSendCompletionMessage(cid)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
    "Inacreditavel!\n" ..
    "Voce derrotou a Elite dos 4 e venceu o Campeao.\n" ..
    "A partir de agora, seu nome entra para a historia de Kanto!"
  )
end
