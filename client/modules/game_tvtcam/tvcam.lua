local horas, mins, secs = 0, 0, 0
local channelName = ""
local playerChannelCreator = ""
local contagem = nil
local reset = false
local channelsList = nil
local password, playerPassName = "", ""
local users = 0
local keybinds = {}

local isWatching = false
local watchingName = ""

local deadWindow
local tvcamCreate
local tvcamList
local tvcamPassword
local mapConn = nil

local function safeUnbind(key)
    if key then
        pcall(function()
            g_keyboard.unbindKeyPress(key)
        end)
    end
end

local function releaseBinds()
    if keybinds._locked then
        safeUnbind(keybinds.up)
        safeUnbind(keybinds.down)
        safeUnbind(keybinds.left)
        safeUnbind(keybinds.right)
        keybinds = {}
    end
end

function requestListEcho(buffer)
    if buffer == "requestList" then
        g_game.getProtocolGame():sendExtendedOpcode(125, "requestList")
    end
end

function deleteChannel(buffer)
    if buffer == "deleteChannel" then
		modules.game_console.removeTabTv()
    end
end

function init()
    connect(g_game, {
        onGameEnd = onGameEnd
    })

    ProtocolGame.registerExtendedOpcode(125, function(protocol, opcode, buffer)
        requestListEcho(buffer)
        doCountPlayer(buffer)
        closeChanneGravando(buffer)
        doRequestPassword(buffer)
        openCreate(buffer)
        doGravando(buffer)
        checkListChannels(buffer)
        openWatching(buffer)
		deleteChannel(buffer)
    end)

    deadWindow = g_ui.displayUI('tvcam')
    tvcamCreate = g_ui.displayUI('tvcamCreate')
    tvcamList = g_ui.displayUI('tvcamList')
    tvcamPassword = g_ui.displayUI('tvcamPassword')

    deadWindow:hide()
    tvcamCreate:hide()
    tvcamList:hide()
    tvcamPassword:hide()
end

function terminate()
    if g_game.setSelfHidden then
        g_game.setSelfHidden(false)
    end
    releaseBinds()
    disconnect(g_game, {
        onGameEnd = onGameEnd
    })
    if deadWindow then
        deadWindow:destroy()
    end
    if tvcamCreate then
        tvcamCreate:destroy()
    end
    if tvcamList then
        tvcamList:destroy()
    end
    if tvcamPassword then
        tvcamPassword:destroy()
    end
end

function onGameEnd()
    if g_game.setSelfHidden then
        g_game.setSelfHidden(false)
    end
    releaseBinds()
    if deadWindow then
        deadWindow:destroy()
    end
    if tvcamCreate then
        tvcamCreate:destroy()
    end
    if tvcamList then
        tvcamList:destroy()
    end
    if tvcamPassword then
        tvcamPassword:destroy()
    end
end

function show()
    if not deadWindow then
        deadWindow = g_ui.displayUI('tvcam')
    end
    deadWindow:show()
    deadWindow:raise()
    deadWindow:focus()
end

function hide(hidden)
    if hidden == 1 then
        if deadWindow then
            deadWindow:hide()
        end
        horas, mins, secs = 0, 0, 0
        channelName = ""
    elseif hidden == 2 then
        if tvcamCreate then
            tvcamCreate:hide()
        end
    elseif hidden == 3 then
        if tvcamList then
            tvcamList:hide()
            channelsList = nil
            tvcamList:destroy()
            tvcamList = nil
            playerChannelCreator = ""
        end
    else
        if tvcamPassword then
            tvcamPassword:hide()
        end
        password = ""
        playerPassName = ""
    end
end

function doCountPlayer(buffer)
    if buffer:find("^users:") then
        local parts = buffer:explode(":")
        users = tonumber(parts[2]) or 0

        if isWatching and deadWindow then
            local lblName = deadWindow:getChildById("tvCamNameLabel")
            if lblName then
                lblName:setText((watchingName ~= "" and watchingName or "channel") .. " (" .. users .. ")")
            end
        end
        return
    end

    if buffer == "add" then
        users = users + 1
    elseif buffer == "remove" then
        users = math.max(0, users - 1)
    end
