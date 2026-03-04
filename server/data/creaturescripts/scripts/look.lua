-- dofile('data/lib/configuration.lua')
-- ================= Opções =================
local IGNORE_PLAYER_LEVEL_ALWAYS = true
local STATS_STYLE = "singleline"
local COMPACT_UNITS = true
local STAT_DECIMALS = 1
-- ===============================================

local function getPokemonConfigByName(name)
    if not name or not pokes then
        return nil
    end
    if pokes[name] then
        return pokes[name]
    end
    local base = name
    base = base:gsub("^Shiny%s+", "")
    base = base:gsub("^Ancient%s+", "")
    base = base:gsub("^Mega%s+", "")
    base = base:gsub("%s+%b()", "")
    return pokes[base]
end

local xhelds = {
    [1] = {
        name = "X-Defense(Tier: 1)"
    },
    [2] = {
        name = "X-Defense(Tier: 2)"
    },
    [3] = {
        name = "X-Defense(Tier: 3)"
    },
    [4] = {
        name = "X-Defense(Tier: 4)"
    },
    [5] = {
        name = "X-Defense(Tier: 5)"
    },
    [6] = {
        name = "X-Defense(Tier: 6)"
    },
    [7] = {
        name = "X-Defense(Tier: 7)"
    },
    [8] = {
        name = "X-Attack(Tier : 1)"
    },
    [9] = {
        name = "X-Attack(Tier : 2)"
    },
    [10] = {
        name = "X-Attack(Tier: 3)"
    },
    [11] = {
        name = "X-Attack(Tier: 4)"
    },
    [12] = {
        name = "X-Attack(Tier: 5)"
    },
    [13] = {
        name = "X-Attack(Tier: 6)"
    },
    [14] = {
        name = "X-Attack(Tier: 7)"
    },
    [15] = {
        name = "X-Return(Tier: 1)"
    },
    [16] = {
        name = "X-Return(Tier: 2)"
    },
    [17] = {
        name = "X-Return(Tier: 3)"
    },
    [18] = {
        name = "X-Return(Tier: 4)"
    },
    [19] = {
        name = "X-Return(Tier: 5)"
    },
    [20] = {
        name = "X-Return(Tier: 6)"
    },
    [21] = {
        name = "X-Return(Tier: 7)"
    },
    [22] = {
        name = "X-Hellfire(Tier: 1)"
    },
    [23] = {
        name = "X-Hellfire(Tier: 2)"
    },
    [24] = {
        name = "X-Hellfire(Tier: 3)"
    },
    [25] = {
        name = "X-Hellfire(Tier: 4)"
    },
    [26] = {
        name = "X-Hellfire(Tier: 5)"
    },
    [27] = {
        name = "X-Hellfire(Tier: 6)"
    },
    [28] = {
        name = "X-Hellfire(Tier: 7)"
    },
    [29] = {
        name = "X-Poison(Tier: 1)"
    },
    [30] = {
        name = "X-Poison(Tier: 2)"
    },
    [31] = {
        name = "X-Poison(Tier: 3)"
    },
    [32] = {
        name = "X-Poison(Tier: 4)"
    },
    [33] = {
        name = "X-Poison(Tier: 5)"
    },
    [34] = {
        name = "X-Poison(Tier: 6)"
    },
    [35] = {
        name = "X-Poison(Tier: 7)"
    },
    [36] = {
        name = "X-Boost(Tier: 1)"
    },
    [37] = {
        name = "X-Boost(Tier: 2)"
    },
    [38] = {
        name = "X-Boost(Tier: 3)"
    },
    [39] = {
        name = "X-Boost(Tier: 4)"
    },
    [40] = {
        name = "X-Boost(Tier: 5)"
    },
    [41] = {
        name = "X-Boost(Tier: 6)"
    },
    [42] = {
        name = "X-Boost(Tier: 7)"
    },
    [43] = {
        name = "X-Agility(Tier: 1)"
    },
    [44] = {
        name = "X-Agility(Tier: 2)"
    },
    [45] = {
        name = "X-Agility(Tier: 3)"
    },
    [46] = {
        name = "X-Agility(Tier: 4)"
    },
    [47] = {
        name = "X-Agility(Tier: 5)"
    },
    [48] = {
        name = "X-Agility(Tier: 6)"
    },
    [49] = {
        name = "X-Agility(Tier: 7)"
    },
    [50] = {
        name = "X-Strafe(Tier: 1)"
    },
    [51] = {
        name = "X-Strafe(Tier: 2)"
    },
    [52] = {
        name = "X-Strafe(Tier: 3)"
    },
    [53] = {
        name = "X-Strafe(Tier: 4)"
    },
    [54] = {
        name = "X-Strafe(Tier: 5)"
    },
    [55] = {
        name = "X-Strafe(Tier: 6)"
    },
    [56] = {
        name = "X-Strafe(Tier: 7)"
    },
    [57] = {
        name = "X-Rage(Tier: 1)"
    },
    [58] = {
        name = "X-Rage(Tier: 2)"
    },
    [59] = {
        name = "X-Rage(Tier: 3)"
    },
    [60] = {
        name = "X-Rage(Tier: 4)"
    },
    [61] = {
        name = "X-Rage(Tier: 5)"
    },
    [62] = {
        name = "X-Rage(Tier: 6)"
    },
    [63] = {
        name = "X-Rage(Tier: 7)"
    },
    [92] = {
        name = "X-Vitality(Tier: 1)"
    },
    [65] = {
        name = "X-Vitality(Tier: 2)"
    },
    [66] = {
        name = "X-Vitality(Tier: 3)"
    },
    [67] = {
        name = "X-Vitality(Tier: 4)"
    },
    [68] = {
        name = "X-Vitality(Tier: 5)"
    },
    [69] = {
        name = "X-Vitality(Tier: 6)"
    },
    [70] = {
        name = "X-Vitality(Tier: 7)"
    },
    [71] = {
        name = "X-Experience(Tier: 1)"
    },
    [72] = {
        name = "X-Experience(Tier: 2)"
    },
    [73] = {
        name = "X-Experience(Tier: 3)"
    },
    [74] = {
        name = "X-Experience(Tier: 4)"
    },
    [75] = {
        name = "X-Experience(Tier: 5)"
    },
    [76] = {
        name = "X-Experience(Tier: 6)"
    },
    [77] = {
        name = "X-Experience(Tier: 7)"
    },
    [113] = {
        name = "X-Cooldown(Tier: 1)"
    },
    [79] = {
        name = "X-Cooldown(Tier: 2)"
    },
    [80] = {
        name = "X-Cooldown(Tier: 3)"
    },
    [81] = {
        name = "X-Cooldown(Tier: 4)"
    },
    [82] = {
        name = "X-Cooldown(Tier: 5)"
    },
    [83] = {
        name = "X-Cooldown(Tier: 6)"
    },
    [84] = {
        name = "X-Cooldown(Tier: 7)"
    }
}

