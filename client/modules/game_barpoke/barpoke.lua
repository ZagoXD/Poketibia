local barPoke = nil
local slots = {}
local MAX_SLOTS = 6

local SLOT_H = 52
local GAP_V = 8
local PAD_T = 18
local PAD_B = 18

local TALK_COMMAND = "/poke"
local SYNC_COMMAND = "/pokebarSync"

local DEFAULT_ICON = "pokes/portait.png"
local BUTTON_ICON = "styles/pokebar"

local POKE_HP_PREFIX = "#ph#,"

local function trim(s)
  return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function fileExists(path)
  local ok, res = pcall(function() return g_resources.fileExists(path) end)
  return ok and res or false
end

local function letterForIndex(i)
  return string.char(string.byte('A') + (i - 1))
end

local function isDigits(s)
  return type(s) == 'string' and s:match("^%d+$") ~= nil
end

local function resetSlotStyle(slot)
  if not slot then return end
  slot:setBorderWidth(0)
  slot:setBorderColor('#00000000')
  slot:setOpacity(1.0)
  slot:setImageColor('white')
  slot:setImageSource('styles/menu')
  slot._isActive = false
  slot._isFainted = false

  local portraitImg = slot:recursiveGetChildById('pokePortrait')
  if portraitImg then portraitImg:setImageColor('white'); portraitImg:setVisible(true) end

  local portraitItem = slot:recursiveGetChildById('pokePortraitItem')
  if portraitItem then portraitItem:setVisible(false) end

  local death = slot:recursiveGetChildById('pokeDeath')
  if death then death:setVisible(false) end
end

local function applyStateStyle(slot, isActive, isFainted)
  if not slot then return end
  slot:setImageSource(isActive and 'styles/menu_using' or 'styles/menu')
  slot._isActive = isActive
  slot._isFainted = isFainted

  if isFainted then
    slot:setOpacity(0.55)
    slot:setImageColor('#C0C0C0')
    local death = slot:recursiveGetChildById('pokeDeath')
    if death then death:setVisible(true) end
  else
    slot:setOpacity(1.0)
    slot:setImageColor('white')
    local death = slot:recursiveGetChildById('pokeDeath')
    if death then death:setVisible(false) end
  end
end

local function colorForPercent(p)
  if p >= 66 then
    return '#3fb85b'
  elseif p >= 33 then
    return '#d9b64b'
  else
    return '#c74a4a'
  end
end

local function setSlotHPPercent(slot, pct)
  local bar = slot:recursiveGetChildById("barHp")
  local lbl = slot:recursiveGetChildById("pokeHp")
  if not bar then return end

  pct = math.max(0, math.min(100, math.floor(tonumber(pct or 0) + 0.5)))

  if bar.setValue then
    bar:setValue(pct, 0, 100)
  else
    bar:setPercent(pct)
  end

  local col = colorForPercent(pct)
  if bar.setForegroundColor then
    bar:setForegroundColor(col)
  elseif bar.setBarColor then
    bar:setBarColor(col)
  else
    bar:setBackgroundColor(col)
  end

  if lbl then lbl:setText(pct .. "%") end
end

local function setPortraitPng(slot, exactDisplayName)
  local portraitImg = slot:recursiveGetChildById('pokePortrait')
  if not portraitImg then return end

  local candidate = "pokes/" .. trim(exactDisplayName or "") .. ".png"
  local chosen = fileExists(candidate) and candidate or DEFAULT_ICON

  portraitImg:setImageSource(chosen)
  portraitImg:setVisible(true)

  local portraitItem = slot:recursiveGetChildById('pokePortraitItem')
  if portraitItem then portraitItem:setVisible(false) end
end

local function setPortraitFromClientId(slot, portraitCid, exactDisplayName)
  local portraitItem = slot:recursiveGetChildById('pokePortraitItem')
  local portraitImg  = slot:recursiveGetChildById('pokePortrait')

  local cid = tonumber(portraitCid or 0) or 0
  if cid > 0 and portraitItem and portraitItem.setItemId then
    portraitItem:setItemId(cid)
    portraitItem:setVisible(true)
    if portraitImg then portraitImg:setVisible(false) end
  else
    setPortraitPng(slot, exactDisplayName)
  end
end

local function bindClick(slot, index)
  local letter = letterForIndex(index)
  local function doClick()
    g_game.talk(TALK_COMMAND .. " !" .. letter)
  end
  slot.onClick = doClick
  for _, id in ipairs({'pokePortraitItem','pokePortrait','pokeBorder','pokeName','barHp','hpFrame','up','down'}) do
    local w = slot:recursiveGetChildById(id)
    if w then w.onClick = doClick end
  end
end

local function ensureSlots()
  for i = 1, MAX_SLOTS do
    if not slots[i] then
      local w = g_ui.createWidget('Slot', barPoke)
      w:setId('Slot' .. i)
      w:setMarginTop(PAD_T + (i - 1) * (SLOT_H + GAP_V))
      w:setMarginLeft(5)
      w:setVisible(false)
      slots[i] = w
    end
  end
end

local function hideAll()
  for i = 1, MAX_SLOTS do
    local s = slots[i]
    if s then s:setVisible(false) end
  end
end

