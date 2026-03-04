local ITEM_MEGA_CHARM = 14166

function onUse(cid, item, frompos, itemEx, topos)
  if item.itemid ~= ITEM_MEGA_CHARM then return false end

  megaCharmActivate(cid, MEGA_CHARM.DURATION)
  local pretty = (type(megaCharmPrettyRemaining) == "function") and megaCharmPrettyRemaining(cid) or "alguns instantes"

  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
    "Mega Charm ativado! Bonus ativo por aproximadamente " .. pretty .. ".")
  doRemoveItem(item.uid, 1)
  doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
  return true
end
