local AID              = 33780
local ANVIL_ITEMID     = 2555
local WATCH_MS         = 500
local MAX_WATCH_SEC    = 600
local STORAGE_ACTIVE   = 92200
local STORAGE_POS_X    = 92201
local STORAGE_POS_Y    = 92202
local STORAGE_POS_Z    = 92203
local STORAGE_WATCH_TS = 92204

local function sendOpenPayload(cid, pos)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
        string.format("[DMEM_HIDE][SHINYPANEL] OPEN X=%d;Y=%d;Z=%d", pos.x, pos.y, pos.z))
end

local function sendHidePayload(cid)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "[DMEM_HIDE][SHINYPANEL] HIDE")
end

local function clearWatch(cid)
    setPlayerStorageValue(cid, STORAGE_ACTIVE, 0)
    setPlayerStorageValue(cid, STORAGE_POS_X, 0)
    setPlayerStorageValue(cid, STORAGE_POS_Y, 0)
    setPlayerStorageValue(cid, STORAGE_POS_Z, 0)
    setPlayerStorageValue(cid, STORAGE_WATCH_TS, 0)
end

local function isNear(posA, posB)
    if not posA or not posB then return false end
    if posA.z ~= posB.z then return false end
    local dx = math.abs(posA.x - posB.x)
    local dy = math.abs(posA.y - posB.y)
    return dx <= 1 and dy <= 1
end

local function startWatch(cid)
    if not isPlayer(cid) then return end
    local startTs = os.time()
    local function tick(pid)
        if not isPlayer(pid) then return end
        if getPlayerStorageValue(pid, STORAGE_ACTIVE) ~= 1 then return end

        local ax = tonumber(getPlayerStorageValue(pid, STORAGE_POS_X)) or 0
        local ay = tonumber(getPlayerStorageValue(pid, STORAGE_POS_Y)) or 0
        local az = tonumber(getPlayerStorageValue(pid, STORAGE_POS_Z)) or 0
        local anvilPos = {x=ax, y=ay, z=az}

        local ppos = getCreaturePosition(pid)
        if not ppos or not isNear(ppos, anvilPos) then
            sendHidePayload(pid)
            clearWatch(pid)
            return
        end

        if os.time() - startTs >= MAX_WATCH_SEC then
            sendHidePayload(pid)
            clearWatch(pid)
            return
        end

        addEvent(tick, WATCH_MS, pid)
    end
    addEvent(tick, WATCH_MS, cid)
end

local function markWatch(cid, pos)
    setPlayerStorageValue(cid, STORAGE_ACTIVE, 1)
    setPlayerStorageValue(cid, STORAGE_POS_X, pos.x)
    setPlayerStorageValue(cid, STORAGE_POS_Y, pos.y)
    setPlayerStorageValue(cid, STORAGE_POS_Z, pos.z)
    setPlayerStorageValue(cid, STORAGE_WATCH_TS, os.time())
    startWatch(cid)
end

local function getActionId(uid)
    local aid = tonumber(getItemAttribute(uid, 'aid') or 0) or 0
    if aid == 0 and getItemActionId then
        aid = tonumber(getItemActionId(uid) or 0) or 0
    end
    return aid
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
    if item.itemid ~= ANVIL_ITEMID then return true end
    if getActionId(item.uid) ~= AID then
        doPlayerSendCancel(cid, "Essa bigorna não está ativa.")
        return true
    end

    local ppos = getCreaturePosition(cid)
    if not isNear(ppos, toPosition) then
        doPlayerSendCancel(cid, "Chegue mais perto da bigorna para usar.")
        return true
    end

    sendOpenPayload(cid, toPosition)
    markWatch(cid, toPosition)
    return true
end
