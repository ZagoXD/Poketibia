-- Privates variables
local cdBarWin = nil
local isIn = 'H' --[[ 'H' = horizontal; 'V' = vertical ]] --
local namesAtks = ''
local icons = {}
-- End privates variables

local function resolveImagePath(base)
  local candidates = {
    base .. ".png",
    base .. ".PNG",
    "/images/" .. base .. ".png",
    "/images/" .. base .. ".PNG",
    "game_pokemoves/" .. base .. ".png",
    "game_pokemoves/" .. base .. ".PNG",
    "/images/game_pokemoves/" .. base .. ".png",
    "/images/game_pokemoves/" .. base .. ".PNG",
  }
  for _, p in ipairs(candidates) do
    local ok = false
    local exists = false
    ok, exists = pcall(function() return g_resources.fileExists(p) end)
    if ok and exists then
      return p
    end
  end
  return nil
end

-- Public functions
function init()
    cdBarWin = g_ui.displayUI('cdBar', modules.game_interface.getRootPanel())
    cdBarWin:setVisible(false)
    cdBarWin:move(250, 50)

    connect(g_game, 'onTextMessage', getParams)
    connect(g_game, {
        onGameEnd = hide
    })
    connect(LocalPlayer, {
        onLevelChange = onLevelChange
    })

    g_mouse.bindPress(cdBarWin, function()
        createMenu()
    end, MouseRightButton)

    createIcons()
end

function terminate()
    disconnect(g_game, {
        onGameEnd = hide
    })
    disconnect(g_game, 'onTextMessage', getParams)
    disconnect(LocalPlayer, {
        onLevelChange = onLevelChange
    })

    destroyIcons()
    cdBarWin:destroy()
end

function onLevelChange(localPlayer, value, percent)
    if not cdBarWin:isVisible() then
        return
    end
    g_game.talk("/reloadCDs")
end

function getParams(mode, text)
    if not g_game.isOnline() then
        return
    end
    if mode == MessageModes.Failure then
        if string.find(text, '12//,') then
            if string.find(text, 'hide') then
                hide()
            else
                show()
            end
        elseif string.find(text, '12|,') then
            atualizarCDs(text)
        elseif string.find(text, '12&,') then
            FixTooltip(text)
        end
    end
end

function atualizarCDs(text)
    if not g_game.isOnline() then
        return
    end
    if not cdBarWin:isVisible() then
        return
    end
    local t = text:explode(",")
    table.remove(t, 1)
    for i = 1, 12 do
        local t2 = t[i]:explode("|")
        barChange(i, tonumber(t2[1]), tonumber(t2[2]), tonumber(t2[3]))
    end
end

function changePercent(progress, icon, perc, num, init)
    if not cdBarWin:isVisible() then
        return
    end
    if init then
        progress:setPercent(0)
    else
        progress:setPercent(progress:getPercent() + perc)
    end
    if progress:getPercent() >= 100 then
        progress:setText("")
        return
    end
    progress:setText(num)
    icons[icon:getId()].event = scheduleEvent(function()
        changePercent(progress, icon, perc, num - 1)
    end, 1000)
end

function barChange(ic, num, lvl, lvlPoke)
    if not g_game.isOnline() then
        return
    end
    if not cdBarWin:isVisible() then
        return
    end

    local icon     = icons['Icon' .. ic].icon
    local progress = icons['Icon' .. ic].progress
    local spell    = icons['Icon' .. ic].spellName

    if not progress:getTooltip() then
        return
    end

    local player = g_game.getLocalPlayer()

    local pathOn
    if spell == "__MEGA__" then
    pathOn = resolveImagePath("moves_icon/Mega_on") or resolveImagePath("moves_icon/mega_on")
    else
    pathOn = resolveImagePath("moves_icon/" .. spell .. "_on")
    end

    if not pathOn then
    pathOn = resolveImagePath("moves_icon/Sketch_on") or "/images/ui/miniwindow"
    end
    icon:setImageSource(pathOn)

    if spell == "__MEGA__" then
        cleanEvents('Icon' .. ic)
        progress:setPercent(100)
        progress:setText("")
        progress:setColor('#FFFFFF')
        return
    end
    if num and num >= 1 then
        cleanEvents('Icon' .. ic)
        changePercent(progress, icon, 100 / num, num, true)
    else
        if (lvlPoke and lvlPoke < lvl) or player:getLevel() < lvl then
            progress:setPercent(0)
            progress:setText('L.' .. lvl)
            progress:setColor('#AD0D0D')
        else
            progress:setPercent(100)
            progress:setText("")
            progress:setColor('#FFFFFF')
        end
    end
