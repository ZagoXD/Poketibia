local BATCH_SIZE  = 50
local MAIL_TOWNID = 1
local LOG_PREFIX  = "[WEB-DEPOT]"
local STACK_MAX   = 100
local ITEM_PARCEL = 2595   -- se sua parcel tiver outro ID, ajuste aqui

-- ===== Compat helpers p/ result =====
local HAS_GETDATA = type(result.getDataInt) == "function"
local function rInt(h, col) return HAS_GETDATA and result.getDataInt(h, col) or result.getNumber(h, col) end
local function rStr(h, col) return (type(result.getDataString)=="function") and result.getDataString(h, col) or result.getString(h, col) end
local function rNext(h)     return result.next(h) end
-- ====================================

-- ===== Compat helpers de item =====
local function hasItemType() return type(ItemType) == "function" end

local function itemIsValid(itemId)
  if hasItemType() then
    local it = ItemType(itemId)
    return it and it:getId() > 0
  end
  if getItemInfo then
    local info = getItemInfo(itemId)
    return info ~= nil
  end
  return true
end

local function isStackable(itemId)
  if hasItemType() then
    local it = ItemType(itemId)
    return it and it:isStackable() or false
  end
  if getItemInfo then
    local info = getItemInfo(itemId)
    return (info and info.stackable) or false
  end
  return false
end
-- ===================================

local MAIL_SAFE_CACHE = {}
local function uidItemId(uid)
  if getItemId then return getItemId(uid) end
  local t = getThingFromUid and getThingFromUid(uid) or nil
  return (t and t.itemid) or 0
end

local function mailFriendlyId(itemid)
  if MAIL_SAFE_CACHE[itemid] then return MAIL_SAFE_CACHE[itemid] end
  local safe = itemid
  local tmp = doCreateItemEx(itemid, 1)
  if tmp and tmp ~= 0 then
    local real = uidItemId(tmp)
    doRemoveItem(tmp, 1)
    if real and real > 0 then safe = real end
  end
  MAIL_SAFE_CACHE[itemid] = safe
  return safe
end

local function splitIntoStacks(total, maxPerStack)
  local t = {}
  while total > 0 do
    local add = math.min(total, maxPerStack)
    table.insert(t, add)
    total = total - add
  end
  return t
end

local function sendStackableByMail(playerName, itemId, amount)
  local safe = mailFriendlyId(itemId)
  for _, cnt in ipairs(splitIntoStacks(amount, STACK_MAX)) do
    local parcel = doCreateItemEx(ITEM_PARCEL)
    if not parcel or parcel == 0 then return false end
    if not doAddContainerItem(parcel, safe, cnt) then return false end
    if not doPlayerSendMailByName(playerName, parcel, MAIL_TOWNID) then return false end
  end
  return true
end

local function sendNonStackableByMail(playerName, itemId, amount)
  local safe = mailFriendlyId(itemId)
  for i = 1, amount do
    local parcel = doCreateItemEx(ITEM_PARCEL)
    if not parcel or parcel == 0 then return false end
    if not doAddContainerItem(parcel, safe, 1) then return false end
    if not doPlayerSendMailByName(playerName, parcel, MAIL_TOWNID) then return false end
  end
  return true
end

local function trySendMail(playerName, itemId, amount)
  if not itemIsValid(itemId) then
    print(string.format("%s item inválido id=%d", LOG_PREFIX, itemId))
    return false
  end
  if isStackable(itemId) then
    return sendStackableByMail(playerName, itemId, amount)
  else
    return sendNonStackableByMail(playerName, itemId, amount)
  end
end

local function dbExec(sql)
  if type(db.query) == "function" then
    return db.query(sql)
  end
  if type(db.executeQuery) == "function" then
    return db.executeQuery(sql)
  end
  if type(db.exec) == "function" then
    return db.exec(sql)
  end
  return false
end

function processQueue()
  local q = db.storeQuery(string.format(
    "SELECT `id`,`player_name`,`itemid`,`count` FROM `web_depot_queue` ORDER BY `id` ASC LIMIT %d;", BATCH_SIZE
  ))
  if not q then return end

  repeat
    local rowId  = rInt(q, "id")
    local name   = (rStr(q, "player_name") or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local itemId = rInt(q, "itemid")
    local amount = rInt(q, "count")

    local p = db.storeQuery("SELECT 1 FROM `players` WHERE `name`=" .. db.escapeString(name) .. " LIMIT 1;")
    local exists = p ~= false
    if p then result.free(p) end

    if not exists then
      print(string.format("%s player não encontrado: '%s' (removendo linha %d)", LOG_PREFIX, name, rowId))
      dbExec("DELETE FROM `web_depot_queue` WHERE `id`=" .. rowId .. ";")
    else
      local ok = trySendMail(name, itemId, amount)
      if ok then
        print(string.format("%s enviado %dx [%d] para %s (linha %d)", LOG_PREFIX, amount, itemId, name, rowId))
        dbExec("DELETE FROM `web_depot_queue` WHERE `id`=" .. rowId .. ";")
      else
        print(string.format("%s FALHA ao enviar %dx [%d] para %s (linha %d); reprocessa depois",
          LOG_PREFIX, amount, itemId, name, rowId))
      end
    end
  until not rNext(q)
  result.free(q)
end

function onThink(interval, lastExecution)
  local ok, err = pcall(processQueue)
  if not ok then
    print(string.format("%s erro: %s", LOG_PREFIX, tostring(err)))
  end
  return true
end
