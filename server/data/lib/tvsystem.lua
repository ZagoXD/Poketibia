
TVTeleportPos = {x=1131, y=582, z=7} 

local G = _G
G.TV = G.TV or { channels = {}, stor = { state = 99284, name = 99285 }, _tickStarted = false }
local TV = G.TV

TV.savedOutfit = TV.savedOutfit or {}
TV.exiting     = TV.exiting     or {}

TV.npcReplacements = TV.npcReplacements or {}
TV.savedPos = TV.savedPos or {}
TV.savedDir = TV.savedDir or {}
local DEBUG = false
local function DBG(...) if DEBUG then print(os.date("%H:%M:%S"), "[TVDBG]", ...) end end
local function S(v) if v == nil then return "" end if type(v) == "boolean" then return v and "true" or "false" end return tostring(v) end

local ACC = {
  ["Á"]="A",["À"]="A",["Â"]="A",["Ã"]="A",["Ä"]="A",["á"]="a",["à"]="a",["â"]="a",["ã"]="a",["ä"]="a",
  ["É"]="E",["È"]="E",["Ê"]="E",["Ë"]="E",["é"]="e",["è"]="e",["ê"]="e",["ë"]="e",
  ["Í"]="I",["Ì"]="I",["Î"]="I",["Ï"]="I",["í"]="i",["ì"]="i",["î"]="i",["ï"]="i",
  ["Ó"]="O",["Ò"]="O",["Ô"]="O",["Õ"]="O",["Ö"]="O",["ó"]="o",["ò"]="o",["ô"]="o",["õ"]="o",["ö"]="o",
  ["Ú"]="U",["Ù"]="U",["Û"]="U",["Ü"]="U",["ú"]="u",["ù"]="u",["û"]="u",["ü"]="u",
  ["Ç"]="C",["ç"]="c",["Ñ"]="N",["ñ"]="n"
}
local function deaccent(s) s = S(s) return (s:gsub("[\192-\255]", function(c) return ACC[c] or c end)) end

local function createTVNPC(cid)
    if not isCreature(cid) then return nil end
    
    local playerName = getCreatureName(cid)
    local playerOutfit = getCreatureOutfit(cid)
    local playerPos = getThingPos(cid)
    local playerDir = getCreatureLookDir(cid)

    local npc = doCreateNpc("TVNPC", playerPos)
    if npc then
        doCreatureSetNick(npc, playerName.." ")

        doCreatureChangeOutfit(npc, playerOutfit)

        doCreatureSetLookDir(npc, playerDir)
        
        TV.npcReplacements[cid] = npc
        return npc
    end
    return nil
end

local function removeTVNPC(cid)
    if TV.savedPos[cid] then
        doTeleportThing(cid, TV.savedPos[cid], false)
        if TV.savedDir[cid] then
            doCreatureSetLookDir(cid, TV.savedDir[cid])
        end
    end

    if TV.npcReplacements[cid] and isCreature(TV.npcReplacements[cid]) then
        doRemoveCreature(TV.npcReplacements[cid])
    end

    TV.npcReplacements[cid] = nil
    TV.savedPos[cid] = nil
    TV.savedDir[cid] = nil
end

function TV.isCamera(cid)
  return isPlayer(cid) and getPlayerStorageValue(cid, 18000) == 1
end

function TV.hasSummon(cid)
  if not isPlayer(cid) then return false end
  if type(getCreatureSummons) == "function" then
    local t = getCreatureSummons(cid); return type(t) == "table" and #t > 0
  end
  if type(getSummons) == "function" then
    local t = getSummons(cid); return type(t) == "table" and #t > 0
  end
  return false
end

function TV.rejectIfCamera(cid, msg)
  if TV.isCamera(cid) then
    doPlayerSendCancel(cid, msg or "You cannot do that while watching a transmission.")
    return true
  end
  return false
end

