dofile('data/lib/pb_sync.lua')

function onSay(cid, words, param, channel)
  sendPokeballOnClientIds(cid)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "PB Sync enviado.")
  return true
end