end


function openCreate(buffer)
    if buffer ~= "doCreate" then
        return true
    end
    tvcamCreate = g_ui.displayUI('tvcamCreate')
    tvcamCreate:show()
end

function doGravando(buffer)
    if not buffer:find("contar") then
        return true
    end
    hide(2)
    deadWindow = g_ui.displayUI('tvcam')
    local strings = buffer:explode(":")
    channelName = strings[2] or ""
    isWatching = false
    watchingName = ""
    users = 0
    local lblTop = deadWindow:getChildById("tvCamLabel")
    local lblName = deadWindow:getChildById("tvCamNameLabel")
    if lblTop then
        lblTop:setText("Gravando...")
    end
    if lblName then
        lblName:setText((channelName ~= "" and channelName or "Channel") .. " - 00:00:00 (" .. users .. ")")
    end

    local btnNxt = deadWindow:getChildById("proximo")
    local btnPrv = deadWindow:getChildById("anterior")
    if btnNxt then
        btnNxt:setVisible(false)
    end
    if btnPrv then
        btnPrv:setVisible(false)
    end

    deadWindow:show()
    reset = false
    horas, mins, secs = 0, 0, 0
    countTime()
end

function openWatching(buffer)
    if not buffer:find("^watching:") then
        return true
    end
    local parts = buffer:explode(":")
    watchingName = parts[2] or "channel"
    isWatching = true

    if g_game.setSelfHidden then
        g_game.setSelfHidden(true)
    end

    deadWindow = g_ui.displayUI('tvcam')

    local lblTop = deadWindow:getChildById("tvCamLabel")
    local lblName = deadWindow:getChildById("tvCamNameLabel")
    if lblTop then
        lblTop:setText("Assistindo...")
    end
    if lblName then
        lblName:setText(watchingName .. " (" .. users .. ")")
    end

    local btnNxt = deadWindow:getChildById("proximo")
    local btnPrv = deadWindow:getChildById("anterior")
    if btnNxt then
        btnNxt:setVisible(false)
    end
    if btnPrv then
        btnPrv:setVisible(false)
    end

    deadWindow:show()
    if not keybinds._locked then
        keybinds._locked = true
        keybinds.up = g_keyboard.bindKeyPress('Up', function()
            return true
        end, nil, true)
        keybinds.down = g_keyboard.bindKeyPress('Down', function()
            return true
        end, nil, true)
        keybinds.left = g_keyboard.bindKeyPress('Left', function()
            return true
        end, nil, true)
        keybinds.right = g_keyboard.bindKeyPress('Right', function()
            return true
        end, nil, true)
    end
    if not mapConn and g_game then
    mapConn = connect(g_game, {
        onGameEnd = function()
            if mapConn and g_game then
                disconnect(g_game, mapConn)
                mapConn = nil
            end
        end
    })
end

if gameMapPanel then
    connect(gameMapPanel, {
        onMousePress = function()
            if isWatching then
                return true
            end
        end,
        onMouseRelease = function()
            if isWatching then
                return true
            end
        end
    })
end

end

function doRequestTvCamCreate()
    local name = tvcamCreate:getChildById('channelNameText'):getText()
    local senha = tvcamCreate:getChildById('channelPasswordText'):getText()
    local useSenha = tvcamCreate:getChildById('usePassword'):isChecked()
    g_game.getProtocolGame():sendExtendedOpcode(125, "create/" .. name .. "/" .. (useSenha and senha or "notASSenha"))
end

function countTime()
    if reset then
        if contagem then
            removeEvent(contagem)
        end
        return true
    end

    secs = secs + 1
    if secs > 59 then
        mins = mins + 1;
        secs = 0
    end
    if mins > 59 then
        horas = horas + 1;
        mins = 0;
        secs = 0
    end

    local lblName = deadWindow and deadWindow:getChildById("tvCamNameLabel")
    if lblName then
        lblName:setText((channelName ~= "" and channelName or "Channel") .. " - " ..
                            (horas < 10 and "0" .. horas or horas) .. ":" .. (mins < 10 and "0" .. mins or mins) .. ":" ..
                            (secs < 10 and "0" .. secs or secs) .. " (" .. users .. ")")
    end

    contagem = scheduleEvent(countTime, 1000)
