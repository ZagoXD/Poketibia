dofile('data/lib/configuration.lua')

local FORBIDDEN_ITEMIDS = {}
do
    local function add(id)
        id = tonumber(id)
        if id and id > 0 then
            FORBIDDEN_ITEMIDS[id] = true
        end
    end

    if type(pokeballs) == 'table' then
        for _, def in pairs(pokeballs) do
            if type(def) == 'table' then
                add(def.on);
                add(def.use);
                add(def.off)
                if type(def.all) == 'table' then
                    for _, sid in ipairs(def.all) do
                        add(sid)
                    end
                end
            end
        end
    end
end

local function isForbidden(id)
    return id and FORBIDDEN_ITEMIDS[id] == true
end

local CURRENCY_ITEMID = 2149
local DELIVERY_MODE = MESSAGE_INFO_DESCR or 18
local DELETE_SOLD_ON_CLAIM = true

local MARKET_VERBOSE = false
local function info(cid, msg)
    if MARKET_VERBOSE then
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)
    end
end

if not string.trim then
    function string.trim(s)
        return (tostring(s or "")):match("^%s*(.-)%s*$")
    end
end
if not string.explode then
    function string.explode(str, sep)
        sep = sep or ","
        local t = {}
        str = tostring(str or "")
        if str == "" then
            return t
        end
        for part in str:gmatch("([^" .. sep .. "]+)") do
            table.insert(t, part)
        end
        return t
    end
end

local function q(sql)
    if db.executeQuery then
        return db.executeQuery(sql)
    end
    if db.query then
        return db.query(sql)
    end
    return false
end
local function store(sql)
    if db.storeQuery then
        local rs = db.storeQuery(sql)
        if not rs then
            return nil
        end
        return {
            mode = "store",
            id = rs
        }
    elseif db.getResult then
        local rs = db.getResult(sql)
        if rs and rs.getID and rs:getID() ~= -1 then
            return {
                mode = "obj",
                obj = rs
            }
        end
        return nil
    end
    return nil
end
local function rgetInt(R, col)
    if not R then
        return nil
    end
    if R.mode == "store" then
        return result.getDataInt(R.id, col)
    else
        return R.obj:getDataInt(col)
    end
end
local function rgetStr(R, col)
    if not R then
        return nil
    end
    if R.mode == "store" then
        return result.getDataString(R.id, col)
    else
        return R.obj:getDataString(col)
    end
end
local function rnext(R)
    if R.mode == "store" then
        return result.next(R.id)
    else
        return R.obj:next()
    end
end
local function rfree(R)
    if not R then
        return
    end
    if R.mode == "store" then
        result.free(R.id)
    else
        R.obj:free()
    end
end

local function getPlayerNameByGuidSafe(guid)
    if getPlayerNameByGUID then
        local n = getPlayerNameByGUID(guid)
        if n and n ~= "" then
            return n
        end
    end
    local R = store("SELECT name FROM players WHERE id=" .. guid .. " LIMIT 1")
    if not R then
        R = store("SELECT name FROM players WHERE guid=" .. guid .. " LIMIT 1")
    end
    if R then
        local n = rgetStr(R, "name");
        rfree(R)
        if n and n ~= "" then
            return n
        end
    end
    return "Unknown"
end

local function resolveItemIdByName(name)
    if not name or name == "" then
        return nil
    end
    if getItemIdByName then
        local id = getItemIdByName(name, false)
        if id and id > 0 then
            return id
        end
    end
    if ItemType then
        local it = ItemType(name)
        if it and it:getId() > 0 then
            return it:getId()
        end
    end
    return nil
end

local function getItemNameByIdSafe(id)
    if getItemNameById then
        local n = getItemNameById(id)
        if n and n ~= "" then
            return n
        end
    end
    if getItemName then
        local n = getItemName(id)
        if n and n ~= "" then
            return n
        end
    end
    if ItemType then
        local it = ItemType(id)
        if it and it:getId() > 0 then
            return it:getName()
        end
    end
    return "#" .. tostring(id)