local yhelds = {
    [1] = {
        name = "Y-Regeneration(Tier: 1)"
    },
    [2] = {
        name = "Y-Regeneration(Tier: 2)"
    },
    [3] = {
        name = "Y-Regeneration(Tier: 3)"
    },
    [4] = {
        name = "Y-Regeneration(Tier: 4)"
    },
    [5] = {
        name = "Y-Regeneration(Tier: 5)"
    },
    [6] = {
        name = "Y-Regeneration(Tier: 6)"
    },
    [7] = {
        name = "Y-Regeneration(Tier: 7)"
    },
    [8] = {
        name = "Y-Cure(Tier: 1)"
    },
    [9] = {
        name = "Y-Cure(Tier: 2)"
    },
    [10] = {
        name = "Y-Cure(Tier: 3)"
    },
    [11] = {
        name = "Y-Cure(Tier: 4)"
    },
    [12] = {
        name = "Y-Cure(Tier: 5)"
    },
    [13] = {
        name = "Y-Cure(Tier: 6)"
    },
    [14] = {
        name = "Y-Cure(Tier: 7)"
    }
}

-- orbs
local ORB_NAMES = {
    [1] = "Life Orb",
    [2] = "Leftovers",
    [3] = "Assault Vest",
    [4] = "Rocky Helmet",
    [5] = "Silk Scarf",
    [6] = "Mystic Water",
    [7] = "Soft Sand",
    [8] = "Charcoal",
    [9] = "Magnet",
    [10] = "Poison Barb",
    [11] = "Twisted Spoon",
    [12] = "Sharp Beak",
    [13] = "Spell Tag",
    [14] = "Black Belt",
    [15] = "Hard Stone",
    [16] = "Silver Powder",
    [17] = "Miracle Seed",
    [18] = "Never-Melt Ice",
    [19] = "Dragon Fang",
    [20] = "Black Glasses",
    [21] = "Metal Disc",
    [22] = "Bright Powder",
    [23] = "Wide Lens",
    [24] = "Gengarite",
    [25] = "Blastoisinite",
    [26] = "Charizardite Y",
    [27] = "Charizardite X",
    [28] = "Venusaurite",
    [29] = "Pidgeotite",
    [30] = "Kangaskhanite",
    [31] = "Alakazite",
    [32] = "Gyaradosite",
    [33] = "Beedrillite",
    [34] = "Pinsirite",
    [35] = "Amulet Coin",
}

