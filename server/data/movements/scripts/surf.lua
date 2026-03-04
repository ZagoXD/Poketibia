local function doSendMagicEffecte(pos, effect)
    addEvent(doSendMagicEffect, 50, pos, effect)
end

local waters = {11756, 4614, 4615, 4616, 4617, 4618, 4619, 4608, 4609, 4610, 4611, 4612, 4613, 7236, 4614, 4615, 4616,
                4617, 4618, 4619, 4620, 4621, 4622, 4623, 4624, 4625, 4665, 4666, 4820, 4821, 4822, 4823, 4824, 4825,
                4654}
local flie = {'4820', '4821', '4822', '4823', '4824', '4825', '4612'}
local premium = false

local NO_MOUNT_AREA = {
    from = {
        x = 2080,
        y = 1080
    },
    to = {
        x = 3670,
        y = 1940
    },
    zmin = 4,
    zmax = 9,
    ignoreZ = true
}

local function isInNoMountArea(pos)
    if not pos then
        return false
    end
    if pos.x < NO_MOUNT_AREA.from.x or pos.x > NO_MOUNT_AREA.to.x then
        return false
    end
    if pos.y < NO_MOUNT_AREA.from.y or pos.y > NO_MOUNT_AREA.to.y then
        return false
    end
    if NO_MOUNT_AREA.ignoreZ then
        return true
    end
    local z = pos.z or 7
    return (z >= NO_MOUNT_AREA.zmin and z <= NO_MOUNT_AREA.zmax)
end

function onStepIn(cid, item, position, fromPosition)
    local NPSpeed = 0
    local PSLimit = 0

    if isPlayer(cid) then
        NPSpeed = PlayerSpeed + (getPlayerLevel(cid) * 0.1)
        if NPSpeed >= PSLimit then
            NPSpeed = PSLimit
        end
    else
        NPSpeed = PlayerSpeed
    end

    if not isPlayer(cid) or isInArray({5, 6}, getPlayerGroupId(cid)) then
        return true
    end

    if getPlayerStorageValue(cid, 75846) >= 1 then
        return true
    end
    if isPlayer(cid) and getCreatureOutfit(cid).lookType == 814 then
        return false
    end -- TV outfit

    if isInNoMountArea(position) then
        doTeleportThing(cid, fromPosition, false)
        doPlayerSendCancel(cid, "You can't surf in this area.")
        return true
    end

    if isPlayer(cid) and not isPremium(cid) and premium == true then
        doTeleportThing(cid, fromPosition, false)
        doPlayerSendCancel(cid, "Only premium members are allowed to surf.")
        return true
    end

    if getCreatureOutfit(cid).lookType == 316 or getCreatureOutfit(cid).lookType == 648 then
        doSendMagicEffect(fromPosition, 136)
    end

    if (getPlayerStorageValue(cid, 63215) >= 1 or getPlayerStorageValue(cid, 17000) >= 1) then
        return true
    end

    local isWatchingTV = getPlayerStorageValue(cid, 18000) == 1

    if not isWatchingTV and #getCreatureSummons(cid) == 0 then
        doPlayerSendCancel(cid, "You need a pokemon to surf.")
        doTeleportThing(cid, fromPosition, false)
        return true
    end

    if not isWatchingTV and (not isInArray(specialabilities["surf"], getPokemonName(getCreatureSummons(cid)[1]))) then
        doPlayerSendCancel(cid, "This pokemon cannot surf.")
        doTeleportThing(cid, fromPosition, false)
        return true
    end

    if not isWatchingTV then
        local ball = getPlayerSlotItem(cid, 8)
        if ball and ball.uid > 0 then
            local megaActive = tonumber(getItemAttribute(ball.uid, "mega_active") or 0) == 1
            if megaActive then
                doPlayerSendCancel(cid, "Voce nao pode usar Surf enquanto seu Pokémon está em Mega Evolucao.")
                doTeleportThing(cid, fromPosition, false)
                return true
            end
        end
    end

    if getPlayerStorageValue(cid, 5700) == 1 then
        doPlayerSendCancel(cid, "You can't do that while is mount in a bike!")
        doTeleportThing(cid, fromPosition, false)
        return true
    end

    if getPlayerStorageValue(cid, 212124) >= 1 then
        doPlayerSendCancel(cid, "You can't do it with a pokemon with mind controlled!")
        doTeleportThing(cid, fromPosition, false)
        return true
    end

    if getPlayerStorageValue(cid, 52480) >= 1 then
        doPlayerSendCancel(cid, "You can't do it while a duel!")
        doTeleportThing(cid, fromPosition, false)
        return true
    end

    if getPlayerStorageValue(cid, 6598754) == 1 or getPlayerStorageValue(cid, 6598755) == 1 then
        doPlayerSendCancel(cid, "You can't do it while in the PVP Zone!")
        doTeleportThing(cid, fromPosition, false)
        return true
    end

    if not isWatchingTV then
        doSetCreatureOutfit(cid, {
            lookType = surfs[getPokemonName(getCreatureSummons(cid)[1])].lookType + 351
        }, -1)
        doCreatureSay(cid, "" .. getPokeName(getCreatureSummons(cid)[1]) .. ", lets surf!", 1)
        doChangeSpeed(cid, -(getCreatureSpeed(cid)))
        local speed = (NPSpeed + surfs[getPokemonName(getCreatureSummons(cid)[1])].speed) * speedRate
        setPlayerStorageValue(cid, 54844, speed)
        doChangeSpeed(cid, speed)

        local pct = getCreatureHealth(getCreatureSummons(cid)[1]) / getCreatureMaxHealth(getCreatureSummons(cid)[1])
        doItemSetAttribute(getPlayerSlotItem(cid, 8).uid, "hp", pct)
        doRemoveCreature(getCreatureSummons(cid)[1])
        addEvent(setPlayerStorageValue, 100, cid, 63215, 1)

        local item = getPlayerSlotItem(cid, 8)
        if getItemAttribute(item.uid, "boost") and getItemAttribute(item.uid, "boost") >= 50 and
            getPlayerStorageValue(cid, 42368) <= 0 then
            addEvent(sendAuraEffect, 120, cid, auraSyst[getItemAttribute(item.uid, "aura")])
        end

        if useOTClient then
            doPlayerSendCancel(cid, '12//,hide')
        end
    end

    return true
