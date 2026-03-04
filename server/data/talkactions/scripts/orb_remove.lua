local returnItemForOrb = {
  [1] = 12682, -- Life Orb
  [2] = 12683, -- Leftovers
  [3] = 12684, -- Assault Vest
  [4] = 12685, -- Rocky Helmet
  [5] = 12686, -- Silk Scarf
  [6] = 12687, -- Mystic Water
  [7] = 12688, -- Soft Sand
  [8] = 12689, -- Charcoal
  [9] = 12690, -- Magnet
  [10] = 12691, -- Poison Barb
  [11] = 12692, -- Twisted Spoon
  [12] = 12693, -- Sharp Beak
  [13] = 12694, -- Spell Tag
  [14] = 12695, -- Black Belt
  [15] = 12696, -- Hard Stone
  [16] = 12697, -- Silver Powder
  [17] = 12698, -- Miracle Seed
  [18] = 12699, -- Never-Melt Ice
  [19] = 12700, -- Dragon Fang
  [20] = 12701, -- Black Glasses
  [21] = 12702, -- Metal Disc
  [22] = 14104, -- Bright Powder
  [23] = 14105, -- Wide Lens
  [24] = 14108, -- Gengarite
  [25] = 14109, -- Blastoisinite
  [26] = 14110, -- Charizardite Y
  [27] = 14111, -- Charizardite X
  [28] = 14112, -- Venusaurite
  [29] = 14117, -- Pidgeotite
  [30] = 14118, -- Kangaskhanite
  [31] = 14119, -- Alakazite
  [32] = 14120, -- Gyaradosite
  [33] = 14121, -- Beedrillite
  [34] = 14122, -- Pinsirite
  [35] = 14153, -- Amulet Coin
}



function onSay(cid, words, param)
  param = (param or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if param ~= "remove" then return true end

  local ball = getPlayerSlotItem(cid, 8)
  if not ball or ball.uid <= 0 or not isPokeball(ball.itemid) then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Coloque a pokebola no slot principal.")
    return true
  end

  local cur = tonumber(getItemAttribute(ball.uid, "orb") or 0) or 0
  if cur == 0 then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Nao ha item para remover.")
    return true
  end

  local retItem = returnItemForOrb[cur]
  if retItem then
    doPlayerAddItem(cid, retItem, 1)
  end

  doItemEraseAttribute(ball.uid, "orb")
  doSendMagicEffect(getThingPos(cid), 14)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Item removido e devolvido a sua mochila.")

  local summons = getCreatureSummons(cid)
  if #summons > 0 then
    local mon = summons[1]
    if adjustStatus then
      adjustStatus(mon, ball.uid, false, true, false)
    end
    if doUpdateMoves then doUpdateMoves(cid) end
    if doUpdateCooldowns then doUpdateCooldowns(cid) end
  end

  return true
end