end

function closeChanne()
	modules.game_console.removeTabTv()
--g_game.getProtocolGame():sendExtendedOpcode(125, "TVcloseTabChannel")
    local wasWatching = isWatching

    hide(1)

    horas, mins, secs = 0, 0, 0
    reset = true

    -- if wasWatching then
        -- g_game.getProtocolGame():sendExtendedOpcode(125, "unwatch/")
    -- else
        -- g_game.getProtocolGame():sendExtendedOpcode(125, "close/")
    -- end
	--g_game.getProtocolGame():sendExtendedOpcode(125, "TVcloseTabChannel")
	
    if g_game.setSelfHidden then
        g_game.setSelfHidden(false)
    end

    channelName = ""
    isWatching = false
    watchingName = ""
    releaseBinds()
    if mapConn then
        disconnect(g_game, mapConn);
        mapConn = nil
    end
end

function closeChanneGravando(buffer)
    if not buffer:find("closeGraveando") then
        return true
    end
    hide(1)
    horas, mins, secs = 0, 0, 0
    channelName = ""
    reset = true
    isWatching = false
    watchingName = ""
    users = 0
    if g_game.setSelfHidden then
        g_game.setSelfHidden(false)
    end

    releaseBinds()
end

function checkListChannels(buffer)
    if not buffer:find("openAllTVS") then
        return true
    end

    tvcamList = g_ui.displayUI('tvcamList')
    if not tvcamList then return true end

    channelsList = tvcamList:getChildById('characters')
    if not channelsList then return true end

    local children = channelsList:getChildren()
    for i = 1, #children do children[i]:destroy() end

    local channels = buffer:explode("|")
    for i = 2, #channels do
        local row = channels[i]
        if row and row ~= "" then
            local parts = row:explode("/")
            if #parts >= 2 then
                local widget = g_ui.createWidget('CharacterWidget', channelsList)
                if widget then
                    local nameWidget = widget:getChildById("name")
                    if nameWidget then
                        local viewers = tonumber(parts[4] or "0") or 0
                        nameWidget:setText(parts[1] .. "/" .. parts[2] .. " (" .. viewers .. ")")
                    end
                    if parts[3] and parts[3] ~= "notASSenha" then
                        local icon = widget:getChildById("iconPass")
                        if icon then icon:setVisible(true) end
                    end
                    connect(widget, {
                        onDoubleClick = function()
                            hide(3)
                            g_game.getProtocolGame():sendExtendedOpcode(125, "watch/" .. parts[1])
                            return true
                        end
                    })
                end
            end
        end
    end

    tvcamList:show()
end

function doWatch()
    channelsList = tvcamList and tvcamList:getChildById('characters')
    local selected = channelsList and channelsList:getFocusedChild()
    if selected then
        local nameLabel = selected:getChildById("name")
        local text = nameLabel and nameLabel:getText() or ""
        local chan = text:explode("/")[1]
        if chan and chan ~= "" then
            g_game.getProtocolGame():sendExtendedOpcode(125, "watch/" .. chan)
            hide(3)
            return
        end
    end
    displayErrorBox(tr('Error'), tr('Selecione um canal para assistir.'))
end

function doRequestPassword(buffer)
    if not buffer:find("^requestPass|") then
        return true
    end
    local parts = buffer:explode("|")
    playerPassName = parts[2] or ""
    tvcamPassword = g_ui.displayUI('tvcamPassword')
    tvcamPassword:show()
    local input = tvcamPassword:getChildById("channelPasswordText")
    if input then input:setText("") end
end

function checkPasswords()
    local typed = tvcamPassword:getChildById("channelPasswordText"):getText()
    if (playerPassName or "") ~= "" then
        g_game.getProtocolGame():sendExtendedOpcode(125, "watchWithPass/" .. playerPassName .. "/" .. typed)
    end
    hide(4)
end