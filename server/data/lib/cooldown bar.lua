local TMC = dofile('data/lib/tm/tm_core.lua')

function getPlayerPokeballs(cid) -- v1.9
    local ret = {}
    local container = 0

    if isCreature(cid) then
        container = getPlayerSlotItem(cid, 3).uid
        local myball = getPlayerSlotItem(cid, 8)
        if myball.uid > 0 then
            table.insert(ret, myball)
        end
    else
        container = cid
    end

    if isContainer(container) and getContainerSize(container) > 0 then
        for slot = 0, (getContainerSize(container) - 1) do
            local item = getContainerItem(container, slot)
            if isContainer(item.uid) then
                local itemsbag = getPlayerPokeballs(item.uid)
                if itemsbag and #itemsbag > 0 then
                    for i = 1, #itemsbag do
                        table.insert(ret, itemsbag[i])
                    end
                end
            elseif isPokeball(item.itemid) then
                table.insert(ret, item)
            end
        end
    end
    return ret
end

function doUpdatePokemonsBar(cid)
    if not isCreature(cid) then
        return true
    end
    if getPlayerStorageValue(cid, 656494) > 0 then
        return true
    end
    setPlayerStorageValue(cid, 656494, 1000)
    addEvent(setPlayerStorageValue, 100, cid, 656494, -1)

    local ret = {}
    table.insert(ret, "p#,")
    local balls = getPlayerPokeballs(cid)
    local times = 0
    for a = 1, #balls do
        local item = balls[a]
        local hp = math.ceil(getItemAttribute(item.uid, "hp") * 100)
        local name = getItemAttribute(item.uid, "poke")
        local port = getPlayerSlotItem(cid, CONST_SLOT_LEGS)
        if fotos[name] >= 11137 and fotos[name] <= 11387 then
            times = times + 1
            local foto = fotos[name] - 911
            doItemSetAttribute(item.uid, "ballorder", times)
            table.insert(ret, foto .. "," .. name .. "" .. times .. "," .. hp .. ",")
        elseif fotos[name] >= 12605 then
            times = times + 1
            local foto = fotos[name] - 1178
            doItemSetAttribute(item.uid, "ballorder", times)
            table.insert(ret, foto .. "," .. name .. "" .. times .. "," .. hp .. ",")
        else
            times = times + 1
            local foto = fotos[name] - 928
            doItemSetAttribute(item.uid, "ballorder", times)
            table.insert(ret, foto .. "," .. name .. "" .. times .. "," .. hp .. ",")
        end
    end
    doPlayerSendCancel(cid, table.concat(ret))
end

function getNewMoveTable(table, n)
    if table == nil or not n then
        return false
    end
    local moves = {table.move1, table.move2, table.move3, table.move4, table.move5, table.move6, table.move7,
                   table.move8, table.move9, table.move10, table.move11, table.move12}
    return moves[n] or false
end

local DEFAULT_MAX = 6
local HARD_CAP = 10
local UI_SLOTS = 12 -- quantos slots a UI espera (fica 12)

local function getMaxActiveForBall(ball)
    local m = ball and ball.uid > 0 and tonumber(getItemAttribute(ball.uid, "max_active_moves")) or nil
    if not m or m < 1 then
        m = DEFAULT_MAX
    end
    if m > HARD_CAP then
        m = HARD_CAP
    end
    return m
end

local function parseActiveMovesAttr(raw)
    local seen, out = {}, {}
    if not raw or raw == "" then
        return out
    end
    for n in tostring(raw):gmatch("%d+") do
        local i = tonumber(n)
        if i and i >= 1 and i <= 12 and not seen[i] then
            seen[i] = true
            table.insert(out, i)
        end
    end
    return out
end

local function listToCsv(t)
    local out = {}
    for i, v in ipairs(t) do
        out[i] = tostring(v)
    end
    return table.concat(out, ",")
end

local function getMovesTableForSummon(summon, ball)
    local name
    if isTransformed and isTransformed(summon) then
        name = getPlayerStorageValue(summon, 1010)
    else
        name = getCreatureName(summon)
    end
    return TMC.buildEffectiveMovesFor(name, ball)