end

local function getClientIdSafe(itemid)
    if ItemType then
        local it = ItemType(itemid)
        if it and it.getClientId then
            local cid = it:getClientId()
            if cid and cid > 0 then
                return cid
            end
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

local function tryTakeItem(cid, itemid, amount)
    return doPlayerRemoveItem(cid, itemid, amount) == TRUE
end

local function isStackable(itemid)
  if ItemType then
    local it = ItemType(itemid)
    if it and it.isStackable then
      return it:isStackable()
    end
  end
  if getItemInfo then
    local info = getItemInfo(itemid)
    if info and info.stackable ~= nil then
      return info.stackable
    end
  end
  return false
end

local function adjustForMail(itemid)
  if isStackable(itemid) then
    return itemid
  end
  local adj = (itemid or 0) - 1
  if adj < 1 then adj = itemid end
  return adj
end

local MAIL_SAFE_CACHE = {}

local function uidItemId(uid)
  if getItemId then
    return getItemId(uid)
  end
  local t = getThingFromUid and getThingFromUid(uid) or nil
  if t and t.itemid then return t.itemid end
  return 0
end

local function mailFriendlyId(itemid)
  if MAIL_SAFE_CACHE[itemid] then
    return MAIL_SAFE_CACHE[itemid]
  end
  local safe = itemid
  local tmp = doCreateItemEx(itemid, 1)
  if tmp and tmp ~= 0 then
    local real = uidItemId(tmp)
    doRemoveItem(tmp, 1)
    if real and real > 0 then
      safe = real
    end
  end
  MAIL_SAFE_CACHE[itemid] = safe
  return safe
end

local function giveItemSmart(cid, itemid, amount, opts)
  amount = tonumber(amount) or 1
  opts = opts or {}
  local allowMail = (opts.allowMail ~= false)

  local function mailStackable(qtd)
    if not allowMail then return false end
    local safe = adjustForMail(itemid)
    local it = doCreateItemEx(safe, qtd)
    if not it or it == 0 then return false end
    return doPlayerSendMailByName(getCreatureName(cid), it, 1) == TRUE
  end

  local function mailNonStackable(qtd)
    if not allowMail then return false end
    local safe = adjustForMail(itemid)
    for i = 1, qtd do
      local it = doCreateItemEx(safe, 1)
      if not it or it == 0 or doPlayerSendMailByName(getCreatureName(cid), it, 1) ~= TRUE then
        if it and it ~= 0 then doRemoveItem(it, 1) end
        return false
      end
    end
    return true
  end

  if isStackable(itemid) then
    local ret = doPlayerAddItem(cid, itemid, amount, false)
    if ret and ret ~= LUA_ERROR then
      return true
    end
    return mailStackable(amount)
  end

  local given = 0
  for i = 1, amount do
    local ret = doPlayerAddItem(cid, itemid, 1, false)
    if not ret or ret == LUA_ERROR then
      local remaining = amount - given
      return mailNonStackable(remaining)
    end
    given = given + 1
  end
  return true
end

local CODE_CONFIRM = 163
local CODE_LIST = 164
local function sendCode(cid, code, payload)
    doPlayerSendTextMessage(cid, DELIVERY_MODE, string.format("&sco&,%d,%s", code, payload or ""))
end

local function cmdHelp(cid)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, [[
/market help
/market list
/market my
/market create <itemVenda>|<quantidade>|<itemQueQuer>|<quantidadeQueQuer>
/market buy <listingId>
/market cancel <listingId>
/market claim
/market create <itemVenda>|<quantidade>|<preco_em_emeralds>
]])
end

