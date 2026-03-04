local function getPokemonConfigByName(name)
  if not name or not pokes then return nil end
  if pokes[name] then return pokes[name] end
  local base = name
  base = base:gsub("^Shiny%s+", "")
  base = base:gsub("^Ancient%s+", "")
  base = base:gsub("^Mega%s+", "")
  base = base:gsub("%s+%b()", "")
  return pokes[base]
end

local xhelds = {
  [1]={name="X-Defense(Tier: 1)"},[2]={name="X-Defense(Tier: 2)"},[3]={name="X-Defense(Tier: 3)"},[4]={name="X-Defense(Tier: 4)"},
  [5]={name="X-Defense(Tier: 5)"},[6]={name="X-Defense(Tier: 6)"},[7]={name="X-Defense(Tier: 7)"},
  [8]={name="X-Attack(Tier : 1)"},[9]={name="X-Attack(Tier : 2)"},[10]={name="X-Attack(Tier: 3)"},[11]={name="X-Attack(Tier: 4)"},
  [12]={name="X-Attack(Tier: 5)"},[13]={name="X-Attack(Tier: 6)"},[14]={name="X-Attack(Tier: 7)"},[15]={name="X-Return(Tier: 1)"},
  [16]={name="X-Return(Tier: 2)"},[17]={name="X-Return(Tier: 3)"},[18]={name="X-Return(Tier: 4)"},[19]={name="X-Return(Tier: 5)"},
  [20]={name="X-Return(Tier: 6)"},[21]={name="X-Return(Tier: 7)"},[36]={name="X-Boost(Tier: 1)"},[37]={name="X-Boost(Tier: 2)"},
  [38]={name="X-Boost(Tier: 3)"},[39]={name="X-Boost(Tier: 4)"},[40]={name="X-Boost(Tier: 5)"},[41]={name="X-Boost(Tier: 6)"},
  [42]={name="X-Boost(Tier: 7)"},[43]={name="X-Agility(Tier: 1)"},[44]={name="X-Agility(Tier: 2)"},[45]={name="X-Agility(Tier: 3)"},
  [46]={name="X-Agility(Tier: 4)"},[47]={name="X-Agility(Tier: 5)"},[48]={name="X-Agility(Tier: 6)"},[49]={name="X-Agility(Tier: 7)"}
}
local yhelds = {
  [1]={name="Y-Regeneration(Tier: 1)"},[2]={name="Y-Regeneration(Tier: 2)"},[3]={name="Y-Regeneration(Tier: 3)"},
  [4]={name="Y-Regeneration(Tier: 4)"},[5]={name="Y-Regeneration(Tier: 5)"},[6]={name="Y-Regeneration(Tier: 6)"},
  [7]={name="Y-Regeneration(Tier: 7)"},[8]={name="Y-Cure(Tier: 1)"},[9]={name="Y-Cure(Tier: 2)"},[10]={name="Y-Cure(Tier: 3)"},
  [11]={name="Y-Cure(Tier: 4)"},[12]={name="Y-Cure(Tier: 5)"},[13]={name="Y-Cure(Tier: 6)"},[14]={name="Y-Cure(Tier: 7)"}
}
local ORB_NAMES = {
  [1]="Life Orb",[2]="Leftovers",[3]="Assault Vest",[4]="Rocky Helmet",[5]="Silk Scarf",[6]="Mystic Water",
  [7]="Soft Sand",[8]="Charcoal",[9]="Magnet",[10]="Poison Barb",[11]="Twisted Spoon",[12]="Sharp Beak",
  [13]="Spell Tag",[14]="Black Belt",[15]="Hard Stone",[16]="Silver Powder",[17]="Miracle Seed",[18]="Never-Melt Ice",
  [19]="Dragon Fang",[20]="Black Glasses",[21]="Metal Disc",[22]="Bright Powder",[23]="Wide Lens",
  [24]="Gengarite",[25]="Blastoisinite",[26]="Charizardite Y",[27]="Charizardite X",[28]="Venusaurite",
  [29]="Pidgeotite",[30]="Kangaskhanite",[31]="Alakazite",[32]="Gyaradosite",[33]="Beedrillite",[34]="Pinsirite",
}

