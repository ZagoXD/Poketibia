local function showHelp(cid)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
    "AutoLoot comandos:\n" ..
    "!aloot or /aloot -> mostra este help\n" ..
    "aloot off    -> desliga\n" ..
    "aloot stones -> so pedras/itens de evolucao\n" ..
    "aloot all    -> tudo")
end

function onSay(cid, words, param, channel)
  local p = param:lower():trim()

  if p == "" then
    showHelp(cid)
    return true
  end

  if p == "off" then
    autolootSetMode(cid, 0)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "AutoLoot: desligado.")
    return true
  elseif p == "stones" then
    autolootSetMode(cid, 2)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "AutoLoot: somente pedras/itens de evolucao.")
    return true
  elseif p == "all" then
    autolootSetMode(cid, 1)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "AutoLoot: todos os itens.")
    return true
  else
    showHelp(cid)
    return true
  end
end