local function cmdCreate(cid, args)
    local parts = string.explode(args or "", "|")
    if #parts < 3 then
        return doPlayerSendCancel(cid, "Uso: /market create <itemVenda>|<quantidade>|<itemQueQuer>|<quantidadeQueQuer>")
    end

    local sellName = string.trim(parts[1] or "")
    local sellAmt = tonumber(parts[2])

    local wantItemId, wantAmt, wantNameForMsg
    if #parts >= 4 then
        local wantName = string.trim(parts[3] or "")
        wantAmt = tonumber(parts[4])
        if wantName == "" or not wantAmt or wantAmt < 1 then
            return doPlayerSendCancel(cid, "Parametros do item desejado invalidos.")
        end
        wantItemId = resolveItemIdByName(wantName)
        if not wantItemId then
            return doPlayerSendCancel(cid, "Item desejado desconhecido: " .. wantName)
        end

        if isForbidden(wantItemId) then
            return doPlayerSendCancel(cid, "Este item nao pode ser requerido no Market.")
        end

        wantNameForMsg = getItemNameByIdSafe(wantItemId)
    else
        local price = tonumber(parts[3])
        if not price or price < 1 then
            return doPlayerSendCancel(cid, "Preco invalido.")
        end
        wantItemId = CURRENCY_ITEMID
        wantAmt = price
        wantNameForMsg = getItemNameByIdSafe(wantItemId)
    end

    if sellName == "" or not sellAmt or sellAmt < 1 then
        return doPlayerSendCancel(cid, "Parametros do item a venda invalidos.")
    end

    local sellId = resolveItemIdByName(sellName)
    if not sellId then
        return doPlayerSendCancel(cid, "Item a venda desconhecido: " .. sellName)
    end

    if isForbidden(sellId) then
        return doPlayerSendCancel(cid, "Este item nao pode ser vendido no Market.")
    end

    if not tryTakeItem(cid, sellId, sellAmt) then
        return doPlayerSendCancel(cid, "Voce nao possui " .. sellAmt .. "x " .. sellName .. ".")
    end

    local sellerId = getPlayerGUID(cid)
    local escSell = db.escapeString(sellName)
    local now = os.time()

    if #parts >= 4 and isForbidden(wantItemId) then
        giveItemSmart(cid, sellId, sellAmt)
        return doPlayerSendCancel(cid, "Este item nao pode ser requerido no Market.")
    end

    local ok = q(string.format(
        "INSERT INTO market_listings (seller_id,itemid,itemname,amount,want_itemid,want_amount,status,created_at) " ..
        "VALUES (%d,%d,%s,%d,%d,%d,'active',%d)", sellerId, sellId, escSell, sellAmt, wantItemId, wantAmt, now))

    if ok then
        info(cid, string.format("Oferta criada: %dx %s por %dx %s.", sellAmt, sellName, wantAmt, wantNameForMsg))
    else
        giveItemSmart(cid, sellId, sellAmt)
        return doPlayerSendCancel(cid, "Falha ao criar oferta.")
    end
end

local function cmdList(cid)
    local R = store([[
    SELECT id,itemid,itemname,amount,want_itemid,want_amount,seller_id
    FROM market_listings
    WHERE status='active'
    ORDER BY id DESC
    LIMIT 100
  ]])
    local rows = {}
    local txt = MARKET_VERBOSE and {} or nil
    if R then
        repeat
            local id = rgetInt(R, "id")
            local itemId = rgetInt(R, "itemid")
            local name = rgetStr(R, "itemname")
            local amount = rgetInt(R, "amount")
            local wantId = rgetInt(R, "want_itemid")
            local wantAmt = rgetInt(R, "want_amount")
            local sellerId = rgetInt(R, "seller_id")

            local wantName = getItemNameByIdSafe(wantId)
            local sellerName = getPlayerNameByGuidSafe(sellerId)
            local sellCid = getClientIdSafe(itemId)
            local wantCid = getClientIdSafe(wantId)

            table.insert(rows, table.concat({id, name, amount, wantAmt, wantName, sellerName, sellCid, wantCid}, ";"))

            if txt then
                table.insert(txt, string.format("#%d  %s x%d - quer %dx %s (por %s)", id, name, amount, wantAmt,
                    wantName, sellerName))
            end
        until not rnext(R)
        rfree(R)
    end

    sendCode(cid, CODE_LIST, table.concat(rows, "|"))

    if txt then
        if #txt == 0 then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Market: sem ofertas ativas.")
        else
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Market (ativas):")
            for _, line in ipairs(txt) do
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "  " .. line)
            end
        end
    end
