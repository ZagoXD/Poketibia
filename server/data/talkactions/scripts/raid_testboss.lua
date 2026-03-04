function onSay(cid, words, param)
  local name = param and param:match("^%s*(.-)%s*$") or ""
  if name == "" then
    doPlayerSendCancel(cid, "Use: /raidtestboss NomeDoMonstro")
    return true
  end
  local pos = getCreaturePosition(cid); pos.x = pos.x + 1
  local m = doCreateMonster(name, pos, false) -- mesma assinatura do /m
  if m and m > 0 then
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "OK: "..name.." criado.")
  else
    doPlayerSendCancel(cid, "Falha ao criar '"..name.."'. Verifique o nome no monsters.xml.")
  end
  return true
end