end

local direffects = {30, 49, 9, 51}

function onStepOut(cid, item, position, fromPosition)
    if isPlayer(cid) and getCreatureOutfit(cid).lookType == 814 then
        return false
    end

    local checkpos = fromPosition
    checkpos.stackpos = 0

    if isInArray(waters, getTileInfo(checkpos).itemid) then
        if getPlayerStorageValue(cid, 63215) >= 1 or getPlayerStorageValue(cid, 17000) >= 1 then
            doSendMagicEffecte(fromPosition, direffects[getCreatureLookDir(cid) + 1])
        end
    end

    if not isInArray(waters, getTileInfo(getThingPos(cid)).itemid) then
        if getPlayerStorageValue(cid, 17000) >= 1 then
            return true
        end
        if getPlayerStorageValue(cid, 63215) <= 0 then
            return true
        end

        doRemoveCondition(cid, CONDITION_OUTFIT)
        setPlayerStorageValue(cid, 63215, -1)

        local item = getPlayerSlotItem(cid, 8)
        local pokemon = getItemAttribute(item.uid, "poke")
        local x = pokes[pokemon]

        if not x then
            return true
        end

        if getItemAttribute(item.uid, "nick") then
            doCreatureSay(cid, getItemAttribute(item.uid, "nick") .. ", I'm tired of surfing!", 1)
        else
            doCreatureSay(cid, getItemAttribute(item.uid, "poke") .. ", I'm tired of surfing!", 1)
        end

        doSummonMonster(cid, pokemon)
        local pk = getCreatureSummons(cid)[1]

        if not isCreature(pk) then
            pk = doCreateMonster(pokemon, backupPos)
            if not isCreature(pk) then
                doPlayerSendCancel(cid, "You can't stop surfing here.")
                doTeleportThing(cid, fromPosition, false)
                return true
            end
            doConvinceCreature(cid, pk)
        end

        doChangeSpeed(pk, getCreatureSpeed(cid))
        doChangeSpeed(cid, -getCreatureSpeed(cid))
        doRegainSpeed(cid)

        local playerPos = getThingPos(cid)
        local newPos = getClosestFreeTile(pk, playerPos)

        if newPos.x == playerPos.x and newPos.y == playerPos.y and newPos.z == playerPos.z then
            local dirs = {{
                x = 1,
                y = 0
            }, {
                x = -1,
                y = 0
            }, {
                x = 0,
                y = 1
            }, {
                x = 0,
                y = -1
            }}
            for _, d in ipairs(dirs) do
                local tryPos = {
                    x = playerPos.x + d.x,
                    y = playerPos.y + d.y,
                    z = playerPos.z
                }
                if doTileQueryAdd(pk, tryPos) == RETURNVALUE_NOERROR then
                    newPos = tryPos
                    break
                end
            end
        end

        doTeleportThing(pk, newPos, false)
        doCreatureSetLookDir(pk, getCreatureLookDir(cid))

        adjustStatus(pk, item.uid, true, false, true)

        if useOTClient then
            doPlayerSendCancel(cid, '12//,show')
        end
    end

    return true
end
