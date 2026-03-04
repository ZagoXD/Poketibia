local QUESTS = {
[55334] = {
    minLevel = 10,
    exp      = 50000,
    items    = {
      {id = 2392,  count = 10},
      {id = 2152,  count = 30},
      {id = 12344, count = 10},
    },
    message  = "Parabens! Voce concluiu a first quest.",
  },
[55338] = {
    minLevel = 40,
    exp      = 70000,
    items    = {
      {id = 2392,  count = 10},
      {id = 11446,  count = 2},
      {id = 2160,  count = 1},
      {id = 12344, count = 10},
    },
    message  = "Parabens! Voce concluiu a punch stone quest.",
  },
[55339] = {
    minLevel = 70,
    exp      = 100000,
    items    = {
      {id = 2392,  count = 10},
      {id = 11443,  count = 2},
      {id = 11641,  count = 1},
      {id = 2160,  count = 5},
      {id = 12344, count = 10},
    },
    message  = "Parabens! Voce concluiu a venom quest.",
  },
[55340] = {
    minLevel = 40,
    exp      = 70000,
    items    = {
      {id = 2392,  count = 10},
      {id = 11451,  count = 2},
      {id = 2160,  count = 5},
      {id = 12344, count = 10},
    },
    message  = "Parabens! Voce concluiu a earth stone quest.",
  },
[55341] = {
    minLevel = 80,
    exp      = 105000,
    items    = {
      {id = 2392,  count = 10},
      {id = 11445,  count = 2},
      {id = 11641,  count = 1},
      {id = 2160,  count = 5},
      {id = 12344, count = 10},
    },
    message  = "Parabens! Voce concluiu a rock quest.",
  },
[55342] = {
    minLevel = 40,
    exp      = 70000,
    items    = {
      {id = 2392,  count = 10},
      {id = 11450,  count = 2},
      {id = 2160,  count = 1},
      {id = 12344, count = 10},
    },
    message  = "Parabens! Voce concluiu a darkness stone quest.",
  },

  [55343] = {
    minLevel = 60,
    exp      = 60000,
    items    = {
      {id = 2392,  count = 10},
      {id = 11452,  count = 2},
      {id = 2160,  count = 1},
      {id = 12344, count = 10},
    },
    message  = "Parabens! Voce concluiu a enigma stone quest.",
  },
[55344] = {
    minLevel = 80,
    exp      = 120000,
    items    = {
      {id = 2392,  count = 10},
      {id = 11449,  count = 2},
      {id = 11454,  count = 2},
      {id = 2160,  count = 10},
      {id = 12344, count = 10},
    },
    message  = "Parabens! Voce concluiu a ice quest.",
  },
  [55345] = {
    minLevel = 50,
    exp      = 60000,
    items    = {
      {id = 2392,  count = 10},
      {id = 11453,  count = 2},
      {id = 2160,  count = 1},
      {id = 12344, count = 10},
    },
    message  = "Parabens! Voce concluiu a heart stone quest.",
  },
[55346] = {
    minLevel = 40,
    exp      = 60000,
    items    = {
      {id = 2392,  count = 10},
      {id = 11444,  count = 2},
      {id = 2160,  count = 1},
      {id = 12344, count = 10},
    },
    message  = "Parabens! Voce concluiu a thunder stone quest.",
  },
  [55347] = {
    minLevel = 120,
    exp      = 120000,
    items    = {
      {id = 12331,  count = 1},
    },
    message  = "Parabens! Voce concluiu a psychic quest.",
  },
  [55348] = {
    minLevel = 40,
    exp      = 70000,
    items    = {
      {id = 2392,  count = 10},
      {id = 11448,  count = 2},
      {id = 2160,  count = 1},
      {id = 12344, count = 10},
    },
    message  = "Parabens! Voce concluiu a darkness stone quest.",
  },
}

local STOR_BASE = 900000

local function chestStorageKey(aid)
  return STOR_BASE + (tonumber(aid) or 0)
end

local function itemName(id)
  local n = getItemNameById(id)
  return n and n or ("item "..tostring(id))
end

local function giveItemsAtomic(cid, items)
  local added = {}
  for _, it in ipairs(items or {}) do
    local count = tonumber(it.count) or 1
    local uid = doPlayerAddItem(cid, it.id, count)
    if not uid or uid <= 0 then
      for _,u in ipairs(added) do
        if u and u > 0 then
          doRemoveItem(u, -1)
        end
      end
      return false
    end
    table.insert(added, uid)
  end
  return true
end

local function fmtRewardText(q)
  local parts = {}
  if q.exp and q.exp > 0 then
    table.insert(parts, (q.exp).." exp")
  end
  if q.items and #q.items > 0 then
    for _,it in ipairs(q.items) do
      table.insert(parts, (it.count or 1).."x "..itemName(it.id))
    end
  end
  return table.concat(parts, ", ")
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
  local aid = item.actionid or 0
  local cfg = QUESTS[aid]
  if not cfg then
    return false
  end

  local storKey = chestStorageKey(aid)
  local done = tonumber(getPlayerStorageValue(cid, storKey)) or -1
  if done > 0 then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
      "Voce ja pegou este bau.")
    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
    return true
  end

  local lvl = getPlayerLevel(cid)
  local need = tonumber(cfg.minLevel) or 1
  if lvl < need then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
      "Voce precisa ser pelo menos level "..need.." para abrir este bau.")
    doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
    return true
  end

  if cfg.exp and cfg.exp > 0 then
    doPlayerAddExperience(cid, cfg.exp)
  end

  if cfg.items and #cfg.items > 0 then
    local ok = giveItemsAtomic(cid, cfg.items)
    if not ok then
      doPlayerSendCancel(cid, "Nao foi possivel entregar os itens. Libere espaco e tente novamente.")
      doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POFF)
      return true
    end
  end

  setPlayerStorageValue(cid, storKey, 1)

  local msg = cfg.message or "Parabens! Voce recebeu sua recompensa."
  local detail = fmtRewardText(cfg)
  if detail ~= "" then
    msg = msg .. " ("..detail..")"
  end
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
  doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)

  return true
end
