local del = {460, 1022, 1023, 1024}

function onStepIn(cid, item, frompos, item2, topos)
    if not isPlayer(cid) or getPlayerStorageValue(cid, 18000) == 1 then
        return true
    end

    if getPlayerStorageValue(cid, 17000) <= 0 then
        doTeleportThing(cid, topos, false)

        local tile = getTileThingByPos(frompos)
        if tile and tile.uid > 0 and tile.itemid > 0 then
            doRemoveItem(tile.uid, 1)
        end

        doPlayerSendCancel(cid, "You can't fly.")
        return true
    end

    if getPlayerStorageValue(cid, 17000) >= 1 then
        if topos.z == frompos.z then
            local effect = (getCreatureOutfit(cid).lookType == 316) and 136 or 2
            doSendMagicEffect(topos, effect)
        end
    end

    for x = -1, 1 do
        for y = -1, 1 do
            local posa = {x = topos.x + x, y = topos.y + y, z = topos.z}
            local thing = getTileThingByPos(posa)
            if thing and thing.uid > 0 and thing.itemid > 0 and isInArray(del, thing.itemid) then
                doRemoveItem(thing.uid, 1)
            end
        end
    end

    for x = -1, 1 do
        for y = -1, 1 do
            local pose = {x = frompos.x + x, y = frompos.y + y, z = frompos.z}
            local thing = getTileThingByPos(pose)
            if thing and thing.itemid == 0 then
                doCombatAreaHealth(cid, 0, pose, 0, 0, 0, CONST_ME_NONE)
                doCreateItem(460, 1, pose)
            end
        end
    end
    addEvent(function()
        for x = -1, 1 do
            for y = -1, 1 do
                local pose = {x = frompos.x + x, y = frompos.y + y, z = frompos.z}
                local thing = getTileThingByPos(pose)
                if thing and thing.itemid == 0 then
                    doCombatAreaHealth(cid, 0, pose, 0, 0, 0, CONST_ME_NONE)
                    doCreateItem(460, 1, pose)
                end
            end
        end
        doCombatAreaHealth(cid, 0, topos, 0, 0, 0, CONST_ME_NONE)
        doCreateItem(460, 1, frompos)
    end, 50)

    doCombatAreaHealth(cid, 0, topos, 0, 0, 0, CONST_ME_NONE)
    doCreateItem(460, 1, frompos)

    if topos.z > frompos.z then
        doCreateItem(11676, 1, frompos)
        local tile = getTileThingByPos(frompos)
        if tile and tile.uid > 0 and tile.itemid > 0 then
            doTransformItem(tile.uid, 11676)
        end
    elseif topos.z < frompos.z then
        doCreateItem(11675, 1, frompos)
        local tile = getTileThingByPos(frompos)
        if tile and tile.uid > 0 and tile.itemid > 0 then
            doTransformItem(tile.uid, 11675)
        end
    end

    return true
end

function onStepOut(cid, item, position, lastPosition, fromPosition, toPosition, actor)
    if not isPlayer(cid) or getPlayerStorageValue(cid, 18000) == 1 then
        return true
    end

    local effect = 2
    if toPosition.z == fromPosition.z and getCreatureOutfit(cid).lookType ~= 316 and getCreatureOutfit(cid).lookType ~= 648 then
        doSendMagicEffect(fromPosition, effect)
    end

    local oldtpos = fromPosition
    oldtpos.stackpos = STACKPOS_GROUND

    local tile = getTileThingByPos(oldtpos)
    if tile and tile.uid > 0 and tile.itemid > 0 then
        doRemoveItem(tile.uid, 1)
    end

    return true
end
