local pokedexButton, fishingButton, movesButton, marketButton
local currentSlot = 0

local MOVES_ICON = '/modules/movesui/images/punch2'
local MARKET_ICON = '/modules/marketui/images/trade'
local ROPE_ICON = '/data/images/rope'

local function toggleMovesUi()

    if g_game.getFeature and g_game.getFeature(GameExtendedOpcode) and g_game.sendExtendedOpcode then
        g_game.sendExtendedOpcode(103, "toggle")
    else
        if g_game.isOnline() then
            g_game.talk('!moves ui')
        end
    end
end

local function toggleMarketUi()
    if g_game.isOnline() then
        g_game.talk('/market list')
    end
end

local function startChooseTile(releaseCallback)
  if g_ui.isMouseGrabbed() then return end
  if not releaseCallback then error("No mouse release callback parameter set.") end
  local mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)
  connect(mouseGrabberWidget, { onMouseRelease = releaseCallback })
  mouseGrabberWidget:grabMouse()
  g_mouse.pushCursor('target')
end

local function onClickRopeMouse(self, mousePosition, mouseButton)
  if mouseButton == MouseLeftButton then
    local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
    if clickedWidget and clickedWidget:getClassName() == 'UIMap' then
      local tile = clickedWidget:getTile(mousePosition)
      if tile then
        local pos = tile:getPosition()
        g_game.talk(string.format('/rope %d %d %d', pos.x, pos.y, pos.z))
      end
    end
  end
  g_mouse.popCursor('target')
  self:ungrabMouse()
  return true
end

local function toggleRope()
  startChooseTile(onClickRopeMouse)
end

function init()
    connect(g_game, {
        onGameStart = enableHotkey,
        onGameEnd = disableHotkey
    })

    pokedexButton = modules.client_topmenu.addRightGameButton('pokedexButton', tr('Pokedex') .. ' (Ctrl+D)',
        '/images/topbuttons/pokedex', togglePokedex)
    pokedexButton:setWidth(34)

    fishingButton = modules.client_topmenu.addRightGameButton('fishingButton', tr('Fishing') .. ' (Ctrl+Z)',
        '/images/topbuttons/fishing', toggleFishing)
    fishingButton:setWidth(32)

    ropeButton = modules.client_topmenu.addRightGameButton('ropeButton', tr('Rope') .. ' (Ctrl+R)', ROPE_ICON,
        toggleRope)
    ropeButton:setWidth(32)

    movesButton = modules.client_topmenu.addRightGameButton('movesUiButton', tr('Moves UI') .. ' (Ctrl+S)', MOVES_ICON,
        toggleMovesUi)
    movesButton:setWidth(32)

    marketButton = modules.client_topmenu.addRightGameButton('marketUIButton', tr('Market') .. ' (Ctrl+M)', MARKET_ICON,
        toggleMarketUi)
    marketButton:setWidth(32)
end

function terminate()
    disconnect(g_game, {
        onGameStart = enableHotkey,
        onGameEnd = disableHotkey
    })

    if ropeButton then
        ropeButton:destroy()
    end

    if pokedexButton then
        pokedexButton:destroy()
    end
    if fishingButton then
        fishingButton:destroy()
    end
    if movesButton then
        movesButton:destroy()
    end
    if marketButton then
        marketButton:destroy()
    end
end

function enableHotkey()
    local player = g_game.getLocalPlayer()
    if not player or player:getName() == 'Account Manager' then
        if pokedexButton then
            pokedexButton:hide()
        end
        if fishingButton then
            fishingButton:hide()
        end
        if movesButton then
            movesButton:hide()
        end
        if marketButton then
            marketButton:hide()
        end
    else
        if pokedexButton then
            pokedexButton:show()
        end
        if fishingButton then
            fishingButton:show()
        end
        if movesButton then
            movesButton:show()
        end
        if marketButton then
            marketButton:show()
        end
    end

    if not player or player:getName() == 'Account Manager' then
        if ropeButton then
            ropeButton:hide()
        end
    else
        if ropeButton then
            ropeButton:show()
        end
    end

    g_keyboard.bindKeyDown('Ctrl+R', toggleRope)

    g_keyboard.bindKeyDown('Ctrl+D', togglePokedex)
    g_keyboard.bindKeyDown('Ctrl+Z', toggleFishing)
    g_keyboard.bindKeyDown('Ctrl+S', toggleMovesUi)
    g_keyboard.bindKeyDown('Ctrl+M', toggleMarketUi)
end

function disableHotkey()
    g_keyboard.unbindKeyDown('Ctrl+D')
    g_keyboard.unbindKeyDown('Ctrl+Z')
    g_keyboard.unbindKeyDown('Ctrl+S')
    g_keyboard.unbindKeyDown('Ctrl+M')
    g_keyboard.unbindKeyDown('Ctrl+R')
end

function startChooseItem(releaseCallback)
    if g_ui.isMouseGrabbed() then
        return
    end
    if not releaseCallback then
        error("No mouse release callback parameter set.")
    end
    local mouseGrabberWidget = g_ui.createWidget('UIWidget')
    mouseGrabberWidget:setVisible(false)
    mouseGrabberWidget:setFocusable(false)
    connect(mouseGrabberWidget, {
        onMouseRelease = releaseCallback
    })
    mouseGrabberWidget:grabMouse()
    g_mouse.pushCursor('target')
end

function onClickWithMouse(self, mousePosition, mouseButton)
    local item = nil
    if mouseButton == MouseLeftButton then
        local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
        if clickedWidget then
            if clickedWidget:getClassName() == 'UIMap' then
                local tile = clickedWidget:getTile(mousePosition)
                if tile then
                    if currentSlot == 1 then
                        item = tile:getGround()
                    else
                        local thing = tile:getTopMoveThing()
                        if thing and thing:isItem() then
                            item = thing
                        else
                            item = tile:getTopCreature()
                        end
                    end
                end
            elseif clickedWidget:getClassName() == 'UICreatureButton' then
                item = clickedWidget:getCreature()
            end
        end
    end

    if item then
        local player = g_game.getLocalPlayer()
        g_game.useInventoryItemWith(player:getInventoryItem(currentSlot):getId(), item)
    end

    g_mouse.popCursor('target')
    self:ungrabMouse()
    return true
end

function togglePokedex()
    currentSlot = 6
    startChooseItem(onClickWithMouse)
end

function toggleOrder()
    currentSlot = 4
    startChooseItem(onClickWithMouse)
end

function toggleFishing()
    currentSlot = 2
    startChooseItem(onClickWithMouse)
end
