function onSay(cid, words, param)
  local cfg = { exhausted = 2, storage = 5858, exp = 2.0 }

  if TV and TV.isCamera and TV.isCamera(cid) then
    doPlayerSendCancel(cid, "You cannot summon while watching a transmission.")
    sendAllPokemonsBarPoke(cid)
    return true
  end

  local now = os.time()
  local nextUse = getPlayerStorageValue(cid, cfg.storage)

  if nextUse > now and nextUse < (now + 100) then
    local remaining = nextUse - now
    doPlayerSendTextMessage(
      cid, MESSAGE_STATUS_CONSOLE_RED,
      "You must wait another " .. remaining .. " second" .. (remaining == 1 and "" or "s") .. " to use new pokemon."
    )
  elseif doSendPokemon(cid, param) then
    sendAllPokemonsBarPoke(cid)
    setPlayerStorageValue(cid, cfg.storage, now + cfg.exhausted)
    return true
  end

  sendAllPokemonsBarPoke(cid)
  return true
end
