-- -- 55294365
-- function init()
--   connect(g_game, { onGameEnd = onGameEnd })
--   duelWindow = g_ui.displayUI('duel')
--   duelWindow:hide()
-- end
-- function terminate()
--   disconnect(g_game, { onGameEnd = onGameEnd })
--   duelWindow:destroy()
-- end
-- function onGameEnd()
--   if duelWindow:isVisible() then
--     duelWindow:hide()
--   end
-- end
-- function show(localPlayer)
--   duelWindow:show()
--   duelWindow:raise()
--   duelWindow:focus()
--   addEvent(function() g_effects.fadeIn(duelWindow, 250) end)
--   doClickPokeball(1)
--   player = localPlayer
-- end
-- function hide()
--   addEvent(function() g_effects.fadeOut(duelWindow, 250) end)
--   scheduleEvent(function() duelWindow:hide() end, 250)
-- end
-- function doClickPokeball(pokeball)
--   pokemons = pokeball
--   for i = 1, pokeball do
--     duelWindow:getChildByIndex(i+1):setImageSource('/images/game/duel/pokeball_on')
--   end
--   if pokeball == 6 then return true end
--   for i = pokeball + 1, 6 do
--     duelWindow:getChildByIndex(i+1):setImageSource('/images/game/duel/pokeball_off')
--   end
-- end
-- function doRequestDuel()
--   if duelWindow:isVisible() then
--     hide()
--   end
--   -- modules.game_textmessage.displayBroadcastMessage('Player: ' .. player:getName()) VEJA ISSO AKI ANTES DE USAR O OPCODE (DPOIS QUANDO VC VER COMO TAH FUNFANDO VC TIRA)
--   -- modules.game_textmessage.displayBroadcastMessage('Pokemons: ' .. pokemons) VEJA ISSO AKI ANTES DE USAR O OPCODE (DPOIS QUANDO VC VER COMO TAH FUNFANDO VC TIRA)
--    g_game.getProtocolGame():sendExtendedOpcode(108, pokemons .. "/" .. player:getName()) --NO SERVER VOCE FAZ ASSIM getPlayerByName(name)
-- end
-- function doAcceptDuel(creatureName)
--    g_game.getProtocolGame():sendExtendedOpcode(109, creatureName) --ISSO AKI É QUANDO O OTRO PLAYER ACEITA
-- end
-- function checkVersion(buffer)
-- 	g_game.getProtocolGame():sendExtendedOpcode(200, "2.5")
-- end



-- === Duel (client) ===========================================================
local DUEL_OP_REQUEST = 108
local DUEL_OP_ACCEPT = 109
local DUEL_OP_DENY    = 110
local DUEL_INVITE = 208
local DUEL_CLEAR = 209

local INVITES_FROM = {}
local PENDING_OUT = {}

local duelWindow = nil
local pokemons = 1
local targetCreature = nil

local function lc(s)
    return s and s:lower() or ""
end
local function setInvite(fromName, value)
    local k = lc(fromName);
    if k == "" then
        return
    end
    if value then
        INVITES_FROM[k] = true
    else
        INVITES_FROM[k] = nil
    end
end
local function setPending(toName, value)
    local k = lc(toName);
    if k == "" then
        return
    end
    if value then
        PENDING_OUT[k] = true
    else
        PENDING_OUT[k] = nil
    end
end

function hasInviteFrom(name)
    return INVITES_FROM[lc(name)] == true
end
function hasPendingTo(name)
    return PENDING_OUT[lc(name)] == true
end
function denyInvite(name)
    setInvite(name, false)
end

function init()
    connect(g_game, {
        onGameEnd = onGameEnd
    })

    ProtocolGame.registerExtendedOpcode(DUEL_INVITE, function(_, _, buffer)
        local name = tostring(buffer or ''):gsub('^%s+', ''):gsub('%s+$', '')
        if name ~= '' then
            g_logger.info(string.format('[DUEL] INVITE from: %s', name))
            setInvite(name, true)
        else
            g_logger.warning('[DUEL] INVITE recebido sem nome')
        end
    end)

    ProtocolGame.registerExtendedOpcode(DUEL_CLEAR, function(_, _, buffer)
        local name = tostring(buffer or ''):gsub('^%s+', ''):gsub('%s+$', '')
        if name ~= '' then
            g_logger.info(string.format('[DUEL] CLEAR for: %s', name))
            setInvite(name, false)
            setPending(name, false)
        else
            g_logger.warning('[DUEL] CLEAR recebido sem nome')
        end
    end)

    duelWindow = g_ui.displayUI('duel')
    duelWindow:hide()
end

function terminate()
    disconnect(g_game, {
        onGameEnd = onGameEnd
    })
    if duelWindow then
        duelWindow:destroy();
        duelWindow = nil
    end
    INVITES_FROM, PENDING_OUT = {}, {}
    targetCreature, pokemons = nil, 1
end

function onGameEnd()
    INVITES_FROM, PENDING_OUT = {}, {}
    targetCreature = nil
    if duelWindow and duelWindow:isVisible() then
        duelWindow:hide()
    end
end

function show(creature)
    targetCreature = creature
    duelWindow:show();
    duelWindow:raise();
    duelWindow:focus()
    addEvent(function()
        g_effects.fadeIn(duelWindow, 250)
    end)
    doClickPokeball(1)
end

function hide()
    addEvent(function()
        g_effects.fadeOut(duelWindow, 250)
    end)
    scheduleEvent(function()
        if duelWindow then
            duelWindow:hide()
        end
    end, 250)
end

function doClickPokeball(count)
    pokemons = math.max(1, math.min(6, tonumber(count) or 1))
    for i = 1, 6 do
        local w = duelWindow:getChildByIndex(i + 1)
        if w then
            w:setImageSource(i <= pokemons and '/images/game/duel/pokeball_on' or '/images/game/duel/pokeball_off')
        end
    end
end

function doRequestDuel()
    if duelWindow and duelWindow:isVisible() then
        hide()
    end

    local need = math.max(1, math.min(6, tonumber(pokemons) or 1))
    local opponentName = nil
    if targetCreature and targetCreature.getName then
        opponentName = targetCreature:getName()
    end

    local payload = tostring(need)
    if opponentName and opponentName ~= '' then
        payload = payload .. '|' .. opponentName
        setPending(opponentName, true)
    end

    g_game.getProtocolGame():sendExtendedOpcode(DUEL_OP_REQUEST, payload)
end

function doAcceptDuel(fromName)
    if not fromName or fromName == '' then
        return
    end
    g_game.getProtocolGame():sendExtendedOpcode(DUEL_OP_ACCEPT, fromName)
    setInvite(fromName, false)
end

function checkVersion()
    g_game.getProtocolGame():sendExtendedOpcode(200, '2.5')
end

if not modules then
    modules = {}
end

function doDenyDuel(fromName)
  local name = tostring(fromName or ''):gsub('^%s+',''):gsub('%s+$','')
  if name == '' then return end
  g_game.getProtocolGame():sendExtendedOpcode(DUEL_OP_DENY, name)
  setInvite(name, false)
  setPending(name, false)
end

if not modules then modules = {} end
modules.game_duel = modules.game_duel or {}
modules.game_duel.hasInviteFrom = hasInviteFrom
modules.game_duel.hasPendingTo  = hasPendingTo
modules.game_duel.denyInvite    = denyInvite
modules.game_duel.doDenyDuel    = doDenyDuel
modules.game_duel.show          = show
modules.game_duel.doAcceptDuel  = doAcceptDuel

