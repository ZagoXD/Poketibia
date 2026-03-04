local win
local confirmWin
local suppressNextUi = false

local LABELS = {
  [1]  = { n = "Fire Stone",     s = "Shining Fire Stone" },
  [2]  = { n = "Enigma Stone",   s = "Shining Enigma Stone" },
  [3]  = { n = "Thunder Stone",  s = "Shining Thunder Stone" },
  [4]  = { n = "Water Stone",    s = "Shining Water Stone" },
  [5]  = { n = "Rock Stone",     s = "Shining Rock Stone" },
  [6]  = { n = "Crystal Stone",  s = "Shining Crystal Stone" },
  [7]  = { n = "Leaf Stone",     s = "Shining Leaf Stone" },
  [8]  = { n = "Venom Stone",    s = "Shining Venom Stone" },
  [9]  = { n = "Coccon Stone",   s = "Shining Coccon Stone" },
  [10] = { n = "Earth Stone",    s = "Shining Earth Stone" },
  [11] = { n = "Heart Stone",    s = "Shining Heart Stone" },
  [12] = { n = "Ice Stone",      s = "Shining Ice Stone" },
  [13] = { n = "Darkness Stone", s = "Shining Darkness Stone" },
  [14] = { n = "Punch Stone",    s = "Shining Punch Stone" }
}

local anchorPos = nil
local watchEvent = nil

local function cancelWatch()
  if watchEvent then
    removeEvent(watchEvent)
    watchEvent = nil
  end
  anchorPos = nil
end

local function destroyConfirm()
  if confirmWin then
    confirmWin:destroy()
    confirmWin = nil
  end
end

local function hide()
  destroyConfirm()
  cancelWatch()
  if win then
    win:destroy()
    win = nil
  end
end

local function startClientWatch()
  cancelWatch()
  if not anchorPos then return end
  local function tick()
    if not win or not anchorPos then watchEvent=nil; return end
    local lp = g_game.getLocalPlayer()
    if not lp then watchEvent=nil; return end
    local p = lp:getPosition()
    if not p then watchEvent=nil; return end
    local far = (p.z ~= anchorPos.z)
      or (math.abs(p.x - anchorPos.x) > 1)
      or (math.abs(p.y - anchorPos.y) > 1)
    if far then
      hide()
      watchEvent = nil
      return
    end
    watchEvent = scheduleEvent(tick, 200)
  end
  watchEvent = scheduleEvent(tick, 200)
end

local function openConfirm(idx)
  destroyConfirm()
  local parent = win or modules.game_interface.getRootPanel()
  confirmWin = g_ui.displayUI('confirm_buy', parent)
  if not confirmWin then
    print('[shinypanel] failed to load confirm_buy.otui')
    return
  end

  local msg = confirmWin:recursiveGetChildById('msg')
  if msg then
    local L = LABELS[idx] or { n = "Stone", s = "Shining Stone" }
    msg:setText(string.format("Voce quer trocar 20x %s e 5x Shiny Dust por 1x %s. Confirmar?", L.n, L.s))
  end

  local yes = confirmWin:recursiveGetChildById('yes')
  local no  = confirmWin:recursiveGetChildById('no')

  if yes then
    local x = idx
    yes.onClick = function()
      g_game.talk('!spbuy ' .. x)
      destroyConfirm()
    end
  end
  if no then
    no.onClick = function() destroyConfirm() end
  end

  confirmWin:show(); confirmWin:raise(); confirmWin:focus()
end

local function bindButtons()
  local btn = win:recursiveGetChildById('close')
  if btn then btn.onClick = function() hide() end end

  for i = 1, 14 do
    local b = win:recursiveGetChildById('buy' .. i)
    if b then
      local idx = i
      b.onMouseRelease = function(_, _, mouseButton)
        if mouseButton == MouseLeftButton then
          openConfirm(idx)
        end
      end
    end
  end
end

local function show()
  if not win then
    win = g_ui.displayUI('shinypanel', modules.game_interface.getRootPanel())
    if not win then
      print('[shinypanel] failed to load shinypanel.otui')
      return
    end
    bindButtons()
  end
  win:show(); win:raise(); win:focus()
end

local function parseOpenWithPos(text)
  local x,y,z = text:match("%[SHINYPANEL%]%s*OPEN%s*X=(%d+);Y=(%d+);Z=(%d+)")
  if x and y and z then
    return { x = tonumber(x), y = tonumber(y), z = tonumber(z) }
  end
  return nil
end

local function parsePayload(text)
  if not text then return false end
  return text:find("%[SHINYPANEL%]") ~= nil
end

local function onTextMessage(_, text)
  if suppressNextUi then suppressNextUi = false; return false end

  if text and text:find("%[SHINYPANEL%]%s*HIDE") then
    hide()
    return true
  end

  if parsePayload(text) then
    local pos = parseOpenWithPos(text)
    if pos then
      anchorPos = pos
    else
      anchorPos = nil
    end
    show()
    if anchorPos then startClientWatch() end
    return true
  end
end

shinypanel = {
  show = show,
  hide = hide,
  toggle = function() if win and win:isVisible() then hide() else show() end end
}

function init()
  connect(g_game, { onTextMessage = onTextMessage, onGameStart = hide, onGameEnd = hide })
end

function terminate()
  disconnect(g_game, { onTextMessage = onTextMessage, onGameStart = hide, onGameEnd = hide })
  hide()
end
