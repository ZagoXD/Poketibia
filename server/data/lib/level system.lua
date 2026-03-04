-- function adjustWildPoke(cid, optionalLevel)
--     if isMonster(cid) and pokes[getCreatureName(cid)] then

--         local level = (optionalLevel and optionalLevel >= 1) and optionalLevel or getPokemonLevel(cid)

--         setPlayerStorageValue(cid, 1000, level)
--         setPlayerStorageValue(cid, 1001, pokes[getCreatureName(cid)].offense * level)
--         setPlayerStorageValue(cid, 1002, pokes[getCreatureName(cid)].defense)
--         setPlayerStorageValue(cid, 1003, pokes[getCreatureName(cid)].agility)
--         setPlayerStorageValue(cid, 1004, pokes[getCreatureName(cid)].vitality * level)
--         setPlayerStorageValue(cid, 1005, pokes[getCreatureName(cid)].specialattack * level)

--         doRegainSpeed(cid)
--         setCreatureMaxHealth(cid, (getVitality(cid) * HPperVITwild))
--         doCreatureAddHealth(cid, getCreatureMaxHealth(cid))

--         print(string.format(
--         "[GYM] uid=%d name=%s optional=%s -> level=%d (sto1000=%d) off=%d spa=%d vit=%d hp=%d",
--         cid,
--         getCreatureName(cid),
--         tostring(optionalLevel),
--         level,
--         getPlayerStorageValue(cid, 1000),
--         getOffense(cid),
--         getSpecialAttack(cid),
--         getVitality(cid),
--         getCreatureMaxHealth(cid)
--         ))

--         if pokes[getCreatureName(cid)].exp then
--             local exp = pokes[getCreatureName(cid)].exp * baseExpRate + pokes[getCreatureName(cid)].vitality * pokemonExpPerLevelRate
--             setPlayerStorageValue(cid, 1006, (exp * generalExpRate / 2) * 10)
--             if getPlayerStorageValue(cid, 22546) == 1 then
--                 setPlayerStorageValue(cid, 1006, 750)
--                 doSetCreatureDropLoot(cid, false)
--             end
--         end
--     end
-- end

function adjustWildPoke(cid, optionalLevel)
    if not (isMonster(cid) and pokes[getCreatureName(cid)]) then return true end

    -- Se alguém já setou um level alto (ginásio/elite) e a chamada veio sem optional,
    -- NÃO deixa o spawn.lua (nil) sobrescrever.
    local cur = getPlayerStorageValue(cid, 1000)
    if (not optionalLevel or optionalLevel < 1) and cur and cur >= 200 then
        return true
    end

    local level = (optionalLevel and optionalLevel >= 1) and optionalLevel or getPokemonLevel(cid)

    setPlayerStorageValue(cid, 1000, level)
    setPlayerStorageValue(cid, 1001, pokes[getCreatureName(cid)].offense * level)
    setPlayerStorageValue(cid, 1002, pokes[getCreatureName(cid)].defense)
    setPlayerStorageValue(cid, 1003, pokes[getCreatureName(cid)].agility)
    setPlayerStorageValue(cid, 1004, pokes[getCreatureName(cid)].vitality * level)
    setPlayerStorageValue(cid, 1005, pokes[getCreatureName(cid)].specialattack * level)

    doRegainSpeed(cid)
    setCreatureMaxHealth(cid, (getVitality(cid) * HPperVITwild))
    doCreatureAddHealth(cid, getCreatureMaxHealth(cid))

    if pokes[getCreatureName(cid)].exp then
        local exp = pokes[getCreatureName(cid)].exp * baseExpRate +
                    pokes[getCreatureName(cid)].vitality * pokemonExpPerLevelRate
        setPlayerStorageValue(cid, 1006, (exp * generalExpRate / 2) * 10)
        if getPlayerStorageValue(cid, 22546) == 1 then
            setPlayerStorageValue(cid, 1006, 750)
            doSetCreatureDropLoot(cid, false)
        end
    end

    return true
