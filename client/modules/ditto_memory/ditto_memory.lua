local win = nil
local SLOTS = {}
local DEFAULT_ICON = "pokes/portait.png"

local CMD_MEMORY = "/memory"
local CMD_SYNC   = "/dittoMemorySync"

local DMEM_PREFIX      = "[DMEM]"
local DMEM_HIDE_PREFIX = "[DMEM_HIDE]"

local function trim(s) return (tostring(s or ""):gsub("^%s+",""):gsub("%s+$","")) end
local function isDigits(s) return type(s)=="string" and s:match("^%d+$") ~= nil end

local function fileExists(path)
  local ok, res = pcall(function() return g_resources.fileExists(path) end)
  return ok and res or false
end

local function setPortraitPNG(slotWidget, name)
  local img = slotWidget:recursiveGetChildById('portraitImg')
  local item = slotWidget:recursiveGetChildById('portraitItem')
  if not img or not item then return end

  local candidate = "pokes/" .. trim(name or "") .. ".png"
  local chosen = fileExists(candidate) and candidate or DEFAULT_ICON

  item:setVisible(false)
  img:setImageSource(chosen)
  img:setVisible(true)
end

local function setPortraitItem(slotWidget, sid, name)
  local img = slotWidget:recursiveGetChildById('portraitImg')
  local item = slotWidget:recursiveGetChildById('portraitItem')
  if not img or not item then return end

  local nSid = tonumber(sid or 0) or 0
  if nSid > 0 and item.setItemId then
    item:setItemId(nSid)
    item:setVisible(true)
    img:setVisible(false)
  else
    setPortraitPNG(slotWidget, name)
  end
end

local function parseDMemPayload(text)
  local body = trim(text:gsub("^%[DMEM%]%s*", ""))
  local parts = body:split("/")
  local out = {}
  for i = 1, 3 do
    local raw = trim(parts[i] or "")
    local name, sid = raw:match("^(.-)%^(%d+)$")
    if not name then
      name = (raw ~= "" and raw) or "-"
      sid  = "0"
    end
    name = trim(name)
    sid  = tostring(sid or "0")
    out[i] = { name = name, sid = sid }
  end
  return out
end

local function bindSlotButtons(slotIdx)
  local slot = SLOTS[slotIdx]
  if not slot then return end

  local btnUse  = slot:recursiveGetChildById('btnUse')
  local btnSave = slot:recursiveGetChildById('btnSave')
  local btnDel  = slot:recursiveGetChildById('btnDel')
  local portraitArea = slot:recursiveGetChildById('portraitImg')

  local function doUse()  g_game.talk(string.format("%s %d", CMD_MEMORY, slotIdx)) end
  local function doSave() g_game.talk(string.format("%s save %d", CMD_MEMORY, slotIdx)) end
  local function doDel()  g_game.talk(string.format("%s forget %d", CMD_MEMORY, slotIdx)) end

  if btnUse  then btnUse.onClick  = doUse end
  if btnSave then btnSave.onClick = doSave end
  if btnDel  then btnDel.onClick  = doDel end

  local itemPortrait = slot:recursiveGetChildById('portraitItem')
  if portraitArea then portraitArea.onClick = doUse end
  if itemPortrait then itemPortrait.onClick = doUse end
end

local function ensureWindow()
  if win then return end
  win = g_ui.displayUI('ditto_memory', modules.game_interface.getRootPanel())
  if not win then
    perror('[DittoMemory] UI ditto_memory.otui não encontrada')
    return
  end
  win:setVisible(false)
  win:move(30, 40)

  local content = win:recursiveGetChildById('content')
  if not content then return end

  SLOTS[1] = content:getChildById('memSlot1')
  SLOTS[2] = content:getChildById('memSlot2')
  SLOTS[3] = content:getChildById('memSlot3')

  for i = 1, 3 do
    bindSlotButtons(i)
  end
end

local function showWindow(show)
  if not win then return end
  if show then win:show() else win:hide() end
end

local function applySlots(data)
  ensureWindow()
  if not win then return end

  for i = 1, 3 do
    local slot = SLOTS[i]
    local entry = data[i]
    if slot and entry then
      local name = trim(entry.name or "-")
      local sid  = trim(entry.sid or "0")

      setPortraitItem(slot, sid, name)

      local btnUse = slot:recursiveGetChildById('btnUse')
      if btnUse then
        if name == "-" or name:lower() == "no memory" then
          btnUse:setText("Vazio")
          btnUse:setEnabled(false)
        else
          btnUse:setText("Usar")
          btnUse:setEnabled(true)
        end
      end
    end
  end

  showWindow(true)
end

local function onGameStart()
  ensureWindow()
  showWindow(false)
  scheduleEvent(function()
    if g_game.isOnline() then g_game.talk(CMD_SYNC) end
  end, 200)
end

local function onGameEnd()
  showWindow(false)
end

local function onTextMessage(mode, text)
  if not g_game.isOnline() or type(text) ~= 'string' then return end

  if text:sub(1, #DMEM_PREFIX) == DMEM_PREFIX then
    local data = parseDMemPayload(text)
    applySlots(data)
    return
  end

  if text:sub(1, #DMEM_HIDE_PREFIX) == DMEM_HIDE_PREFIX then
    showWindow(false)
    return
  end
end

function init()
  ensureWindow()
  connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
  connect(g_game, 'onTextMessage', onTextMessage)
end

function terminate()
  disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
  disconnect(g_game, 'onTextMessage', onTextMessage)
  if win and win.destroy then win:destroy() end
  win = nil
  SLOTS = {}
end