local function sendExtOpcode(cid, code, buffer)
  if not isPlayer(cid) then return false end
  buffer = S(buffer)
  if type(doSendPlayerExtendedOpcode) == "function" then
    return doSendPlayerExtendedOpcode(cid, code, buffer)
  elseif type(doPlayerSendExtendedOpcode) == "function" then
    return doPlayerSendExtendedOpcode(cid, code, buffer)
  end
  return false
end
local function notify(pid, msg) return sendExtOpcode(pid, 125, msg) end

local function startSpectate(watcher, owner)
  if type(doPlayerStartSpectate) == "function" then
    local ok = doPlayerStartSpectate(watcher, owner)
    if ok then
      setPlayerStorageValue(watcher, 18000, 1)
      return true
    end
  end
  return false
end

local function stopSpectate(watcher, restore)
  if type(doPlayerStopSpectate) == "function" then
    doPlayerStopSpectate(watcher, restore ~= false)
    setPlayerStorageValue(watcher, 18000, -1)
  end
end

local function makeWatcherSafe(cid, ownerPos)
    if getCreatureOutfit then 
        TV.savedOutfit[cid] = getCreatureOutfit(cid) 
    end

    TV.savedPos[cid] = getThingPos(cid)
    TV.savedDir[cid] = getCreatureLookDir(cid)

    createTVNPC(cid)

    doTeleportThing(cid, TVTeleportPos, true)

    if type(doPlayerSetGhostMode) == "function" then 
        pcall(doPlayerSetGhostMode, cid, true) 
    end
    
    if type(doCreatureSetNoMove) == "function" then 
        pcall(doCreatureSetNoMove, cid, true)
    else 
        setPlayerStorageValue(cid, 99286, 1) 
    end
end
local function restoreWatcher(cid)
  if type(doPlayerSetGhostMode) == "function" then pcall(doPlayerSetGhostMode, cid, false) end
  if type(doSetCreatureHide)   == "function" then pcall(doSetCreatureHide, cid, false)
  elseif TV.savedOutfit[cid] and type(doCreatureChangeOutfit) == "function" then
    pcall(doCreatureChangeOutfit, cid, TV.savedOutfit[cid])
  end
  TV.savedOutfit[cid] = nil

  if type(doCreatureSetNoMove) == "function" then pcall(doCreatureSetNoMove, cid, false)
  else setPlayerStorageValue(cid, 99286, -1) end

  if type(setPlayerGroupId) == "function" then pcall(setPlayerGroupId, cid, 1) end
end

local function sayIn(owner, chanId, text)
  if chanId ~= 0 and type(doPlayerSendChannelMessage) == "function" and isPlayer(owner) then
    pcall(function() return doPlayerSendChannelMessage(owner, "[TV]", deaccent(text), 7, chanId) end)
  end
end

local function openOwnerTab(owner, chanId, title)
  if chanId == 0 then return end
  sayIn(owner, chanId, 'Canal da transmissao iniciado: "' .. deaccent(title or "?") ..'".')
end

local function openWatcherTab(watcher, owner, chanId)
  if chanId == 0 then return end
  if type(doTVChannelAddUser) ~= "function" and type(doPlayerSendToChannel) == "function" then
    pcall(function() return doPlayerSendToChannel(watcher, chanId, 0, "") end)
  end
  sayIn(owner, chanId, (getCreatureName(watcher) or "um espectador") .. " entrou no chat da transmissao.")
end

local function tryAddWatcherToChat(info, watcher, tries)
  tries = tries or 3
  local chanId = info.chatId or 0
  if chanId == 0 then return false end

  if type(doTVChannelAddUser) == "function" then
    local ok = doTVChannelAddUser(chanId, watcher, info.owner)
    DBG("doTVChannelAddUser(", chanId, ",", watcher, ",", info.owner, ") =>", ok)
    if ok then
      info.chatMembers = info.chatMembers or {}
      info.chatMembers[watcher] = true
      sayIn(info.owner, chanId, (getCreatureName(watcher) or "um espectador") .. " entrou no chat da transmissao.")
      return true
    end
    if tries > 1 then
      addEvent(function() tryAddWatcherToChat(info, watcher, tries - 1) end, 150)
      return false
    end
  end

  openWatcherTab(watcher, info.owner, chanId)
  info.chatMembers = info.chatMembers or {}
  info.chatMembers[watcher] = true
  return true
