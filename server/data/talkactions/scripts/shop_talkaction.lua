local CURRENCY_ITEMID = 2149
local MESSAGE_CODE    = 163

local DEFAULT_BALL_ON_ID = pokeballs["ultra"].on
local CLAN_COST = 50

local function sendShopTextBuffer(cid, payload)
  doPlayerSendTextMessage(cid, MESSAGE_FAILURE, "&sco&," .. tostring(MESSAGE_CODE) .. "," .. payload)
end

local function tryBuyVip(cid, cost, days, labelName, labelDesc)
  if getPlayerItemCount(cid, CURRENCY_ITEMID) < cost then
    doPlayerSendCancel(cid, "You don't have enough emeralds.")
    return true
  end
  if not doPlayerRemoveItem(cid, CURRENCY_ITEMID, cost) then
    doPlayerSendCancel(cid, "Failed to remove emeralds.")
    return true
  end
  doPlayerAddPremiumDays(cid, days)
  sendShopTextBuffer(cid, labelName .. "|" .. labelDesc)
  doSendMagicEffect(getThingPos(cid), 173)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, string.format("You bought %s (%s).", labelName, labelDesc))
  return true
end

local function tryChangeSex(cid, cost)
  if getPlayerItemCount(cid, CURRENCY_ITEMID) < cost then
    doPlayerSendCancel(cid, "You don't have enough emeralds.")
    return true
  end
  if not doPlayerRemoveItem(cid, CURRENCY_ITEMID, cost) then
    doPlayerSendCancel(cid, "Failed to remove emeralds.")
    return true
  end
  local newSex = (getPlayerSex(cid) == 0) and 1 or 0
  doPlayerSetSex(cid, newSex)
  sendShopTextBuffer(cid, "Gender|Change Sex")
  doSendMagicEffect(getThingPos(cid), 173)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Your gender has been changed.")
  return true
end

local function chooseGenderByRate(pokeName)
  local rate = newpokedex[pokeName] and newpokedex[pokeName].gender or -1
  if rate == 0 then return 3
  elseif rate == 1000 then return 4
  elseif rate == -1 then return 0
  elseif math.random(1, 1000) <= rate then return 4 else return 3 end
end

local function tryGiveItem(cid, cost, itemid, amount, labelName, labelDesc)
  amount = amount or 1
  if getPlayerItemCount(cid, CURRENCY_ITEMID) < cost then
    doPlayerSendCancel(cid, "You don't have enough emeralds.")
    return true
  end
  if not doPlayerRemoveItem(cid, CURRENCY_ITEMID, cost) then
    doPlayerSendCancel(cid, "Failed to remove emeralds.")
    return true
  end

  local it = doPlayerAddItem(cid, itemid, amount, true)
  if not it then
    doPlayerSendCancel(cid, "Could not deliver the item right now.")
    return true
  end

  sendShopTextBuffer(cid, labelName .. "|" .. labelDesc)
  doSendMagicEffect(getThingPos(cid), 173)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
    string.format("You bought %s (%s).", labelName, labelDesc))
  return true
end

local function givePokemonBall(cid, pokeName, ballOnId)
  local sendToDepot = (getPlayerFreeCap(cid) >= 6 and not isInArray({5, 6}, getPlayerGroupId(cid)))
                      or not hasSpaceInContainer(getPlayerSlotItem(cid, 3).uid)

  local item
  if sendToDepot then
    item = doCreateItemEx(ballOnId - 1)
  else
    item = addItemInFreeBag(getPlayerSlotItem(cid, 3).uid, ballOnId, 1)
  end

  local description = "Contains a " .. pokeName .. "."
  doItemSetAttribute(item, "poke", pokeName)
  doItemSetAttribute(item, "hp", 1)
  doItemSetAttribute(item, "happy", 250)
  doItemSetAttribute(item, "gender", chooseGenderByRate(pokeName))
  doItemSetAttribute(item, "fakedesc", description)
  doItemSetAttribute(item, "description", description)
  doItemSetAttribute(item, "10002", pokeName)

  doTransformItem(item, ballOnId - 1)
  doTransformItem(item, ballOnId)

  if pokeName == "Hitmonchan" or pokeName == "Shiny Hitmonchan" then
    doItemSetAttribute(item, "hands", 0)
  end

  if sendToDepot then
    doPlayerSendMailByName(getCreatureName(cid), item, 1)
    doPlayerSendTextMessage(cid, 27, "Since you are already holding six pokemons, this pokeball has been sent to your depot.")
  end
end

local function tryBuyPokemon(cid, cost, pokeName, labelName, labelDesc)
  if not pokes[pokeName] then
    doPlayerSendCancel(cid, "This pokemon is not available right now.")
    return true
  end
  if getPlayerItemCount(cid, CURRENCY_ITEMID) < cost then
    doPlayerSendCancel(cid, "You don't have enough emeralds.")
    return true
  end
  if not doPlayerRemoveItem(cid, CURRENCY_ITEMID, cost) then
    doPlayerSendCancel(cid, "Failed to remove emeralds.")
    return true
  end
  givePokemonBall(cid, pokeName, DEFAULT_BALL_ON_ID)
  sendShopTextBuffer(cid, labelName .. "|" .. labelDesc)
  doSendMagicEffect(getThingPos(cid), 173)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, string.format("You bought %s (%s).", labelName, labelDesc))
  return true