-- ====== NATURES ======
local NATURE_MOD_PCT = 0.08
local NATURES = {
    Hardy = {},
    Docile = {},
    Serious = {},
    Bashful = {},
    Quirky = {},
    Adamant = {
        off = "up",
        spa = "down"
    },
    Brave = {
        off = "up",
        agi = "down"
    },
    Lonely = {
        off = "up",
        def = "down"
    },
    Naughty = {
        off = "up",
        vit = "down"
    },
    Modest = {
        spa = "up",
        off = "down"
    },
    Quiet = {
        spa = "up",
        agi = "down"
    },
    Mild = {
        spa = "up",
        def = "down"
    },
    Rash = {
        spa = "up",
        vit = "down"
    },
    Bold = {
        def = "up",
        off = "down"
    },
    Relaxed = {
        def = "up",
        agi = "down"
    },
    Impish = {
        def = "up",
        spa = "down"
    },
    Lax = {
        def = "up",
        vit = "down"
    },
    Calm = {
        vit = "up",
        off = "down"
    },
    Sassy = {
        vit = "up",
        agi = "down"
    },
    Careful = {
        vit = "up",
        spa = "down"
    },
    Gentle = {
        vit = "up",
        def = "down"
    },
    Timid = {
        agi = "up",
        off = "down"
    },
    Jolly = {
        agi = "up",
        spa = "down"
    },
    Hasty = {
        agi = "up",
        def = "down"
    },
    Naive = {
        agi = "up",
        vit = "down"
    }
}

local STAT_ABBR = {
    off = "Off",
    spa = "SpA",
    def = "Def",
    vit = "Vit",
    agi = "Agi"
}

local function parseTmSlots(raw)
    local list = {}
    if not raw or raw == "" then
        return list
    end
    for token in tostring(raw):gmatch("[^|]+") do
        local idxStr, name = token:match("^(%d+)=([^|]+)$")
        local idx = tonumber(idxStr)
        if idx and idx >= 1 and idx <= 12 and name and name ~= "" then
            table.insert(list, {
                idx = idx,
                name = name
            })
        end
    end
    table.sort(list, function(a, b)
        return a.idx < b.idx
    end)
    return list
end

local function tmListStringFromBall(ballUid)
    if not ballUid or ballUid <= 0 then
        return nil
    end
    local raw = getItemAttribute(ballUid, "tm_slots")
    local entries = parseTmSlots(raw)
    if #entries == 0 then
        return nil
    end
    local names = {}
    for _, e in ipairs(entries) do
        table.insert(names, e.name)
    end
    return "TMs aprendidos: " .. table.concat(names, ", ") .. "."
end

