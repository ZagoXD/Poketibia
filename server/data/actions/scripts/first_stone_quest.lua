local TELEPORT_POS = {x = 1055, y = 1050, z = 7}

local REWARDS = {
  [55335] = {itemId = 11447, count = 2},
  [55336] = {itemId = 11441, count = 2},
  [55337] = {itemId = 11442, count = 2},
}

local STOR_FIRST_STONE_CHOICE = 90501

local function itemName(id)
  local n = getItemNameById(id)
  return n and n or ("item "..id)
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
  local aid = item.actionid or 0
  local reward = REWARDS[aid]
  if not reward then
    return false
  end

  local chosen = tonumber(getPlayerStorageValue(cid, STOR_FIRST_STONE_CHOICE)) or -1
  if chosen > 0 then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
      "Voce ja concluiu esta quest. Nao e possivel pegar outro bau.")
    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
    return true
  end

  local uid = doPlayerAddItem(cid, reward.itemId, reward.count)
  if not uid or uid <= 0 then
    doPlayerSendCancel(cid, "Nao foi possivel entregar a recompensa (inventario?). Tente liberar espaco.")
    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
    return true
  end

  setPlayerStorageValue(cid, STOR_FIRST_STONE_CHOICE, aid)

  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
    string.format("Parabens! Voce recebeu %dx %s.", reward.count, itemName(reward.itemId)))

  doTeleportThing(cid, TELEPORT_POS, true)
  doSendMagicEffect(TELEPORT_POS, CONST_ME_TELEPORT)

  return true
end
