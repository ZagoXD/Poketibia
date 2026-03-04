Raid = {
    lobbies = {},
    fights = {},
    bossArena = {}
}

local function _now()
    return os.time() * 1000
end

local function _random(min, max)
    return math.random(min, max)
end

local function _rollCount(range)
    if type(range) == "table" then
        return _random(range[1], range[2])
    end
    return tonumber(range) or 1
end

local function _addTimer(ms, cb)
    return addEvent(cb, ms)
end

local function _tp(cid, pos)
    doTeleportThing(cid, pos, true)
end

local function _msgAll(msg)
    doBroadcastMessage(msg)
end

local function _cleanItems(uids)
    for _, uid in ipairs(uids or {}) do
        if uid and uid > 0 then
            doRemoveItem(uid)
        end
    end
end

local function _setActionId(uid, aid)
    if setItemActionId then
        setItemActionId(uid, aid)
    else
        doItemSetAttribute(uid, "aid", aid)
    end
end

local function _getActionId(uid)
    if getItemActionId then
        return getItemActionId(uid)
    else
        return tonumber(getItemAttribute(uid, "aid"))
    end
end

local function _samePos(a, b)
    return a and b and a.x == b.x and a.y == b.y and a.z == b.z
end

RAID_DEBUG = false
local function _d(fmt, ...)
    if RAID_DEBUG then
        print("[RAID] " .. string.format(fmt, ...))
    end
end

function Raid.findLobbyByPos(pos)
    for lobbyId, _ in pairs(Raid.lobbies) do
        local def = RAID_LOBBY_SPAWNS[lobbyId]
        if def and def.pads then
            for _, p in ipairs(def.pads) do
                if _samePos(p, pos) then
                    return lobbyId
                end
            end
        end
    end
    return nil
end

function Raid.isActive(cid)
    return getPlayerStorageValue(cid, RAID_STOR.ACTIVE) == 1
end

local function _removeLobbyStructureByPos(def)
    for _, p in ipairs(def.pads or {}) do
        local it = getTileItemById(p, RAID_LOBBY_PAD_ITEMID)
        if it and it.uid and it.uid > 0 then
            local aid = _getActionId(it.uid)
            if not aid or aid == RAID_LOBBY_PAD_ACTIONID then
                doRemoveItem(it.uid)
            end
        end
    end
    local c = getTileItemById(def.center, RAID_LOBBY_CENTER_ITEMID)
    if c and c.uid and c.uid > 0 then
        doRemoveItem(c.uid)
    end
end

local function _ejectOutside(cid, center, r)
    local pos = getCreaturePosition(cid)
    local dx, dy = (pos.x - center.x), (pos.y - center.y)
    local sx = (dx >= 0) and 1 or -1
    local sy = (dy >= 0) and 1 or -1
    local out = {
        x = center.x + sx * (r + 1),
        y = center.y + sy * (r + 1),
        z = center.z
    }
    doTeleportThing(cid, out, true)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING,
        ("Lobby cheio (%d/%d). Tente o proximo."):format(RAID_MAX_PLAYERS, RAID_MAX_PLAYERS))
end

local function _setActionId(uid, aid)
    if setItemActionId then
        setItemActionId(uid, aid)
    else
        doItemSetAttribute(uid, "aid", aid)
    end
end

local function _getActionId(uid)
    if getItemActionId then
        return getItemActionId(uid)
    else
        return tonumber(getItemAttribute(uid, "aid"))
    end
end

local function _samePos(a, b)
    return a and b and a.x == b.x and a.y == b.y and a.z == b.z
end

local _DIFF_NAMES = {
    [1] = "Facil",
    [2] = "Media",
    [3] = "Dificil"
}