local function natureEffectLabel(natureName)
    local spec = NATURES[natureName or ""] or {}
    local order = {"off", "spa", "def", "vit", "agi"}
    local ups, downs = {}, {}
    for _, k in ipairs(order) do
        local flag = spec[k]
        if flag == "up" then
            table.insert(ups, "+" .. STAT_ABBR[k])
        end
        if flag == "down" then
            table.insert(downs, "-" .. STAT_ABBR[k])
        end
    end
    if #ups == 0 and #downs == 0 then
        return " (neutral)"
    end
    local parts = {}
    for _, s in ipairs(ups) do
        table.insert(parts, s)
    end
    for _, s in ipairs(downs) do
        table.insert(parts, s)
    end
    return " (" .. table.concat(parts, " ") .. ")"
end
-----

local function natureMultipliers(natureName)
    local spec = NATURES[natureName or ""] or {}
    local function m(flag)
        if flag == "up" then
            return 1 + NATURE_MOD_PCT
        end
        if flag == "down" then
            return 1 - NATURE_MOD_PCT
        end
        return 1
    end
    local offMul = m(spec.off)
    local spaMul = m(spec.spa)
    local defMul = m(spec.def)
    local vitMul = m(spec.vit)
    local agiMul = m(spec.agi)
    return offMul, spaMul, defMul, vitMul, agiMul
end
-- ====== /NATURES ======

local NPCBattle = {
    ["Brock"] = {
        artig = "He is",
        cidbat = "Pewter"
    },
    ["Misty"] = {
        artig = "She is",
        cidbat = "Cerulean"
    },
    ["Blaine"] = {
        artig = "He is",
        cidbat = "Cinnabar"
    },
    ["Sabrina"] = {
        artig = "She is",
        cidbat = "Saffron"
    },
    ["Kira"] = {
        artig = "She is",
        cidbat = "Viridian"
    },
    ["Koga"] = {
        artig = "He is",
        cidbat = "Fushcia"
    },
    ["Erika"] = {
        artig = "She is",
        cidbat = "Celadon"
    },
    ["Surge"] = {
        artig = "He is",
        cidbat = "Vermilion"
    }
}

local function heldLineFromBall(ballUid)
    if not ballUid or ballUid <= 0 then
        return nil
    end
    local heldx = getItemAttribute(ballUid, "heldx")
    local heldy = getItemAttribute(ballUid, "heldy")
    if heldx and heldy and xhelds[heldx] and yhelds[heldy] then
        return "Holding: " .. xhelds[heldx].name .. " and " .. yhelds[heldy].name .. ". "
    elseif heldx and xhelds[heldx] then
        return "Holding: " .. xhelds[heldx].name .. ". "
    elseif heldy and yhelds[heldy] then
        return "Holding: " .. yhelds[heldy].name .. ". "
    end
    return nil
end

local function getIVsFromBall(ballUid)
    if not ballUid or ballUid <= 0 then
        return nil
    end
    local rawOff = getItemAttribute(ballUid, "iv_off")
    local rawDef = getItemAttribute(ballUid, "iv_def")
    local rawSpa = getItemAttribute(ballUid, "iv_spa")
    local rawVit = getItemAttribute(ballUid, "iv_vit")
    local rawHp = getItemAttribute(ballUid, "iv_hp")
    local rawCdr = getItemAttribute(ballUid, "iv_cdr")
    if rawOff == nil and rawDef == nil and rawSpa == nil and rawVit == nil and rawHp == nil and rawCdr == nil then
        return nil
    end
    return {
        off = tonumber(rawOff or 0),
        def = tonumber(rawDef or 0),
        spa = tonumber(rawSpa or 0),
        vit = tonumber(rawVit or 0),
        hp = tonumber(rawHp or 0),
        cdr = tonumber(rawCdr or 0)
    }
end

local function fmtNumber(n, decimals)
    decimals = decimals or STAT_DECIMALS
    if COMPACT_UNITS then
        if n >= 1e6 then
            return string.format("%." .. decimals .. "fM", n / 1e6)
        elseif n >= 1e3 then
            return string.format("%." .. decimals .. "fK", n / 1e3)
        else
            return string.format("%." .. decimals .. "f", n)
        end
    else
        return string.format("%." .. decimals .. "f", n)
    end