end


function getPokemonXMLOutfit(name) -- alterado v1.9 \/
    local path = "data/monster/pokes/Shiny/" .. name .. ".xml"
    local tpw = io.type(io.open(path))

    if not tpw then
        path = "data/monster/pokes/geracao 2/" .. name .. ".xml"
        tpw = io.type(io.open(path))
    end
    if not tpw then
        path = "data/monster/pokes/geracao 1/" .. name .. ".xml"
        tpw = io.type(io.open(path))
    end
    if not tpw then
        path = "data/monster/pokes/" .. name .. ".xml"
        tpw = io.type(io.open(path))
    end
    if not tpw then
        return print("[getPokemonXMLOutfit] Poke with name: " .. name .. " ins't in any paste on monster/pokes/") and 2
    end
    local arq = io.open(path, "a+")
    local txt = arq:read("*all")
    arq:close()
    local a, b = txt:find('look type="(.-)"')
    txt = string.sub(txt, a + 11, b - 1)
    return tonumber(txt)
end

function doEvolutionOutfit(cid, oldout, outfit)
    if not isCreature(cid) then
        return true
    end
    if getCreatureOutfit(cid).lookType == oldout then
        doSetCreatureOutfit(cid, {
            lookType = outfit
        }, -1)
    else
        doSetCreatureOutfit(cid, {
            lookType = oldout
        }, -1)
    end
end

function doSendEvolutionEffect(cid, pos, evolution, turn, ssj, evolve, f, h)
    if not isCreature(cid) then
        doSendAnimatedText(pos, "CANCEL", 215)
        return true
    end
    if evolve then
        doEvolvePokemon(getCreatureMaster(cid), {
            uid = cid
        }, evolution, 0, 0)
        return true
    end
    doSendMagicEffect(pos, 18)
    if ssj then
        sendSSJEffect(evo)
    end
    doEvolutionOutfit(cid, f, h)
    addEvent(doSendEvolutionEffect, math.pow(1900, turn / 20), cid, getThingPos(cid), evolution, turn - 1, turn == 19,
        turn == 2, f, h)
end

function sendSSJEffect(cid)
    if not isCreature(cid) then
        return true
    end
    local pos1 = getThingPos(cid)
    local pos2 = getThingPos(cid)
    pos2.x = pos2.x + math.random(-1, 1)
    pos2.y = pos2.y - math.random(1, 2)
    doSendDistanceShoot(pos1, pos2, 37)
    addEvent(sendSSJEffect, 45, cid)
end

function sendFinishEvolutionEffect(cid, alternate)
    if not isCreature(cid) then
        return true
    end
    local pos1 = getThingPos(cid)

    if alternate then
        local pos = {
            [1] = {-2, 0},
            [2] = {-1, -1},
            [3] = {0, -2},
            [4] = {1, -1},
            [5] = {2, 0},
            [6] = {1, 1},
            [7] = {0, 2},
            [8] = {-1, 1}
        }
        for a = 1, 8 do
            local pos2 = getThingPos(cid)
            pos2.x = pos2.x + pos[a][1]
            pos2.y = pos2.y + pos[a][2]
            local pos = getThingPos(cid)
            doSendDistanceShoot(pos2, pos, 37)
            addEvent(doSendDistanceShoot, 300, pos, pos2, 37)
        end
    else
        for a = 0, 3 do
            doSendDistanceShoot(pos1, getPosByDir(pos1, a), 37)
        end
        for a = 4, 7 do
            addEvent(doSendDistanceShoot, 600, pos1, getPosByDir(pos1, a), 37)
        end
    end
end