end

local function resolveClanByNameLower(lower)
  for num, data in pairs(clansName) do
    local canon = string.lower(data[1])
    if canon == lower then
      return num, data[1]
    end
  end
  return nil, nil
end

local function forceRemoveClan(cid)
  setPlayerStorageValue(cid, 86228, -1)
  setPlayerStorageValue(cid, 862281, -1)

  setPlayerStorageValue(cid, 854789, -1)
  setPlayerStorageValue(cid, 854788, -1)
  setPlayerStorageValue(cid, 854787, -1)

  for i = 181612, 181638 do
    setPlayerStorageValue(cid, i, -1)
  end
end

local function tryBuyClan(cid, clanNameLower)
  local okTest = setPlayerClan(cid, clanNameLower)
  if not okTest then
    doPlayerSendCancel(cid, "This clan does not exist.")
    return true
  end
  forceRemoveClan(cid)
  if getPlayerItemCount(cid, CURRENCY_ITEMID) < CLAN_COST then
    doPlayerSendCancel(cid, "You don't have enough emeralds.")
    return true
  end
  if not doPlayerRemoveItem(cid, CURRENCY_ITEMID, CLAN_COST) then
    doPlayerSendCancel(cid, "Failed to remove emeralds.")
    return true
  end
  forceRemoveClan(cid)
  local ok = setPlayerClan(cid, clanNameLower)
  if not ok then
    doPlayerSendCancel(cid, "Could not set clan now.")
    return true
  end
  setPlayerClanRank(cid, 5)

  local canonName = getPlayerClanName(cid) or "Clan"
  local rank = tonumber(getPlayerClanRank(cid)) or 5

  sendShopTextBuffer(cid, "Clan|" .. canonName .. " (Rank " .. rank .. ")")
  doSendMagicEffect(getThingPos(cid), 173)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You joined the clan " .. canonName .. " (Rank " .. rank .. ").")
  return true
end

function onSay(cid, words, param, channel)
  local w = string.lower(string.trim(words or ""))
  local p = string.lower(string.trim(param or ""))

  if w == "/shop" then
    if p == "vip30" then
      return tryBuyVip(cid, 10, 30, "Vip", "30 Days")
    elseif p == "vip60" then
      return tryBuyVip(cid, 18, 60, "Vip", "60 Days")
    elseif p == "vip90" then
      return tryBuyVip(cid, 25, 90, "Vip", "90 Days")
    elseif p == "sexy" then
      return tryChangeSex(cid, 5)
    elseif p == "charm3" then
      return tryGiveItem(cid, 17, 14107, 1, "Shiny Charm", "3 Days")
    elseif p == "blanktm" then
      return tryGiveItem(cid, 20, 12999, 1, "Blank TM", "Convert into any TM")
    elseif p == "bottlecap" then
      return tryGiveItem(cid, 30, 12703, 1, "Bottle Cap", "One IV to 31")
    elseif p == "goldcap" then
      return tryGiveItem(cid, 75, 12704, 1, "Golden Bottle Cap", "All IVs to 31")
    elseif p == "bike" then
      return tryGiveItem(cid, 5, 14113, 1, "Bike", "Move speed boost")
    elseif p == "yellowrobot" then
      return tryGiveItem(cid, 10, 14152, 1, "Yellow Robot", "Move speed and HP boost")
    elseif p == "moveinc" then
      return tryGiveItem(cid, 15, 12681, 1, "Move Increaser", "Increase moves amount")
    elseif p == "boxheld" then
      return tryGiveItem(cid, 28, 14114, 1, "Generic Held Prize Box", "Random held item")
    elseif p == "boxtype" then
      return tryGiveItem(cid, 28, 14115, 1, "Type Held Prize Box", "Random type-boost item")
    elseif p == "boxmega" then
      return tryGiveItem(cid, 60, 14116, 1, "Mega Stone Prize Box", "Random mega stone")
    elseif p == "sdust" then
      return tryGiveItem(cid, 3, 14125, 1, "Shiny Dust", "Shiny dust")
    elseif p == "boost" then
      return tryGiveItem(cid, 1, 12618, 1, "Boost your pokemon", "Boost your pokemon")
    elseif p == "xpboost" then
      return tryGiveItem(cid, 5, 14154, 1, "Boost your Exp Gain", "Boost your Exp Gain")
    elseif p == "shbox" then
      return tryGiveItem(cid, 50, 12227, 1, "Shiny Pokemon Box", "Random shiny pokemon")
    elseif p == "ditto" then
      return tryBuyPokemon(cid, 15, "Ditto", "Pokemon", "Ditto")
    elseif p == "shinyditto" then
      return tryBuyPokemon(cid, 60, "Shiny Ditto", "Pokemon", "Shiny Ditto")
    elseif p == "mega3" then
      return tryGiveItem(cid, 30, 14166, 1, "Mega Charm", "3 Days")

    else
      doPlayerSendCancel(cid, "Unknown shop code.")
      return true
    end

  elseif w == "/clan" then
    if p == "" then
      doPlayerSendCancel(cid, "Usage: /clan <volcanic|seavell|orebound|wingeon|malefic|gardestrike|psycraft|naturia|raibolt>")
      return true
    end
    return tryBuyClan(cid, p)

  else
    doPlayerSendCancel(cid, "Unknown command.")
    return true
  end
end

