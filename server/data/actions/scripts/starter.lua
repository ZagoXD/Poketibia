local starterpokes = {
  ["Charmander"] = {x = 51, y = 70, z = 7},
  ["Bulbasaur"]  = {x = 49, y = 70, z = 7},
  ["Squirtle"]   = {x = 47, y = 70, z = 7},
}

local btype = "normal"
local STORAGE_STARTER_TOWN  = 9658754
local STORAGE_ALREADY_TAKEN = 9658755

function onUse(cid, item, frompos, item2, topos)
  if getPlayerStorageValue(cid, STORAGE_ALREADY_TAKEN) == 1 then
    doPlayerSendTextMessage(cid, 27, "Você já recebeu seu Pokémon inicial.")
    return true
  end

  if getPlayerStorageValue(cid, STORAGE_STARTER_TOWN) ~= 1 then
    sendMsgToPlayer(cid, 27, "Fale com o Prof. Robert para escolher sua cidade inicial primeiro!")
    return true
  end

  local pokemon = ""
  for name, pos in pairs(starterpokes) do
    if isPosEqualPos(topos, pos) then
      pokemon = name
      break
    end
  end
  if pokemon == "" then
    return true
  end

  doPlayerSendTextMessage(cid, 27, "Você recebeu seu primeiro Pokémon, algumas pokébolas e poções para ajudar na jornada.")
  doPlayerSendTextMessage(cid, 27, "Não se esqueça de usar sua Pokédex!")

  addPokeToPlayer(cid, pokemon, 0, nil, btype, true)
  doPlayerAddItem(cid, 2394, 50)
  doPlayerAddItem(cid, 2391, 30)
  doPlayerAddItem(cid, 2392, 20)
  doPlayerAddItem(cid, 12345, 20)
  doPlayerAddItem(cid, 12344, 10)

  doSendMagicEffect(getThingPos(cid), 29)
  doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)))
  doSendMagicEffect(getThingPos(cid), 27)
  doSendMagicEffect(getThingPos(cid), 29)

  setPlayerStorageValue(cid, STORAGE_ALREADY_TAKEN, 1)
  return true
end
