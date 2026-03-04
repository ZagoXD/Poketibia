local orbTable = {
    [12682] = {
        attribute = "orb",
        ident = 1
    }, -- Life Orb
    [12683] = {
        attribute = "orb",
        ident = 2
    }, -- Leftovers
    [12684] = {
        attribute = "orb",
        ident = 3
    }, -- Assault Vest
    [12685] = {
        attribute = "orb",
        ident = 4
    }, -- Rocky Helmet
    [12686] = {
        attribute = "orb",
        ident = 5
    }, -- Silk Scarf
    [12687] = {
        attribute = "orb",
        ident = 6
    }, -- Mystic Water
    [12688] = {
        attribute = "orb",
        ident = 7
    }, -- Soft Sand
    [12689] = {
        attribute = "orb",
        ident = 8
    }, -- Charcoal
    [12690] = {
        attribute = "orb",
        ident = 9
    }, -- Magnet
    [12691] = {
        attribute = "orb",
        ident = 10
    }, -- Poison Barb
    [12692] = {
        attribute = "orb",
        ident = 11
    }, -- Twisted Spoon
    [12693] = {
        attribute = "orb",
        ident = 12
    }, -- Sharp Beak
    [12694] = {
        attribute = "orb",
        ident = 13
    }, -- Spell Tag
    [12695] = {
        attribute = "orb",
        ident = 14
    }, -- Black Belt
    [12696] = {
        attribute = "orb",
        ident = 15
    }, -- Hard Stone
    [12697] = {
        attribute = "orb",
        ident = 16
    }, -- Silver Powder
    [12698] = {
        attribute = "orb",
        ident = 17
    }, -- Miracle Seed
    [12699] = {
        attribute = "orb",
        ident = 18
    }, -- Never-Melt Ice
    [12700] = {
        attribute = "orb",
        ident = 19
    }, -- Dragon Fang
    [12701] = {
        attribute = "orb",
        ident = 20
    }, -- Black Glasses
    [12702] = {
        attribute = "orb",
        ident = 21
    }, -- Metal Disc
    [14104] = {
        attribute = "orb",
        ident = 22
    }, -- Bright Powder
    [14105] = {
        attribute = "orb",
        ident = 23
    }, -- Wide Lens
    [14108] = {
        attribute = "orb",
        ident = 24
    }, -- Gengarite
    [14109] = {
        attribute = "orb",
        ident = 25
    }, -- Blastoisinite
    [14110] = {
        attribute = "orb",
        ident = 26
    }, -- Charizardite Y
    [14111] = {
        attribute = "orb",
        ident = 27
    }, -- Charizardite X
    [14112] = {
        attribute = "orb",
        ident = 28
    }, -- Venusaurite
    [14117] = {
        attribute = "orb",
        ident = 29
    }, -- Pidgeotite

    [14118] = {
        attribute = "orb",
        ident = 30
    }, -- Kangaskhanite

    [14119] = {
        attribute = "orb",
        ident = 31
    }, -- Alakazite

    [14120] = {
        attribute = "orb",
        ident = 32
    }, -- Gyaradosite

    [14121] = {
        attribute = "orb",
        ident = 33
    }, -- Beedrillite

    [14122] = {
        attribute = "orb",
        ident = 34
    }, -- Pinsirite
    [14153] = {
        attribute = "orb",
        ident = 35
    }, -- Amulet Coin

}

local orbBackItemId = {
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
    [23] = 14105, -- wide lens
    [24] = 14108, -- Gengarite
    [25] = 14109, -- Blastoisinite
    [26] = 14110, -- Charizardite Y
    [27] = 14111, -- Charizardite X
    [28] = 14112, -- Venusaur
    [29] = 14117, -- Pidgeot
    [30] = 14118, -- Kangaskhan
    [31] = 14119, -- Alakazam
    [32] = 14120, -- Gyarados
    [33] = 14121, -- Beedrill
    [34] = 14122, -- Pinsir
    [35] = 14153, -- Amulet Coin
}

local function giveBackOrb(cid, orbIdent)
    local itemid = orbBackItemId[orbIdent]
    if not itemid then
        return
    end
    doPlayerAddItem(cid, itemid, 1)
end

function onUse(cid, item, frompos, item2, topos)
    if not orbTable[item.itemid] then
        return false
    end
    local cfg = orbTable[item.itemid]

    local ball
    if isPokeball(item2.itemid) then
        if #getCreatureSummons(cid) > 0 then
            return false
        end
        ball = item2
    elseif isCreature(item2.uid) and isSummon(item2.uid) and getCreatureMaster(item2.uid) == cid then
        ball = getPlayerSlotItem(cid, 8)
        if not ball or ball.uid <= 0 then
            return false
        end
    else
        return false
    end

    local pokename = getItemAttribute(ball.uid, "poke") or ""
    local orbname = getItemInfo(item.itemid).name

    local old = tonumber(getItemAttribute(ball.uid, cfg.attribute) or 0) or 0
    if old > 0 then
        giveBackOrb(cid, old)
    end

    doSetItemAttribute(ball.uid, cfg.attribute, cfg.ident)
    doRemoveItem(item.uid, 1)
    doSendMagicEffect(getThingPos(cid), 14)
    sendMsgToPlayer(cid, 27, "Seu " .. pokename .. " recebeu " .. orbname .. ".")

    return true
end
