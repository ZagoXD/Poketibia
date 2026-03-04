dofile('data/lib/configuration.lua')
local function getClientIdSafe(itemid)
  if ItemType then
    local it = ItemType(itemid)
    if it and it.getClientId then
      local cid = it:getClientId()
      if cid and cid > 0 then return cid end
    end
  end
  if getItemInfo then
    local info = getItemInfo(itemid)
    if info and info.clientId and info.clientId > 0 then
      return info.clientId
    end
  end
  return 0
end

PB_SYNC_CODE = 205

local function sendCode(cid, code, payload)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR or 18, string.format("&sco&,%d,%s", code, payload or ""))
end

function sendPokeballOnClientIds(cid)
  if not cid then return end

  local seen, ids = {}, {}

  if type(pokeballs) == "table" then
    for _, def in pairs(pokeballs) do
      if def and def.on then
        local clientId = getClientIdSafe(def.on)
        if clientId > 0 and not seen[clientId] then
          table.insert(ids, clientId); seen[clientId] = true
        end
      end
    end
  end

  sendCode(cid, PB_SYNC_CODE, table.concat(ids, ";"))
end

function syncBallHpAndIcon(cid, ballUid, pushClientHp)
  if not ballUid or ballUid <= 0 then return end

  local base = getItemAttribute(ballUid, "poke") or ""
  if base == "" then return end

  local hpFrac = tonumber(getItemAttribute(ballUid, "hp") or 0) or 0
  if hpFrac < 0 then hpFrac = 0 end
  if hpFrac > 1 then hpFrac = 1 end

  if hpFrac <= 0 then
    doItemSetAttribute(ballUid, "10002", base .. "_off")
  else
    doItemSetAttribute(ballUid, "10002", base)
  end

  local it = getPlayerSlotItem(cid, 8)
  local id = it and it.uid == ballUid and it.itemid or getThing(ballUid).itemid
  if id and id > 0 then
    doTransformItem(ballUid, id - 1)
    doTransformItem(ballUid, id)
  end

  if pushClientHp then
  local savedMax = tonumber(getItemAttribute(ballUid, "last_maxhp") or 0) or 0
  local maxHp = savedMax
  if maxHp <= 0 then
    maxHp = (getVitalityByMaster(cid) * HPperVITsummon)
    if maxHp <= 0 then
      maxHp = (getVitalityFormula(cid) or 0) * HPperVITsummon
    end
  end
    local hpAbs = math.floor(maxHp * hpFrac + 0.5)
    doPlayerSendCancel(cid, '#ph#,' .. math.floor(hpAbs) .. ',' .. math.floor(maxHp))
  end
end
