function isRocket(cid)                                            
return isCreature(cid) and getPlayerStorageValue(cid, 665450) >= 1  --alterado v1.9
end
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
function isOfficer(cid)
return isCreature(cid) and getPlayerStorageValue(cid, 665460) >= 1  --alterado v1.9
end
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
function randOutfit(cid, outs)  --alterado v1.9
outfit = getCreatureOutfit(cid)
if getPlayerStorageValue(cid, 665451) >= 1 then
   outfit = {lookType = choose(605, 604), lookHead = math.random(1, 250), lookBody = math.random(1, 250), lookLegs = math.random(1, 250), lookFeet = math.random(1, 250)}
elseif getPlayerStorageValue(cid, 665461) >= 1 then
   outfit = {lookType = choose(1184, 1183), lookHead = math.random(1, 250), lookBody = math.random(1, 250), lookLegs = math.random(1, 250), lookFeet = math.random(1, 250)}
elseif getPlayerStorageValue(cid, 665471) >= 1 then
   outfit = {lookType = choose(1016, 1015), lookHead = math.random(1, 250), lookBody = math.random(1, 250), lookLegs = math.random(1, 250), lookFeet = math.random(1, 250)}
elseif getPlayerStorageValue(cid, 665481) >= 1 then
   outfit = {lookType = choose(outs[1], outs[2]), lookHead = math.random(1, 250), lookBody = math.random(1, 250), lookLegs = math.random(1, 250), lookFeet = math.random(1, 250)}
end         --alterei v1.9 /\
doSetCreatureOutfit(cid, outfit, -1)
end   
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
function doCloneOut(npc, outfit)
if isCreature(npc) then
   doSetCreatureOutfit(npc, outfit, -1)
end
end
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
function beDrunk(target)
if not isCreature(target) then return true end
doChangeSpeed(target, -getCreatureSpeed(target))
doChangeSpeed(target, 100)
if not isSleeping(target) and getPlayerStorageValue(target, 654878) <= 0 then
   doPushCreature(target, math.random(0, 3), 1, 0)
end
doChangeSpeed(target, -100)
addEvent(beDrunk, 2000, target)
end
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
function randWalk(cid, cd, check, target)
if not isCreature(cid) then return true end
if check and check ~= getPlayerStorageValue(cid, 154788) then return true end
if getPlayerStorageValue(cid, 154788) >= 2 and cd ~= -1 then return true end 
-------
local alvo = target
-------
setPlayerStorageValue(cid, 154788, getPlayerStorageValue(cid, 154788)+cd)
local a = getPlayerStorageValue(cid, 154788)
if a <= 0 then setPlayerStorageValue(cid, 154788, -1) return true end
-------
doChangeSpeed(cid, -getCreatureSpeed(cid))
doChangeSpeed(cid, 100)
-------
if not isSleeping(cid) and getPlayerStorageValue(cid, 654878) <= 0 then
   doPushCreature(cid, math.random(0, 3), 1, 0)
end
-------
doChangeSpeed(cid, -100)
if isCreature(alvo) then
   doCreatureSetLookDir(cid, getCreatureDirectionToTarget(cid, alvo))