local NATURE_MOD_PCT = 0.08
local NATURES = {
  Hardy={}, Docile={}, Serious={}, Bashful={}, Quirky={},
  Adamant={off="up", spa="down"}, Brave={off="up", agi="down"}, Lonely={off="up", def="down"}, Naughty={off="up", vit="down"},
  Modest={spa="up", off="down"}, Quiet={spa="up", agi="down"}, Mild={spa="up", def="down"}, Rash={spa="up", vit="down"},
  Bold={def="up", off="down"}, Relaxed={def="up", agi="down"}, Impish={def="up", spa="down"}, Lax={def="up", vit="down"},
  Calm={vit="up", off="down"}, Sassy={vit="up", agi="down"}, Careful={vit="up", spa="down"}, Gentle={vit="up", def="down"},
  Timid={agi="up", off="down"}, Jolly={agi="up", spa="down"}, Hasty={agi="up", def="down"}, Naive={agi="up", vit="down"},
}
local function natureMultipliers(natureName)
  local spec = NATURES[natureName or ""] or {}
  local function m(flag) return (flag=="up" and (1+NATURE_MOD_PCT)) or (flag=="down" and (1-NATURE_MOD_PCT)) or 1 end
  return m(spec.off), m(spec.spa), m(spec.def), m(spec.vit), m(spec.agi)
end
local function natureEffectLabel(natureName)
  local spec = NATURES[natureName or ""] or {}
  local order = {"off","spa","def","vit","agi"}
  local ups, downs = {}, {}
  for _,k in ipairs(order) do
    if spec[k]=="up" then table.insert(ups, "+"..k:upper()) end
    if spec[k]=="down" then table.insert(downs, "-"..k:upper()) end
  end
  if #ups==0 and #downs==0 then return " (neutral)" end
  return " ("..table.concat(ups, " ").." "..table.concat(downs, " ")..")"
end

local function getIVsFromBall(ballUid)
  if not ballUid or ballUid <= 0 then return nil end
  local function num(a) return tonumber(a or 0) or 0 end
  local rawOff = getItemAttribute(ballUid, "iv_off")
  local rawDef = getItemAttribute(ballUid, "iv_def")
  local rawSpa = getItemAttribute(ballUid, "iv_spa")
  local rawVit = getItemAttribute(ballUid, "iv_vit")
  local rawHp  = getItemAttribute(ballUid, "iv_hp")
  local rawCdr = getItemAttribute(ballUid, "iv_cdr")
  if rawOff==nil and rawDef==nil and rawSpa==nil and rawVit==nil and rawHp==nil and rawCdr==nil then return nil end
  return { off=num(rawOff), def=num(rawDef), spa=num(rawSpa), vit=num(rawVit), hp=num(rawHp), cdr=num(rawCdr) }
end

local function parseTmSlots(raw)
  local list = {}
  if not raw or raw=="" then return list end
  for token in tostring(raw):gmatch("[^|]+") do
    local idxStr, name = token:match("^(%d+)=([^|]+)$")
    local idx = tonumber(idxStr)
    if idx and idx>=1 and idx<=12 and name and name~="" then
      table.insert(list, {idx=idx, name=name})
    end
  end
  table.sort(list, function(a,b) return a.idx<b.idx end)
  return list
end
local function tmListStringFromBall(ballUid)
  if not ballUid or ballUid <= 0 then return nil end
  local entries = parseTmSlots(getItemAttribute(ballUid, "tm_slots"))
  if #entries==0 then return nil end
  local names = {}
  for _,e in ipairs(entries) do table.insert(names, e.name) end
  return "TMs aprendidos: "..table.concat(names, ", ").."."
end