local function resizeBar(visibleCount)
  if visibleCount < 1 then
    barPoke:setHeight(SLOT_H + PAD_T + PAD_B)
    return
  end
  local h = PAD_T + (visibleCount * SLOT_H) + ((visibleCount - 1) * GAP_V) + PAD_B
  barPoke:setHeight(h)
end

function init()
  local top = modules and modules.client_topmenu
  if top and top.addRightGameToggleButton then
    if pokeButton and pokeButton.setOn then
      pokeButton:setOn(true)
    end
  end

  barPoke = g_ui.displayUI('barpoke', modules.game_interface.getRootPanel())
  if not barPoke then
    perror('[barpoke] UI "barpoke" nao encontrada (.otui)')
    return
  end

  barPoke:setVisible(false)
  barPoke:move(250, 50)

  ensureSlots()
  hideAll()

  connect(g_game, 'onTextMessage', getParams)
  connect(g_game, { onGameEnd = hide })
  connect(g_game, { onGameStart = onGameStart })
end

function terminate()
  disconnect(g_game, { onGameEnd = hide })
  disconnect(g_game, { onGameStart = onGameStart })
  disconnect(g_game, 'onTextMessage', getParams)
  if barPoke and barPoke.destroy then barPoke:destroy() end
  barPoke = nil
  slots = {}
end

function onGameStart()
  hide()
  scheduleEvent(function()
    if g_game.isOnline() then
      g_game.talk(SYNC_COMMAND)
    end
  end, 150)
end

function toggle()
  if not pokeButton or not barPoke then return end
  if pokeButton:isOn() then
    barPoke:hide(); pokeButton:setOn(false)
  else
    barPoke:show(); pokeButton:setOn(true)
  end
end

function hide()
  if barPoke then barPoke:setVisible(false) end
  if pokeButton and pokeButton.setOn then pokeButton:setOn(false) end
end

function show()
  if barPoke then barPoke:setVisible(true) end
  if pokeButton and pokeButton.setOn then pokeButton:setOn(true) end
end

local function updateActiveSlotFromPh(hp, max)
  hp  = tonumber(hp)  or 0
  max = tonumber(max) or 0
  local pct = 0
  if max > 0 then pct = math.floor((hp / max) * 100 + 0.5) end
  for i = 1, MAX_SLOTS do
    local s = slots[i]
    if s and s:isVisible() and s._isActive then
      setSlotHPPercent(s, pct)
      break
    end
  end
end

local function parseEntry(raw)
  local name, flags, pctStr, cidStr

  name, flags, pctStr, cidStr = raw:match("^(.-)%^([AF]+)%^([%d%.]+)%^([%d]+)$")
  if name then return name, flags, pctStr, cidStr end

  name, pctStr, cidStr = raw:match("^(.-)%^([%d%.]+)%^([%d]+)$")
  if name then return name, nil, pctStr, cidStr end

  name, flags, pctStr = raw:match("^(.-)%^([AF]+)%^([%d%.]+)$")
  if name then return name, flags, pctStr, nil end

  name, flags = raw:match("^(.-)%^([AF]+)$")
  if name then return name, flags, nil, nil end

  name, pctStr = raw:match("^(.-)%^([%d%.]+)$")
  if name then return name, nil, pctStr, nil end

  name = raw
  return name, nil, nil, nil
end

function getParams(mode, text)
  if not g_game.isOnline() then return end
  if mode ~= MessageModes.Failure then return end
  if type(text) ~= 'string' then return end

  local p9 = text:sub(1, 9)
  local p7 = text:sub(1, 7)
  if p9 == "BarClosed" then
    hide(); return
  elseif p7 == "Pokebar" then
    atualizarBar(text); return
  end

  if text:sub(1, 5) == POKE_HP_PREFIX then
    local t = text:explode(',')
    updateActiveSlotFromPh(tonumber(t[2]), tonumber(t[3]))
  end
end

function atualizarBar(text)
  if not g_game.isOnline() then return end
  ensureSlots()
  hideAll()

  local parts = string.explode(text, "/")
  local shown = 0

  for i = 2, math.min(#parts, MAX_SLOTS + 1) do
    local idx = i - 1
    local raw = parts[i]
    if raw and raw ~= "" then
      local name, flags, pctStr, portraitCid = parseEntry(raw)

      local isActive  = flags and flags:find('A', 1, true) and true or false
      local isFainted = flags and flags:find('F', 1, true) and true or false

      local slot = slots[idx]
      if slot then
        resetSlotStyle(slot)

        if isDigits(portraitCid) and tonumber(portraitCid) and tonumber(portraitCid) > 0 then
          setPortraitFromClientId(slot, portraitCid, name)
        else
          setPortraitPng(slot, name)
        end

        local lbl = slot:recursiveGetChildById('pokeName')
        if lbl then lbl:setText(name) end

        applyStateStyle(slot, isActive, isFainted)

        local pct = tonumber(pctStr)
        if isFainted then
          setSlotHPPercent(slot, 0)
        elseif pct then
          setSlotHPPercent(slot, pct)
        else
          setSlotHPPercent(slot, 100)
        end

        bindClick(slot, idx)
        slot:setVisible(true)
        shown = shown + 1
      end
    end
  end

  if shown > 0 then
    resizeBar(shown)
    show()
  else
    hide()
  end
end
