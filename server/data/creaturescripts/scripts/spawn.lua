local shinys = {"Venusaur", "Charizard", "Blastoise", "Butterfree", "Beedrill", "Pidgeot", "Rattata", "Raticate",
                "Raichu", "Zubat", "Golbat", "Paras", "Parasect", "Venonat", "Venomoth", "Growlithe", "Arcanine",
                "Abra", "Alakazam", "Tentacool", "Tentacruel", "Farfetch'd", "Grimer", "Muk", "Gengar", "Onix",
                "Krabby", "Kingler", "Voltorb", "Electrode", "Cubone", "Marowak", "Hitmonlee", "Hitmonchan", "Tangela",
                "Horsea", "Seadra", "Scyther", "Jynx", "Electabuzz", "Pinsir", "Magikarp", "Gyarados", "Snorlax",
                "Dragonair", "Dratini"}
local raros = {"Dragonite"}

local function stripVisualPrefixes(name)
    name = tostring(name or "")
    local changed = true
    while changed do
        changed = false
        local n1 = name:gsub("^Shiny%s+", "")
        if n1 ~= name then name = n1; changed = true end
        local n2 = name:gsub("^Mega%s+", "")
        if n2 ~= name then name = n2; changed = true end
    end
    return name
end

local function ShinyName(cid)
    if not isCreature(cid) then return end
    if not HIDE_SHINY_PREFIX then return end

    local name = tostring(getCreatureName(cid))
    local newName = stripVisualPrefixes(name)

    if newName ~= name then
        doCreatureSetNick(cid, newName)
        if isMonster(cid) and name:find("^Shiny%s+") then
            doSetCreatureDropLoot(cid, false)
        end
    end
end

local function doSetRandomGender(cid)
    if not isCreature(cid) then
        return true
    end
    if isSummon(cid) then
        return true
    end
    local gender = 0
    local name = getCreatureName(cid)
    if not newpokedex[name] then
        return true
    end
    local rate = newpokedex[name].gender
    if rate == 0 then
        gender = 3
    elseif rate == 1000 then
        gender = 4
    elseif rate == -1 then
        gender = 0
    elseif math.random(1, 1000) <= rate then
        gender = 4
    else
        gender = 3
    end
    doCreatureSetSkullType(cid, gender)
end

local function doShiny(cid)
    if isCreature(cid) then
        if isSummon(cid) then
            return true
        end
        if getPlayerStorageValue(cid, 74469) >= 1 then
            return true
        end
        if getPlayerStorageValue(cid, 22546) >= 1 then
            return true
        end
        if isNpcSummon(cid) then
            return true
        end
        if getPlayerStorageValue(cid, 637500) >= 1 then
            return true
        end -- alterado v1.9

        if isInArray(shinys, getCreatureName(cid)) then -- alterado v1.9 \/
            chance = 1 -- 1% chance        
        elseif isInArray(raros, getCreatureName(cid)) then -- n coloquem valores menores que 0.1 !!
            chance = 0.5 -- 0.5% chance       
        else
            return true
        end
        if math.random(1, 1000) <= chance * 10 then
            doSendMagicEffect(getThingPos(cid), 18)
            local name, pos = "Shiny " .. getCreatureName(cid), getThingPos(cid)
            doRemoveCreature(cid)
            local shi = doCreateMonster(name, pos, false)
            setPlayerStorageValue(shi, 74469, 1)
        else
            setPlayerStorageValue(cid, 74469, 1)
        end -- /\
    else
        return true
    end
end

function onSpawn(cid)

    registerCreatureEvent(cid, "Experience")
    registerCreatureEvent(cid, "GeneralConfiguration")
    registerCreatureEvent(cid, "DirectionSystem")
    registerCreatureEvent(cid, "CastSystem")

    if isSummon(cid) then
        registerCreatureEvent(cid, "SummonDeath")
        return true
    end

    addEvent(doSetRandomGender, 5, cid)
    addEvent(doShiny, 10, cid)
    addEvent(ShinyName, 15, cid)
    addEvent(adjustWildPoke, 5, cid)

    return true
end
