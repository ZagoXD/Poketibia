local STG_BIKE_FLAG = 5712
local STG_BIKE_HP_BASE = 5710

local function BikeSpeedOn(cid, t)
    setPlayerStorageValue(cid, t.s, t.speed)
    doChangeSpeed(cid, -getCreatureSpeed(cid))
    doChangeSpeed(cid, t.speed)
end

local function BikeSpeedOff(cid, t)
    setPlayerStorageValue(cid, t.s, -1)
    doRegainSpeed(cid)
end

local t = {
    text = 'Mount, bike!',
    dtext = 'Demount, bike!',
    s = 5700,
    speed = 1200
}

local function getBikeConfByItemId(itemid)
    if itemid == 14113 then
        return 1300, 1394, 1393, false
    elseif itemid == 14152 then
        return 1000, 3519, 3519, true
    end
    return nil
end

local function applyBikeHpBoost(cid)
    if getPlayerStorageValue(cid, STG_BIKE_FLAG) == 1 then
        return
    end

    local baseMax = getCreatureMaxHealth(cid)
    setPlayerStorageValue(cid, STG_BIKE_HP_BASE, baseMax)

    local pct = getCreatureHealth(cid) / math.max(1, baseMax)
    local newMax = baseMax * 2
    setCreatureMaxHealth(cid, newMax)
    local targetHp = math.floor(newMax * pct + 0.5)
    doCreatureAddHealth(cid, targetHp - getCreatureHealth(cid))

    setPlayerStorageValue(cid, STG_BIKE_FLAG, 1)
end

local function removeBikeHpBoost(cid)
    if getPlayerStorageValue(cid, STG_BIKE_FLAG) ~= 1 then
        return
    end

    local currentMax = getCreatureMaxHealth(cid)
    local savedBase = tonumber(getPlayerStorageValue(cid, STG_BIKE_HP_BASE) or -1)

    local baseMax
    if savedBase and savedBase > 0 and savedBase < currentMax then
        baseMax = savedBase
    else
        baseMax = math.floor(currentMax / 2)
    end

    local pct = getCreatureHealth(cid) / math.max(1, currentMax)
    setCreatureMaxHealth(cid, baseMax)
    local targetHp = math.floor(baseMax * pct + 0.5)
    doCreatureAddHealth(cid, targetHp - getCreatureHealth(cid))

    setPlayerStorageValue(cid, STG_BIKE_HP_BASE, -1)
    setPlayerStorageValue(cid, STG_BIKE_FLAG, -1)
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
    if getPlayerStorageValue(cid, 17001) >= 1 or getPlayerStorageValue(cid, 63215) >= 1 or
        getPlayerStorageValue(cid, 17000) >= 1 or getPlayerStorageValue(cid, 75846) >= 1 or
        getPlayerStorageValue(cid, 6598754) >= 1 or getPlayerStorageValue(cid, 6598755) >= 1 then
        return doPlayerSendCancel(cid, "You can't do that right now.")
    end

    local speed, maleLook, femaleLook, dupHp = getBikeConfByItemId(item.itemid)
    if not speed then
        return doPlayerSendCancel(cid, "This bike is not configured.")
    end

    t.speed = speed

    if getPlayerStorageValue(cid, t.s) <= 0 then
        doCreatureSay(cid, t.text, 19)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, 'You have mounted in a bike.')
        BikeSpeedOn(cid, t)

        local look = (getPlayerSex(cid) == 1) and maleLook or femaleLook
        doSetCreatureOutfit(cid, {
            lookType = look
        }, -1)
        setPlayerStorageValue(cid, 5701, look)

        if dupHp then
            if getPlayerStorageValue(cid, STG_BIKE_FLAG) == 1 then
                removeBikeHpBoost(cid)
            end
            applyBikeHpBoost(cid)
        else
            removeBikeHpBoost(cid)
        end
    else
        doCreatureSay(cid, t.dtext, 19)
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, 'You haven demouted of a bike.')

        removeBikeHpBoost(cid)

        BikeSpeedOff(cid, t)
        doRemoveCondition(cid, CONDITION_OUTFIT)

        setPlayerStorageValue(cid, 5701, -1)
    end

    return true
end
