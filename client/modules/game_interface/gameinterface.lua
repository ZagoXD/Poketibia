-- 55294365
WALK_STEPS_RETRY = 10

gameRootPanel = nil
gameMapPanel = nil
gameRightPanel = nil
gameLeftPanel = nil
gameBottomPanel = nil
logoutButton = nil
mouseGrabberWidget = nil
countWindow = nil
logoutWindow = nil
exitWindow = nil
bottomSplitter = nil
limitedZoom = false
currentViewMode = 0
smartWalkDirs = {}
smartWalkDir = nil
walkFunction = nil
-- local TVBLOCK = false
local INIT_TW, INIT_TH = nil, nil
local INIT_ZOOM = 17

local POKEBALL_ON_IDS = {}
local PB_SYNC_CODE = 205

local CHAT_WIDTH_RATIO = 0.70
local CHAT_MIN_WIDTH = 640
local CHAT_ALPHA_IDLE = '#FFFFFF80'
local CHAT_ALPHA_ACTIVE = '#FFFFFFE6'
local chatOpacityTimer = nil

local function widgetIsDescendantOf(child, parent)
    while child do
        if child == parent then
            return true
        end
        child = child:getParent()
    end
    return false
end

local function getCodeBuffer(text, code)
    local prefix = "&sco&," .. tostring(code) .. ","
    local pos = text:find(prefix, 1, true)
    if not pos then
        return nil
    end
    return text:sub(pos + #prefix)
end

local function onPbSyncMessage(mode, text)
    local payload = getCodeBuffer(text, PB_SYNC_CODE)
    if not payload then
        return false
    end

    local t = {}
    for num in tostring(payload):gmatch("(%d+)") do
        t[tonumber(num)] = true
    end
    POKEBALL_ON_IDS = t
    return true
end

local function isChatFocused()
    local fw = g_ui.getFocusWidget and g_ui.getFocusWidget() or nil
    return fw and widgetIsDescendantOf(fw, gameBottomPanel) or false
end

local function refreshChatOpacity()
    if not gameBottomPanel then
        return
    end
    local hovered = gameBottomPanel.isHovered and gameBottomPanel:isHovered() or false
    local active = hovered or isChatFocused()
    gameBottomPanel:setImageColor(active and CHAT_ALPHA_ACTIVE or CHAT_ALPHA_IDLE)
end

local function adjustChatWidth()
    if not (gameRootPanel and gameBottomPanel) then
        return
    end
    local pw = gameRootPanel:getWidth()
    if pw <= 0 then
        return
    end

    local target = math.floor(math.max(CHAT_MIN_WIDTH, pw * CHAT_WIDTH_RATIO))
    target = math.min(target, pw)

    local margin = math.floor((pw - target) / 2)
    gameBottomPanel:setMarginLeft(margin)
    gameBottomPanel:setMarginRight(margin)
end

local function recomputeVisibleDimension()
    if not gameMapPanel then
        return
    end

    local w, h = gameMapPanel:getWidth(), gameMapPanel:getHeight()
    if w < 32 or h < 32 then
        return
    end

    local tw = math.floor(w / 32)
    local th = math.floor(h / 32)

    tw = math.max(15, tw)
    th = math.max(11, th)

    if tw % 2 == 0 then
        tw = tw - 1
    end
    if th % 2 == 0 then
        th = th - 1
    end

    if not INIT_TW or not INIT_TH then
        INIT_TW, INIT_TH = tw, th
    else
        tw = math.min(tw, INIT_TW)
        th = math.min(th, INIT_TH)
    end

    gameMapPanel:setKeepAspectRatio(false)
    gameMapPanel:setLimitVisibleRange(true)
    gameMapPanel:setVisibleDimension({
        width = tw,
        height = th
    })

    gameMapPanel:setZoom(INIT_ZOOM)

    if g_game.isOnline() then
        g_game.changeMapAwareRange(tw + 3, th + 3)
    end
end

function init()
    g_ui.importStyle('styles/countwindow')

    connect(g_game, {
        onGameStart = onGameStart,
        onGameEnd = onGameEnd,
        onLoginAdvice = onLoginAdvice
    }, true)

    connect(g_game, {
        onTextMessage = onPbSyncMessage
    }, true)

    gameRootPanel = g_ui.displayUI('gameinterface')
    gameRootPanel:hide()
    gameRootPanel:lower()
    gameRootPanel.onGeometryChange = function()
        updateStretchShrink()
        adjustChatWidth()
    end
    gameRootPanel.onFocusChange = stopSmartWalk

    mouseGrabberWidget = gameRootPanel:getChildById('mouseGrabber')
    mouseGrabberWidget.onMouseRelease = onMouseGrabberRelease

    bottomSplitter = gameRootPanel:getChildById('bottomSplitter')
    gameMapPanel = gameRootPanel:getChildById('gameMapPanel')
    gameMapPanel.onGeometryChange = function()
        recomputeVisibleDimension()
    end
    backGameRightPanel = gameRootPanel:getChildById('backgroundGameRightPanel')
    gameRightPanel = gameRootPanel:getChildById('gameRightPanel')
    backGameLeftPanel = gameRootPanel:getChildById('backgroundGameLeftPanel')
    skinLeft = gameRootPanel:getChildById('skinLeft')
    gameLeftPanel = gameRootPanel:getChildById('gameLeftPanel')
    gameBottomPanel = gameRootPanel:getChildById('gameBottomPanel')
    gameBottomPanel.onHoverChange = function()
        refreshChatOpacity()
    end
    addEvent(refreshChatOpacity)
    connect(gameLeftPanel, {
        onVisibilityChange = onLeftPanelVisibilityChange
    })

    logoutButton = modules.client_topmenu.addLeftButton('logoutButton', tr('Exit'), '/images/topbuttons/logout',
        tryLogout, true)
    logoutButton:setWidth(32)

    setupViewMode(0)

    bindKeys()
    load()

    if g_game.isOnline() then
        show()
    end
end
function onClientVersionChange(version)
    g_things.loadOtml('/things/things.otml')
end

function bindKeys()
    gameRootPanel:setAutoRepeatDelay(200)

    bindWalkKey('Up', North)
    bindWalkKey('Right', East)
    bindWalkKey('Down', South)
    bindWalkKey('Left', West)
    bindWalkKey('Numpad8', North)
    bindWalkKey('Numpad9', NorthEast)
    bindWalkKey('Numpad6', East)
    bindWalkKey('Numpad3', SouthEast)
    bindWalkKey('Numpad2', South)
    bindWalkKey('Numpad1', SouthWest)
    bindWalkKey('Numpad4', West)
    bindWalkKey('Numpad7', NorthWest)

    g_keyboard.bindKeyPress('Ctrl+Up', function()
        g_game.turn(North)
        changeWalkDir(North)
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Ctrl+Right', function()
        g_game.turn(East)
        changeWalkDir(East)
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Ctrl+Down', function()
        g_game.turn(South)
        changeWalkDir(South)
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Ctrl+Left', function()
        g_game.turn(West)
        changeWalkDir(West)
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Ctrl+Numpad8', function()
        g_game.turn(North)
        changeWalkDir(North)
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Ctrl+Numpad6', function()
        g_game.turn(East)
        changeWalkDir(East)
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Ctrl+Numpad2', function()
        g_game.turn(South)
        changeWalkDir(South)
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Ctrl+Numpad4', function()
        g_game.turn(West)
        changeWalkDir(West)
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Escape', function()
        g_game.cancelAttackAndFollow()
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Ctrl+=', function()
        gameMapPanel:zoomIn()
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Ctrl+-', function()
        gameMapPanel:zoomOut()
    end, gameRootPanel)
    g_keyboard.bindKeyDown('Ctrl+Q', function()
        tryLogout(true)
    end, gameRootPanel)
    g_keyboard.bindKeyDown('Ctrl+L', function()
        tryLogout(true)
    end, gameRootPanel)
    g_keyboard.bindKeyDown('Ctrl+W', function()
        g_map.cleanTexts()
        modules.game_textmessage.clearMessages()
    end, gameRootPanel)
    g_keyboard.bindKeyDown('Ctrl+.', nextViewMode, gameRootPanel)
end

function bindWalkKey(key, dir)
    g_keyboard.bindKeyDown(key, function()
        changeWalkDir(dir)
    end, gameRootPanel, true)
    g_keyboard.bindKeyUp(key, function()
        changeWalkDir(dir, true)
    end, gameRootPanel, true)
    g_keyboard.bindKeyPress(key, function()
        smartWalk(dir)
    end, gameRootPanel)
end

function unbindWalkKey(key)
    g_keyboard.unbindKeyDown(key, gameRootPanel)
    g_keyboard.unbindKeyUp(key, gameRootPanel)
    g_keyboard.unbindKeyPress(key, gameRootPanel)
end

function terminate()
    save()
    hide()

    if chatOpacityTimer then
        removeEvent(chatOpacityTimer)
        chatOpacityTimer = nil
    end

    stopSmartWalk()

    disconnect(g_game, {
        onGameStart = onGameStart,
        onGameEnd = onGameEnd,
        onLoginAdvice = onLoginAdvice
    })

    disconnect(g_game, {
        onTextMessage = onPbSyncMessage
    })

    disconnect(gameLeftPanel, {
        onVisibilityChange = onLeftPanelVisibilityChange
    })

    logoutButton:destroy()
    gameRootPanel:destroy()
end

function onGameStart()
    show()

    -- open tibia has delay in auto walking
    if not g_game.isOfficialTibia() then
        g_game.enableFeature(GameForceFirstAutoWalkStep)
    else
        g_game.disableFeature(GameForceFirstAutoWalkStep)
    end
end

function onGameEnd()
    setupViewMode(0)
    hide()
end

function show()
    connect(g_app, {
        onClose = tryExit
    })
    modules.client_background.hide()
    gameRootPanel:show()
    gameRootPanel:focus()
    gameMapPanel:followCreature(g_game.getLocalPlayer())
    setupViewMode(0)
    updateStretchShrink()
    logoutButton:setTooltip(tr('Logout'))

    addEvent(function()
        if not limitedZoom or g_game.isGM() then
            gameMapPanel:setMaxZoomOut(INIT_ZOOM) -- não deixa “Ctrl -” passar do normal
            gameMapPanel:setLimitVisibleRange(true)
            gameMapPanel:setZoom(INIT_ZOOM)
        else
            gameMapPanel:setMaxZoomOut(11)
            gameMapPanel:setLimitVisibleRange(false)
        end
        adjustChatWidth()
        if not chatOpacityTimer then
            chatOpacityTimer = cycleEvent(refreshChatOpacity, 100)
        end
    end)
end

function hide()
    disconnect(g_app, {
        onClose = tryExit
    })
    logoutButton:setTooltip(tr('Exit'))

    if logoutWindow then
        logoutWindow:destroy()
        logoutWindow = nil
    end
    if exitWindow then
        exitWindow:destroy()
        exitWindow = nil
    end
    if countWindow then
        countWindow:destroy()
        countWindow = nil
    end
    gameRootPanel:hide()
    modules.client_background.show()
end

function save()
    local settings = {}
    settings.splitterMarginBottom = bottomSplitter:getMarginBottom()
    settings.imageSkin = modules.client_options.getImageSkin()
    g_settings.setNode('game_interface', settings)
end

function load()
    local settings = g_settings.getNode('game_interface')
    if settings then
        if settings.splitterMarginBottom then
            bottomSplitter:setMarginBottom(settings.splitterMarginBottom)
        end
        if settings.imageSkin then
            skinLeft:setImageSource(settings.imageSkin)
        end
    end
end

function onLoginAdvice(message)
    displayInfoBox(tr("For Your Information"), message)
end

function forceExit()
    g_game.cancelLogin()
    scheduleEvent(exit, 10)
    return true
end

function tryExit()
    if exitWindow then
        return true
    end

    local exitFunc = function()
        g_game.safeLogout()
        forceExit()
    end
    local logoutFunc = function()
        g_game.safeLogout()
        exitWindow:destroy()
        exitWindow = nil
    end
    local cancelFunc = function()
        exitWindow:destroy()
        exitWindow = nil
    end

    exitWindow = displayGeneralBox(tr('Exit'), tr(
        "If you shut down the program, your character might stay in the game.\nClick on 'Logout' to ensure that you character leaves the game properly.\nClick on 'Exit' if you want to exit the program without logging out your character."),
        {
            {
                text = tr('Force Exit'),
                callback = exitFunc
            },
            {
                text = tr('Logout'),
                callback = logoutFunc
            },
            {
                text = tr('Cancel'),
                callback = cancelFunc
            },
            anchor = AnchorHorizontalCenter
        }, logoutFunc, cancelFunc)

    return true
end

function tryLogout(prompt)
    if type(prompt) ~= "boolean" then
        prompt = true
    end
    if not g_game.isOnline() then
        exit()
        return
    end

    if logoutWindow then
        return
    end

    local msg, yesCallback
    if not g_game.isConnectionOk() then
        msg =
            'Your connection is failing, if you logout now your character will be still online, do you want to force logout?'

        yesCallback = function()
            g_game.forceLogout()
            if logoutWindow then
                logoutWindow:destroy()
                logoutWindow = nil
            end
        end
    else
        msg = 'Are you sure you want to logout?'

        yesCallback = function()
            g_game.safeLogout()
            if logoutWindow then
                logoutWindow:destroy()
                logoutWindow = nil
            end
        end
    end

    local noCallback = function()
        logoutWindow:destroy()
        logoutWindow = nil
    end

    if prompt then
        logoutWindow = displayGeneralBox(tr('Logout'), tr(msg), {
            {
                text = tr('Yes'),
                callback = yesCallback
            },
            {
                text = tr('No'),
                callback = noCallback
            },
            anchor = AnchorHorizontalCenter
        }, yesCallback, noCallback)
    else
        yesCallback()
    end
end

function stopSmartWalk()
    smartWalkDirs = {}
    smartWalkDir = nil
end

function changeWalkDir(dir, pop)
    while table.removevalue(smartWalkDirs, dir) do
    end
    if pop then
        if #smartWalkDirs == 0 then
            stopSmartWalk()
            return
        end
    else
        table.insert(smartWalkDirs, 1, dir)
    end

    smartWalkDir = smartWalkDirs[1]
    if modules.client_options.getOption('smartWalk') and #smartWalkDirs > 1 then
        for _, d in pairs(smartWalkDirs) do
            if (smartWalkDir == North and d == West) or (smartWalkDir == West and d == North) then
                smartWalkDir = NorthWest
                break
            elseif (smartWalkDir == North and d == East) or (smartWalkDir == East and d == North) then
                smartWalkDir = NorthEast
                break
            elseif (smartWalkDir == South and d == West) or (smartWalkDir == West and d == South) then
                smartWalkDir = SouthWest
                break
            elseif (smartWalkDir == South and d == East) or (smartWalkDir == East and d == South) then
                smartWalkDir = SouthEast
                break
            end
        end
    end
end

function smartWalk(dir)
    if g_keyboard.getModifiers() == KeyboardNoModifier then
        local func = walkFunction
        if not func then
            if modules.client_options.getOption('dashWalk') then
                func = g_game.dashWalk
            else
                func = g_game.walk
            end
        end
        local dire = smartWalkDir or dir
        func(dire)
        return true
    end
    return false
end

function updateStretchShrink()
    if modules.client_options.getOption('dontStretchShrink') and not alternativeView then
        gameMapPanel:setVisibleDimension({
            width = 15,
            height = 11
        })
        bottomSplitter:setMarginBottom(bottomSplitter:getMarginBottom() + (gameMapPanel:getHeight() - 32 * 11) - 10)
    end
    recomputeVisibleDimension()
end

function onMouseGrabberRelease(self, mousePosition, mouseButton)
    if selectedThing == nil then
        return false
    end
    if mouseButton == MouseLeftButton or mouseButton == MouseMidButton then
        local clickedWidget = gameRootPanel:recursiveGetChildByPos(mousePosition, false)
        if clickedWidget then
            if selectedType == 'use' then
                onUseWith(clickedWidget, mousePosition)
            elseif selectedType == 'trade' then
                onTradeWith(clickedWidget, mousePosition)
            end
        end
    end

    selectedThing = nil
    g_mouse.popCursor('target')
    self:ungrabMouse()
    return true
end

function onUseWith(clickedWidget, mousePosition)
    if clickedWidget:getClassName() == 'UIMap' then
        local tile = clickedWidget:getTile(mousePosition)
        if tile then
            g_game.useWith(selectedThing, tile:getTopMultiUseThing())
        end
    elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
        g_game.useWith(selectedThing, clickedWidget:getItem())
    elseif clickedWidget:getClassName() == 'UICreatureButton' then
        local creature = clickedWidget:getCreature()
        if creature then
            g_game.useWith(selectedThing, creature)
        end
    end
end

function onTradeWith(clickedWidget, mousePosition)
    if clickedWidget:getClassName() == 'UIMap' then
        local tile = clickedWidget:getTile(mousePosition)
        if tile then
            g_game.requestTrade(selectedThing, tile:getTopCreature())
        end
    end
end

function startUseWith(thing)
    if not thing then
        return
    end
    if g_ui.isMouseGrabbed() then
        if selectedThing then
            selectedThing = thing
            selectedType = 'use'
        end
        return
    end
    selectedType = 'use'
    selectedThing = thing
    mouseGrabberWidget:grabMouse()
    g_mouse.pushCursor('target')
end

function startTradeWith(thing)
    if not thing then
        return
    end
    if g_ui.isMouseGrabbed() then
        if selectedThing then
            selectedThing = thing
            selectedType = 'trade'
        end
        return
    end
    selectedType = 'trade'
    selectedThing = thing
    mouseGrabberWidget:grabMouse()
    g_mouse.pushCursor('target')
end

function createThingMenu(menuPosition, lookThing, useThing, creatureThing)
    if not g_game.isOnline() then
        return
    end
    -- if TVBLOCK then return end
    local menu = g_ui.createWidget('PopupMenu')
    local classic = modules.client_options.getOption('classicControl')
    local shortcut = nil

    if not classic then
        shortcut = '(Shift)'
    else
        shortcut = nil
    end
    if lookThing then
        menu:addOption(tr('Look'), function()
            g_game.look(lookThing)
        end, shortcut)
    end

    if not classic then
        shortcut = '(Ctrl)'
    else
        shortcut = nil
    end
    if useThing then
        if useThing:isContainer() then
            if useThing:getParentContainer() then
                menu:addOption(tr('Open'), function()
                    g_game.open(useThing, useThing:getParentContainer())
                end, shortcut)
                menu:addOption(tr('Open in new window'), function()
                    g_game.open(useThing)
                end)
            else
                menu:addOption(tr('Open'), function()
                    g_game.open(useThing)
                end, shortcut)
            end
        else
            if useThing:isMultiUse() then
                menu:addOption(tr('Use with ...'), function()
                    startUseWith(useThing)
                end, shortcut)
            else
                menu:addOption(tr('Use'), function()
                    g_game.use(useThing)
                end, shortcut)
            end
        end

        if useThing:isRotateable() then
            menu:addOption(tr('Rotate'), function()
                g_game.rotate(useThing)
            end)
        end

    end

    if lookThing and not lookThing:isCreature() and not lookThing:isNotMoveable() and lookThing:isPickupable() then
        if lookThing:getId() == 12174 or lookThing:getId() == 12174 then
            menu:addSeparator()
            menu:addOption(tr('Ditto memory ...'), function()
                modules.game_memory.sendRequestShow()
            end)
        end
        menu:addSeparator()
        menu:addOption(tr('Trade with ...'), function()
            startTradeWith(lookThing)
        end)
    end

    do
        local itemForCheck = useThing or lookThing
        if itemForCheck and POKEBALL_ON_IDS[itemForCheck:getId()] then
            menu:addSeparator()
            menu:addOption(tr('Remove item'), function()
                g_game.talk('!orb remove')
            end)
        end
    end

    if lookThing then
        local parentContainer = lookThing:getParentContainer()
        if parentContainer and parentContainer:hasParent() then
            menu:addOption(tr('Move up'), function()
                g_game.moveToParentContainer(lookThing, lookThing:getCount())
            end)
        end
    end

    if creatureThing then
        local localPlayer = g_game.getLocalPlayer()
        menu:addSeparator()

        if creatureThing:isLocalPlayer() then
            menu:addOption(tr('Set Outfit'), function()
                g_game.requestOutfit()
            end)

            if g_game.getFeature(GamePlayerMounts) then
                if not localPlayer:isMounted() then
                    menu:addOption(tr('Mount'), function()
                        localPlayer:mount()
                    end)
                else
                    menu:addOption(tr('Dismount'), function()
                        localPlayer:dismount()
                    end)
                end
            end

            if creatureThing:isPartyMember() then
                if creatureThing:isPartyLeader() then
                    if creatureThing:isPartySharedExperienceActive() then
                        menu:addOption(tr('Disable Shared Experience'), function()
                            g_game.partyShareExperience(false)
                        end)
                    else
                        menu:addOption(tr('Enable Shared Experience'), function()
                            g_game.partyShareExperience(true)
                        end)
                    end
                end
                menu:addOption(tr('Leave Party'), function()
                    g_game.partyLeave()
                end)
            end

        else
            local localPosition = localPlayer:getPosition()
            if not classic then
                shortcut = '(Alt)'
            else
                shortcut = nil
            end
            if creatureThing:getPosition().z == localPosition.z then
                if g_game.getAttackingCreature() ~= creatureThing then
                    menu:addOption(tr('Attack'), function()
                        g_game.attack(creatureThing)
                    end, shortcut)
                else
                    menu:addOption(tr('Stop Attack'), function()
                        g_game.cancelAttack()
                    end, shortcut)
                end

                if g_game.getFollowingCreature() ~= creatureThing then
                    menu:addOption(tr('Follow'), function()
                        g_game.follow(creatureThing)
                    end)
                else
                    menu:addOption(tr('Stop Follow'), function()
                        g_game.cancelFollow()
                    end)
                end
            end

            if creatureThing:isPlayer() then
                menu:addSeparator()
                local creatureName = creatureThing:getName()
                menu:addOption(tr('Message to %s', creatureName), function()
                    g_game.openPrivateChannel(creatureName)
                end)
                if modules.game_console.getOwnPrivateTab() then
                    menu:addOption(tr('Invite to private chat'), function()
                        g_game.inviteToOwnChannel(creatureName)
                    end)
                    menu:addOption(tr('Exclude from private chat'), function()
                        g_game.excludeFromOwnChannel(creatureName)
                    end) -- [TODO] must be removed after message's popup labels been implemented
                end
                -- ==== DUEL ====
                local localPlayer = g_game.getLocalPlayer()
                local mySkull = localPlayer and localPlayer:getSkull() or 0
                local inviterSkull = creatureThing:getSkull() or 0

                local creatureName = (creatureThing:getName() or ''):gsub('^%s+', ''):gsub('%s+$', '')
                local hasInvite = modules.game_duel.hasInviteFrom and modules.game_duel.hasInviteFrom(creatureName)
                local hasPending = modules.game_duel.hasPendingTo and modules.game_duel.hasPendingTo(creatureName)

                local looksLikeInvite = (not hasInvite) and (inviterSkull == 2) and (mySkull ~= 2)

                if hasInvite or looksLikeInvite then
                    menu:addOption(tr('Accept duel from %s', creatureName), function()
                        modules.game_duel.doAcceptDuel(creatureName)
                    end)
                    menu:addOption(tr('Deny duel from %s', creatureName), function()
                        if modules.game_duel.doDenyDuel then
                            modules.game_duel.doDenyDuel(creatureName)
                        elseif modules.game_duel.denyInvite then
                            modules.game_duel.denyInvite(creatureName)
                        end
                        modules.game_textmessage.displayFailureMessage(
                            tr('You declined the duel invite from %s.', creatureName))
                    end)
                elseif not hasPending then
                    menu:addOption(tr('Duel with %s', creatureName), function()
                        modules.game_duel.show(creatureThing)
                    end)
                end
                -- ==== DUEL ====
                if not localPlayer:hasVip(creatureName) then
                    menu:addOption(tr('Add to VIP list'), function()
                        g_game.addVip(creatureName)
                    end)
                end

                if modules.game_console.isIgnored(creatureName) then
                    menu:addOption(tr('Unignore') .. ' ' .. creatureName, function()
                        modules.game_console.removeIgnoredPlayer(creatureName)
                    end)
                else
                    menu:addOption(tr('Ignore') .. ' ' .. creatureName, function()
                        modules.game_console.addIgnoredPlayer(creatureName)
                    end)
                end

                ---//// Duel
                --[[local MySkullType = localPlayer:getSkull()
		local ThingSkullType = creatureThing:getSkull()
		
		if MySkullType == 2 and ThingSkullType == 1 then
            menu:addOption(tr("Accept duel of %s", creatureThing:getName()), function() modules.game_duel.doAcceptDuel(creatureThing:getName()) end)
          else
            menu:addOption(tr('Duel with %s', creatureThing:getName()), function() modules.game_duel.show(creatureThing) end)
        end]] --
                ---//// Duel

                local localPlayerShield = localPlayer:getShield()
                local creatureShield = creatureThing:getShield()

                if localPlayerShield == ShieldNone or localPlayerShield == ShieldWhiteBlue then
                    if creatureShield == ShieldWhiteYellow then
                        menu:addOption(tr('Join %s\'s Party', creatureThing:getName()), function()
                            g_game.partyJoin(creatureThing:getId())
                        end)
                    else
                        menu:addOption(tr('Invite to Party'), function()
                            g_game.partyInvite(creatureThing:getId())
                        end)
                    end
                elseif localPlayerShield == ShieldWhiteYellow then
                    if creatureShield == ShieldWhiteBlue then
                        menu:addOption(tr('Revoke %s\'s Invitation', creatureThing:getName()), function()
                            g_game.partyRevokeInvitation(creatureThing:getId())
                        end)
                    end
                elseif localPlayerShield == ShieldYellow or localPlayerShield == ShieldYellowSharedExp or
                    localPlayerShield == ShieldYellowNoSharedExpBlink or localPlayerShield == ShieldYellowNoSharedExp then
                    if creatureShield == ShieldWhiteBlue then
                        menu:addOption(tr('Revoke %s\'s Invitation', creatureThing:getName()), function()
                            g_game.partyRevokeInvitation(creatureThing:getId())
                        end)
                    elseif creatureShield == ShieldBlue or creatureShield == ShieldBlueSharedExp or creatureShield ==
                        ShieldBlueNoSharedExpBlink or creatureShield == ShieldBlueNoSharedExp then
                        menu:addOption(tr('Pass Leadership to %s', creatureThing:getName()), function()
                            g_game.partyPassLeadership(creatureThing:getId())
                        end)
                    else
                        menu:addOption(tr('Invite to Party'), function()
                            g_game.partyInvite(creatureThing:getId())
                        end)
                    end
                end

            end
        end

        if modules.game_ruleviolation.hasWindowAccess() and creatureThing:isPlayer() and creatureThing ~= localPlayer then
            menu:addSeparator()
            menu:addOption(tr('Rule Violation'), function()
                modules.game_ruleviolation.show(creatureThing:getName())
            end)
        end

        menu:addSeparator()
        menu:addOption(tr('Copy Name'), function()
            g_window.setClipboardText(creatureThing:getName())
        end)
    end

    menu:display(menuPosition)
end

function processMouseAction(menuPosition, mouseButton, autoWalkPos, lookThing, useThing, creatureThing, attackCreature)
    local keyboardModifiers = g_keyboard.getModifiers()

    if not modules.client_options.getOption('classicControl') then
        if keyboardModifiers == KeyboardNoModifier and mouseButton == MouseRightButton then
            createThingMenu(menuPosition, lookThing, useThing, creatureThing)
            return true
        elseif lookThing and keyboardModifiers == KeyboardShiftModifier and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.look(lookThing)
            return true
        elseif useThing and keyboardModifiers == KeyboardCtrlModifier and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            if useThing:isContainer() then
                if useThing:getParentContainer() then
                    g_game.open(useThing, useThing:getParentContainer())
                else
                    g_game.open(useThing)
                end
                return true
            elseif useThing:isMultiUse() then
                startUseWith(useThing)
                return true
            else
                g_game.use(useThing)
                return true
            end
            return true
        elseif attackCreature and g_keyboard.isAltPressed() and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.attack(attackCreature)
            return true
        elseif creatureThing and creatureThing:getPosition().z == autoWalkPos.z and g_keyboard.isAltPressed() and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.attack(creatureThing)
            return true
            -- Funcao clicar no npc e conversar
        elseif creatureThing.isNpc() and g_keyboard.isAltPressed() and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            local destPos = attackCreature:getPosition()
            local myPos = g_game.getLocalPlayer():getPosition()
            if ((destPos.x >= myPos.x - 3) and (destPos.x <= myPos.x + 3) and (destPos.y >= myPos.y - 3) and
                (destPos.y <= myPos.y + 3)) then
                scheduleEvent(g_game.talkChannel(11, 0, "hi"), 500)
            else
                modules.game_textmessage.displayFailureMessage(
                    "Voce nao pode conversar com o NPC pois voce esta muito longe. Aproxime-se e tente novamente.")
            end
            return true
        end

        -- classic control
    else
        if useThing and keyboardModifiers == KeyboardNoModifier and mouseButton == MouseRightButton and
            not g_mouse.isPressed(MouseLeftButton) then
            local player = g_game.getLocalPlayer()
            if attackCreature and attackCreature ~= player then
                -- funcao npc ao clicar falar com ele
                if not attackCreature:isNpc() then
                    g_game.attack(attackCreature)
                else
                    local destPos = attackCreature:getPosition()
                    local myPos = player:getPosition()
                    if ((destPos.x >= myPos.x - 3) and (destPos.x <= myPos.x + 3) and (destPos.y >= myPos.y - 3) and
                        (destPos.y <= myPos.y + 3)) then
                        scheduleEvent(g_game.talkChannel(11, 0, "hi"), 500)
                    else
                        modules.game_textmessage.displayFailureMessage(
                            "Voce nao pode conversar com o NPC pois voce esta muito longe. Aproxime-se e tente novamente.")
                    end
                end
                return true
                -- funcao npc ao clicar falar com ele
            elseif creatureThing and creatureThing ~= player and creatureThing:getPosition().z == autoWalkPos.z then
                g_game.attack(creatureThing)
                return true
            elseif useThing:isContainer() then
                if useThing:getParentContainer() then
                    g_game.open(useThing, useThing:getParentContainer())
                    return true
                else
                    g_game.open(useThing)
                    return true
                end
            elseif useThing:isMultiUse() then
                startUseWith(useThing)
                return true
            else
                g_game.use(useThing)
                return true
            end
            return true
        elseif lookThing and keyboardModifiers == KeyboardShiftModifier and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.look(lookThing)
            return true
        elseif lookThing and ((g_mouse.isPressed(MouseLeftButton) and mouseButton == MouseRightButton) or
            (g_mouse.isPressed(MouseRightButton) and mouseButton == MouseLeftButton)) then
            g_game.look(lookThing)
            return true
        elseif useThing and keyboardModifiers == KeyboardCtrlModifier and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            createThingMenu(menuPosition, lookThing, useThing, creatureThing)
            return true
        elseif attackCreature and g_keyboard.isAltPressed() and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.attack(attackCreature)
            return true
        elseif creatureThing and creatureThing:getPosition().z == autoWalkPos.z and g_keyboard.isAltPressed() and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.attack(creatureThing)
            return true
        end
    end

    local player = g_game.getLocalPlayer()
    player:stopAutoWalk()

    if autoWalkPos and keyboardModifiers == KeyboardNoModifier and mouseButton == MouseLeftButton then
        player:autoWalk(autoWalkPos)
        return true
    end

    return false
end

function moveStackableItem(item, toPos)
    if countWindow then
        return
    end
    if g_keyboard.isCtrlPressed() then
        g_game.move(item, toPos, item:getCount())
        return
    elseif g_keyboard.isShiftPressed() then
        g_game.move(item, toPos, 1)
        return
    end
    local count = item:getCount()

    countWindow = g_ui.createWidget('CountWindow', rootWidget)
    local itembox = countWindow:getChildById('item')
    local scrollbar = countWindow:getChildById('countScrollBar')
    itembox:setItemId(item:getId())
    itembox:setItemCount(count)
    scrollbar:setMaximum(count)
    scrollbar:setMinimum(1)
    scrollbar:setValue(count)

    local spinbox = countWindow:getChildById('spinBox')
    spinbox:setMaximum(count)
    spinbox:setMinimum(0)
    spinbox:setValue(0)
    spinbox:hideButtons()
    spinbox:focus()
    spinbox.firstEdit = true

    local spinBoxValueChange = function(self, value)
        spinbox.firstEdit = false
        scrollbar:setValue(value)
    end
    spinbox.onValueChange = spinBoxValueChange

    local check = function()
        if spinbox.firstEdit then
            spinbox:setValue(spinbox:getMaximum())
            spinbox.firstEdit = false
        end
    end
    g_keyboard.bindKeyPress("Up", function()
        check()
        spinbox:setValue(spinbox:getValue() + 10)
    end, spinbox)
    g_keyboard.bindKeyPress("Down", function()
        check()
        spinbox:setValue(spinbox:getValue() - 10)
    end, spinbox)
    g_keyboard.bindKeyPress("Right", function()
        check()
        spinbox:up()
    end, spinbox)
    g_keyboard.bindKeyPress("Left", function()
        check()
        spinbox:down()
    end, spinbox)

    scrollbar.onValueChange = function(self, value)
        itembox:setItemCount(value)
        spinbox.onValueChange = nil
        spinbox:setValue(value)
        spinbox.onValueChange = spinBoxValueChange
    end

    local okButton = countWindow:getChildById('buttonOk')
    local moveFunc = function()
        g_game.move(item, toPos, itembox:getItemCount())
        okButton:getParent():destroy()
        countWindow = nil
    end
    local cancelButton = countWindow:getChildById('buttonCancel')
    local cancelFunc = function()
        cancelButton:getParent():destroy()
        countWindow = nil
    end

    countWindow.onEnter = moveFunc
    countWindow.onEscape = cancelFunc

    okButton.onClick = moveFunc
    cancelButton.onClick = cancelFunc
end

function getRootPanel()
    return gameRootPanel
end

function getMapPanel()
    return gameMapPanel
end

function getRightPanel()
    return gameRightPanel
end

function getSkinLeft()
    return skinLeft
end

function getLeftPanel()
    return gameLeftPanel
end

function getBottomPanel()
    return gameBottomPanel
end

function onLeftPanelVisibilityChange(leftPanel, visible)
    if not visible and g_game.isOnline() then
        local children = leftPanel:getChildren()
        backGameLeftPanel:setVisible(false)
        skinLeft:setVisible(false)
        for i = 1, #children do
            children[i]:setParent(gameRightPanel)
        end
    else
        backGameLeftPanel:setVisible(true)
        skinLeft:setVisible(true)
    end
end

function nextViewMode()
    setupViewMode((currentViewMode + 1) % 3)
end

function setupViewMode(mode)
    if mode == currentViewMode then
        return
    end

    if currentViewMode == 2 then
        gameMapPanel:addAnchor(AnchorLeft, 'gameLeftPanel', AnchorRight)
        gameMapPanel:addAnchor(AnchorRight, 'gameRightPanel', AnchorLeft)
        gameMapPanel:addAnchor(AnchorBottom, 'gameRootPanel', AnchorBottom)
        gameRootPanel:addAnchor(AnchorTop, 'topMenu', AnchorBottom)
        backGameLeftPanel:setImageColor('white')
        backGameRightPanel:setImageColor('white')
        gameRightPanel:setMarginTop(0)
        gameBottomPanel:setImageColor('white')
        modules.client_topmenu.getTopMenu():setImageColor('white')
        g_game.changeMapAwareRange(18, 14)
    end

    local limit = limitedZoom and not g_game.isGM()
    gameMapPanel:setKeepAspectRatio(false)
    gameMapPanel:setLimitVisibleRange(false)
    gameMapPanel:setZoom(11)
    gameMapPanel:fill('parent')
    gameRootPanel:fill('parent')

    if mode == 2 then
        backGameLeftPanel:setImageColor('alpha')
        backGameRightPanel:setImageColor('alpha')
        gameRightPanel:setMarginTop(modules.client_topmenu.getTopMenu():getHeight() - gameRightPanel:getPaddingTop())
        gameBottomPanel:setImageColor('#ffffff88')
        modules.client_topmenu.getTopMenu():setImageColor('#ffffff66')
    else
        backGameLeftPanel:setImageColor('white')
        backGameRightPanel:setImageColor('white')
        gameRightPanel:setMarginTop(0)
        gameBottomPanel:setImageColor('white')
        modules.client_topmenu.getTopMenu():setImageColor('white')
    end

    addEvent(recomputeVisibleDimension)

    currentViewMode = mode
    refreshChatOpacity()
end

function limitZoom()
    limitedZoom = true
end