local function statLineNoMasterLevel(pokeName, boost, heldx, orb, ivs, natureName, megaMul)
  local conf = getPokemonConfigByName(pokeName)
  if not conf then return nil end
  boost = tonumber(boost or 0) or 0
  heldx = tonumber(heldx or 0) or 0
  orb   = tonumber(orb or 0) or 0
  megaMul = tonumber(megaMul or 1) or 1

  local DEF_BONUS = (type(DefBonus1) == "number" and DefBonus1) or 1
  local BOOST_BONUS = (type(BoostBonus1) == "number" and BoostBonus1) or 0
  local HASTE_ADD = (type(Hasteadd1) == "number" and Hasteadd1) or 0
  local VITA_MULT = (type(Vitality1) == "number" and Vitality1) or 1
  local atkBase = (type(AtkBonus1) == "number" and AtkBonus1) or (type(XAttackBonus1) == "number" and XAttackBonus1) or 1
  local IV_PCT_PER_POINT = 0.0065

  local bonusdef   = (heldx>0 and heldx<8)   and DEF_BONUS or 1
  local bonusboost = (heldx>35 and heldx<43) and BOOST_BONUS or 0
  local hastespeed = (heldx>98 and heldx<106) and HASTE_ADD or 0
  local vitapoint  = (heldx>91 and heldx<99) and VITA_MULT or 1
  local atkMul     = (heldx>7 and heldx<15)  and atkBase or 1

  local orbOffMul, orbSpaMul, orbDefMul, orbVitMul, orbAgiMul = 1,1,1,1,1
  if orb == 1 then -- Life Orb
    orbOffMul, orbSpaMul = 2.00, 2.00
  elseif orb == 3 then -- Assault Vest
    orbDefMul, orbVitMul = 1.40, 1.25
    orbOffMul, orbSpaMul = 0.70, 0.70
    orbAgiMul = 0.80
  end

  local nOff, nSpa, nDef, nVit, nAgi = natureMultipliers(natureName)
  local factor = math.max(1, boost)

  local ivOff = ivs and tonumber(ivs.off or 0) or 0
  local ivDef = ivs and tonumber(ivs.def or 0) or 0
  local ivSpa = ivs and tonumber(ivs.spa or 0) or 0
  local ivVit = ivs and tonumber(ivs.vit or 0) or 0

  local off = (((conf.offense or 0) * factor) + bonusboost) * atkMul * orbOffMul * nOff
  local def = (((conf.defense or 0) + bonusboost)) * orbDefMul * bonusdef * nDef
  local spa = (((conf.specialattack or 0) * factor) + bonusboost) * atkMul * orbSpaMul * nSpa
  local vit = (((conf.vitality or 0) * factor) + bonusboost) * vitapoint * orbVitMul * nVit
  local agi = math.max(0, math.floor(((conf.agility or 0) * orbAgiMul * nAgi) + hastespeed))

  off = off * (1 + ivOff * IV_PCT_PER_POINT)
  def = def * (1 + ivDef * IV_PCT_PER_POINT)
  spa = spa * (1 + ivSpa * IV_PCT_PER_POINT)
  vit = vit * (1 + ivVit * IV_PCT_PER_POINT)

  off = off * megaMul; def = def * megaMul; spa = spa * megaMul; vit = vit * megaMul; agi = math.floor(agi * megaMul)

  local function fmt(n)
    if n >= 1e6 then return string.format("%.1fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n/1e3)
    else return string.format("%.1f", n) end
  end
  return string.format("Stats (no player level): Off %s | Def %s | SpA %s | Vit %s | Agi %s",
    fmt(off), fmt(def), fmt(spa), fmt(vit), fmt(agi))
end

local function buildBallTradeDescription(ballUid)
  local iname    = getItemInfo(getThing(ballUid).itemid)
  local poke     = getItemAttribute(ballUid, "poke") or "Unknown"
  local nick     = getItemAttribute(ballUid, "nick")
  local boost    = tonumber(getItemAttribute(ballUid, "boost") or 0) or 0
  local heldx    = getItemAttribute(ballUid, "heldx")
  local heldy    = getItemAttribute(ballUid, "heldy")
  local orb      = getItemAttribute(ballUid, "orb")
  local nature   = getItemAttribute(ballUid, "nature")
  local ivs      = getIVsFromBall(ballUid)
  local tmLine   = tmListStringFromBall(ballUid)
  local megaAct  = (tonumber(getItemAttribute(ballUid, "mega_active") or 0) == 1)
  local megaMul  = megaAct and 1.7 or 1.0

  local t = {}
  table.insert(t, "You see " .. iname.article .. " " .. iname.name .. ".")
  table.insert(t, " It contains " .. getArticle(poke) .. " " .. poke .. ".")
  if nick and nick ~= "" then table.insert(t, " Nick: " .. nick .. ".") end
  if boost > 0 then table.insert(t, " Boost +" .. boost .. ".") end

  if heldx and xhelds[heldx] then table.insert(t, " Holding: " .. xhelds[heldx].name .. ".") end
  if heldy and yhelds[heldy] then table.insert(t, " " .. yhelds[heldy].name .. ".") end
  if orb and ORB_NAMES[orb] then table.insert(t, " Holding (Orb): " .. ORB_NAMES[orb] .. ".") end

  if nature and tostring(nature) ~= "" then
    table.insert(t, " Nature: " .. tostring(nature) .. natureEffectLabel(nature) .. ".")
  end
  if ivs then
    table.insert(t, string.format(" IVs: Off %d | Def %d | SpA %d | Vit %d | HP %d | CDR %d.",
      tonumber(ivs.off or 0), tonumber(ivs.def or 0), tonumber(ivs.spa or 0),
      tonumber(ivs.vit or 0), tonumber(ivs.hp or 0), tonumber(ivs.cdr or 0)))
  end
  local line = statLineNoMasterLevel(poke, boost, heldx, orb, ivs, nature, megaMul)
  if line then table.insert(t, " " .. line .. ".") end
  if megaAct then table.insert(t, " (Mega Evolution ativa).") end
  if tmLine then table.insert(t, " " .. tmLine) end

  return table.concat(t)
end

local function setSpecialDesc(uid, text)
  if doSetItemSpecialDescription then
    doSetItemSpecialDescription(uid, text)
  else
    doItemSetAttribute(uid, "description", text)
  end
end

local function isStackableId(id)
  local info = getItemInfo(id)
  return (info and info.stackable) or false
end

function onTradeRequest(cid, target, item)
  for _, b in pairs(pokeballs) do
    if b.use == item.itemid then
      doPlayerSendCancel(cid, "You can't trade this item.")
      return false
    end
  end
  if isContainer(item.uid) then
    local bagItems = getItensUniquesInContainer(item.uid)
    if #bagItems >= 1 then
      doPlayerSendCancel(cid, "There is a Unique Item in this bag, you can't trade this item.")
      return false
    end
  elseif getItemAttribute(item.uid, "unique") then
    doPlayerSendCancel(cid, "It is a Unique Item, you can't trade this item.")
    return false
  end

  if isContainer(item.uid) then
    local itens = getPokeballsInContainer(item.uid)
    for i = 1, #itens do
      local lvl = getItemAttribute(itens[i], "level")
      local name = getItemAttribute(itens[i], "poke")
      if not lvl and name and pokes[name] then
        doItemSetAttribute(itens[i], "level", pokes[name].level)
      end
    end
  elseif isPokeball(item.itemid) then
    local lvl = getItemAttribute(item.uid, "level")
    local name = getItemAttribute(item.uid, "poke")
    if not lvl and name and pokes[name] then
      doItemSetAttribute(item.uid, "level", pokes[name].level)
    end
  end

  if getPlayerStorageValue(cid, 52480) >= 1 then
    doPlayerSendTextMessage(cid, 20, "You can't do that while being in a duel!")
    return false
  end

  if isPokeball(item.itemid) then
    local desc = buildBallTradeDescription(item.uid)
    setSpecialDesc(item.uid, desc)
  elseif isContainer(item.uid) then
    local itens = getPokeballsInContainer(item.uid)
    for i = 1, #itens do
      local this = getThing(itens[i])
      if isPokeball(this.itemid) then
        local desc = buildBallTradeDescription(itens[i])
        setSpecialDesc(itens[i], desc)
      end
    end
  end

  return true
end

local function noCap(cid, sid)
  if isCreature(cid) then
    doPlayerSendCancel(cid, "You can't carry more than six pokemons, trade cancelled.")
  end
  if isCreature(sid) then
    doPlayerSendCancel(sid, "You can't carry more than six pokemons, trade cancelled.")
  end
end

function onTradeAccept(cid, target, item, targetItem)
  if not item or item.uid <= 0 or not targetItem or targetItem.uid <= 0 then
    return true
  end

  if item.itemid == targetItem.itemid and isStackableId(item.itemid) then
    local msg = "Trade blocked: both sides added the same stackable item. Change the quantity or put the item inside a bag/parcel."
    doPlayerSendCancel(cid, msg)
    doPlayerSendCancel(target, msg)
    return false
  end

  local p1, p2 = 0, 0
  local itemPokeball       = isPokeball(item.itemid) and 1 or 0
  local targetItemPokeball = isPokeball(targetItem.itemid) and 1 or 0
  local cancel = false

  if getPlayerMana(cid) + itemPokeball > 6 then cancel = true p1 = cid end
  if getPlayerMana(target) + targetItemPokeball > 6 then cancel = true p2 = target end

  local pbs = #getPokeballsInContainer(item.uid)
  if pbs > 0 and getCreatureMana(target) + pbs > 6 + targetItemPokeball then cancel = true p1 = target end

  pbs = #getPokeballsInContainer(targetItem.uid)
  if pbs > 0 and getCreatureMana(cid) + pbs > 6 + itemPokeball then cancel = true p2 = cid end

  if cancel then
    addEvent(noCap, 20, p1, p2)
    return false
  end

  if itemPokeball == 1 and targetItemPokeball == 1 then
    setPlayerStorageValue(cid, 8900, 1)
    setPlayerStorageValue(target, 8900, 1)
  end

  -- opcional: apagar a descrição especial depois de aceitar (pra não “colar” no item)
  -- if doItemEraseAttribute then
  --   if isPokeball(item.itemid) then doItemEraseAttribute(item.uid, "description") end
  --   if isPokeball(targetItem.itemid) then doItemEraseAttribute(targetItem.uid, "description") end
  -- end

  return true
end
