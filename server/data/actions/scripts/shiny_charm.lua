local ITEM_SHINY_CHARM = 14107

function onUse(cid, item, frompos, itemEx, topos)
  if item.itemid ~= ITEM_SHINY_CHARM then return false end

  shinyCharmActivate(cid, SHINY_CHARM.DURATION)
  local pretty = (type(shinyCharmPrettyRemaining) == "function") and shinyCharmPrettyRemaining(cid) or "alguns instantes"

  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
    "Shiny Charm ativado! Bonus ativo por aproximadamente " .. pretty .. ".")
  doRemoveItem(item.uid, 1)
  doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_RED)
  return true
end
