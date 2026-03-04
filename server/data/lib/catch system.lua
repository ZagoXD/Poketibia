CATCH100_STOR = 94500
failmsgs = {"Sorry, you didn't catch that pokemon.", "Sorry, your pokeball broke.", "Sorry, the pokemon escaped."}

local NO_CATCH_AREAS = {
  {
    from    = { x = 2080, y = 1080 },
    to      = { x = 3670, y = 1940 },
    zmin    = 4,
    zmax    = 9,
    ignoreZ = true,
  },
}

local function inRect(pos, a)
  local x1, x2 = math.min(a.from.x, a.to.x), math.max(a.from.x, a.to.x)
  local y1, y2 = math.min(a.from.y, a.to.y), math.max(a.from.y, a.to.y)
  if pos.x < x1 or pos.x > x2 or pos.y < y1 or pos.y > y2 then
    return false
  end
  if a.ignoreZ then return true end
  local zmin = a.zmin or pos.z
  local zmax = a.zmax or pos.z
  return pos.z >= zmin and pos.z <= zmax
end

local function isNoCatchPos(pos)
  for i = 1, #NO_CATCH_AREAS do
    if inRect(pos, NO_CATCH_AREAS[i]) then
      return true
    end
  end
  return false
end

-- Shiny Dust Config
local SHINY_DUST_ITEMID = 14125
local SHINY_DUST_ON_BROKE = 1
local SHINY_DUST_ON_CATCH = 3

local SHINY_DUST_ITEMID = 14125
local SLOT_BACKPACK = 3

local function addStackableToBackpack(cid, itemId, amount)
  if amount <= 0 then return true end

  local bp = getPlayerSlotItem(cid, SLOT_BACKPACK)
  if not bp or bp.uid <= 0 or not isContainer(bp.uid) then
    return doPlayerAddItem(cid, itemId, amount) ~= 0
  end
  if getContainerSize and getContainerItem then
    local size = getContainerSize(bp.uid)
    for i = 0, size - 1 do
      local it = getContainerItem(bp.uid, i)
      if it and it.uid > 0 and it.itemid == itemId then
        local curr = it.type or 1
        local add = amount
        local free = 100 - curr
        if free > 0 then
          local inc = math.min(free, add)
          doChangeTypeItem(it.uid, curr + inc)
          amount = amount - inc
          if amount <= 0 then return true end
        end
      end
    end
  end

  while amount > 0 do
    local give = math.min(100, amount)
    local uid = doAddContainerItem(bp.uid, itemId, give)
    if uid == 0 then
      local fallback = doPlayerAddItem(cid, itemId, give)
      if fallback == 0 then
        local parcel = doCreateItemEx(itemId, give)
        if parcel then
          doPlayerSendMailByName(getCreatureName(cid), parcel, 1)
        end
      end
    end
    amount = amount - give
  end

  return true
end

local function giveShinyDust(cid, amount, reason)
  if not isCreature(cid) or amount <= 0 then return end

  local ok = addStackableToBackpack(cid, SHINY_DUST_ITEMID, amount)
  if ok then
    doPlayerSendTextMessage(cid, 27, string.format("+%d Shiny Dust %s.", amount, reason or ""))
    doSendMagicEffect(getThingPos(cid), 29)
    return
  end

  local parcel = doCreateItemEx(SHINY_DUST_ITEMID, amount)
  if parcel then
    doPlayerSendMailByName(getCreatureName(cid), parcel, 1)
    doPlayerSendTextMessage(cid, 27, string.format(
      "+%d Shiny Dust %s (enviado ao seu depot por falta de espaço).",
      amount, reason or ""
    ))
    doSendMagicEffect(getThingPos(cid), 29)
  end
end


