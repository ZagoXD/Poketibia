local a = {
  [11638] = {pokemons = {"Magnemite","Slowpoke", "Seel", "Eevee", "Squirtle", "Grimer", "Gastly", "Drowzee", "Voltorb", "Cubone", "Koffing", "Goldeen", "Staryu", "Vulpix", "Bulbasaur", "Charmander", "Butterfree", "Beedrill", "Kakuna", "Metapod", "Pidgeotto", "Spearow", "Raticate", "Ekans", "Abra", "Mankey", "Sandshrew", "Nidoranfe", "Nidoranma", "Zubat", "Diglett", "Venonat", "Meowth",
  "Poliwag", "Growlithe", "Machop", "Weepinbell", "Ponyta", "Geodude", "Psyduck", "Tentacool", "Chikorita", "Cyndaquil", "Totodile", "Pichu", "Cleffa", "Iglybuff", "Mareep", "Wooper", "Togepi", "Hoothoot", "Sentret", "Slugma", "Marill", "Poliwhril", "Chinchou", "Natu", "Ledyba", "Skiploom", "Snubbull", "Houndour", "Magby", "Elekid", "Smoochum", "Pineco"}},
  [11639] = {pokemons = {"Clefairy", "Jigglypuff", "Kabuto", "Omanyte", "Arbok", "Pikachu", "Nidorina", "Nidorino", "Dodrio", "Golbat", "Parasect", "Venomoth", "Dugtrio", "Persian", "Yanma", "Machoke", "Slowbro", "Graveler", "Farfetch'd", "Haunter", "Kadabra", "Kingler", "Electrode", "Rhyhorn", "Seadra", "Weezing", "Seaking", "Tauros", "Eevee", "Charmeleon", "Wartortle",
  "Ivysaur", "Bayleef", "Croconaw", "Dratini", "Quilava", "Furret", "Ariados", "Ledian", "Dunsparce", "Shuckle", "Flaaffy", "Qwilfish", "Aipom", "Larvitar", "Shuppet", "Spheal", "Smoochum", "Meditite", "Nuzleaf", "Magby", "Swablu", "Snorunt", "Corphish", "Aron", "Taillow", "Numel", "Spoink", "Elekid", "Electrike", "Slakoth", "Marshtomp", "Grovyle", "Gligar"}},
  [11640] = {pokemons = {"Politoed", "Magcargo", "Noctowl", "Poliwrath", "Nidoking", "Pidgeot", "Sandslash", "Ninetales", "Vileplume",
  "Primeape", "Nidoqueen", "Granbull", "Jumpluff", "Golduck", "Kadabra", "Rapidash", "Azumarill", "Murkrow",
  "Clefable", "Wigglytuff", "Dewgong", "Onix", "Cloyster", "Hypno", "Exeggutor", "Marowak",
  "Hitmonchan", "Quagsire", "Stantler", "Xatu", "Hitmonlee", "Bellossom", "Lanturn", "Pupitar", "Smeargle",
  "Lickitung", "Golem", "Chansey", "Tangela", "Mr. Mime", "Pinsir", "Espeon", "Umbreon", "Vaporeon", "Jolteon",
  "Flareon", "Porygon", "Dragonair", "Hitmontop", "Octillery", "Sneasel", "Tyrogue"}},
  [11641] = {pokemons = {"Hitmonlee", "Hitmonchan", "Dragonite", "Snorlax", "Kingdra",
  "Ampharos", "Blissey", "Donphan", "Girafarig", "Mantine", "Miltank", "Porygon2", "Skarmory",
  "Lapras", "Gyarados", "Magmar", "Electabuzz", "Jynx", "Scyther", "Kangaskhan",
  "Venusaur", "Crobat", "Heracross", "Meganium",  "Piloswine", "Scizor",
  "Machamp", "Arcanine", "Charizard", "Blastoise", "Tentacruel", "Alakazam", "Feraligatr", "Houndoom",
  "Gengar", "Rhydon", "Misdreavus", "Raichu", "Slowking", "Steelix", "Sudowoodo", "Typhlosion", "Tyranitar", "Ursaring", "Tyrogue"}},
  [12331] = {pokemons = {"Shiny Abra"}},
  [14594] = {pokemons = {"Tamed Articuno"}},
  [14595] = {pokemons = {"Tamed Moltres"}},
  [14596] = {pokemons = {"Tamed Zapdos"}},
  [15572] = {pokemons = {"Unown Legion"}},
  [15574] = {pokemons = {"Shiny Ditto"}},
  [12227] = {pokemons = {"Shiny Crobat", "Shiny Magmar", "Shiny Giant Magikarp", "Shiny Venusaur", "Shiny Charizard", "Shiny Blastoise", "Shiny Arcanine", "Shiny Alakazam",
  "Shiny Gengar", "Shiny Scyther", "Shiny Pidgeot", "Shiny Raichu", "Shiny Tentacruel", "Shiny Ampharos", "Shiny Feraligatr", "Shiny Meganium",
  "Shiny Jynx", "Shiny Electabuzz", "Shiny Tangela", "Shiny Typhlosion", "Shiny Tauros", "Shiny Venomoth", "Shiny Pupitar", "Shiny Machamp",
  "Shiny Golbat", "Shiny Farfetch'd", "Shiny Pinsir", "Shiny Zubat", "Shiny Dratini", "Shiny Venonat",
  "Shiny Muk", "Shiny Stantler", "Shiny Marowak", "Shiny Dragonair", "Shiny Mr. Mime"}}
}

local happy = 1000

function onUse(cid, item, frompos, item2, topos)
  local b = a[item.itemid]
  if not b then return true end
  local pokemon = b.pokemons[math.random(#b.pokemons)]
  if not pokes[pokemon] then return true end

  if (getPlayerFreeCap(cid) >= 6 and not isInArray({5, 6}, getPlayerGroupId(cid))) then
    return doPlayerSendCancel(cid, "Voce ja esta carregando 6 pokemons!")
  end
  if not hasSpaceInContainer(getPlayerSlotItem(cid, 3).uid) then
    return doPlayerSendCancel(cid, "Voce esta com a bag cheia, libere espacos!")
  end

  doPlayerSendTextMessage(cid, 27, "You opened a pokemon prize box +"..item.itemid - (11637).."!")
  doPlayerSendTextMessage(cid, 27, "The prize pokemon was a "..pokemon..", congratulations!")
  doSendMagicEffect(getThingPos(cid), 29)

  addPokeToPlayer(cid, pokemon, 0, nil, btype)
  doRemoveItem(item.uid, 1)

  return true
end