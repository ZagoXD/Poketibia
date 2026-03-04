function onExtendedOpcode(cid, opcode, buffer)
  if opcode ~= 125 then
    return true
  end
  
   if buffer == "requestList" then
    openTVDialog(cid)
    return true
  end
  
  if buffer == "TVcloseTabChannel" then
    closeTabChannel(cid)
    return true
  end

  local name, pass

  if buffer:find("^create/") then
    local _, _, n, p = buffer:find("^create/(.-)/(.+)$")
    name, pass = n or "", p or ""
    local ok, err = tvCreateChannel(cid, name, pass)
    if not ok then
      doPlayerSendCancel(cid, err or "Unable to start the transmission.")
    end
    return true
  end

  if buffer == "close/" then
    tvCloseOwnerChannel(cid)
    return true
  end

  if buffer:find("^watch/") then
    local _, _, n = buffer:find("^watch/(.+)$")
    name = n or ""
    local ok, err = tvWatchChannel(cid, name)
    if not ok then
      doPlayerSendCancel(cid, err or "Unable to watch this channel.")
    end
    return true
  end

  if buffer == "unwatch/" then
    tvUnwatch(cid)
    return true
  end

  if buffer:find("^watchWithPass/") then
    local _, _, n, p = buffer:find("^watchWithPass/([^/]+)/(.+)$")
    name, pass = n or "", p or ""
    local ok, err = tvWatchChannelWithPass(cid, name, pass)
    if not ok then
      doPlayerSendCancel(cid, err or "Wrong password.")
    end
    return true
  end

  return true
end

-- function onCloseChannel(cid, channelId)
  -- -- if tvOnCloseChannel then
    -- -- return tvOnCloseChannel(cid, channelId)
  -- -- end
  -- -- return true
-- end

function onLogin(cid)
  registerCreatureEvent(cid, "TV_ExtOP")
  registerCreatureEvent(cid, "TV_Logout")
  registerCreatureEvent(cid, "TV_ChatClose")
  return true
end

function onLogout(cid)
  return tvOnLogout(cid)
end