function doEvolvePokemon(cid, item2, theevo, stone1, stone2)

    if not isCreature(cid) then
        return true
    end

    if not pokes[theevo] or not pokes[theevo].offense then
        doReturnPokemon(cid, item2.uid, getPlayerSlotItem(cid, 8),
            pokeballs[getPokeballType(getPlayerSlotItem(cid, 8).itemid)].effect, false, true)
        return true
    end

    local owner = getCreatureMaster(item2.uid)
    local pokeball = getPlayerSlotItem(cid, 8)
    local description = "Contains a " .. theevo .. "."
    local pct = getCreatureHealth(item2.uid) / getCreatureMaxHealth(item2.uid)

    doItemSetAttribute(pokeball.uid, "hp", pct)

    doItemSetAttribute(pokeball.uid, "poke", theevo)
    doItemSetAttribute(pokeball.uid, "description", "Contains a " .. theevo .. ".")

    doPlayerSendTextMessage(cid, 27,
        "Congratulations! Your " .. getPokeName(item2.uid) .. " evolved into a " .. theevo .. "!")

    doSendMagicEffect(getThingPos(item2.uid), 18)
    doTransformItem(getPlayerSlotItem(cid, 7).uid, fotos[theevo])
    doSendMagicEffect(getThingPos(cid), 173)

    local oldpos = getThingPos(item2.uid)
    local oldlod = getCreatureLookDir(item2.uid)
    doRemoveCreature(item2.uid)

    doSummonMonster(cid, theevo)
    local pk = getCreatureSummons(cid)[1]

    doTeleportThing(pk, oldpos, false)
    doCreatureSetLookDir(pk, oldlod)

    sendFinishEvolutionEffect(pk, true)
    addEvent(sendFinishEvolutionEffect, 550, pk, true)
    addEvent(sendFinishEvolutionEffect, 1050, pk)

    doPlayerRemoveItem(cid, stone1, 1)
    doPlayerRemoveItem(cid, stone2, 1)

    doAddPokemonInOwnList(cid, theevo)

    local happy = getItemAttribute(pokeball.uid, "happy")

    doItemSetAttribute(pokeball.uid, "happy", happy + happyGainedOnEvolution)

    if happy + happyGainedOnEvolution > 255 then
        doItemSetAttribute(pokeball.uid, "happy", 255)
    end

    adjustStatus(pk, pokeball.uid, true, false)

    sendAllPokemonsBarPoke(cid)

    if useKpdoDlls then
        doUpdateMoves(cid)
    end
end

function doMathDecimal(number, casas)

    if math.floor(number) == number then
        return number
    end

    local c = casas and casas + 1 or 3

    for a = 0, 10 do
        if math.floor(number) < math.pow(10, a) then
            local str = string.sub("" .. number .. "", 1, a + c)
            return tonumber(str)
        end
    end

    return number
end

function doAdjustWithDelay(cid, pk, health, vit, status)
    if isCreature(cid) then
        adjustStatus(pk, getPlayerSlotItem(cid, 8).uid, health, vir, status)
    end
end

-- ===================== IV SYSTEM  =====================

local IV_MIN, IV_MAX = 0, 31

local IV_PCT_PER_POINT = 0.0065

local HP_IV_PCT_PER_POINT = 0.003

local function iv_roll()
    return math.random(IV_MIN, IV_MAX)
end

-- ===== Cooldown por IV/Held =====
local STORAGE_CDR_MULT = 1015
local CDR_IV_PCT_PER_POINT = 0.0065
-- local CDR_MIN_MULT = 0.50
local CDR_MIN_MULT = nil

local function getHeldCdrBonus(tier)
    local t = {
        [113] = (type(XCooldownBonus1) == "number" and XCooldownBonus1) or 0,
        [79] = (type(XCooldownBonus2) == "number" and XCooldownBonus2) or 0,
        [80] = (type(XCooldownBonus3) == "number" and XCooldownBonus3) or 0,
        [81] = (type(XCooldownBonus4) == "number" and XCooldownBonus4) or 0,
        [82] = (type(XCooldownBonus5) == "number" and XCooldownBonus5) or 0,
        [83] = (type(XCooldownBonus6) == "number" and XCooldownBonus6) or 0,
        [84] = (type(XCooldownBonus7) == "number" and XCooldownBonus7) or 0
    }
    return t[tier] or 0
