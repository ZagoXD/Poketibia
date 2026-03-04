local msgs = {"use ", ""}

local UI_SLOTS = 12
local DEFAULT_MAX = 6
local HARD_CAP = 10

local TMC = dofile('data/lib/tm/tm_core.lua')

local function getMovesTableForSummonName(name)
    return movestable[name]
end

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
        if i and i >= 1 and i <= UI_SLOTS and not seen[i] then
            seen[i] = true
            table.insert(out, i)
        end
    end
    return out
end

local function normalizeActiveListForMoves(moves, list, maxActive)
    local ok, seen, out = {}, {}, {}
    if not moves then
        return out
    end
    for i = 1, UI_SLOTS do
        if moves["move" .. i] then
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
    for i = 1, UI_SLOTS do
        if moves["move" .. i] then
            table.insert(picked, i)
            if #picked >= maxActive then
                break
            end
        end
    end
    return picked
end

local function ensureActiveMovesForBallName(name, ball)
    local moves = TMC.buildEffectiveMovesFor(name, ball)
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
        local t = {}
        for i, v in ipairs(normalized) do
            t[i] = tostring(v)
        end
        doItemSetAttribute(ball.uid, "active_moves", table.concat(t, ","))
    end

    return normalized, maxActive, moves

end

-- ===== Aviso quando a skill volta =====

local function doAlertReady(cid, id, movename, n, cd)
    if not isCreature(cid) then
        return true
    end
    local myball = getPlayerSlotItem(cid, 8)
    if myball.itemid > 0 and getItemAttribute(myball.uid, cd) == "cd:" .. id .. "" then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
            getPokeballName(myball.uid) .. " - " .. movename .. " (m" .. n .. ") is ready!")
        return true
    end
    local p = getPokeballsInContainer(getPlayerSlotItem(cid, 3).uid)
    if not p or #p <= 0 then
        return true
    end
    for a = 1, #p do
        if getItemAttribute(p[a], cd) == "cd:" .. id .. "" then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
                getPokeballName(p[a]) .. " - " .. movename .. " (m" .. n .. ") is ready!")
            return true
        end
    end
end

-- ===== Entrada principal =====

