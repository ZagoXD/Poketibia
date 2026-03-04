local CHEST_AID = 55350

local ELITE_CHAMPION_DONE = 9350
local ELITE_ACCOUNT_DONE  = 9351

local ELITE_REWARD_CLAIM_PLAYER  = 9353
local ELITE_REWARD_CLAIM_ACCOUNT = 9354

local ELITE_ABORT_POS = {x = 558, y = 1066, z = 6}

local REWARD = {
  {id = 14106, count = 50},
  {id = 12704, count = 1},
  {id = 12703, count = 3},
  {id = 14159, count = 1},
  {id = 12999, count = 3},
}

local function hasWonElite(cid)
  if type(eliteChampionLocked) == "function" and eliteChampionLocked(cid) then
    return true
  end

  if getPlayerStorageValue(cid, ELITE_CHAMPION_DONE) > 0 then
    return true
  end

  if type(getAccountStorageValue) == "function" then
    local accId = getPlayerAccountId(cid)
    if getAccountStorageValue(accId, ELITE_ACCOUNT_DONE) > 0 then
      return true
    end
  end

  return false
end

local function alreadyClaimed(cid)
  if type(getAccountStorageValue) == "function" then
    local accId = getPlayerAccountId(cid)
    if getAccountStorageValue(accId, ELITE_REWARD_CLAIM_ACCOUNT) > 0 then
      return true
    end
  end
  return getPlayerStorageValue(cid, ELITE_REWARD_CLAIM_PLAYER) > 0
end

local function markClaimed(cid)
  if type(setAccountStorageValue) == "function" then
    local accId = getPlayerAccountId(cid)
    setAccountStorageValue(accId, ELITE_REWARD_CLAIM_ACCOUNT, 1)
  end
  setPlayerStorageValue(cid, ELITE_REWARD_CLAIM_PLAYER, 1)
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
  if item.actionid ~= CHEST_AID then
    return false
  end

  if not hasWonElite(cid) then
    doPlayerSendCancel(cid, "Voce precisa derrotar o Campeao (Green) para pegar este premio.")
    return true
  end

  if alreadyClaimed(cid) then
    doPlayerSendCancel(cid, "Voce ja pegou o premio deste bau.")
    return true
  end

  local bag = doPlayerAddItem(cid, 1991, 1)
  if bag == 0 then
    doPlayerSendCancel(cid, "Sem espaco para receber o premio (inventario cheio).")
    return true
  end

  for _, it in ipairs(REWARD) do
    local uid = doAddContainerItem(bag, it.id, it.count)
    if uid == 0 then
      doPlayerSendCancel(cid, "Erro ao entregar o premio. Avise um administrador.")
      return true
    end
  end

  markClaimed(cid)

  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
    "Parabens! Voce recebeu o premio final da Liga.")

  doTeleportThing(cid, ELITE_ABORT_POS)
  doSendMagicEffect(ELITE_ABORT_POS, CONST_ME_TELEPORT)

  return true
end