local function _pickDifficulty(def)
    local d = def.diff or RAID_DEFAULT_DIFFICULTY or 0
    if d == 0 then
        local opts = {RAID_DIFF.EASY, RAID_DIFF.MEDIUM, RAID_DIFF.HARD}
        return opts[_random(1, #opts)]
    end
    return d
end

local function _collectNearbyPlayers(center, radius)
    local r = radius or (RAID_LOBBY_RADIUS or 2)
    local found = {}

    if type(getSpectators) == "function" then
        local ok, res = pcall(getSpectators, center, r, r, false)
        if ok and type(res) == "table" then
            for _, thing in ipairs(res) do
                local uid = thing
                if type(thing) == "table" and thing.uid then
                    uid = thing.uid
                end
                if uid and uid > 0 and isPlayer(uid) then
                    table.insert(found, uid)
                end
            end
            return found
        end
    end

    for dx = -r, r do
        for dy = -r, r do
            local pos = {
                x = center.x + dx,
                y = center.y + dy,
                z = center.z
            }
            local top = getTopCreature(pos)
            if top and top.uid and top.uid > 0 and isPlayer(top.uid) then
                table.insert(found, top.uid)
            end
        end
    end
    return found
end

local function _creatureExists(uid)
    if not uid or uid <= 0 then
        return false
    end
    if isCreature then
        return isCreature(uid)
    end
    return isPlayer(uid) or isMonster(uid)
end

function Raid.findLobbyFromItem(item, pos)
    local lid = tonumber(getItemAttribute(item.uid, "raidLobbyId")) or 0
    if lid > 0 and Raid.lobbies[lid] then
        return lid
    end
    for lobbyId, _ in pairs(Raid.lobbies) do
        local def = RAID_LOBBY_SPAWNS[lobbyId]
        if def and def.pads then
            for _, p in ipairs(def.pads) do
                if _samePos(p, pos) then
                    return lobbyId
                end
            end
        end
    end
    return nil
end

function Raid.scanLobby(lobbyId)
    local L = Raid.lobbies[lobbyId];
    if not L then
        return
    end
    local def = RAID_LOBBY_SPAWNS[lobbyId];
    if not def then
        return
    end
    local R = RAID_LOBBY_RADIUS or 2
    local MAX = RAID_MAX_PLAYERS or 4

    local nearby = _collectNearbyPlayers(def.center, R)
    local nearSet = {}
    for _, cid in ipairs(nearby) do
        nearSet[cid] = true
    end

    for cid, _ in pairs(L.players) do
        if (not nearSet[cid]) or (not isPlayer(cid)) then
            Raid.leaveLobby(cid, lobbyId, true)
        end
    end

    if L.count < MAX then
        for _, cid in ipairs(nearby) do
            if isPlayer(cid) and not L.players[cid] then
                if L.count < MAX then
                    Raid.joinLobby(cid, lobbyId)
                else
                    break
                end
            end
        end
    end

    if L.count >= MAX then
        for _, cid in ipairs(nearby) do
            if isPlayer(cid) and not L.players[cid] then
                _ejectOutside(cid, def.center, R)
            end
        end
    end

    L.scanTimer = addEvent(function()
        Raid.scanLobby(lobbyId)
    end, 700)
end

function Raid.spawnLobby(lobbyId)
    local def = RAID_LOBBY_SPAWNS[lobbyId];
    if not def then
        return false
    end
    if Raid.lobbies[lobbyId] then
        return false
    end

    local rType = tostring(def.type or "fire")
    local typeSpec = RAID_TYPES[rType]
    if not typeSpec then
        print(("[RAID] ERRO: tipo '%s' inválido no lobby %d."):format(rType, lobbyId))
        return false
    end
    local diff = _pickDifficulty(def)
    local diffSpec = RAID_DIFF_CFG[diff] or RAID_DIFF_CFG[RAID_DIFF.EASY]

    -- cria o item central do TIPO correto
    doCreateItem(typeSpec.centerItemId, 1, def.center)

    local centerUid = 0
    local c = getTileItemById(def.center, typeSpec.centerItemId)
    if c and c.uid and c.uid > 0 then
        centerUid = c.uid
        if doItemSetAttribute then
            doItemSetAttribute(centerUid, "raidLobbyId", lobbyId)
        end
    end

    Raid.lobbies[lobbyId] = {
        players = {},
        joinOrder = {},
        count = 0,
        endsAt = _now() + RAID_LOBBY_WINDOW_MS,
        timers = {},
        scanTimer = nil,
        centerUid = centerUid,
        centerItemId = typeSpec.centerItemId,
        raidType = rType,
        raidDiff = diff
    }

    Raid.scanLobby(lobbyId)

    table.insert(Raid.lobbies[lobbyId].timers, addEvent(function()
        Raid.startFromLobby(lobbyId)
    end, RAID_LOBBY_WINDOW_MS))

    local mins = math.max(1, math.floor(RAID_LOBBY_WINDOW_MS / 60000))
    local hint = RAID_LOBBY_HINT and (" " .. RAID_LOBBY_HINT:format(RAID_LOBBY_RADIUS)) or ""
    doBroadcastMessage(("[RAID] Um portal de raid (%s - %s) apareceu em (%d,%d,%d) por %d minuto(s)!%s"):format(rType,
        _DIFF_NAMES[diff], def.center.x, def.center.y, def.center.z, mins, hint))
    return true
end

function Raid.joinLobby(cid, lobbyId)
    local L = Raid.lobbies[lobbyId];
    if not L then
        return false
    end
    if L.players[cid] then
        return true
    end

    if L.count >= (RAID_MAX_PLAYERS or 4) then
        doPlayerSendCancel(cid, "Lobby cheio.")
        return false
    end

    L.players[cid] = true
    table.insert(L.joinOrder, cid)
    L.count = L.count + 1

    setPlayerStorageValue(cid, RAID_STOR.ACTIVE, 1)
    setPlayerStorageValue(cid, RAID_STOR.STAGE, 1)
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voce entrou na fila da raid. Aguarde o inicio!")
    return true
end

function Raid.leaveLobby(cid, lobbyId, silent)
    local L = Raid.lobbies[lobbyId];
    if not L then
        return false
    end
    if not L.players[cid] then
        return false
    end

    L.players[cid] = nil
    L.count = math.max(0, L.count - 1)
    for i, pid in ipairs(L.joinOrder) do
        if pid == cid then
            table.remove(L.joinOrder, i);
            break
        end
    end

    if getPlayerStorageValue(cid, RAID_STOR.STAGE) == 1 then
        setPlayerStorageValue(cid, RAID_STOR.ACTIVE, 0)
        setPlayerStorageValue(cid, RAID_STOR.STAGE, 0)
        setPlayerStorageValue(cid, RAID_STOR.INST, 0)
        if not silent then
            doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voce saiu da fila da raid.")
        end
    end
    return true
end

function Raid.startFromLobby(lobbyId)
    local L = Raid.lobbies[lobbyId];
    if not L then
        return
    end
    local def = RAID_LOBBY_SPAWNS[lobbyId];
    if not def then
        return
    end
    local R = RAID_LOBBY_RADIUS or 2
    local MAX = RAID_MAX_PLAYERS or 4

    if L.scanTimer then
        stopEvent(L.scanTimer);
        L.scanTimer = nil
    end

    while true do
        local c = getTileItemById(def.center, L.centerItemId)
        if not c or not c.uid or c.uid <= 0 then
            break
        end
        local rid = 0
        if getItemAttribute then
            rid = tonumber(getItemAttribute(c.uid, "raidLobbyId")) or 0
        end
        if rid ~= lobbyId then
            break
        end
        doRemoveItem(c.uid)
    end

    local nearby = _collectNearbyPlayers(def.center, R)
    local nearSet = {}
    for _, cid in ipairs(nearby) do
        nearSet[cid] = true
    end

    local players = {}
    for _, cid in ipairs(L.joinOrder) do
        if #players >= MAX then
            break
        end
        if L.players[cid] and nearSet[cid] and isPlayer(cid) then
            table.insert(players, cid)
        end
    end

    local spec = {
        type = L.raidType,
        diff = L.raidDiff
    }
    Raid.lobbies[lobbyId] = nil
    if #players == 0 then
        return
    end

    Raid.startFight(lobbyId, players, spec)
end

function Raid.startFight(instId, players, spec)
    local rType = spec and spec.type or "fire"
    local diff = spec and spec.diff or RAID_DIFF.EASY

    local typeSpec = RAID_TYPES[rType]
    local diffSpec = RAID_DIFF_CFG[diff]
    local bossName = (RAID_BOSSES[rType] and RAID_BOSSES[rType][diff]) or "Charizard"

    if not typeSpec or not diffSpec then
        print("[RAID] ERRO: spec inválida em startFight.");
        return false
    end

    local F = {
        players = {},
        bossUid = 0,
        timer = nil,
        watch = nil,
        ended = false,
        type = rType,
        diff = diff,
        time_ms = diffSpec.time_ms,
        enterPos = typeSpec.enter,
        bossPos = typeSpec.bossPos,
        chestRoom = diffSpec.chest_room,
        chestAid = diffSpec.chest_aid,
        lootMult = diffSpec.loot_mult,
        endsAt = _now() + diffSpec.time_ms
    }

    for _, cid in ipairs(players) do
        if isPlayer(cid) then
            F.players[cid] = true
            setPlayerStorageValue(cid, RAID_STOR.ACTIVE, 1)
            setPlayerStorageValue(cid, RAID_STOR.STAGE, 2)
            setPlayerStorageValue(cid, RAID_STOR.INST, instId)
            doTeleportThing(cid, F.enterPos, true)
        end
    end

    local function spawnMonsterSafe(name, pos)
        local m = doCreateMonster(name, pos, false);
        if m and m > 0 then
            return m
        end
        m = doCreateMonster(name, pos);
        if m and m > 0 then
            return m
        end
        if doSummonCreature then
            m = doSummonCreature(name, pos);
            if m and m > 0 then
                return m
            end
        end
        return 0
    end

    local mob = spawnMonsterSafe(bossName, F.bossPos)
    if not mob or mob == 0 then
        local spawned = false
        for dx = -1, 1 do
            for dy = -1, 1 do
                if not spawned and not (dx == 0 and dy == 0) then
                    local p = {
                        x = F.bossPos.x + dx,
                        y = F.bossPos.y + dy,
                        z = F.bossPos.z
                    }
                    mob = spawnMonsterSafe(bossName, p)
                    if mob and mob > 0 then
                        spawned = true;
                        break
                    end
                end
            end
        end
        if not spawned then
            print("[RAID] ERRO: falha ao criar boss.")
            Raid.failFight(instId, "Falha ao criar o chefe.");
            return false
        end
    end

    F.bossUid = mob
    Raid.bossArena[mob] = instId
    if registerCreatureEvent then
        registerCreatureEvent(mob, "RaidBossDeath")
    end

    local function watchBoss()
        if F.ended then
            return
        end
        if not _creatureExists(F.bossUid) then
            F.watch = nil;
            Raid.winFight(instId);
            return
        end
        F.watch = addEvent(watchBoss, 500)
    end
    F.watch = addEvent(watchBoss, 500)

    F.timer = _addTimer(F.time_ms, function()
        Raid.failFight(instId, "Tempo esgotado.")
    end)

    Raid.fights[instId] = F
    return true
end

function Raid.kickFromRaid(cid, msg, silent)
    if not isPlayer(cid) then
        return true
    end
    if getPlayerStorageValue(cid, RAID_STOR.REMOVING) == 1 then
        return true
    end
    setPlayerStorageValue(cid, RAID_STOR.REMOVING, 1)

    doTeleportThing(cid, RAID_EXIT_POS, true)

    addEvent(function()
        if not isPlayer(cid) then
            return
        end
        local hp, maxhp = getCreatureHealth(cid), getCreatureMaxHealth(cid)
        if hp < maxhp then
            doCreatureAddHealth(cid, (maxhp - hp))
        end
        doRemoveConditions(cid, true)
        Raid.clearPlayer(cid)
        if not silent then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING, msg or "Voce foi retirado da raid.")
        end
        setPlayerStorageValue(cid, RAID_STOR.REMOVING, 0)
    end, 50)

    return true
end

function Raid.failFight(instId, reason)
    local F = Raid.fights[instId];
    if not F then
        return
    end
    F.ended = true
    if F.timer then
        stopEvent(F.timer);
        F.timer = nil
    end
    if F.watch then
        stopEvent(F.watch);
        F.watch = nil
    end

    if F.bossUid and F.bossUid > 0 then
        Raid.bossArena[F.bossUid] = nil
        if isMonster(F.bossUid) then
            doRemoveCreature(F.bossUid)
        end
    end

    for cid, _ in pairs(F.players) do
        if isPlayer(cid) and getPlayerStorageValue(cid, RAID_STOR.ACTIVE) == 1 and
            getPlayerStorageValue(cid, RAID_STOR.STAGE) >= 2 then
            Raid.kickFromRaid(cid, "A raid falhou.", true)
        end
    end
    Raid.fights[instId] = nil
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "A raid falhou!!")
end