function onSay(cid, words, param, channel)
    if param ~= "" then
        return true
    end
    if string.len(words) > 3 then
        return true
    end

    if #getCreatureSummons(cid) == 0 then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You need a pokemon to use moves.")
        return 0
    end

    local mypoke = getCreatureSummons(cid)[1]
    if getCreatureCondition(cid, CONDITION_EXHAUST) then
        return true
    end
    if getCreatureName(mypoke) == "Evolution" then
        return true
    end

    local name
    if getCreatureName(mypoke) == "Ditto" or getCreatureName(mypoke) == "Shiny Ditto" then
        name = getPlayerStorageValue(mypoke, 1010)
    else
        name = getCreatureName(mypoke)
    end

    local it = words:match("^m(%d+)$")
    if not it then
        return true
    end
    local uiSlot = tonumber(it)

    local ball = getPlayerSlotItem(cid, 8)
    local activeList, maxActive, movesTbl = ensureActiveMovesForBallName(name, ball)

    local cdzin
    if getPlayerStorageValue(mypoke, 212123) >= 1 then
        cdzin = "cm_move" .. uiSlot
    else
        cdzin = "move" .. uiSlot
    end

    if uiSlot > maxActive then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Esse slot nao esta ativo.")
        return true
    end

    -- Mapeia o slot da UI -> índice real do move (1..12)
    local realIndex = activeList[uiSlot]
    local move = realIndex and movesTbl["move" .. realIndex] or nil

    if not move then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Your pokemon doesn't recognize this move.")
        return true
    end

    if getPlayerLevel(cid) < move.level then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
            "You need be atleast level " .. move.level .. " to use this move.")
        return true
    end

    -- ===== Cálculo final do cooldown (usa APENAS cdr_mult da ball) =====
    local cdzao = move.cd
    local mult = tonumber(getItemAttribute(ball.uid, "cdr_mult") or 1)
    if mult and mult > 0 then
        cdzao = math.ceil(cdzao * mult)
        if cdzao < 0 then
            cdzao = 0
        end
    end
    -- =====================================

    if getCD(ball.uid, cdzin) > 0 and getCD(ball.uid, cdzin) < (cdzao + 2) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You have to wait " .. getCD(ball.uid, cdzin) ..
            " seconds to use " .. move.name .. " again.")
        return true
    end

    if getTileInfo(getThingPos(mypoke)).protection then
        doPlayerSendCancel(cid, "Your pokemon cannot use moves while in protection zone.")
        return true
    end

    if getTilePzInfo(getCreaturePosition(cid)) == TRUE then
        doPlayerSendCancel(cid, "Não pode atacar em zona protegida.")
        return true
    end

    if getPlayerStorageValue(mypoke, 3894) >= 1 then
        return doPlayerSendCancel(cid, "You can't attack because you is with fear")
    end

    if (move.name == "Team Slice" or move.name == "Team Claw") and #getCreatureSummons(cid) < 2 then
        doPlayerSendCancel(cid, "Your pokemon need be in a team for use this move!")
        return true
    end

    if move.target == 1 then
        if not isCreature(getCreatureTarget(cid)) then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You don\'t have any targets.")
            return 0
        end
        if getCreatureCondition(getCreatureTarget(cid), CONDITION_INVISIBLE) then
            return 0
        end
        if getCreatureHealth(getCreatureTarget(cid)) <= 0 then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Your have already defeated your target.")
            return 0
        end
        if not isCreature(getCreatureSummons(cid)[1]) then
            return true
        end
        if getDistanceBetween(getThingPos(getCreatureSummons(cid)[1]), getThingPos(getCreatureTarget(cid))) > move.dist then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Get closer to the target to use this move.")
            return 0
        end
        if not isSightClear(getThingPos(getCreatureSummons(cid)[1]), getThingPos(getCreatureTarget(cid)), false) then
            return 0
        end
    end

    if isCreature(getCreatureTarget(cid)) and
        isInArray(specialabilities["evasion"], getCreatureName(getCreatureTarget(cid))) then
        local target = getCreatureTarget(cid)
        if math.random(1, 100) <= passivesChances["Evasion"][getCreatureName(target)] then
            if isCreature(getMasterTarget(target)) then
                doSendMagicEffect(getThingPos(target), 211)
                doSendAnimatedText(getThingPos(target), "TOO BAD", 215)
                doTeleportThing(target, getClosestFreeTile(target, getThingPos(mypoke)), false)
                doSendMagicEffect(getThingPos(target), 211)
                doFaceCreature(target, getThingPos(mypoke))
                return true
            end
        end
    end

    local newid = 0
    if isSleeping(mypoke) or isSilence(mypoke) then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Sorry you can't do that right now.")
        return 0
    else
        newid = setCD(ball.uid, cdzin, cdzao)
    end

    doCreatureSay(cid, "" .. getPokeName(mypoke) .. ", " .. msgs[math.random(#msgs)] .. "" .. move.name .. "!",
        TALKTYPE_SAY)

    local summons = getCreatureSummons(cid)
    addEvent(doAlertReady, cdzao * 1000, cid, newid, move.name, uiSlot, cdzin)

    for i = 2, #summons do
        if isCreature(summons[i]) and getPlayerStorageValue(cid, 637501) >= 1 then
            docastspell(summons[i], move.name)
        end
    end

    docastspell(mypoke, move.name)
    doCreatureAddCondition(cid, playerexhaust)
    doItemSetAttribute(ball.uid, "tm_last_move_used", move.name)

    if useKpdoDlls then
        doUpdateCooldowns(cid)
    end

    return 0
end
