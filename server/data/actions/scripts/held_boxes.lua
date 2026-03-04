local PRIZE_BOXES = {
  [14114] = {
    boxName = "Generic Held Prize Box",
    rewards = {
      {id = 12683, count = 1}, -- Leftovers
      {id = 12684, count = 1}, -- Assault Vest
      {id = 12685, count = 1}, -- Rocky Helmet
      {id = 14104, count = 1}, -- Bright Powder
      {id = 14105, count = 1}, -- Wide Lens
      {id = 14153, count = 1}, -- Amulet Coin
    }
  },

  [14115] = {
    boxName = "Type Held Prize Box",
    rewards = {
      {id = 12686, count = 1}, -- Silk Scarf
      {id = 12687, count = 1}, -- Mystic Water
      {id = 12688, count = 1}, -- Soft Sand
      {id = 12689, count = 1}, -- Charcoal
      {id = 12690, count = 1}, -- Magnet
      {id = 12691, count = 1}, -- Poison Barb
      {id = 12692, count = 1}, -- Twisted Spoon
      {id = 12693, count = 1}, -- Sharp Beak
      {id = 12694, count = 1}, -- Spell Tag
      {id = 12695, count = 1}, -- Black Belt
      {id = 12696, count = 1}, -- Hard Stone
      {id = 12697, count = 1}, -- Silver Powder
      {id = 12698, count = 1}, -- Miracle Seed
      {id = 12699, count = 1}, -- Never-Melt Ice
      {id = 12700, count = 1}, -- Dragon Fang
      {id = 12701, count = 1}, -- Black Glasses
      {id = 12702, count = 1}, -- Metal Disc
    }
  },

  [14116] = {
    boxName = "Mega Stone Prize Box",
    rewards = {
      {id = 14108, count = 1}, -- Gengarite
      {id = 14109, count = 1}, -- Blastoisinite
      {id = 14110, count = 1}, -- Charizardite Y
      {id = 14111, count = 1}, -- Charizardite X
      {id = 14112, count = 1}, -- Venusaurite
      {id = 14117, count = 1}, -- Pidgeotite
      {id = 14118, count = 1}, -- Kangaskhanite
      {id = 14119, count = 1}, -- Alakazite
      {id = 14120, count = 1}, -- Gyaradosite
      {id = 14121, count = 1}, -- Beedrillite
      {id = 14122, count = 1}, -- Pinsirite
    }
  }
}

local function givePrizeItem(cid, itemId, amount)
  amount = amount or 1
  local ok = doPlayerAddItem(cid, itemId, amount, true)
  if not ok then
    local tmp = doCreateItemEx(itemId, amount)
    if tmp then
      doPlayerSendMailByName(getCreatureName(cid), tmp, 1)
      return "mail"
    else
      return false
    end
  end
  return true
end

function onUse(cid, item, fromPos, item2, toPos)
  local cfg = PRIZE_BOXES[item.itemid]
  if not cfg then return true end

  local prize = cfg.rewards[math.random(#cfg.rewards)]
  local result = givePrizeItem(cid, prize.id, prize.count)

  if not result then
    doPlayerSendCancel(cid, "Your inventory is full and delivery by mail failed.")
    return true
  end

  local itName = getItemNameById(prize.id)
  local boxName = cfg.boxName or "Prize Box"

  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
    string.format("You opened a %s!", boxName))
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR,
    string.format("Your reward is: %s x%d. Congratulations!", itName, prize.count))

  doSendMagicEffect(getThingPos(cid), 29)
  doRemoveItem(item.uid, 1)

  if result == "mail" then
    doPlayerSendTextMessage(cid, 27, "Your reward has been sent to your depot (mail).")
  end
  return true
end