function Raid.winFight(instId)
    local F = Raid.fights[instId];
    if not F then
        return
    end
    F.ended = true
    if F.timer then
        stopEvent(F.timer);
        F.timer = nil
    end
    if F.watch then
        stopEvent(F.watch);
        F.watch = nil
    end
    if F.bossUid and F.bossUid > 0 then
        Raid.bossArena[F.bossUid] = nil
    end

    for cid, _ in pairs(F.players) do
        if isPlayer(cid) and getPlayerStorageValue(cid, RAID_STOR.ACTIVE) == 1 and
            getPlayerStorageValue(cid, RAID_STOR.STAGE) == 2 then
            setPlayerStorageValue(cid, RAID_STOR.STAGE, 3)
            setPlayerStorageValue(cid, RAID_STOR.CLAIMED, 0)
            setPlayerStorageValue(cid, RAID_STOR.DIFF, F.diff)
            doTeleportThing(cid, F.chestRoom, true)
        end
    end
    Raid.fights[instId] = nil

end

function Raid.clearPlayer(cid)
    setPlayerStorageValue(cid, RAID_STOR.ACTIVE, 0)
    setPlayerStorageValue(cid, RAID_STOR.STAGE, 0)
    setPlayerStorageValue(cid, RAID_STOR.INST, 0)