end


local function placeIcon(ic, order)
  local step  = 34
  local start = 5
  if isIn == 'H' then
    ic.icon:setMarginLeft(4)
    ic.icon:setMarginTop(start + (order - 1) * step)
  else
    ic.icon:setMarginTop(4)
    ic.icon:setMarginLeft(start + (order - 1) * step)
  end
end

function FixTooltip(text)
  cdBarWin:setHeight(isIn == 'H' and 416 or 40)
  cdBarWin:setWidth (isIn == 'H' and 40  or 416)

  if not text then text = namesAtks else namesAtks = text end
  local t2 = text:explode(",")

  local visible = 0
  local hidden  = 0

  for j = 2, 13 do
    local idx = j - 1
    local ic  = icons['Icon' .. idx]

    local cell = t2[j]
    if cell == 'n/n' or cell == nil or cell == '' then
      ic.icon:hide()
      ic.progress:setVisible(false)
      ic.progress:setTooltip(nil)
      ic.progress:setText("")
      ic.progress:setPercent(100)
      ic.progress.onClick = nil
      ic.spellName = nil
      hidden = hidden + 1

    else
      visible = visible + 1
      placeIcon(ic, visible)

      ic.icon:show()
      ic.progress:setVisible(true)

      if cell == '[MEGA]' then
        ic.progress:setTooltip("Mega Evolution")
        ic.spellName = "__MEGA__"
        ic.progress.onClick = function()
          g_game.talk("/mega")
        end
      else
        if cell:find("Sketch") then
          ic.progress:setTooltip("Sketch")
          ic.spellName = "Sketch"
        else
          ic.progress:setTooltip(cell)
          ic.spellName = cell
        end
        ic.progress.onClick = function()
          g_game.talk('m' .. idx)
        end
      end
    end
  end

  if visible == 0 then
    cleanEvents()
    cdBarWin:setVisible(false)
    return
  end

  if hidden > 0 then
    if isIn == "H" then
      cdBarWin:setHeight(416 - (hidden * 34))
    else
      cdBarWin:setWidth (416 - (hidden * 34))
    end
  end
end

function createIcons()
    local d = 38
    for i = 1, 12 do
        local icon = g_ui.createWidget('SpellIcon', cdBarWin)
        local progress = g_ui.createWidget('SpellProgress', cdBarWin)
        icon:setId('Icon' .. i)
        progress:setId('Progress' .. i)
        icons['Icon' .. i] = {
            icon = icon,
            progress = progress,
            dist = (i == 1 and 5 or i == 2 and 38 or d + ((i - 2) * 34)),
            event = nil
        }
        icon:setMarginTop(icons['Icon' .. i].dist)
        icon:setMarginLeft(4)
        progress:fill(icon:getId())
        progress:setVisible(false)
        progress:setText("")
        progress:setPercent(100)
        progress.onClick = function()
            g_game.talk('m' .. i)
        end
    end
end

function destroyIcons()
    for i = 1, 12 do
        icons['Icon' .. i].icon:destroy()
        icons['Icon' .. i].progress:destroy()
    end
    cleanEvents()
    icons = {}
end

function cleanEvents(icon)
    local e = nil
    if icon then
        e = icons[icon]
        if e and e.event ~= nil then
            removeEvent(e.event)
            e.event = nil
        end
    else
        for i = 1, 12 do
            e = icons['Icon' .. i]
            cleanEvents('Icon' .. i)
            e.progress:setPercent(100)
            e.progress:setText("")
        end
    end
end

function createMenu()
    local menu = g_ui.createWidget('PopupMenu')
    menu:addOption("Set " .. (isIn == 'H' and 'Vertical' or 'Horizontal'), function()
        toggle()
    end)
    menu:display()
end

function toggle()
    if not cdBarWin:isVisible() then
        return
    end
    cdBarWin:setVisible(false)
    if isIn == 'H' then
        isIn = 'V'
    else
        isIn = 'H'
    end
    FixTooltip()
    show()
end

function hide()
  cleanEvents()
  for i = 1, 12 do
    local ic = icons['Icon'..i]
    if ic then
      ic.icon:hide()
      ic.progress:setVisible(false)
      ic.progress:setTooltip(nil)
      ic.progress:setText("")
      ic.progress:setPercent(100)
    end
  end
  cdBarWin:setVisible(false)
end


function show()
    cdBarWin:setVisible(true)
end
-- End public functions
