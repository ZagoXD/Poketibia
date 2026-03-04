local AID            = 33780
local ANVIL_ITEMID   = 2555
local SHINY_DUST_ID  = 14125

local STORAGE_ACTIVE   = 92200
local STORAGE_POS_X    = 92201
local STORAGE_POS_Y    = 92202
local STORAGE_POS_Z    = 92203

local NORMAL_STONE_COST = 20
local DUST_COST_DEFAULT = 5

local IDS = {
  fire     = { normal = 11447, shiny = 12401 }, -- 1
  enigma   = { normal = 11452, shiny = 12405 }, -- 2
  thunder  = { normal = 11444, shiny = 12409 }, -- 3
  water    = { normal = 11442, shiny = 12402 }, -- 4
  rock     = { normal = 11445, shiny = 12406 }, -- 5
  crystal  = { normal = 11449, shiny = 12410 }, -- 6
  leaf     = { normal = 11441, shiny = 12403 }, -- 7
  venom    = { normal = 11443, shiny = 12407 }, -- 8
  coccon   = { normal = 11448, shiny = 12411 }, -- 9
  earth    = { normal = 11451, shiny = 12414 }, -- 10
  heart    = { normal = 11453, shiny = 12404 }, -- 11
  ice      = { normal = 11454, shiny = 12408 }, -- 12
  darkness = { normal = 11450, shiny = 12412 }, -- 13
  punch    = { normal = 11446, shiny = 12413 }, -- 14
}

local ORDER = {
  [1]='fire', [2]='enigma', [3]='thunder', [4]='water',
  [5]='rock', [6]='crystal', [7]='leaf', [8]='venom',
  [9]='coccon', [10]='earth', [11]='heart', [12]='ice',
  [13]='darkness', [14]='punch'
}

local DUST_COST_PER_STONE = { }

local function isNear(a, b)
  if not a or not b then return false end
  if a.z ~= b.z then return false end
  return math.abs(a.x-b.x) <= 1 and math.abs(a.y-b.y) <= 1
end

local function getWatchedAnvilPos(cid)
  if getPlayerStorageValue(cid, STORAGE_ACTIVE) == 1 then
    local pos = { x = getPlayerStorageValue(cid, STORAGE_POS_X),
                  y = getPlayerStorageValue(cid, STORAGE_POS_Y),
                  z = getPlayerStorageValue(cid, STORAGE_POS_Z) }
    if pos.x ~= -1 and pos.y ~= -1 and pos.z ~= -1 then
      return pos
    end
  end
  return nil
end

local function findNearbyAnvil(cid)
  local p = getCreaturePosition(cid)
  for dx=-1,1 do for dy=-1,1 do
    local pos = {x=p.x+dx, y=p.y+dy, z=p.z, stackpos=1}
    local it = getTileItemById(pos, ANVIL_ITEMID)
    if it and it.uid > 0 then
      local aid = tonumber(getItemAttribute(it.uid, 'aid') or 0) or 0
      if aid == 0 and getItemActionId then aid = tonumber(getItemActionId(it.uid) or 0) or 0 end
      if aid == AID then return pos end
    end
  end end
  return nil
end

local function dustCostFor(key)
  return DUST_COST_PER_STONE[key] or DUST_COST_DEFAULT
end

local function labelOf(key)
  return (key:gsub("^%l", string.upper)) .. " Stone"
end
local function shinyLabelOf(key)
  return "Shining " .. (key:gsub("^%l", string.upper)) .. " Stone"
end

local function tryTransmute(cid, key)
  local pair = IDS[key]; if not pair then return false, "Stone inválida." end
  local dust = dustCostFor(key)

  if getPlayerItemCount(cid, pair.normal) < NORMAL_STONE_COST then
    return false, "Voce nao tem pedras normais suficientes ("..NORMAL_STONE_COST.."x "..labelOf(key)..")."
  end
  if getPlayerItemCount(cid, SHINY_DUST_ID) < dust then
    return false, "Voce nao tem Shiny Dust suficiente ("..dust.."x)."
  end

  if not doPlayerRemoveItem(cid, pair.normal, NORMAL_STONE_COST) then
    return false, "Nao consegui pegar suas stones. Tente novamente."
  end
  if not doPlayerRemoveItem(cid, SHINY_DUST_ID, dust) then
    doPlayerAddItem(cid, pair.normal, NORMAL_STONE_COST)
    return false, "Nao consegui pegar seu Shiny Dust. Tente novamente."
  end

  local uid = doPlayerAddItem(cid, pair.shiny, 1)
  if not uid or uid <= 0 then
    local it = doCreateItemEx(pair.shiny, 1)
    doPlayerSendMailByName(getCreatureName(cid), it, 1)
    return true, "Mochila cheia. Sua "..shinyLabelOf(key).." foi enviada para o depot."
  end

  return true, "Transmutado: "..shinyLabelOf(key).."."
end

function onSay(cid, words, param)
  local idx = tonumber(param)
  if not idx or idx < 1 or idx > 14 then
    doPlayerSendCancel(cid, "Uso: !spbuy 1..14")
    return true
  end
  local key = ORDER[idx]

  local ppos = getCreaturePosition(cid)
  local watchPos = getWatchedAnvilPos(cid)
  local nearPos = watchPos or findNearbyAnvil(cid)
  if not nearPos or not isNear(ppos, nearPos) then
    doPlayerSendCancel(cid, "Chegue ao lado da bigorna para comprar.")
    return true
  end

  local ok, msg = tryTransmute(cid, key)
  if ok then
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, msg)
  else
    doPlayerSendCancel(cid, msg)
  end
  return true
end