end

local function ensureIVsOnBall(ballUid)
    local hasSet = getItemAttribute(ballUid, "iv_set")
    if not hasSet then
        doItemSetAttribute(ballUid, "iv_off", iv_roll())
        doItemSetAttribute(ballUid, "iv_spa", iv_roll())
        doItemSetAttribute(ballUid, "iv_def", iv_roll())
        doItemSetAttribute(ballUid, "iv_vit", iv_roll())
        doItemSetAttribute(ballUid, "iv_hp", iv_roll())
        doItemSetAttribute(ballUid, "iv_cdr", iv_roll())
        doItemSetAttribute(ballUid, "iv_set", 1)
        return
    end

    if getItemAttribute(ballUid, "iv_cdr") == nil then
        doItemSetAttribute(ballUid, "iv_cdr", iv_roll())
    end
end

local function readIV(ballUid, name)
    return tonumber(getItemAttribute(ballUid, name)) or 0
end

local function ivMul(ivPoints)
    return 1 + (ivPoints * IV_PCT_PER_POINT)
end

-- ====== NATURES (defs + helpers) ======
local NATURE_MOD_PCT = 0.08 -- ~8% buff/debuff

-- Tabela de natures (Gen 3) — neutras e com up/down
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

local NATURE_LIST = {"Hardy", "Docile", "Serious", "Bashful", "Quirky", "Adamant", "Brave", "Lonely", "Naughty",
                     "Modest", "Quiet", "Mild", "Rash", "Bold", "Relaxed", "Impish", "Lax", "Calm", "Sassy", "Careful",
                     "Gentle", "Timid", "Jolly", "Hasty", "Naive"}