end

function Raid.giveChestReward(cid)
  if getPlayerStorageValue(cid, RAID_STOR.ACTIVE) ~= 1 then
    doPlayerSendCancel(cid, "Voce nao esta em uma raid."); return false
  end
  if getPlayerStorageValue(cid, RAID_STOR.STAGE) ~= 3 then
    doPlayerSendCancel(cid, "Este bau nao e para voce agora."); return false
  end
  if getPlayerStorageValue(cid, RAID_STOR.CLAIMED) == 1 then
    doPlayerSendCancel(cid, "Voce ja pegou sua recompensa."); return false
  end

  local diff = tonumber(getPlayerStorageValue(cid, RAID_STOR.DIFF)) or RAID_DIFF.EASY
  local lootCfgEasy = RAID_LOOT_TABLE[RAID_DIFF.EASY]
  local lootCfgThis = RAID_LOOT_TABLE[diff]
  if not lootCfgEasy or not lootCfgThis then
    doPlayerSendCancel(cid, "Loot da raid nao configurado."); return false
  end

  local pool = {}
  local function append(list) for _,it in ipairs(list or {}) do table.insert(pool, it) end end
  append(lootCfgEasy.pool)
  if diff >= RAID_DIFF.MEDIUM then append(RAID_LOOT_TABLE[RAID_DIFF.MEDIUM].extra) end
  if diff >= RAID_DIFF.HARD   then append(RAID_LOOT_TABLE[RAID_DIFF.HARD].extra)   end
  if #pool == 0 then
    doPlayerSendCancel(cid, "Loot vazio."); return false
  end

  local pmin, pmax = lootCfgThis.picks[1] or 1, lootCfgThis.picks[2] or 1
  local picks = math.max(1, _random(pmin, pmax))
  picks = math.min(picks, #pool)

  local idx = {}
  for i = 1, #pool do idx[i] = i end
  for i = #idx, 2, -1 do
    local j = _random(1, i)
    idx[i], idx[j] = idx[j], idx[i]
  end

  for i = 1, picks do
    local it = pool[idx[i]]
    local qty = 1
    if type(it.count) == "table" then
      local a, b = tonumber(it.count[1]) or 1, tonumber(it.count[2]) or tonumber(it.count[1]) or 1
      if b < a then b = a end
      qty = _random(a, b)
    else
      qty = tonumber(it.count) or 1
    end
    doPlayerAddItem(cid, it.id, qty, true)
  end

  setPlayerStorageValue(cid, RAID_STOR.CLAIMED, 1)
  _tp(cid, RAID_EXIT_POS)
  Raid.clearPlayer(cid)
  return true
end