end

local function renderStatsBlock(tag, off, def, spa, vit, agi)
    if STATS_STYLE == "multiline" then
        return table.concat({tag .. ":", "  - Off: " .. fmtNumber(off), "  - Def: " .. fmtNumber(def),
                             "  - SpA: " .. fmtNumber(spa), "  - Vit: " .. fmtNumber(vit),
                             "  - Agi: " .. fmtNumber(agi, 0)}, "\n")
    else
        return string.format("%s: Off %s | Def %s | SpA %s | Vit %s | Agi %s", tag, fmtNumber(off), fmtNumber(def),
            fmtNumber(spa), fmtNumber(vit), fmtNumber(agi, 0))
    end
end

local function statLineNoMasterLevel(pokeName, boost, heldx, orb, ivs, natureName, megaMul)
    local conf = getPokemonConfigByName(pokeName)
    if not conf then
        return nil
    end

    boost = tonumber(boost or 0) or 0
    heldx = tonumber(heldx or 0) or 0
    orb = tonumber(orb or 0) or 0
    megaMul = tonumber(megaMul or 1) or 1

    local DEF_BONUS = (type(DefBonus1) == "number" and DefBonus1) or 1
    local BOOST_BONUS = (type(BoostBonus1) == "number" and BoostBonus1) or 0
    local HASTE_ADD = (type(Hasteadd1) == "number" and Hasteadd1) or 0
    local VITA_MULT = (type(Vitality1) == "number" and Vitality1) or 1

    -- X-Attack
    local atkBase =
        (type(AtkBonus1) == "number" and AtkBonus1) or (type(XAttackBonus1) == "number" and XAttackBonus1) or 1

    local IV_PCT_PER_POINT = 0.0065

    local bonusdef = (heldx > 0 and heldx < 8) and DEF_BONUS or 1
    local bonusboost = (heldx > 35 and heldx < 43) and BOOST_BONUS or 0
    local hastespeed = (heldx > 98 and heldx < 106) and HASTE_ADD or 0
    local vitapoint = (heldx > 91 and heldx < 99) and VITA_MULT or 1
    local atkMul = (heldx > 7 and heldx < 15) and atkBase or 1

    -- Orbs visuais
    local orbOffMul, orbSpaMul, orbDefMul, orbVitMul, orbAgiMul = 1, 1, 1, 1, 1
    if orb == 1 then
        -- Life Orb
        orbOffMul, orbSpaMul = 2.00, 2.00
    elseif orb == 3 then
        -- Assault Vest (buffs e debuffs)
        orbDefMul, orbVitMul = 1.40, 1.25
        orbOffMul, orbSpaMul = 0.70, 0.70
        orbAgiMul = 0.80
    end

    -- Nature
    local nOff, nSpa, nDef, nVit, nAgi = natureMultipliers(natureName)

    local effBoost = boost * BOOST_UNIT
    local factor = 1 + effBoost

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

    off = off * megaMul
    def = def * megaMul
    spa = spa * megaMul
    vit = vit * megaMul
    agi = math.floor(agi * megaMul)

    return renderStatsBlock("Stats (no player level)", off, def, spa, vit, agi)
end
-- <<<

local function statLineFromStorages(creatureUid)
    local off = getOffense(creatureUid) or 0
    local def = getDefense(creatureUid) or 0
    local spa = getSpecialAttack(creatureUid) or 0
    local vit = getVitality(creatureUid) or 0
    local agi = getSpeed(creatureUid) or 0
    return renderStatsBlock("Stats (effective)", off, def, spa, vit, agi)
end

local function statLineFromConfig(name)
    local conf = getPokemonConfigByName(name)
    if not conf then
        return nil
    end
    local off = conf.offense or 0
    local def = conf.defense or 0
    local spa = conf.specialattack or 0
    local vit = conf.vitality or 0
    local agi = conf.agility or 0
    return renderStatsBlock("Stats (base config)", off, def, spa, vit, agi)
