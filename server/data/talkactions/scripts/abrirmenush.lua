local AID = 33780
local ANVIL_ITEMID = 2555

local STORAGE_ACTIVE   = 92200
local STORAGE_POS_X    = 92201
local STORAGE_POS_Y    = 92202
local STORAGE_POS_Z    = 92203
local STORAGE_WATCH_TS = 92204

local function sendOpenPayload(cid, pos)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE,
        string.format("[DMEM_HIDE][SHINYPANEL] OPEN X=%d;Y=%d;Z=%d", pos.x, pos.y, pos.z))
end

local function startWatch(cid)
    local function isNear(a,b)
        if a.z ~= b.z then return false end
        return math.abs(a.x-b.x) <= 1 and math.abs(a.y-b.y) <= 1
    end
    local WATCH_MS = 500
    local MAX_WATCH_SEC = 600
    local startTs = os.time()
    local function tick(pid)
        if not isPlayer(pid) then return end
        if getPlayerStorageValue(pid, STORAGE_ACTIVE) ~= 1 then return end
        local ax = tonumber(getPlayerStorageValue(pid, STORAGE_POS_X)) or 0
        local ay = tonumber(getPlayerStorageValue(pid, STORAGE_POS_Y)) or 0
        local az = tonumber(getPlayerStorageValue(pid, STORAGE_POS_Z)) or 0
        local anvilPos = {x=ax,y=ay,z=az}
        local ppos = getCreaturePosition(pid)
        if not isNear(ppos, anvilPos) or (os.time() - startTs) >= MAX_WATCH_SEC then
            doPlayerSendTextMessage(pid, MESSAGE_STATUS_CONSOLE_ORANGE, "[DMEM_HIDE][SHINYPANEL] HIDE")
            setPlayerStorageValue(pid, STORAGE_ACTIVE, 0)
            return
        end
        addEvent(tick, WATCH_MS, pid)
    end
    addEvent(tick, WATCH_MS, cid)
end

local function setWatchPos(cid, pos)
    setPlayerStorageValue(cid, STORAGE_ACTIVE, 1)
    setPlayerStorageValue(cid, STORAGE_POS_X, pos.x)
    setPlayerStorageValue(cid, STORAGE_POS_Y, pos.y)
    setPlayerStorageValue(cid, STORAGE_POS_Z, pos.z)
    setPlayerStorageValue(cid, STORAGE_WATCH_TS, os.time())
end

local function getActionId(uid)
    local aid = tonumber(getItemAttribute(uid, 'aid') or 0) or 0
    if aid == 0 and getItemActionId then
        aid = tonumber(getItemActionId(uid) or 0) or 0
    end
    return aid
end

local function findNearbyAnvil(cid)
    local p = getCreaturePosition(cid)
    for dx = -1, 1 do
        for dy = -1, 1 do
            local pos = {x=p.x+dx, y=p.y+dy, z=p.z, stackpos=1}
            local it = getTileItemById(pos, ANVIL_ITEMID)
            if it and it.uid > 0 then
                if getActionId(it.uid) == AID then
                    return pos
                end
            end
        end
    end
    return nil
end

function onSay(cid, words, param)
    local pos = findNearbyAnvil(cid)
    if not pos then
        doPlayerSendCancel(cid, "Você precisa estar ao lado de uma bigorna ativa.")
        return true
    end

    sendOpenPayload(cid, pos)
    setWatchPos(cid, pos)
    startWatch(cid)
    return true
end
