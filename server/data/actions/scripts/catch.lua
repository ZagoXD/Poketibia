local ballcatch = {                  
  [2394]  = { cr = 3,  on = 193, off = 192, ball = {11826, 11737}, send = 47, typeee = "normal" }, -- Poké Ball
  [2391]  = { cr = 6,  on = 198, off = 197, ball = {11832, 11740}, send = 48, typeee = "great"  }, -- Great Ball
  [2393]  = { cr = 10, on = 202, off = 201, ball = {11835, 11743}, send = 46, typeee = "super"  }, -- Super Ball
  [2392]  = { cr = 15, on = 200, off = 199, ball = {11829, 11746}, send = 49, typeee = "ultra"  }, -- Ultra Ball
  [12617] = { cr = 3,  on = 204, off = 203, ball = {10975, 12621}, send = 35, typeee = "saffari"}, -- Safari Ball
  [14159] = { cr = 10000,  on = 313, off = 313, ball = {14160, 14163}, send = 53, typeee = "masterball"}, -- master ball
}

local NO_CATCH_AREAS = {
  {
    from    = { x = 2080, y = 1080 },
    to      = { x = 3670, y = 1940 },
    zmin    = 4,
    zmax    = 9,
    ignoreZ = true,
  },
}

local LEGENDARIES = {
  -- Gen 1
  ["articuno"] = true,
  ["zapdos"] = true,
  ["moltres"] = true,
  ["mewtwo"] = true,
  ["mew"] = true,

  -- Gen 2
  ["raikou"] = true,
  ["entei"] = true,
  ["suicune"] = true,
  ["lugia"] = true,
  ["ho-oh"] = true,
  ["celebi"] = true,

  -- Gen 3
  ["regirock"] = true,
  ["regice"] = true,
  ["registeel"] = true,
  ["latias"] = true,
  ["latios"] = true,
  ["kyogre"] = true,
  ["groudon"] = true,
  ["rayquaza"] = true,
  ["jirachi"] = true,
  ["deoxys"] = true,
}

local function normalizePokeNameForLegendCheck(name)
  name = tostring(name or "")
  name = name:lower()
  name = name:gsub("^shiny%s+", "")
  name = name:gsub("^mega%s+", "")
  name = name:gsub("^shiny", "")
  return name
end

local function isLegendaryName(name)
  local n = normalizePokeNameForLegendCheck(name)
  return LEGENDARIES[n] == true
end


local function inRect(pos, a)
  local x1, x2 = math.min(a.from.x, a.to.x), math.max(a.from.x, a.to.x)
  local y1, y2 = math.min(a.from.y, a.to.y), math.max(a.from.y, a.to.y)
  if pos.x < x1 or pos.x > x2 or pos.y < y1 or pos.y > y2 then return false end
  if a.ignoreZ then return true end
  local zmin = a.zmin or pos.z
  local zmax = a.zmax or pos.z
  return pos.z >= zmin and pos.z <= zmax
end

local function isNoCatchPos(pos)
  for i = 1, #NO_CATCH_AREAS do
    if inRect(pos, NO_CATCH_AREAS[i]) then return true end
  end
  return false
end

function onUse(cid, item, frompos, item3, topos)
  if isNoCatchPos(topos) then
    doSendMagicEffect(topos, CONST_ME_POFF)
    doPlayerSendCancel(cid, "Voce nao pode usar Pokebolas nesta area.")
    return true
  end

  local item2 = getTopCorpse(topos)
  if item2 == null then
    return true
  end

  if getItemAttribute(item2.uid, "catching") == 1 then
    return true
  end

  if getItemAttribute(item2.uid, "golden") and getItemAttribute(item2.uid, "golden") == 1 then
    return doPlayerSendCancel(cid, "You can't try to catch a pokemon in the Golden Arena!")
  end

  local name = string.lower(getItemNameById(item2.itemid))
  name = string.gsub(name, "fainted ", "")
  name = string.gsub(name, "defeated ", "")
  name = doCorrectPokemonName(name)
  if isLegendaryName(name) then
    doSendMagicEffect(topos, CONST_ME_POFF)
    doPlayerSendCancel(cid, "Voce nao pode capturar Pokemon lendarios.")
    return true
  end

  local x = pokecatches[name]
  if not x then return true end

  local storage = newpokedex[name].stoCatch
  if getPlayerStorageValue(cid, storage) == -1 or not string.find(getPlayerStorageValue(cid, storage), ";") then
    setPlayerStorageValue(cid, storage, "normal = 0, great = 0, super = 0, ultra = 0, saffari = 0;")
  end

  local owner = getItemAttribute(item2.uid, "corpseowner")
  if owner and isCreature(owner) and isPlayer(owner) and cid ~= owner then
    doPlayerSendCancel(cid, "You are not allowed to catch this pokemon.")
    return true
  end

  local newidd = isShinyName(name) and ballcatch[item.itemid].ball[2] or ballcatch[item.itemid].ball[1]
  local typeee = ballcatch[item.itemid].typeee

  local catchinfo = {}
  catchinfo.rate   = ballcatch[item.itemid].cr
  catchinfo.catch  = ballcatch[item.itemid].on
  catchinfo.fail   = ballcatch[item.itemid].off
  catchinfo.newid  = newidd
  catchinfo.name   = doCorrectPokemonName(name)
  catchinfo.topos  = topos
  catchinfo.chance = x.chance

  doSendDistanceShoot(getThingPos(cid), topos, ballcatch[item.itemid].send)
  doRemoveItem(item.uid, 1)

  local d = getDistanceBetween(getThingPos(cid), topos)

  if getPlayerStorageValue(cid, 98796) >= 1 and getPlayerItemCount(cid, 12617) <= 0 then
    setPlayerStorageValue(cid, 98796, -1)
    setPlayerStorageValue(cid, 98797, -1)
    doTeleportThing(cid, SafariOut, false)
    doSendMagicEffect(getThingPos(cid), 21)
    doPlayerSendTextMessage(cid, 27, "You spend all your saffari balls, good luck in the next time...")
  end

  addEvent(doSendPokeBall, d * 70 + 100 - (d * 14), cid, catchinfo, false, false, typeee)
  addEvent(doSendMagicEffect, (d * 70 + 100 - (d * 14)) - 100, topos, 3)
  return true
end
