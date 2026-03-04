local DUEL_OP_REQUEST = 108
local DUEL_OP_ACCEPT = 109
local DUEL_OP_DENY = 110
local DUEL_INVITE = 208
local DUEL_CLEAR = 209

local storages = {17000, 63215, 17001, 13008, 5700}

local function hasAnyRestrictStorages(cid, list)
    for i = 1, #list do
        if getPlayerStorageValue(cid, list[i]) >= 1 then
            return true
        end
    end
    return false
end

function onExtendedOpcode(cid, opcode, buffer)
    if not isPlayer(cid) then
        return true
    end

    if opcode == DUEL_OP_REQUEST then
        local need, targetName = nil, nil
        if buffer and buffer:find("|", 1, true) then
            need, targetName = buffer:match("^(%d+)|(.+)$")
        else
            need = buffer
        end
        need = tonumber(need) or 1
        if need < 1 then
            need = 1
        end
        if need > 6 then
            need = 6
        end

        local target = nil
        if targetName then
            target = getPlayerByName(targetName)
        end
        if not isCreature(target) or not isPlayer(target) or target == cid then
            target = getCreatureTarget(cid)
        end
        if not isCreature(target) or not isPlayer(target) or target == cid then
            doPlayerSendTextMessage(cid, 20, "No valid opponent found for duel.")
            return true
        end

        if getPlayerStorageValue(target, 6598754) > -1 or getPlayerStorageValue(target, 52480) > -1 then
            doPlayerSendTextMessage(cid, 20, "That player is busy.")
            return true
        end
        if getPlayerStorageValue(cid, 52480) > -1 or
            (getPlayerStorageValue(cid, 52481) >= 1 and getPlayerStorageValue(cid, 52482) ~= -1) then
            doPlayerSendTextMessage(cid, 20, "You are already in a duel invite flow.")
            return true
        end
        if hasAnyRestrictStorages(cid, storages) then
            doPlayerSendTextMessage(cid, 20, "You can't do that while Flying, Riding, Surfing, Diving or on a bike!")
            return true
        end
        if getPlayerStorageValue(cid, 6598754) == 1 or getPlayerStorageValue(cid, 6598755) == 1 then
            doPlayerSendTextMessage(cid, 20, "You can't do that while in PVP zone!")
            return true
        end
        if #getCreatureSummons(cid) < 1 then
            doPlayerSendTextMessage(cid, 20, "You need a pokemon to invite someone to duel!")
            return true
        end

        local bagCid = getPlayerSlotItem(cid, 3).uid
        local bagTar = getPlayerSlotItem(target, 3).uid
        local pokes1 = getLivePokeballs(cid, bagCid, true) or {}
        local pokes2 = getLivePokeballs(target, bagTar, true) or {}
        if #pokes1 < need or #pokes2 < need then
            doPlayerSendTextMessage(cid, 20,
                "You or your opponent doesn't have that amount of pokemons in their bags! Duel is canceled!")
            return true
        end

        local myName = getCreatureName(cid)
        local targetName2 = getCreatureName(target)

        setPlayerStorageValue(cid, 52480, 1)
        setPlayerStorageValue(cid, 52484, 1)
        setPlayerStorageValue(cid, 52481, need)
        setPlayerStorageValue(target, 52481, need)

        setPlayerStorageValue(cid, 52482, myName .. ",")
        setPlayerStorageValue(cid, 52483, targetName2 .. ",")

        setPlayerStorageValue(target, 52485, myName)

        setPlayerStorageValue(cid, 6598754, 5)
        doCreatureSetSkullType(cid, 2)
        doSendAnimatedText(getThingPosWithDebug(cid), "FIRST TEAM", 215)
        doSendAnimatedText(getThingPos(cid), "BATTLE", COLOR_ELECTRIC)

        local msg = {myName .. " is inviting you to a duel! Use order in him to accept it!\n",
                     "Info Battle: Duel 1x1 - " .. need .. " pokes."}
        doPlayerSendTextMessage(target, 20, table.concat(msg))

        if doSendPlayerExtendedOpcode then
            doSendPlayerExtendedOpcode(target, DUEL_INVITE, myName)
        end
        return true
    end

    if opcode == DUEL_OP_ACCEPT then
        local inviterName = buffer or ""
        local inviter = getPlayerByName(inviterName)
        if not isCreature(inviter) or not isPlayer(inviter) then
            doPlayerSendTextMessage(cid, 20, "Opponent is not online.")
            return true
        end

        local t1 = string.explode(getPlayerStorageValue(inviter, 52482) or "", ",")
        local t2 = string.explode(getPlayerStorageValue(inviter, 52483) or "", ",")
        if not isInArray(t1, getCreatureName(cid)) and not isInArray(t2, getCreatureName(cid)) then
            return true
        end

        if hasAnyRestrictStorages(cid, storages) then
            doPlayerSendTextMessage(cid, 20, "You can't do that while Flying, Riding, Surfing, Diving or on a bike!")
            return true
        end
        if getPlayerStorageValue(cid, 6598754) == 1 or getPlayerStorageValue(cid, 6598755) == 1 then
            doPlayerSendTextMessage(cid, 20, "You can't do that while in PVP zone!")
            return true
        end

        local need = getPlayerStorageValue(inviter, 52481)
        local bag = getPlayerSlotItem(cid, 3).uid
        if (#(getLivePokeballs(cid, bag, true) or {})) < need then
            doPlayerSendTextMessage(cid, 20, "You need atleast " .. need .. " pokemons to duel with this person!")
            return true
        end
        if getPlayerStorageValue(cid, 52482) ~= -1 then
            doPlayerSendTextMessage(cid, 20, "You already invit someone to duel!")
            return true
        end
        if #getCreatureSummons(cid) < 1 then
            doPlayerSendTextMessage(cid, 20, "You need a pokemon to accept a duel!")
            return true
        end

        setPlayerStorageValue(cid, 52480, getPlayerStorageValue(inviter, 52480)) -- 1
        setPlayerStorageValue(inviter, 52484, getPlayerStorageValue(inviter, 52484) - 1)

        if getPlayerStorageValue(inviter, 52484) == 0 then
            for a = 1, #t1 do
                local pid = getPlayerByName(t1[a])
                local sid = getPlayerByName(t2[a])
                if not isCreature(pid) or getPlayerStorageValue(pid, 52480) <= -1 then
                    removeFromTableDuel(inviter, t1[a])
                else
                    doCreatureSetSkullType(pid, 1)
                end
                if not isCreature(sid) or getPlayerStorageValue(sid, 52480) <= -1 then
                    removeFromTableDuel(inviter, t2[a])
                else
                    doCreatureSetSkullType(sid, 1)
                end
            end
            beginDuel(inviter, 6)
        else
            doCreatureSetSkullType(cid, 2)
        end

        doSendAnimatedText(getThingPos(cid), "BATTLE", COLOR_ELECTRIC)

        if doSendPlayerExtendedOpcode then
            doSendPlayerExtendedOpcode(cid, DUEL_CLEAR, inviterName)
            doSendPlayerExtendedOpcode(inviter, DUEL_CLEAR, getCreatureName(cid))
        end
        return true
    end

    if opcode == DUEL_OP_DENY then
        local inviterName = tostring(buffer or "")
        local inviter = getPlayerByName(inviterName)
        if not isCreature(inviter) or not isPlayer(inviter) then
            doPlayerSendTextMessage(cid, 20, "Opponent is not online.")
            return true
        end

        local t1 = string.explode(getPlayerStorageValue(inviter, 52482) or "", ",")
        local t2 = string.explode(getPlayerStorageValue(inviter, 52483) or "", ",")
        local myName = getCreatureName(cid)
        local invitedWasListed = isInArray(t1, myName) or isInArray(t2, myName)

        if not invitedWasListed or getPlayerStorageValue(inviter, 52480) <= -1 then
            return true
        end

        local function clearPlayerState(p)
            if not isCreature(p) then
                return
            end
            doCreatureSetSkullType(p, 0)
            doRemoveCondition(p, CONDITION_INFIGHT)
            setPlayerStorageValue(p, 52480, -1)
            setPlayerStorageValue(p, 52481, -1)
            setPlayerStorageValue(p, 52482, -1)
            setPlayerStorageValue(p, 52483, -1)
            setPlayerStorageValue(p, 52484, -1)
            setPlayerStorageValue(p, 52485, -1)
            setPlayerStorageValue(p, 6598754, -1)
        end

        clearPlayerState(inviter)
        for i = 1, #t1 do
            local pid = getPlayerByName(t1[i])
            if isCreature(pid) then
                clearPlayerState(pid)
            end
        end
        for i = 1, #t2 do
            local sid = getPlayerByName(t2[i])
            if isCreature(sid) then
                clearPlayerState(sid)
            end
        end

        setPlayerStorageValue(cid, 52481, -1)
        setPlayerStorageValue(cid, 52485, -1)

        doPlayerSendTextMessage(inviter, 20, myName .. " declined your duel invite.")
        doPlayerSendTextMessage(cid, 20, "You declined the duel invite from " .. inviterName .. ".")

        if doSendPlayerExtendedOpcode then
            doSendPlayerExtendedOpcode(inviter, DUEL_CLEAR, myName)
            doSendPlayerExtendedOpcode(cid, DUEL_CLEAR, inviterName)
        end

        return true
    end

    return true
end
