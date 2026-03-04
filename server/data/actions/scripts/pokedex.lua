local rate = 20

function onUse(cid, item, fromPos, item2, toPos)

    if not isCreature(item2.uid) then
        return true
    end

    local poke = getCreatureName(item2.uid)

    if isMonster(item2.uid) then
        local poke = getCreatureName(item2.uid)

        local info = getPlayerInfoAboutPokemon(cid, poke)
        local entry = newpokedex[poke]
        if type(info) ~= "table" or not entry then
            doPlayerSendCancel(cid, "Nao e possivel utilizar a Pokedex nesse pokemon.")
            return true
        end

        local myball = 0
        if isSummon(item2.uid) then
            myball = getPlayerSlotItem(getCreatureMaster(item2.uid), 8)
        end

        if not info.dex then
            local exp = entry.level * rate
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE,
                "You have unlocked " .. poke .. " in your pokedex!")
            doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You have gained " .. exp .. " experience points.")
            doSendMagicEffect(getThingPos(cid), 210)
            doPlayerAddExperience(cid, exp)
            doAddPokemonInDexList(cid, poke)
        else
            doShowPokedexRegistration(cid, item2, myball)
        end
        return true
    end

    if not isPlayer(item2.uid) then
        return true
    end

    local kanto = 0
    local johto = 0
    -- alterado v1.7 \/\/
    for i = 1, #oldpokedex do
        if getPlayerInfoAboutPokemon(item2.uid, oldpokedex[i][1]).dex then
            if i <= 151 then
                kanto = kanto + 1
            elseif i >= 209 then
                johto = johto + 1
            end
        end
    end -- alterado v1.6

    local player = getRecorderPlayer(toPos, cid)

    if cid == player then
        doPlayerSendTextMessage(cid, 27, "You has unlocked " .. kanto .. " kanto's and " .. johto ..
            " johto's pok�mons until now.")
        doPlayerSetVocation(cid, 9) -- alterado v1.6
        openChannelDialog(cid)
    end

    return true
end