end

local function normalizeActiveListForMoves(moves, list, maxActive)
    local ok, seen, out = {}, {}, {}
    if not moves then
        return out
    end
    for i = 1, 12 do
        if getNewMoveTable(moves, i) then
            ok[i] = true
        end
    end
    for _, idx in ipairs(list) do
        if ok[idx] and not seen[idx] then
            seen[idx] = true
            table.insert(out, idx)
            if #out >= maxActive then
                break
            end
        end
    end
    return out
end

local function autoPickFirstMoves(moves, maxActive)
    local picked = {}
    if not moves then
        return picked
    end
    for i = 1, 12 do
        if getNewMoveTable(moves, i) then
            table.insert(picked, i)
            if #picked >= maxActive then
                break
            end
        end
    end
    return picked
end

local function ensureActiveMovesForBall(cid, summon, ball)
    local moves = getMovesTableForSummon(summon, ball)
    if not moves then
        return {}, getMaxActiveForBall(ball)
    end
    local maxActive = getMaxActiveForBall(ball)
    local raw = ball and ball.uid > 0 and getItemAttribute(ball.uid, "active_moves") or nil
    local parsed = parseActiveMovesAttr(raw)
    local normalized = normalizeActiveListForMoves(moves, parsed, maxActive)

    if #normalized < maxActive then
        local fillers = autoPickFirstMoves(moves, maxActive)
        local seen = {}
        for _, v in ipairs(normalized) do
            seen[v] = true
        end
        for _, v in ipairs(fillers) do
            if not seen[v] then
                table.insert(normalized, v)
                seen[v] = true
                if #normalized >= maxActive then
                    break
                end
            end
        end
    end

    if ball and ball.uid > 0 then
        doItemSetAttribute(ball.uid, "active_moves", listToCsv(normalized))
    end

    return normalized, maxActive

end

local MEGA_CFG = {
  [24] = { names = { "gengar", "shiny gengar"} },
  [25] = { names = { "blastoise", "shiny blastoise"} },
  [26] = { names = { "charizard", "shiny charizard"} },
  [27] = { names = { "charizard", "shiny charizard"} },
  [28] = { names = { "venusaur", "shiny venusaur"} },
  [29] = { names = { "pidgeot", "shiny pidgeot"} },
  [30] = { names = { "kangaskhan", "shiny kangaskhan"} },
  [31] = { names = { "alakazam", "shiny alakazam"} },
  [32] = { names = { "gyarados", "shiny gyarados"} },
  [33] = { names = { "beedrill", "shiny beedrill"} },
  [34] = { names = { "pinsir", "shiny pinsir"} },
}


local MEGA_SLOT = UI_SLOTS

local function normName(s)
    return tostring(s or ""):lower()
end

local function baseNameForMega(creature)
    if isTransformed and isTransformed(creature) then
        return normName(getPlayerStorageValue(creature, 1010))
    end
    return normName(getCreatureName(creature))
end

local _MEGA_NAMESETS = nil
local function buildMegaNameSets()
    _MEGA_NAMESETS = {}
    for ident, cfg in pairs(MEGA_CFG) do
        local set = {}
        for _, nm in ipairs(cfg.names or {}) do
            set[normName(nm)] = true
        end
        _MEGA_NAMESETS[ident] = set
    end
end

local function getBallMegaIdent(ball)
    if not ball or ball.uid <= 0 then return 0 end
    return tonumber(getItemAttribute(ball.uid, "orb") or 0) or 0
end

local function isMegaEligible(summon, ball)
    if not summon or not isCreature(summon) then return false end
    if not _MEGA_NAMESETS then buildMegaNameSets() end

    local ident = getBallMegaIdent(ball)
    local nameset = _MEGA_NAMESETS[ident]
    if not nameset then return false end

    local base = baseNameForMega(summon)
    return nameset[base] == true
end

local function shouldShowMegaButton(summon, ball)
    return isMegaEligible(summon, ball)
