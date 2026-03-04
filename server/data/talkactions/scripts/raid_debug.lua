function onSay(cid, words, param)
  local id = tonumber(param) or 1
  if not RAID_LOBBY_SPAWNS[id] then
    doPlayerSendCancel(cid, "Lobby "..id.." não existe.")
    return true
  end
  if Raid.lobbies[id] then
    doPlayerSendCancel(cid, "Lobby "..id.." já está ativo.")
    return true
  end
  Raid.spawnLobby(id)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Lobby "..id.." spawned.")
  return true
end