end

function onLook(cid, thing, position, lookDistance)
    local str = {}

    if not isCreature(thing.uid) then
        local iname = getItemInfo(thing.itemid)

        if isPokeball(thing.itemid) and getItemAttribute(thing.uid, "poke") then
            unLock(thing.uid)
            local lock     = getItemAttribute(thing.uid, "lock")
            local pokename = getItemAttribute(thing.uid, "poke")
            local heldx    = getItemAttribute(thing.uid, "heldx")
            local heldy    = getItemAttribute(thing.uid, "heldy")
            local boost    = getItemAttribute(thing.uid, "boost") or 0
            local ivs      = getIVsFromBall(thing.uid)
            local orb      = getItemAttribute(thing.uid, "orb")
            local nature   = getItemAttribute(thing.uid, "nature")

            -- Mega (na pokébola)
            local megaActive = (tonumber(getItemAttribute(thing.uid, "mega_active") or 0) == 1)
            local megaMul    = megaActive and 1.7 or 1.0

            table.insert(str, "You see " .. iname.article .. " " .. iname.name .. ".")
            if getItemAttribute(thing.uid, "unique") then
                table.insert(str, " It's an unique item.")
            end
            table.insert(str, "\nIt contains " .. getArticle(pokename) .. " " .. pokename .. ".\n")

            if lock and lock > 0 then
                table.insert(str, "It will unlock in " .. os.date("%d/%m/%y %X", lock) .. ".\n")
            end
            if boost > 0 then
                table.insert(str, "Boost level: +" .. boost .. ".\n")
            end
            if getItemAttribute(thing.uid, "nick") then
                table.insert(str, "It's nickname is: " .. getItemAttribute(thing.uid, "nick") .. ".\n")
            end

            if heldx and heldy and xhelds[heldx] and yhelds[heldy] then
                table.insert(str, "Holding: " .. xhelds[heldx].name .. " and " .. yhelds[heldy].name .. ". ")
            elseif heldx and xhelds[heldx] then
                table.insert(str, "Holding: " .. xhelds[heldx].name .. ". ")
            elseif heldy and yhelds[heldy] then
                table.insert(str, "Holding: " .. yhelds[heldy].name .. ". ")
            end
            -- Orb
            if orb and ORB_NAMES[orb] then
                table.insert(str, "Holding (Orb): " .. ORB_NAMES[orb] .. ". ")
            end
            -- Nature
            if nature and tostring(nature) ~= "" then
                table.insert(str, "\nNature: " .. tostring(nature) .. natureEffectLabel(nature) .. ".")
            else
                table.insert(str, "\nNature: (unset).")
            end

            if ivs then
                table.insert(str,
                    string.format("\nIVs: Off %d | Def %d | SpA %d | Vit %d | HP %d | Agi %d",
                        tonumber(ivs.off or 0), tonumber(ivs.def or 0), tonumber(ivs.spa or 0),
                        tonumber(ivs.vit or 0), tonumber(ivs.hp or 0), tonumber(ivs.cdr or 0)))
            end

            local tmLine = tmListStringFromBall(thing.uid)
            if tmLine then
                table.insert(str, tmLine .. "\n")
            end

            local line = statLineNoMasterLevel(pokename, boost, heldx, orb, ivs, nature, megaMul)
            if line then
                table.insert(str, "\n" .. line .. "\n")
            end
            if megaActive then
                table.insert(str, "(Mega Evolution ativa)\n")
            end

            local g = getItemAttribute(thing.uid, "gender")
            if g == SEX_MALE then
                table.insert(str, "It is male.")
            elseif g == SEX_FEMALE then
                table.insert(str, "It is female.")
            else
                table.insert(str, "It is genderless.")
            end

            doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
            return false
        end

        if string.find(iname.name, "fainted") or string.find(iname.name, "defeated") then
            table.insert(str, "You see a " .. string.lower(iname.name) .. ". ")
            if isContainer(thing.uid) then
                table.insert(str, "(Vol: " .. getContainerCap(thing.uid) .. ")")
            end
            table.insert(str, "\n")
            local g = getItemAttribute(thing.uid, "gender")
            if g == SEX_MALE then
                table.insert(str, "It is male.")
            elseif g == SEX_FEMALE then
                table.insert(str, "It is female.")
            else
                table.insert(str, "It is genderless.")
            end
            doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
            return false

        elseif isContainer(thing.uid) then
            if iname.name == "dead human" and getItemAttribute(thing.uid, "pName") then
                table.insert(str, "You see a dead human (Vol:" .. getContainerCap(thing.uid) .. "). ")
                table.insert(str, "You recognize " .. getItemAttribute(thing.uid, "pName") .. ". " ..
                    getItemAttribute(thing.uid, "article") .. " was killed by a ")
                table.insert(str, getItemAttribute(thing.uid, "attacker") .. ".")
            else
                table.insert(str, "You see " .. iname.article .. " " .. iname.name .. ". (Vol:" ..
                    getContainerCap(thing.uid) .. ").")
            end
            if getPlayerGroupId(cid) >= 4 and getPlayerGroupId(cid) <= 6 then
                table.insert(str, "\nItemID: [" .. thing.itemid .. "]")
                local pos = getThingPos(thing.uid)
                table.insert(str, "\nPosition: [X: " .. pos.x .. "][Y: " .. pos.y .. "][Z: " .. pos.z .. "]")
            end
            doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
            return false

        elseif getItemAttribute(thing.uid, "unique") then
            local p = getThingPos(thing.uid)
            table.insert(str, "You see ")
            if thing.type > 1 then
                table.insert(str, thing.type .. " " .. iname.plural .. ".")
            else
                table.insert(str, iname.article .. " " .. iname.name .. ".")
            end
            table.insert(str, " It's an unique item.\n" .. iname.description)
            if getPlayerGroupId(cid) >= 4 and getPlayerGroupId(cid) <= 6 then
                table.insert(str, "\nItemID: [" .. thing.itemid .. "]")
                table.insert(str, "\nPosition: [" .. p.x .. "][" .. p.y .. "][" .. p.z .. "]")
            end
            sendMsgToPlayer(cid, MESSAGE_INFO_DESCR, table.concat(str))
            return false
        else
            return true
        end
    end

    local npcname = getCreatureName(thing.uid)
    if ehNPC(thing.uid) and NPCBattle[npcname] then
        table.insert(str,
            "You see " .. npcname .. ". " .. NPCBattle[npcname].artig .. " leader of the gym from " ..
            NPCBattle[npcname].cidbat .. ".")
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
        return false
    end

    if getPlayerStorageValue(thing.uid, 697548) ~= -1 then
        table.insert(str, getPlayerStorageValue(thing.uid, 697548))
        local pos = getThingPos(thing.uid)
        if youAre[getPlayerGroupId(cid)] then
            table.insert(str, "\nPosition: [X: " .. pos.x .. "][Y: " .. pos.y .. "][Z: " .. pos.z .. "]")
        end
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
        return false
    end

    if not isPlayer(thing.uid) and not isMonster(thing.uid) then
        table.insert(str, "You see " .. getCreatureName(thing.uid) .. ".")
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
        return false
    end

    if isPlayer(thing.uid) then
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, getPlayerDesc(cid, thing.uid, false))
        return false
    end

    if getCreatureName(thing.uid) == "Evolution" then
        return false
    end

    if not isSummon(thing.uid) then
        local name = getCreatureName(thing.uid)
        table.insert(str, "You see a wild " .. string.lower(name) .. ".\n")
        table.insert(str, "Hit Points: " .. getCreatureHealth(thing.uid) .. " / " .. getCreatureMaxHealth(thing.uid) .. ".\n")
        table.insert(str, statLineFromStorages(thing.uid) .. "\n")
        if getPokemonGender(thing.uid) == SEX_MALE then
            table.insert(str, "It is male.")
        elseif getPokemonGender(thing.uid) == SEX_FEMALE then
            table.insert(str, "It is female.")
        else
            table.insert(str, "It is genderless.")
        end
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
        return false

    else
        local owner = getCreatureMaster(thing.uid)
        local name  = getCreatureName(thing.uid)
        local ball  = getPlayerSlotItem(owner, 8)
        local boost = (ball and ball.uid > 0) and (getItemAttribute(ball.uid, "boost") or 0) or 0
        local ivs   = (ball and ball.uid > 0) and getIVsFromBall(ball.uid) or nil
        local orb   = (ball and ball.uid > 0) and getItemAttribute(ball.uid, "orb") or nil
        local heldxBall = (ball and ball.uid > 0) and getItemAttribute(ball.uid, "heldx") or nil
        local nature= (ball and ball.uid > 0) and getItemAttribute(ball.uid, "nature") or nil

        local megaActive = (ball and ball.uid > 0) and (tonumber(getItemAttribute(ball.uid, "mega_active") or 0) == 1) or false
        local megaMul    = megaActive and 1.7 or 1.0

        if owner == cid then
            table.insert(str, "You see your " .. string.lower(name) .. ".")
            if boost > 0 then
                table.insert(str, "\nBoost level: +" .. boost .. ".")
            end
            local heldLine = (ball and ball.uid > 0) and heldLineFromBall(ball.uid) or nil
            if heldLine then
                table.insert(str, "\n" .. heldLine)
            end
            if orb and ORB_NAMES[orb] then
                table.insert(str, "\nHolding (Orb): " .. ORB_NAMES[orb] .. ".")
            end
            if nature and tostring(nature) ~= "" then
                table.insert(str, "\nNature: " .. tostring(nature) .. natureEffectLabel(nature) .. ".")
            end
            table.insert(str, "\nHit points: " .. getCreatureHealth(thing.uid) .. "/" .. getCreatureMaxHealth(thing.uid) .. ".")

            if IGNORE_PLAYER_LEVEL_ALWAYS then
                local line = statLineNoMasterLevel(name, boost, heldxBall, orb, ivs, nature, megaMul)
                if line then
                    table.insert(str, "\n" .. line)
                end
            else
                table.insert(str, "\n" .. statLineFromStorages(thing.uid))
            end
            if megaActive then
                table.insert(str, "\n(Mega Evolution ativa)")
            end

            if ivs then
                table.insert(str,
                    string.format("\nIVs: Off %d | Def %d | SpA %d | Vit %d | HP %d | CDR %d",
                        tonumber(ivs.off or 0), tonumber(ivs.def or 0), tonumber(ivs.spa or 0),
                        tonumber(ivs.vit or 0), tonumber(ivs.hp or 0), tonumber(ivs.cdr or 0)))
            end

            local tmLine = tmListStringFromBall(ball and ball.uid or 0)
            if tmLine then
                table.insert(str, "\n" .. tmLine)
            end

            table.insert(str, "\n" .. getPokemonHappinessDescription(thing.uid))
            doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))

        else
            table.insert(str, "You see a " .. string.lower(name) .. ".\nIt belongs to " .. getCreatureName(owner) .. ".")
            if IGNORE_PLAYER_LEVEL_ALWAYS and ball and ball.uid > 0 then
                if orb and ORB_NAMES[orb] then
                    table.insert(str, "\nHolding (Orb): " .. ORB_NAMES[orb] .. ".")
                end
                if nature and tostring(nature) ~= "" then
                    table.insert(str, "\nNature: " .. tostring(nature) .. natureEffectLabel(nature) .. ".")
                end
                local line = statLineNoMasterLevel(name, boost, heldxBall, orb, ivs, nature, megaMul)
                if line then
                    table.insert(str, "\n" .. line)
                end
                if megaActive then
                    table.insert(str, "\n(Mega Evolution ativa)")
                end
            else
                table.insert(str, "\n" .. statLineFromStorages(thing.uid))
            end
            doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, table.concat(str))
        end
        return false
    end

    return true
end