end

-- ===== Atualiza nomes de moves na barra =====
function doUpdateMoves(cid)
    if not isCreature(cid) then
        return true
    end

    local summon = getCreatureSummons(cid)[1]
    local ret = {}
    table.insert(ret, tostring(UI_SLOTS) .. "&,")

    if not summon then
        for i = 1, UI_SLOTS do
            table.insert(ret, "n/n,")
        end
        doPlayerSendCancel(cid, table.concat(ret))
        addEvent(doUpdateCooldowns, 100, cid)
        return true
    end

    local ball = getPlayerSlotItem(cid, 8)
    local moves = getMovesTableForSummon(summon, ball)
    local activeList, maxActive = ensureActiveMovesForBall(cid, summon, ball)

    for uiSlot = 1, UI_SLOTS do
        local srcIndex = (uiSlot <= maxActive) and activeList[uiSlot] or nil
        local mt = srcIndex and getNewMoveTable(moves, srcIndex) or nil
        if mt then
            table.insert(ret, mt.name .. ",")
        else
            table.insert(ret, "n/n,")
        end
    end
    if shouldShowMegaButton(summon, ball) then
        ret[1 + UI_SLOTS] = "[MEGA],"
    end
    doPlayerSendCancel(cid, table.concat(ret))
    addEvent(doUpdateCooldowns, 100, cid)
    return true
end