end

local function countWatchers(info)
  local n = 0
  for _ in pairs(info.watchers or {}) do n = n + 1 end
  return n
end

local function broadcastUsers(info)
  if not info then return end
  local n = countWatchers(info)
  if isPlayer(info.owner) then
    notify(info.owner, "users:" .. n)
  end
  for pid, _ in pairs(info.watchers or {}) do
    if isPlayer(pid) then
      notify(pid, "users:" .. n)
    end
  end
end

function checkChannelsList(_cid)
  for _ in pairs(TV.channels) do return true end
  return false
end

function openTVDialog(cid)
  local chunks, had = {"openAllTVS"}, false
  for name, info in pairs(TV.channels) do
    had = true
    local owner = getCreatureName(info.owner) or "unknown"
    local flag = info.pass and "hasPass" or "notASSenha"
    local n = countWatchers(info)
    table.insert(chunks, string.format("%s/%s/%s", deaccent(name), deaccent(owner), flag))
  end
  if not had then table.insert(chunks, "") end
  sendExtOpcode(cid, 125, table.concat(chunks, "|"))
end

local function isRecording(cid) return getPlayerStorageValue(cid, TV.stor.state) == 1 end
local function setRecording(cid, b) setPlayerStorageValue(cid, TV.stor.state, b and 1 or -1) end
local function setChannelName(cid, name) setPlayerStorageValue(cid, TV.stor.name, deaccent(name or "")) end
local function getChannelName(cid) return getPlayerStorageValue(cid, TV.stor.name) end

local function tvTick()
  for name, info in pairs(TV.channels) do
    if not isPlayer(info.owner) then
      DBG("TICK_PURGE owner gone for chan", name)
      TV.channels[name] = nil
    end
  end
  addEvent(tvTick, 300)
end

local function ensureTick()
  if not TV._tickStarted then
    TV._tickStarted = true
    addEvent(tvTick, 300)
  end
end

function tvCreateChannel(cid, name, pass)
  if TV.hasSummon(cid) then
    return false, "You cannot start a transmission while a Pokémon is out."
  end

  if isRecording(cid) then return false, "You are already on air." end
  name = deaccent((S(name)):gsub("^%s+", ""):gsub("%s+$", ""))
  if name == "" then return false, "Invalid channel name." end
  if TV.channels[name] then return false, "This channel name is already in use." end

  local chanId = 0
  if type(doPlayerCreateTVChannel) == "function" then
    chanId = tonumber(doPlayerCreateTVChannel(cid, name)) or 0
  end
  DBG("CREATE", name, "owner=", getCreatureName(cid), cid, "chanId=", chanId)

  TV.channels[name] = {
    owner = cid,
    pass  = (pass and pass ~= "notASSenha") and pass or nil,
    watchers = {},
    chatId = chanId,
    chatMembers = {}
  }

  setChannelName(cid, name)
  setRecording(cid, true)
  ensureTick()

  if chanId > 0 then
    TV.channels[name].chatMembers[cid] = true
    openOwnerTab(cid, chanId, name)
  else
    DBG("WARN: doPlayerCreateTVChannel nao retornou id > 0")
  end
  sendExtOpcode(cid, 125, "users:0")
  sendExtOpcode(cid, 125, "contar:" .. name)
  return true
end

function closeTabChannel(cid)
  if isRecording(cid) then
    tvCloseOwnerChannel(cid)
	sendExtOpcode(cid, 125, "deleteChannel")
  else
    tvUnwatch(cid)
	sendExtOpcode(cid, 125, "deleteChannel")
  end
  return true
end