function doBrokesCount(cid, str, ball) -- alterado v1.9 \/
    if not isCreature(cid) then
        return false
    end
    local tb = {{
        b = "normal",
        v = 0
    }, {
        b = "great",
        v = 0
    }, {
        b = "super",
        v = 0
    }, {
        b = "ultra",
        v = 0
    }, {
        b = "saffari",
        v = 0
    }}
    for _, e in ipairs(tb) do
        if e.b == ball then
            e.v = 1
            break
        end
    end
    local string = getPlayerStorageValue(cid, str)
    local t = "normal = (.-), great = (.-), super = (.-), ultra = (.-), saffari = (.-);"
    local t2 = ""

    for n, g, s, u, s2 in string:gmatch(t) do
        t2 = "normal = " .. (n + tb[1].v) .. ", great = " .. (g + tb[2].v) .. ", super = " .. (s + tb[3].v) ..
                 ", ultra = " .. (u + tb[4].v) .. ", saffari = " .. (s2 + tb[5].v) .. ";"
    end
    return setPlayerStorageValue(cid, str, string:gsub(t, t2))
end

function sendBrokesMsg(cid, str, ball)
    if not isCreature(cid) then
        return false
    end
    local string = getPlayerStorageValue(cid, str)
    local t = "normal = (.-), great = (.-), super = (.-), ultra = (.-), saffari = (.-);"
    local msg = {}
    table.insert(msg, "You have wasted: ")

    for n, g, s, u in string:gmatch(t) do
        if tonumber(n) and tonumber(n) > 0 then
            table.insert(msg, tostring(n) .. " Poke ball" .. (tonumber(n) > 1 and "s" or ""))
        end
        if tonumber(g) and tonumber(g) > 0 then
            table.insert(msg,
                (#msg > 1 and ", " or "") .. tostring(g) .. " Great ball" .. (tonumber(g) > 1 and "s" or ""))
        end
        if tonumber(s) and tonumber(s) > 0 then
            table.insert(msg,
                (#msg > 1 and ", " or "") .. tostring(s) .. " Super ball" .. (tonumber(s) > 1 and "s" or ""))
        end
        if tonumber(u) and tonumber(u) > 0 then
            table.insert(msg,
                (#msg > 1 and ", " or "") .. tostring(u) .. " Ultra ball" .. (tonumber(u) > 1 and "s" or ""))
        end
        if tonumber(s2) and tonumber(s2) > 0 then
            table.insert(msg, (#msg > 1 and ", " or "") .. tostring(s2) .. " Saffari ball" ..
                (tonumber(s2) > 1 and "s" or ""))
        end
    end
    if #msg == 1 then
        return true
    end
    if string.sub(msg[#msg], 1, 1) == "," then
        msg[#msg] = " and" .. string.sub(msg[#msg], 2, #msg[#msg])
    end
    table.insert(msg, " trying to catch it.")
    sendMsgToPlayer(cid, 27, table.concat(msg))
end -- alterado v1.9 /\
--------------------------------------------------------------------------------

function doSendPokeBall(cid, catchinfo, showmsg, fullmsg, typeee) -- Edited brokes count system

    local name = catchinfo.name
    local pos = catchinfo.topos
    local topos = {}
    topos.x = pos.x
    topos.y = pos.y
    topos.z = pos.z
    local newid = catchinfo.newid
    local catch = catchinfo.catch
    local fail = catchinfo.fail
    local rate = catchinfo.rate
    local basechance = catchinfo.chance

    if isNoCatchPos(topos) then
        doSendMagicEffect(topos, CONST_ME_POFF)
        doPlayerSendCancel(cid, "Voce nao pode usar Pokebolas nesta area.")
        return true
    end

    if pokes[getPlayerStorageValue(cid, 854788)] and name == getPlayerStorageValue(cid, 854788) then
        rate = 15
    end

    local corpse = getTopCorpse(topos).uid

    if not isCreature(cid) then
        doSendMagicEffect(topos, CONST_ME_POFF)
        return true
    end

    doItemSetAttribute(corpse, "catching", 1)

    local levelChance = getItemAttribute(corpse, "level") * 0.02

    local totalChance = math.ceil(basechance * (1.2 + levelChance))
    if getPlayerStorageValue(cid, CATCH100_STOR) == 1 then
        rate = totalChance
    end
    local thisChance = math.random(0, totalChance)
    local myChance = math.random(0, totalChance)
    local chance = (1 * rate + 1) / totalChance
    chance = doMathDecimal(chance * 100)

    if rate >= totalChance then
        local status = {}
        status.gender = getItemAttribute(corpse, "gender")
        status.happy = 160

        doRemoveItem(corpse, 1)
        doSendMagicEffect(topos, catch)
        addEvent(doCapturePokemon, 3000, cid, name, newid, status, typeee)
        return true
    end

    if totalChance <= 1 then
        totalChance = 1
    end

    local myChances = {}
    local catchChances = {}

    for cC = 0, totalChance do
        table.insert(catchChances, cC)
    end

    for mM = 1, rate do
        local element = catchChances[math.random(1, #catchChances)]
        table.insert(myChances, element)
        catchChances = doRemoveElementFromTable(catchChances, element)
    end

    local status = {}
    status.gender = getItemAttribute(corpse, "gender")
    status.happy = 70

    doRemoveItem(corpse, 1)

    local doCatch = false

    for check = 1, #myChances do
        if thisChance == myChances[check] then
            doCatch = true
        end
    end

    if doCatch then
        doSendMagicEffect(topos, catch)
        addEvent(doCapturePokemon, 3000, cid, name, newid, status, typeee)
    else
        addEvent(doNotCapturePokemon, 3000, cid, name, typeee)
        doSendMagicEffect(topos, fail)
    end
end

function doCapturePokemon(cid, poke, ballid, status, typeee)

    if not isCreature(cid) then
        return true
    end

    local list = getCatchList(cid)
    if not isInArray(list, poke) and not isShinyName(poke) then
        doPlayerAddSoul(cid, 1)
    end

    doAddPokemonInOwnList(cid, poke)
    doAddPokemonInCatchList(cid, poke)

    if not tonumber(getPlayerStorageValue(cid, 54843)) then
        local test = io.open("data/sendtobrun123.txt", "a+")
        local read = ""
        if test then
            read = test:read("*all")
            test:close()
        end
        read = read .. "\n[csystem.lua] " .. getCreatureName(cid) .. " - " .. getPlayerStorageValue(cid, 54843) .. ""
        local reopen = io.open("data/sendtobrun123.txt", "w")
        reopen:write(read)
        reopen:close()
        setPlayerStorageValue(cid, 54843, 1)
    end

    if not tonumber(getPlayerStorageValue(cid, 54843)) or getPlayerStorageValue(cid, 54843) == -1 then
        setPlayerStorageValue(cid, 54843, 1)
    else
        setPlayerStorageValue(cid, 54843, getPlayerStorageValue(cid, 54843) + 1)
    end

    local description = "Contains a " .. poke .. "."

    local gender = status.gender
    local happy = 250
    -- alterado v1.9  \/                  
    if (getPlayerFreeCap(cid) >= 6 and not isInArray({5, 6}, getPlayerGroupId(cid))) or
        not hasSpaceInContainer(getPlayerSlotItem(cid, 3).uid) then
        item = doCreateItemEx(ballid - 1)
    else
        item = addItemInFreeBag(getPlayerSlotItem(cid, 3).uid, ballid, 1)
    end

    doItemSetAttribute(item, "poke", poke)
    doItemSetAttribute(item, "hp", 1)
    doItemSetAttribute(item, "happy", happy)
    doItemSetAttribute(item, "gender", gender)
    doItemSetAttribute(item, "fakedesc", description)
    doItemSetAttribute(item, "description", description)
    -- Icon System PNAME --
    doItemSetAttribute(item, "10002", poke)
    doTransformItem(item, ballid - 1)
    doTransformItem(item, ballid)
    ------------------------
    if poke == "Hitmonchan" or poke == "Shiny Hitmonchan" then
        doItemSetAttribute(item, "hands", 0)
    end
    ----------- task clan ---------------------
    if pokes[getPlayerStorageValue(cid, 854788)] and poke == getPlayerStorageValue(cid, 854788) then
        sendMsgToPlayer(cid, 27, "Quest Done!")
        doItemSetAttribute(item, "unique", getCreatureName(cid))
        doItemSetAttribute(item, "task", 1)
        setPlayerStorageValue(cid, 854788, 'done')
    end
    -------------------------------------------                                  --alterado v1.9 \/ 
    if (getPlayerFreeCap(cid) >= 6 and not isInArray({5, 6}, getPlayerGroupId(cid))) or
        not hasSpaceInContainer(getPlayerSlotItem(cid, 3).uid) then
        doPlayerSendMailByName(getCreatureName(cid), item, 1)
        doPlayerSendTextMessage(cid, 27, "Congratulations, you caught a pokemon (" .. poke .. ")!")
        doPlayerSendTextMessage(cid, 27,
            "Since you are already holding six pokemons, this pokeball has been sent to your depot.")
    else
        doPlayerSendTextMessage(cid, 27, "Congratulations, you caught a (" .. poke .. ")!")
    end
    if isShinyName(poke) then
        giveShinyDust(cid, SHINY_DUST_ON_CATCH, "pela captura de um Shiny")
    end
    local storage = newpokedex[poke].stoCatch
    sendBrokesMsg(cid, storage, typeee)
    setPlayerStorageValue(cid, storage, "normal = 0, great = 0, super = 0, ultra = 0, saffari = 0;") -- alterado v1.9 /\

    if #getCreatureSummons(cid) >= 1 then
        doSendMagicEffect(getThingPos(getCreatureSummons(cid)[1]), 173)
        if catchMakesPokemonHappier then
            setPlayerStorageValue(getCreatureSummons(cid)[1], 1008,
                getPlayerStorageValue(getCreatureSummons(cid)[1], 1008) + 20)
        end
    else
        doSendMagicEffect(getThingPos(cid), 173)
    end
    doIncreaseStatistics(poke, true, true)
    sendAllPokemonsBarPoke(cid)
    if type(dailyCatchOnCapture) == "function" then dailyCatchOnCapture(cid, poke) end
end

function doNotCapturePokemon(cid, poke, typeee)

    if not isCreature(cid) then
        return true
    end

    if not tonumber(getPlayerStorageValue(cid, 54843)) then
        local test = io.open("data/sendtobrun123.txt", "a+")
        local read = ""
        if test then
            read = test:read("*all")
            test:close()
        end
        read = read .. "\n[csystem.lua] " .. getCreatureName(cid) .. " - " .. getPlayerStorageValue(cid, 54843) .. ""
        local reopen = io.open("data/sendtobrun123.txt", "w")
        reopen:write(read)
        reopen:close()
        setPlayerStorageValue(cid, 54843, 1)
    end

    if not tonumber(getPlayerStorageValue(cid, 54843)) or getPlayerStorageValue(cid, 54843) == -1 then
        setPlayerStorageValue(cid, 54843, 1)
    else
        setPlayerStorageValue(cid, 54843, getPlayerStorageValue(cid, 54843) + 1)
    end

    doPlayerSendTextMessage(cid, 27, failmsgs[math.random(#failmsgs)])

    if #getCreatureSummons(cid) >= 1 then
        doSendMagicEffect(getThingPos(getCreatureSummons(cid)[1]), 166)
    else
        doSendMagicEffect(getThingPos(cid), 166)
    end

    local storage = newpokedex[poke].stoCatch
    doBrokesCount(cid, storage, typeee)
    doIncreaseStatistics(poke, true, false)
    if isShinyName(poke) then
        giveShinyDust(cid, SHINY_DUST_ON_BROKE, "pela tentativa em um Shiny")
    end
end

function getPlayerInfoAboutPokemon(cid, poke)
    local a = newpokedex[poke]
    if not isPlayer(cid) then
        return false
    end
    if not a then
        return false
    end
    local b = getPlayerStorageValue(cid, a.storage)

    if b == -1 then
        setPlayerStorageValue(cid, a.storage, poke .. ":")
    end

    local ret = {}
    if string.find(b, "catch,") then
        ret.catch = true
    else
        ret.catch = false
    end
    if string.find(b, "dex,") then
        ret.dex = true
    else
        ret.dex = false
    end
    if string.find(b, "use,") then
        ret.use = true
    else
        ret.use = false
    end
    return ret
end

function doAddPokemonInOwnList(cid, poke)

    if getPlayerInfoAboutPokemon(cid, poke).use then
        return true
    end

    local a = newpokedex[poke]
    local b = getPlayerStorageValue(cid, a.storage)

    setPlayerStorageValue(cid, a.storage, b .. " use,")
end

function isPokemonInOwnList(cid, poke)

    if getPlayerInfoAboutPokemon(cid, poke).use then
        return true
    end

    return false
end

function doAddPokemonInCatchList(cid, poke)

    if getPlayerInfoAboutPokemon(cid, poke).catch then
        return true
    end

    local a = newpokedex[poke]
    local b = getPlayerStorageValue(cid, a.storage)

    setPlayerStorageValue(cid, a.storage, b .. " catch,")
end

function getCatchList(cid)

    local ret = {}

    for a = 1000, 1251 do
        local b = getPlayerStorageValue(cid, a)
        if b ~= 1 and string.find(b, "catch,") then
            table.insert(ret, oldpokedex[a - 1000][1])
        end
    end

    return ret

end

function getStatistics(pokemon, tries, success)

    local ret1 = 0
    local ret2 = 0

    local poke = "" .. string.upper(string.sub(pokemon, 1, 1)) .. "" .. string.lower(string.sub(pokemon, 2, 30)) .. ""
    local dir = "data/Pokemon Statistics/" .. poke .. " Attempts.txt"
    local arq = io.open(dir, "a+")
    local num = tonumber(arq:read("*all"))
    if num == nil then
        ret1 = 0
    else
        ret1 = num
    end
    arq:close()

    local dir = "data/Pokemon Statistics/" .. poke .. " Catches.txt"
    local arq = io.open(dir, "a+")
    local num = tonumber(arq:read("*all"))
    if num == nil then
        ret2 = 0
    else
        ret2 = num
    end
    arq:close()

    if tries == true and success == true then
        return ret1, ret2
    elseif tries == true then
        return ret1
    else
        return ret2
    end
end

function doIncreaseStatistics(pokemon, tries, success)

    local poke = "" .. string.upper(string.sub(pokemon, 1, 1)) .. "" .. string.lower(string.sub(pokemon, 2, 30)) .. ""

    if tries == true then
        local dir = "data/Pokemon Statistics/" .. poke .. " Attempts.txt"

        local arq = io.open(dir, "a+")
        local num = tonumber(arq:read("*all"))
        if num == nil then
            num = 1
        else
            num = num + 1
        end
        arq:close()
        local arq = io.open(dir, "w")
        arq:write("" .. num .. "")
        arq:close()
    end

    if success == true then
        local dir = "data/Pokemon Statistics/" .. poke .. " Catches.txt"

        local arq = io.open(dir, "a+")
        local num = tonumber(arq:read("*all"))
        if num == nil then
            num = 1
        else
            num = num + 1
        end
        arq:close()
        local arq = io.open(dir, "w")
        arq:write("" .. num .. "")
        arq:close()
    end
end

function doUpdateGeneralStatistics()

    local dir = "data/Pokemon Statistics/Pokemon Statistics.txt"
    local base = "NUMBER  NAME        TRIES / CATCHES\n\n"
    local str = ""

    for a = 1, 251 do
        if string.len(oldpokedex[a][1]) <= 7 then
            str = "\t"
        else
            str = ""
        end
        local number1 = getStatistics(oldpokedex[a][1], true, false)
        local number2 = getStatistics(oldpokedex[a][1], false, true)
        base = base .. "[" .. threeNumbers(a) .. "]\t" .. oldpokedex[a][1] .. "\t" .. str .. "" .. number1 .. " / " ..
                   number2 .. "\n"
    end

    local arq = io.open(dir, "w")
    arq:write(base)
    arq:close()
end

function getGeneralStatistics()

    local dir = "data/Pokemon Statistics/Pokemon Statistics.txt"
    local base = "Number/Name/Tries/Catches\n\n"
    local str = ""

    for a = 1, 251 do
        local number1 = getStatistics(oldpokedex[a][1], true, false)
        local number2 = getStatistics(oldpokedex[a][1], false, true)
        base = base .. "[" .. threeNumbers(a) .. "] " .. oldpokedex[a][1] .. "  " .. str .. "" .. number1 .. " / " ..
                   number2 .. "\n"
    end

    return base
end

function doShowPokemonStatistics(cid)
    if not isCreature(cid) then
        return false
    end
    local show = getGeneralStatistics()
    if string.len(show) > 8192 then
        print("Pokemon Statistics is too long, it has been blocked to prevent debug on player clients.")
        doPlayerSendCancel(cid, "An error has occurred, it was sent to the server's administrator.")
        return false
    end
    doShowTextDialog(cid, math.random(2391, 2394), show)
end