function ensureNatureOnBall(item)
    if not item or item <= 0 then
        return
    end
    local cur = getItemAttribute(item, "nature")
    if cur and tostring(cur) ~= "" then
        return
    end
    local idx = math.random(1, #NATURE_LIST)
    doItemSetAttribute(item, "nature", NATURE_LIST[idx])
end

function natureMultipliers(natureName)
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
    local nOff = m(spec.off)
    local nSpa = m(spec.spa)
    local nDef = m(spec.def)
    local nVit = m(spec.vit)
    local nAgi = m(spec.agi)
    local nHp = 1
    local nCdrFromAgi = 1 / nAgi
    return nOff, nSpa, nDef, nVit, nAgi, nHp, nCdrFromAgi
end
-- ====== /NATURES ======

function adjustStatus(pk, item, health, vite, conditions)
    if not isCreature(pk) then
        return true
    end

    local gender = getItemAttribute(item, "gender") and getItemAttribute(item, "gender") or 0
    addEvent(doCreatureSetSkullType, 10, pk, gender)

    -- >>> IVs: gerar na primeira vez
    ensureIVsOnBall(item)
    local IV_OFF = readIV(item, "iv_off")
    local IV_SPA = readIV(item, "iv_spa")
    local IV_DEF = readIV(item, "iv_def")
    local IV_VIT = readIV(item, "iv_vit")
    local IV_HP = readIV(item, "iv_hp")
    -- <<<

    -- >>> Nature: garantir e ler
    ensureNatureOnBall(item)
    local NATURE = tostring(getItemAttribute(item, "nature") or "")
    local nOffMul, nSpaMul, nDefMul, nVitMul, nAgiMul, nHpMul, nCdrMulFromAgi = natureMultipliers(NATURE)
    -- <<<

    -- Defense
    local Tier = tonumber(getItemAttribute(item, "heldx")) or 0
    local DEF_BONUS = (type(DefBonus1) == "number" and DefBonus1) or 1
    local bonusdef = (Tier > 0 and Tier < 8) and DEF_BONUS or 1

    -- X-Attack
    local atkBase =
        (type(AtkBonus1) == "number" and AtkBonus1) or (type(XAttackBonus1) == "number" and XAttackBonus1) or 1
    local atkMul = (Tier > 7 and Tier < 15) and atkBase or 1

    -- Boost
    local BOOST_BONUS = (type(BoostBonus1) == "number" and BoostBonus1) or 0
    local bonusboost = (Tier > 35 and Tier < 43) and BOOST_BONUS or 0

    -- Haste
    local HASTE_ADD = (type(Hasteadd1) == "number" and Hasteadd1) or 0
    local hastespeed = (Tier > 98 and Tier < 106) and HASTE_ADD or 0

    -- Vitality
    local VITA_MULT = (type(Vitality1) == "number" and Vitality1) or 1
    local vitapoint = (Tier > 91 and Tier < 99) and VITA_MULT or 1

    local name = getCreatureName(pk)
    local baseOff = pokes[name].offense
    local baseDef = pokes[name].defense
    local baseAgi = pokes[name].agility
    local baseVit = pokes[name].vitality
    local baseSpA = pokes[name].specialattack
    local b = getPokemonBoost(pk)
    local effBoost = b * BOOST_UNIT
    local scale = getMasterLevel(pk) + effBoost

    -- Multiplicadores vindos de IV
    local mulOff = ivMul(IV_OFF)
    local mulDef = ivMul(IV_DEF)
    local mulVit = ivMul(IV_VIT)
    local mulSpA = ivMul(IV_SPA)

    ----------CDR
    local iv_cdr = tonumber(getItemAttribute(item, "iv_cdr") or 0)
    if iv_cdr < 0 then
        iv_cdr = 0
    elseif iv_cdr > 31 then
        iv_cdr = 31
    end
    local cdr_from_iv = iv_cdr * CDR_IV_PCT_PER_POINT
    local cdr_from_held = getHeldCdrBonus(Tier)
    local total_cdr = 1 - ((1 - cdr_from_iv) * (1 - cdr_from_held))
    local cdr_mult = 1 - total_cdr

    cdr_mult = cdr_mult * nCdrMulFromAgi

    if cdr_mult < 0 then
        cdr_mult = 0
    end

    setPlayerStorageValue(pk, STORAGE_CDR_MULT, cdr_mult)
    doItemSetAttribute(item, "cdr_mult", cdr_mult)
    -- <<< CDR

    -- Orbs System
    local ORB = tonumber(getItemAttribute(item, "orb") or 0) or 0
    local lifeOrbMul = (ORB == 1 and 2.00) or 1

    -- Assault Vest (buffs + debuffs)
    local vestDefMul, vestVitMul, vestHpMul = 1, 1, 1
    local vestOffMul, vestSpaMul, vestAgiMul = 1, 1, 1
    if ORB == 3 then
        vestDefMul = 1.40
        vestVitMul = 1.25
        vestHpMul = 1.20
        vestOffMul = 0.70
        vestSpaMul = 0.70
        vestAgiMul = 0.80
    end

    local megaMul = 1.0
    do
        local mActive = tonumber(getItemAttribute(item, "mega_active") or 0) or 0
        if mActive == 1 then
            megaMul = 1.7
        end
    end

    setPlayerStorageValue(pk, 1001, ((((baseOff * scale) + bonusboost) * atkMul) * mulOff * lifeOrbMul * vestOffMul *
        nOffMul) * megaMul)

    setPlayerStorageValue(pk, 1002, ((((baseDef * bonusdef) + bonusboost) * mulDef) * vestDefMul * nDefMul) * megaMul)

    setPlayerStorageValue(pk, 1003, math.floor(((((baseAgi) * vestAgiMul) * nAgiMul) + hastespeed) * megaMul))

    setPlayerStorageValue(pk, 1004,
        (((((baseVit * scale) + bonusboost) * vitapoint) * mulVit) * vestVitMul * nVitMul) * megaMul)

    setPlayerStorageValue(pk, 1005, ((((baseSpA * scale) + bonusboost) * atkMul) * mulSpA * lifeOrbMul * vestSpaMul *
        nSpaMul) * megaMul)

    if vite == true then
        local pct = getCreatureHealth(pk) / getCreatureMaxHealth(pk)

        local vit = getVitality(pk)
        local baseHP = HPperVITsummon * vit
        baseHP = math.floor(baseHP * vestHpMul * nHpMul)

        local hpExtra = math.floor(baseHP * (IV_HP * HP_IV_PCT_PER_POINT))
        local newMax = baseHP + hpExtra
        setCreatureMaxHealth(pk, baseHP + hpExtra)
        doCreatureAddHealth(pk, (baseHP + hpExtra) * pct)
        doItemSetAttribute(item, "last_maxhp", newMax)
    end

    doRegainSpeed(pk)

    local nick = getItemAttribute(item, "poke")
    if isGhostPokemon(pk) then
        setPlayerStorageValue(pk, 8981, 1)
        updateGhostWalk(pk)
    end

    local function stripVisualPrefixes(name)
        name = tostring(name or "")
        local changed = true
        while changed do
            changed = false
            local n1 = name:gsub("^Shiny%s+", "")
            if n1 ~= name then
                name = n1;
                changed = true
            end
            local n2 = name:gsub("^Mega%s+", "")
            if n2 ~= name then
                name = n2;
                changed = true
            end
        end
        return name
    end

    if getItemAttribute(item, "nick") then
        nick = getItemAttribute(item, "nick")
    else
        if HIDE_SHINY_PREFIX then
            nick = stripVisualPrefixes(nick)
        end
    end

    setPlayerStorageValue(pk, 1007, nick)
    doCreatureSetNick(pk, nick)

    if not getItemAttribute(item, "happy") then
        doItemSetAttribute(item, "happy", 120)
    end
    if not getItemAttribute(item, "hunger") then
        doItemSetAttribute(item, "hunger", 5)
    end

    local happy = getItemAttribute(item, "happy")
    if happy < 0 then
        happy = 1
    end
    setPlayerStorageValue(pk, 1008, happy)
    setPlayerStorageValue(pk, 1009, getItemAttribute(item, "hunger"))

    if health == true then
        local mh = getCreatureMaxHealth(pk)
        local rd = 1 - (tonumber(getItemAttribute(item, "hp")))
        doCreatureAddHealth(pk, mh)
        doCreatureAddHealth(pk, -(mh * rd))
    end

    if isSummon(pk) and conditions then
        local burn = getItemAttribute(item, "burn")
        if burn and burn >= 0 then
            local ret = {
                id = pk,
                cd = burn,
                check = false,
                damage = getItemAttribute(item, "burndmg"),
                cond = "Burn"
            }
            addEvent(doCondition2, 3500, ret)
        end
        local poison = getItemAttribute(item, "poison")
        if poison and poison >= 0 then
            local ret = {
                id = pk,
                cd = poison,
                check = false,
                damage = getItemAttribute(item, "poisondmg"),
                cond = "Poison"
            }
            addEvent(doCondition2, 1500, ret)
        end
        for i = 1, 3 do
            local buff = getItemAttribute(item, "Buff" .. i)
            if buff and buff >= 0 then
                local ret = {
                    id = pk,
                    cd = buff,
                    eff = getItemAttribute(item, "Buff" .. i .. "eff"),
                    check = false,
                    buff = getItemAttribute(item, "Buff" .. i .. "skill"),
                    first = true,
                    attr = "Buff" .. i
                }
                doCondition2(ret)
            end
        end
    end

    if getItemAttribute(item, "boost") and getItemAttribute(item, "boost") >= 50 and getItemAttribute(item, "aura") then
        sendAuraEffect(pk, auraSyst[getItemAttribute(item, "aura")])
    end

    if getPlayerStorageValue(getCreatureMaster(pk), 6598754) >= 1 then
        setPlayerStorageValue(pk, 6598754, 1)
    elseif getPlayerStorageValue(getCreatureMaster(pk), 6598755) >= 1 then
        setPlayerStorageValue(pk, 6598755, 1)
    end

    return true
end

function getOffense(cid)
    if not isCreature(cid) then
        return 0
    end
    return tonumber(getPlayerStorageValue(cid, 1001))
end

function getDefense(cid)
    if not isCreature(cid) then
        return 0
    end
    return tonumber(getPlayerStorageValue(cid, 1002))
end

function getSpeed(cid)
    if not isCreature(cid) then
        return 0
    end
    return tonumber(getPlayerStorageValue(cid, 1003))
end

function getVitality(cid)
    if not isCreature(cid) then
        return 0
    end
    return tonumber(getPlayerStorageValue(cid, 1004))
end

function getSpecialAttack(cid)
    if not isCreature(cid) then
        return 0
    end
    return tonumber(getPlayerStorageValue(cid, 1005))
end

function getHappiness(cid)
    if not isCreature(cid) then
        return 0
    end
    return tonumber(getPlayerStorageValue(cid, 1008))
end

function getSpecialDefense(cid)
    if not isCreature(cid) then
        return 0
    end
    return getSpecialAttack(cid) * 0.85 + getDefense(cid) * 0.2
end

function getPokemonLevel(cid, dex)
    if not isCreature(cid) then
        return 0
    end
    if not dex then -- alterado v1.9
        if ehMonstro(cid) and getPlayerStorageValue(cid, 1000) > 0 then
            return getPlayerStorageValue(cid, 1000)
        elseif ehMonstro(cid) then
            return pokes[getCreatureName(cid)].wildLvl
        end
    end
    return pokes[getCreatureName(cid)].level
end

function getPokemonLevelByName(name)
    return pokes[name] and pokes[name].level or 0 -- alterado v1.9
end

function getMasterLevel(poke)
    if not isSummon(poke) then
        return 0
    end
    return getPlayerLevel(getCreatureMaster(poke))
end

function getPokemonBoost(poke)
    if not isSummon(poke) then
        return 0
    end
    return getItemAttribute(getPlayerSlotItem(getCreatureMaster(poke), 8).uid, "boost") or 0
end

function getPokeballBoost(ball)
    if not isPokeball(ball.itemid) then
        return 0
    end -- alterado v1.8
    return getItemAttribute(ball.uid, "boost") or 0
end

function getPokeName(cid)
    if not isSummon(cid) then
        return getCreatureName(cid)
    end
    if getCreatureName(cid) == "Evolution" then
        return getPlayerStorageValue(cid, 1007)
    end

    local item = getPlayerSlotItem(getCreatureMaster(cid), 8)
    if getItemAttribute(item.uid, "nick") then
        return getItemAttribute(item.uid, "nick")
    end

    if HIDE_SHINY_PREFIX and tostring(getCreatureName(cid)):find("^Shiny%s+") then
        local newName = tostring(getCreatureName(cid)):gsub("^Shiny%s+", "")
        return newName
    end
    return getCreatureName(cid)
end

function getPokeballName(item, truename)
    if not truename and getItemAttribute(item, "nick") then
        return getItemAttribute(item, "nick")
    end
    return getItemAttribute(item, "poke")
end

function getPokemonName(cid)
    return getCreatureName(cid)
end

function getPokemonGender(cid) -- alterado v1.9
    return getCreatureSkullType(cid)
end

function setPokemonGender(cid, gender)
    if isCreature(cid) and gender then -- alterado v1.8
        doCreatureSetSkullType(cid, gender)
        return true
    end
    return false
end

function getWildPokemonExp(cid)
    return getPlayerStorageValue(cid, 1006)
end