function tvCloseOwnerChannel(cid)
  local name = getChannelName(cid)
  DBG("CLOSE_OWNER", getCreatureName(cid), "chan=", name or "nil")

  if name and TV.channels[name] and TV.channels[name].owner == cid then
    local info   = TV.channels[name]
    local chanId = info.chatId or 0

    -- if chanId ~= 0 then
      -- sayIn(cid, chanId, 'Transmissao encerrada: "' .. (name or "?") ..'".')
    -- end

    for pid, _ in pairs(info.watchers) do
      if isPlayer(pid) then
        stopSpectate(pid, true)
        restoreWatcher(pid)
		---------
		removeTVNPC(pid)
		---------
        sendExtOpcode(pid, 125, "closeGraveando")
		---
		sendExtOpcode(pid, 125, "deleteChannel")
      end
    end

    TV.channels[name] = nil
  end

  setRecording(cid, false)
  setChannelName(cid, "")
  sendExtOpcode(cid, 125, "users:0")
  sendExtOpcode(cid, 125, "closeGraveando")
  sendExtOpcode(cid, 125, "deleteChannel")
end

local function checkPass(info, provided)
  if not info.pass then return true end
  return S(provided) ~= "" and S(provided) == S(info.pass)
end


function tvWatchChannel(cid, name)
  local info = TV.channels[name]
  if not info then
    DBG("WATCH_FAIL offline", getCreatureName(cid), "->", name)
    return false, "Channel is offline."
  end


  if info.pass then
    sendExtOpcode(cid, 125, "requestPass|" .. name)
    return true
  end

  DBG("WATCH_REQ", getCreatureName(cid), "->", name, "owner=", getCreatureName(info.owner))
  info.watchers[cid] = true

  makeWatcherSafe(cid)

  local ok = startSpectate(cid, info.owner)
  if not ok then
    restoreWatcher(cid)
    info.watchers[cid] = nil
    return false, "Unable to spectate now."
  end

  tryAddWatcherToChat(info, cid, 3)
  notify(info.owner, "add")
  broadcastUsers(info)
  sendExtOpcode(cid, 125, "watching:" .. name)
  return true
end

function tvWatchChannelWithPass(cid, name, pass)
  local info = TV.channels[name]
  if not info then return false, "Channel is offline." end
  if not checkPass(info, pass) then return false, "Wrong password." end

  info.watchers[cid] = true
  makeWatcherSafe(cid)

  local ok = startSpectate(cid, info.owner)
  if not ok then
    restoreWatcher(cid)
    info.watchers[cid] = nil
    return false, "Unable to spectate now."
  end

  tryAddWatcherToChat(info, cid, 3)
  notify(info.owner, "add")
  broadcastUsers(info)
  sendExtOpcode(cid, 125, "watching:" .. name)
  return true
end

function tvUnwatch(cid)
  local removedFrom = {}
  for name, info in pairs(TV.channels) do
    if info.watchers[cid] then
      info.watchers[cid] = nil
      removedFrom[name] = info
    end
  end

  if next(removedFrom) == nil then
    DBG("UNWATCH_NOOP", getCreatureName(cid))
    return
  end

  for _, info in pairs(removedFrom) do
    local chanId = info.chatId or 0
    if chanId ~= 0 and info.chatMembers and info.chatMembers[cid] then
      info.chatMembers[cid] = nil
      sayIn(info.owner, chanId, (getCreatureName(cid) or "um espectador") .. " saiu do chat da transmissao.")
    end
    notify(info.owner, "remove")
    broadcastUsers(info)
  end

  TV.exiting[cid] = true
  addEvent(function() TV.exiting[cid] = nil end, 1500)

  stopSpectate(cid, true)
  restoreWatcher(cid)
  removeTVNPC(cid)

  addEvent(function()
    if not isPlayer(cid) then return end
    sendExtOpcode(cid, 125, "closeGraveando")
    DBG("UNWATCH_DONE", getCreatureName(cid))
  end, 100)

  sendExtOpcode(cid, 125, "deleteChannel")
end

function tvOnLogout(cid)
  if getPlayerStorageValue(cid, TV.stor.state) == 1 then
    tvCloseOwnerChannel(cid)
  else
    tvUnwatch(cid)
  end
  return true
end