end
-------
addEvent(randWalk, 5000, cid, -1, a, target)
end
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
rocketTalks = {"I will kill you, your pig!!", "HAHA you won't get me!!!", "I will win and disappear!!"}
policeTalks = {"I will get you, thief!!", "So you belong to the team rocket? Come here for i get you!!", "I will kill you, your little thief!!"} 
hunterTalks = {"I will kill you!!", "Wasn't for you be here!", "This field is sacred! Get out of here!!"}
hunterWingeonTalks = {"You will die!", "The force of the air will help me!"}  --alterado v1.9 alterem aki
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
wildRocket = {
[1] = {{name = "Bulbasaur", optionalLevel = 20, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Squirtle", optionalLevel = 15, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Charmander", optionalLevel = 25, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Raticate", optionalLevel = 15, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Gloom", optionalLevel = 28, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[2] = {{name = "Chikorita", optionalLevel = 25, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Totodile", optionalLevel = 10, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Cyndaquil", optionalLevel = 20, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Natu", optionalLevel = 26, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Pidgeotto", optionalLevel = 28, sex = SEX_MALE, nick = "", ball = "ultra"},
      }, 
[3] = {{name = "Muk", optionalLevel = 35, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Ivysaur", optionalLevel = 40, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Ledian", optionalLevel = 43, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Venonat", optionalLevel = 25, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Ariados", optionalLevel = 40, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[4] = {{name = "Pichu", optionalLevel = 20, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Flaaffy", optionalLevel = 35, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Seadra", optionalLevel = 45, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Koffing", optionalLevel = 25, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Cubone", optionalLevel = 30, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[5] = {{name = "Haunter", optionalLevel = 40, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Furret", optionalLevel = 30, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Marill", optionalLevel = 25, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Charmeleon", optionalLevel = 50, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Yanma", optionalLevel = 50, sex = SEX_MALE, nick = "", ball = "ultra"},
      },     
}
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
wildPolice = {
[1] = {{name = "Golbat", optionalLevel = 20, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Hoothoot", optionalLevel = 15, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Magnemite", optionalLevel = 25, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Doduo", optionalLevel = 15, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Kingler", optionalLevel = 28, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[2] = {{name = "Aipom", optionalLevel = 25, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Murkrow", optionalLevel = 10, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Pineco", optionalLevel = 20, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Swinub", optionalLevel = 26, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Bulbasaur", optionalLevel = 28, sex = SEX_MALE, nick = "", ball = "ultra"},
      }, 
[3] = {{name = "Croconaw", optionalLevel = 35, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Kadabra", optionalLevel = 40, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Weepinbell", optionalLevel = 43, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Graveler", optionalLevel = 25, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Houndour", optionalLevel = 40, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[4] = {{name = "Magby", optionalLevel = 20, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Shuckle", optionalLevel = 35, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Seaking", optionalLevel = 45, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Seel", optionalLevel = 25, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Machoke", optionalLevel = 35, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[5] = {{name = "Slowpoke", optionalLevel = 40, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Wartortle", optionalLevel = 30, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Bayleef", optionalLevel = 25, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Dugtrio", optionalLevel = 50, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Hypno", optionalLevel = 50, sex = SEX_MALE, nick = "", ball = "ultra"},
      },     
}
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
wildCommanderOfficer = {
[1] = {{name = "Donphan", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Porygon2", optionalLevel = 65, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Octillery", optionalLevel = 60, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Bellossom", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Nidoking", optionalLevel = 55, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[2] = {{name = "Sandslash", optionalLevel = 55, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Electabuzz", optionalLevel = 60, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Jynx", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Tauros", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Venomoth", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "ultra"},
      }, 
[3] = {{name = "Lanturn", optionalLevel = 55, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Umbreon", optionalLevel = 69, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Magcargo", optionalLevel = 60, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Ninetales", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Primeape", optionalLevel = 75, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[4] = {{name = "Machamp", optionalLevel = 80, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Snorlax", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Magneton", optionalLevel = 70, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Mantine", optionalLevel = 75, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Exeggutor", optionalLevel = 65, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[5] = {{name = "Dewgong", optionalLevel = 45, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Xatu", optionalLevel = 55, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Skarmory", optionalLevel = 60, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Hitmonlee", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Hitmonchan", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "ultra"},
      }, 
}
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
wildCommanderRocket = {
[1] = {{name = "Raichu", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Pidgeot", optionalLevel = 65, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Politoed", optionalLevel = 60, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Nidoqueen", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Vileplume", optionalLevel = 55, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[2] = {{name = "Clefable", optionalLevel = 55, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Noctowl", optionalLevel = 60, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Forretress", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Golduck", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Dragonair", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "ultra"},
      }, 
[3] = {{name = "Victreebel", optionalLevel = 55, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Tentacruel", optionalLevel = 69, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Togetic", optionalLevel = 60, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Espeon", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Heracross", optionalLevel = 75, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[4] = {{name = "Girafarig", optionalLevel = 80, sex = SEX_FEMALE, nick = "", ball = "normal"},  --alterado v1.6
       {name = "Ursaring", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Piloswine", optionalLevel = 70, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Mantine", optionalLevel = 75, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Wigglytuff", optionalLevel = 65, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[5] = {{name = "Slowpoke", optionalLevel = 45, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Poliwrath", optionalLevel = 55, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Farfetch'd", optionalLevel = 60, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Cloyster", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Hitmontop", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "ultra"},
      },     
}
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
wildHunter = {
[1] = {{name = "Raichu", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Pidgeot", optionalLevel = 65, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Politoed", optionalLevel = 60, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Nidoqueen", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Gengar", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[2] = {{name = "Clefable", optionalLevel = 55, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Noctowl", optionalLevel = 60, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Forretress", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Golduck", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Dragonair", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "ultra"},
      }, 
[3] = {{name = "Victreebel", optionalLevel = 55, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Tentacruel", optionalLevel = 69, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Magmar", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Espeon", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Heracross", optionalLevel = 75, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[4] = {{name = "Girafarig", optionalLevel = 80, sex = SEX_FEMALE, nick = "", ball = "normal"}, --alterado v1.6
       {name = "Ursaring", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Piloswine", optionalLevel = 70, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Mantine", optionalLevel = 75, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Kangaskhan", optionalLevel = 65, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[5] = {{name = "Slowpoke", optionalLevel = 45, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Poliwrath", optionalLevel = 55, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Scyther", optionalLevel = 85, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Cloyster", optionalLevel = 70, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Hitmontop", optionalLevel = 80, sex = SEX_MALE, nick = "", ball = "ultra"},
      },     
}
hunterWingeon = {
[1] = {{name = "Fearow", optionalLevel = 1000, sex = SEX_FEMALE, nick = "", ball = "normal"},     --alterado v1.9
       {name = "Pidgeot", optionalLevel = 1000, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Noctowl", optionalLevel = 1000, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Dragonite", optionalLevel = 1000, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Dragonair", optionalLevel = 1000, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
[2] = {{name = "Shiny Dragonair", optionalLevel = 1000, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Noctowl", optionalLevel = 1000, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Skarmory", optionalLevel = 1000, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Gyarados", optionalLevel = 1000, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Dragonair", optionalLevel = 1000, sex = SEX_MALE, nick = "", ball = "ultra"},
      }, 
[3] = {{name = "Shiny Pidgeot", optionalLevel = 1000, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Shiny Dragonair", optionalLevel = 1000, sex = SEX_MALE, nick = "", ball = "normal"},   
       {name = "Dragonite", optionalLevel = 1000, sex = SEX_MALE, nick = "", ball = "super"},
       {name = "Skarmory", optionalLevel = 1000, sex = SEX_FEMALE, nick = "", ball = "normal"},
       {name = "Pidgeot", optionalLevel = 1000, sex = SEX_MALE, nick = "", ball = "ultra"},
      },
}