local MINT_TO_NATURE = {
    [12706] = "Lonely",
    [12707] = "Adamant",
    [12708] = "Naughty",
    [12709] = "Brave",
    [12710] = "Bold",
    [12711] = "Impish",
    [12712] = "Lax",
    [12713] = "Relaxed",
    [12714] = "Modest",
    [12715] = "Mild",
    [12716] = "Rash",
    [12717] = "Quiet",
    [12718] = "Calm",
    [12719] = "Gentle",
    [12720] = "Careful",
    [12721] = "Sassy",
    [12722] = "Timid",
    [12723] = "Hasty",
    [12724] = "Jolly",
    [12725] = "Naive",
    [12726] = "Serious"
}

local function isPokeballItem(itemid)

    if type(isPokeball) == "function" then
        return isPokeball(itemid)
    end
    return false
end

local function tryRecalcIfSummoned(cid, ball)
    if not ball or ball.uid <= 0 then
        return
    end
    local summons = getCreatureSummons(cid)
    if not summons or #summons == 0 then
        return
    end

    local mon = summons[1]
    if type(adjustStatus) == "function" then
        adjustStatus(mon, ball, true, true, false)
    end
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local nature = MINT_TO_NATURE[item.itemid]
    if not nature then
        doPlayerSendCancel(cid, "This mint is not configured.")
        return true
    end

    if not itemEx or itemEx.uid <= 0 then
        doPlayerSendCancel(cid, "Use the mint on a pokeball.")
        return true
    end

    local info = getItemInfo(itemEx.itemid)
    local hasPokeAttr = getItemAttribute(itemEx.uid, "poke")
    local isBall = false
    if type(isPokeball) == "function" then
        isBall = isPokeball(itemEx.itemid)
    else
        isBall = (info and info.name and info.name:lower():find("ball")) and true or false
    end

    if not isBall or not hasPokeAttr then
        doPlayerSendCancel(cid, "You must use the mint on a pokeball that contains a Pokemon.")
        return true
    end

    local current = getItemAttribute(itemEx.uid, "nature")
    if current == nature then
        doPlayerSendCancel(cid, "This Pokemon already has the " .. nature .. " nature.")
        return true
    end

    doItemSetAttribute(itemEx.uid, "nature", nature)

    doRemoveItem(item.uid, 1)

    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
        "Nature set to " .. nature .. ". The Pokemon's stats will reflect this nature.")
    doSendMagicEffect(getThingPos(cid), CONST_ME_MAGIC_GREEN)

    local summons = getCreatureSummons(cid)
    if summons and #summons > 0 then
        local mon = summons[1]
        if type(adjustStatus) == "function" then
            adjustStatus(mon, itemEx, true, true, false)
        end
        doSendMagicEffect(getThingPos(mon), CONST_ME_MAGIC_GREEN)
        doSendAnimatedText(getThingPos(mon), nature, 65)
    end

    return true
end