end

local function cmdMy(cid)
    local sellerId = getPlayerGUID(cid)
    local myName = getPlayerNameByGuidSafe(sellerId)
    local R = store([[
    SELECT id,itemid,itemname,amount,status,want_itemid,want_amount
    FROM market_listings
    WHERE seller_id=]] .. sellerId .. [[ 
    ORDER BY id DESC
    LIMIT 100
  ]])
    local rows = {}
    local txt = MARKET_VERBOSE and {} or nil
    if R then
        repeat
            local id = rgetInt(R, "id")
            local itemId = rgetInt(R, "itemid")
            local name = rgetStr(R, "itemname")
            local amount = rgetInt(R, "amount")
            local status = rgetStr(R, "status")
            local wantId = rgetInt(R, "want_itemid")
            local wantAmt = rgetInt(R, "want_amount")

            local wantName = getItemNameByIdSafe(wantId)
            local sellCid = getClientIdSafe(itemId)
            local wantCid = getClientIdSafe(wantId)

            table.insert(rows,
                table.concat({id, name, amount, status, wantAmt, wantName, myName, sellCid, wantCid}, ";"))

            if txt then
                table.insert(txt, string.format("#%d  %s x%d - quer %dx %s  [%s]", id, name, amount, wantAmt, wantName,
                    status))
            end
        until not rnext(R)
        rfree(R)
    end

    sendCode(cid, CODE_LIST, table.concat(rows, "|"))

    if txt then
        if #txt == 0 then
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Market: voce nao possui ofertas.")
        else
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Minhas ofertas:")
            for _, line in ipairs(txt) do
                doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "  " .. line)
            end
        end
    end
end

local function cmdBuy(cid, idStr)
    local listingId = tonumber(idStr)
    if not listingId then
        return doPlayerSendCancel(cid, "ID invalido.")
    end

    local R = store(
        "SELECT id,itemid,itemname,amount,want_itemid,want_amount,seller_id FROM market_listings WHERE id=" .. listingId ..
            " AND status='active' LIMIT 1")
    if not R then
        return doPlayerSendCancel(cid, "Oferta nao encontrada.")
    end

    local itemid = rgetInt(R, "itemid")
    local itemname = rgetStr(R, "itemname")
    local amount = rgetInt(R, "amount")
    local wantItemId = rgetInt(R, "want_itemid")
    local wantAmt = rgetInt(R, "want_amount")
    local sellerId = rgetInt(R, "seller_id")
    rfree(R)

    if sellerId == getPlayerGUID(cid) then
        return doPlayerSendCancel(cid, "Voce nao pode comprar sua propria oferta.")
    end

    if not tryTakeItem(cid, wantItemId, wantAmt) then
        local wantName = getItemNameByIdSafe(wantItemId)
        return doPlayerSendCancel(cid, "Voce nao possui " .. wantAmt .. "x " .. wantName .. ".")
    end

    local buyerGuid = getPlayerGUID(cid)
    local markSold = q(string.format("UPDATE market_listings SET status='sold', sold_to=%d, sold_at=%d " ..
                                         "WHERE id=%d AND status='active'", buyerGuid, os.time(), listingId))

    local V = store("SELECT sold_to,status FROM market_listings WHERE id=" .. listingId .. " LIMIT 1")
    local okSold = false
    if V then
        local st = rgetStr(V, "status")
        local to = rgetInt(V, "sold_to")
        okSold = (st == "sold" and to == buyerGuid)
        rfree(V)
    end
    if not markSold or not okSold then
        giveItemSmart(cid, wantItemId, wantAmt)
        return doPlayerSendCancel(cid, "Oferta indisponivel.")
    end

    if not giveItemSmart(cid, itemid, amount, { allowMail = true }) then
    q(string.format(
        "UPDATE market_listings SET status='active', sold_to=NULL, sold_at=NULL WHERE id=%d AND sold_to=%d",
        listingId, buyerGuid))
    giveItemSmart(cid, wantItemId, wantAmt, { allowMail = true })
    return doPlayerSendCancel(cid, "Sem espaço para receber o item.")
    end

    q(string.format("INSERT INTO market_payouts (listing_id,seller_id,itemid,amount,created_at) " ..
                        "VALUES (%d,%d,%d,%d,%d)", listingId, sellerId, wantItemId, wantAmt, os.time()))

    info(cid, string.format("Comprado: %dx %s por %dx %s.", amount, itemname, wantAmt, getItemNameByIdSafe(wantItemId)))
