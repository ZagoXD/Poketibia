local lower = {'460', '11675', '11676'}

local function removeFlyArea(centerPos)
    local del = {460, 1022, 1023, 1024, 11675, 11676}
    for x = -1, 1 do
        for y = -1, 1 do
            local posa = {x = centerPos.x + x, y = centerPos.y + y, z = centerPos.z}
            local tile = getTileThingByPos(posa)
            if tile and tile.uid > 0 and tile.itemid > 0 and isInArray(del, tile.itemid) then
                doRemoveItem(tile.uid, 1)
            end
        end
    end
end

local function createFlyArea(centerPos)
    for x = -1, 1 do
        for y = -1, 1 do
            local posa = {x = centerPos.x + x, y = centerPos.y + y, z = centerPos.z}
            local tile = getTileThingByPos(posa)
            if tile and tile.itemid == 0 then
                doCreateItem(460, 1, posa)
            end
        end
    end
end

function onSay(cid, words, param)
    if param ~= "" then
        return false
    end

    if getPlayerStorageValue(cid, 17000) <= 0 then
        return true
    end

    local pos = getThingPos(cid)

    if pos.z == 7 or getTileInfo(pos).itemid == 11677 then
        doPlayerSendCancel(cid, "You can't go lower!")
        createFlyArea(pos)
        return true
    end

    if not isInArray(lower, getTileInfo(pos).itemid) and getTileInfo(pos).itemid >= 2 then
        doPlayerSendCancel(cid, "You can't go lower.")
        createFlyArea(pos)
        return true
    end

    removeFlyArea(pos)

    local newPos = {x = pos.x, y = pos.y, z = pos.z + 1, stackpos = 0}

    if getTileThingByPos(newPos).itemid >= 1 then
        if getTilePzInfo(newPos) == true or not canWalkOnPos(newPos, true, true, false, false, true) then
            doPlayerSendCancel(cid, "You can't go down here.")
            createFlyArea(pos)
            return true
        end

        doTeleportThing(cid, newPos)
        if getCreatureOutfit(cid).lookType == 667 or getCreatureOutfit(cid).lookType == 999 then
            markPosEff(cid, newPos)
        end
    else
        doCombatAreaHealth(cid, 0, newPos, 0, 0, 0, CONST_ME_NONE)
        doCreateItem(11675, 1, newPos)
        doTeleportThing(cid, newPos)
        if getCreatureOutfit(cid).lookType == 667 or getCreatureOutfit(cid).lookType == 999 then
            markPosEff(cid, newPos)
        end
    end

    return true
end