-- ===== Atualiza cooldowns =====
function doUpdateCooldowns(cid)
    if not isCreature(cid) then
        return true
    end

    local ball = getPlayerSlotItem(cid, 8)
    local ret = {}
    table.insert(ret, tostring(UI_SLOTS) .. "|,")

    if ball.uid <= 0 or #getCreatureSummons(cid) <= 0 then
        for i = 1, UI_SLOTS do
            if useOTClient then
                table.insert(ret, "-1|0,")
            else
                table.insert(ret, "-1,")
            end
        end
        doPlayerSendCancel(cid, table.concat(ret))
        return true
    end

    local summon = getCreatureSummons(cid)[1]
    local moves = getMovesTableForSummon(summon, ball)
    local activeList, maxActive = ensureActiveMovesForBall(cid, summon, ball)
    local isCM = (summon and getPlayerStorageValue(summon, 212123) >= 1)

    for uiSlot = 1, UI_SLOTS do
        if uiSlot <= maxActive then
            local cdKey = (isCM and "cm_move" or "move") .. uiSlot
            local srcIndex = activeList[uiSlot]
            local mt = srcIndex and getNewMoveTable(moves, srcIndex) or nil
            local cd = getCD(ball.uid, cdKey)
            if cd > 0 then
                if useOTClient and mt then
                    table.insert(ret, cd .. "|" .. (mt.level or 0) .. ",")
                elseif useOTClient then
                    table.insert(ret, cd .. "|0,")
                else
                    table.insert(ret, cd .. ",")
                end
            else
                if useOTClient and mt then
                    table.insert(ret, "0|" .. (mt.level or 0) .. ",")
                elseif useOTClient then
                    table.insert(ret, "0|0,")
                else
                    table.insert(ret, "0,")
                end
            end
        else
            if useOTClient then
                table.insert(ret, "-1|0,")
            else
                table.insert(ret, "-1,")
            end
        end
        if uiSlot == UI_SLOTS then
            if shouldShowMegaButton(summon, ball) then
                if useOTClient then
                    ret[#ret] = nil
                    table.insert(ret, "0|0,")
                else
                    ret[#ret] = nil
                    table.insert(ret, "0,")
                end
            end
        end
    end

    doPlayerSendCancel(cid, table.concat(ret))
    return true
end

local _BALL_ATTR_LIST = {"poke", "gender", "nick", "boost", "happy", "hp", "description", "ballorder", "unique", "lock",
                         "transBegin", "hunger", "transLeft", "transTurn", "transOutfit", "transName", "trans", "light",
                         "blink", "move1", "move2", "move3", "move4", "move5", "move6", "move7", "move8", "move9",
                         "move10", "move11", "move12", "burn", "burndmg", "poison", "poisondmg", "confuse", "sleep",
                         "miss", "missSpell", "missEff", "fear", "fearSkill", "silence", "silenceEff", "stun",
                         "stunEff", "stunSpell", "paralyze", "paralyzeEff", "slow", "slowEff", "leech", "leechdmg",
                         "Buff1", "Buff2", "Buff3", "Buff1skill", "Buff2skill", "Buff3skill", "control", "hands",
                         "aura", "iv_set", "iv_off", "iv_spa", "iv_def", "iv_vit", "iv_hp", "iv_cdr", "nature",
                         "cdr_mult", "orb", "heldx", "heldy", "active_moves", "max_active_moves", "ballid", "tm_slots", 
                         "tm_last_move_used", "10002", "moves_next_change", "mega_active"}

function getBallsAttributes(item)
    local ret = {}
    for i = 1, #_BALL_ATTR_LIST do
        local k = _BALL_ATTR_LIST[i]
        ret[k] = getItemAttribute(item, k) or false
    end
    return ret
end

function doChangeBalls(cid, item1, item2)
    local item1ID = item1.itemid
    local item2ID = item2.itemid
    if not isCreature(cid) then
        return true
    end

    if item1.uid == item2.uid then
        if #getCreatureSummons(cid) <= 0 then
            doGoPokemon(cid, getPlayerSlotItem(cid, 8))
        else
            doReturnPokemon(cid, getCreatureSummons(cid)[1], getPlayerSlotItem(cid, 8),
                pokeballs[getPokeballType(getPlayerSlotItem(cid, 8).itemid)].effect)
        end
        doUpdateMoves(cid)
        addEvent(doUpdateCooldowns, 50, cid)
        addEvent(sendAllPokemonsBarPoke, 50, cid)
        return true
    end

    if item1.uid > 0 and item2.uid > 0 then
        local order1 = getItemAttribute(item1.uid, "ballorder")
        local order2 = getItemAttribute(item2.uid, "ballorder")

        local io = getBallsAttributes(item1.uid)
        local it = getBallsAttributes(item2.uid)

        for a, b in pairs(io) do
            if b ~= nil then
                doItemSetAttribute(item2.uid, a, b)
            else
                doItemEraseAttribute(item2.uid, a)
            end
        end
        for a, b in pairs(it) do
            if b ~= nil then
                doItemSetAttribute(item1.uid, a, b)
            else
                doItemEraseAttribute(item1.uid, a)
            end
        end

        local id = item2.itemid
        doTransformItem(item2.uid, item1.itemid)
        doTransformItem(item1.uid, id)

        local now1 = getItemAttribute(item1.uid, "ballorder")
        local now2 = getItemAttribute(item2.uid, "ballorder")
        if now1 == order1 and now2 == order2 then
            if order1 ~= nil then
                doItemSetAttribute(item1.uid, "ballorder", order2)
            end
            if order2 ~= nil then
                doItemSetAttribute(item2.uid, "ballorder", order1)
            end
        end
        doTransformItem(item1.uid, item2ID - 1)
        doTransformItem(item1.uid, item2ID)
        
        doTransformItem(item2.uid, item1ID - 1)
        doTransformItem(item2.uid, item1ID)

        doUpdateMoves(cid)
        addEvent(doUpdateCooldowns, 50, cid)
        addEvent(sendAllPokemonsBarPoke, 50, cid)
        return true

    else
        local id = item2.itemid
        local b = getBallsAttributes(item2.uid)
        local a = doPlayerAddItem(cid, 2643, false)

        for c, d in pairs(b) do
            if d then
                doItemSetAttribute(a, c, d)
            else
                doItemEraseAttribute(a, c)
            end
        end

        doRemoveItem(item2.uid, 1)
        doTransformItem(a, id)

        doUpdateMoves(cid)
        addEvent(doUpdateCooldowns, 50, cid)
        addEvent(sendAllPokemonsBarPoke, 50, cid)
        return true
    end
end