end

local function cmdCancel(cid, idStr)
    local listingId = tonumber(idStr)
    if not listingId then
        return doPlayerSendCancel(cid, "ID invalido.")
    end

    local sellerId = getPlayerGUID(cid)
    local R = store(string.format("SELECT id,itemid,itemname,amount FROM market_listings " ..
                                      "WHERE id=%d AND seller_id=%d AND status='active' LIMIT 1", listingId, sellerId))
    if not R then
        return doPlayerSendCancel(cid, "Oferta nao encontrada ou ja vendida.")
    end

    local itemid = rgetInt(R, "itemid")
    local itemname = rgetStr(R, "itemname")
    local amount = rgetInt(R, "amount")
    rfree(R)

    local okDel = q(string.format(
        "DELETE FROM market_listings WHERE id=%d AND seller_id=%d AND status='active' LIMIT 1", listingId, sellerId))
    if not okDel then
        return doPlayerSendCancel(cid, "Falha ao cancelar.")
    end

    local chk = store("SELECT id FROM market_listings WHERE id=" .. listingId .. " LIMIT 1")
    if chk then
        rfree(chk)
        return doPlayerSendCancel(cid, "Oferta nao encontrada ou ja vendida.")
    end

    giveItemSmart(cid, itemid, amount)
    info(cid, string.format("Oferta #%d cancelada e removida. Recebeu de volta %dx %s.", listingId, amount, itemname))
end

local function cmdClaim(cid)
    local sellerId = getPlayerGUID(cid)
    local R = store("SELECT id,listing_id,itemid,amount FROM market_payouts WHERE seller_id=" .. sellerId ..
                        " AND collected=0")
    if not R then
        return info(cid, "Sem pagamentos pendentes.")
    end

    local total = 0
    repeat
        local pid = rgetInt(R, "id")
        local lid = rgetInt(R, "listing_id")
        local itemid = rgetInt(R, "itemid")
        local amount = rgetInt(R, "amount")

        if giveItemSmart(cid, itemid, amount) then
            q("DELETE FROM market_payouts WHERE id=" .. pid)

            if DELETE_SOLD_ON_CLAIM and lid and lid > 0 then
                q("DELETE FROM market_listings WHERE id=" .. lid .. " AND status='sold'")
            end

            total = total + amount
        else
        end
    until not rnext(R)
    rfree(R)

    info(cid, "Pagamentos coletados: " .. total)
end

function onSay(cid, words, param, channel)
    local cmd, rest = (param or ""):match("^%s*(%S+)%s*(.*)$")
    cmd = (cmd or ""):lower()

    if cmd == "" or cmd == "help" then
        cmdHelp(cid)
    elseif cmd == "create" then
        cmdCreate(cid, rest)
    elseif cmd == "list" then
        cmdList(cid)
    elseif cmd == "my" then
        cmdMy(cid)
    elseif cmd == "buy" then
        cmdBuy(cid, rest)
    elseif cmd == "cancel" then
        cmdCancel(cid, rest)
    elseif cmd == "claim" then
        cmdClaim(cid)
    else
        cmdHelp(cid)
    end
    return true
end
