dofile('data/lib/tm/tm_config.lua')
local skills = specialabilities                                    --alterado v1.9 \/ peguem tudo!

function doAddPokemonInDexList(cid, poke)
if getPlayerInfoAboutPokemon(cid, poke).dex then return true end
	local a = newpokedex[poke]                                              
	local b = getPlayerStorageValue(cid, a.storage)
	setPlayerStorageValue(cid, a.storage, b.." dex,")
end

function getPokemonEvolutionDescription(name, next)
	local kev = poevo[name]
	local stt = {}
	if isInArray(specialevo, name) then
       if name == "Poliwhirl" then
          if next then
             return "\nPoliwrath or Politoed, requires level 65."
          end   
          table.insert(stt, "Evolve Stone: Water Stone and Punch Stone or Water Stone and King's Rock\n\n")
          table.insert(stt, "Evolutions:\nPoliwrath, requires level 65.\nPolitoed, requires level 65.")
       elseif name == "Gloom" then
          if next then
             return "\nVileplume or Bellossom, requires level 50."
          end
          table.insert(stt, "Evolve Stone: Leaf Stone and Venom Stone or Leaf Stone and Sun Stone\n\n")
          table.insert(stt, "Evolutions:\nVileplume, requires level 50.\nBellossom, requires level 50.")
       elseif name == "Slowpoke" then
          if next then
             return "\nSlowbro, requires level 45.\nSlowking, requires level 100."
          end
          table.insert(stt, "Evolve Stone: Enigma Stone or King's Rock\n\n")
          table.insert(stt, "Evolutions:\nSlowbro, requires level 45.\nSlowking, requires level 100.")
       elseif name == "Eevee" then
          if next then
             return "\nVaporeon, requires level 55.\nJolteon, requires level 55.\nFlareon, requires level 55.\nUmbreon, requires level 55.\nEspeon, requires level 55."
          end
          table.insert(stt, "Evolve Stone: Water Stone or Thunder Stone or Fire Stone or Darkness Stone or Enigma Stone\n\n")
          table.insert(stt, "Evolutions:\nVaporeon, requires level 55.\nJolteon, requires level 55.\nFlareon, requires level 55.\nUmbreon, requires level 55.\nEspeon, requires level 55.")
       elseif name == "Tyrogue" then
          if next then
             return "\nHitmonlee, requires level 60.\nHitmonchan, requires level 60.\nHitmontop, requires level 60."
          end
          table.insert(stt, "Evolve Stone: Punch Stone\n\n")   
          table.insert(stt, "Evolutions:\nHitmonlee, requires level 60.\nHitmonchan, requires level 60.\nHitmontop, requires level 60.")
       end
    elseif kev then
       if next then
          table.insert(stt, "\n"..kev.evolution..", requires level "..kev.level..".")
          return table.concat(stt)
       end
       local id = tonumber(kev.stoneid)
       local id2 = tonumber(kev.stoneid2)
       local stone = ""
       if tonumber(kev.count) == 2 then
          stone = doConvertStoneIdToString(id).." (2x)"
       else
          stone = id2 == 0 and doConvertStoneIdToString(id) or doConvertStoneIdToString(id).." and "..doConvertStoneIdToString(id2)
       end
       table.insert(stt, "Evolve Stone: "..stone.."\n\n")
       table.insert(stt, "Evolutions:\n"..kev.evolution..", requeris level "..kev.level..".")
       table.insert(stt, getPokemonEvolutionDescription(kev.evolution, true))
    else
        if not next then
           table.insert(stt, "Evolutions:\nIt doen't evolve.")
        end
    end   
return table.concat(stt)
end

local function getBaseStatsBlock(name)
  local P = pokes and pokes[name]
  if not P then
    return "Base Stats:\n- Offense:  ?\n- Defense: ?\n- Sp. Attack:   ?\n- Vitality:    ?\n- Agility:    ?\n"
  end

  local o = tonumber(P.offense)
  local d = tonumber(P.defense)
  local s = tonumber(P.specialattack or P.special)
  local v = tonumber(P.vitality)
  local a = tonumber(P.agility)

  local function makeBar(val, minV, maxV, width)
    if type(val) ~= 'number' then return string.rep("-", width) end
    if maxV <= minV then return string.rep("-", width) end
    local t = (val - minV) / (maxV - minV)
    if t < 0 then t = 0 elseif t > 1 then t = 1 end
    local n = math.floor(0.5 + t * width)
    local full, empty = "#", "-"
    return string.rep(full, n) .. string.rep(empty, width - n)
  end

  local function fmt(val, decimals, width)
    if type(val) ~= 'number' then
      return string.format("%" .. width .. "s", "?")
    end
    return string.format("%" .. width .. "." .. decimals .. "f", val)
  end

  local function line(label, val, minV, maxV, decimals, numWidth)
    local bar  = makeBar(val, minV, maxV, 20)
    local num  = fmt(val, decimals, numWidth)
    return string.format("- %-10s [%s] %s", label .. ":", bar, num)
  end

  local lines = {
    "Base Stats:",
    line("Offense",  o, 4,   20, 1, 5),
    line("Defense",  d, 4,   20, 1, 5),
    line("Sp. Atk",  s, 4,   20, 1, 5),
    line("Vitality", v, 4,   20, 1, 5),
    line("Agility",  a, 100, 200, 0, 3),
    ""
  }
  return table.concat(lines, "\n")
end

local function getMoveCategoryTag(moveName)
  local cat

  if movesinfo and movesinfo[moveName] then
    local mi = movesinfo[moveName]

    if mi.category then
      cat = tostring(mi.category):lower()
    elseif mi.cat then
      cat = tostring(mi.cat):lower()
    elseif mi.isPhysical ~= nil then
      cat = mi.isPhysical and "physical" or "special"
    end
  end

  if not cat and TM and TM.moveCategory and TM.moveCategory[moveName] then
    cat = tostring(TM.moveCategory[moveName]):lower()
  end

  if cat == "physical" or cat == "phys" then return "phy" end
  if cat == "special"  or cat == "spa"  then return "spa" end
  return nil
end


local function getMoveDexDescr(cid, name, number)
  local x = movestable[name]
  if not x then return "" end

  local z = "\n"
  local tables = {x.move1, x.move2, x.move3, x.move4, x.move5, x.move6, x.move7, x.move8, x.move9, x.move10, x.move11, x.move12}
  local y = tables[number]
  if not y then return "" end

  if getTableMove(cid, y.name) == "" then
    print(""..y.name.." faltando")
    return "unknown error"
  end

  local tag = getMoveCategoryTag(y.name)
  local catStr = tag and (" - " .. tag) or ""

  local txt = z .. y.name .. " - m" .. number .. " - level " .. y.level .. " - " .. (y.t) .. catStr
  return txt
end
    
local skillcheck = {"fly", "ride", "surf", "teleport", "rock smash", "cut", "dig", "light", "blink", "control mind", "transform", "levitate_fly"}
local passivas = {
["Electricity"] = {"Electabuzz", "Shiny Electabuzz", "Elekid", tpw = "electric"},
["Lava Counter"] = {"Magmar", "Magby", tpw = "fire"},
["Counter Helix"] = {"Scyther", "Shiny Scyther", tpw = "bug"},
["Giroball"] = {"Pineco", "Forretress", tpw = "steel"},
["Counter Claw"] = {"Scizor", tpw = "bug"},
["Counter Spin"] = {"Hitmontop", "Shiny Hitmontop", tpw = "fighting"},
["Demon Kicker"] = {"Hitmonlee", "Shiny Hitmonlee", tpw = "fighting"},
["Demon Puncher"] = {"Hitmonchan", "Shiny Hitmonchan", tpw = "unknow"},               --alterado v1.6
["Stunning Confusion"] = {"Psyduck", "Golduck", "Wobbuffet", tpw = "psychic"},
["Groundshock"] = {"Kangaskhan", tpw = "normal"},
["Electric Charge"] = {"Pikachu", "Raichu", "Shiny Raichu", tpw = "electric"},
["Melody"] = {"Wigglytuff", tpw = "normal"},
["Dragon Fury"] = {"Dratini", "Dragonair", "Dragonite", "Shiny Dratini", "Shiny Dragonair", "Shiny Dragonite", tpw = "dragon"},
["Fury"] = {"Persian", "Raticate", "Shiny Raticate", tpw = "normal"},
["Mega Drain"] = {"Oddish", "Gloom", "Vileplume", "Kabuto", "Kabutops", "Parasect", "Tangela", "Shiny Vileplume", "Shiny Tangela", tpw = "grass"},
["Spores Reaction"] = {"Oddish", "Gloom", "Vileplume", "Shiny Vileplume", tpw = "grass"},
["Amnesia"] = {"Wooper", "Quagsire", "Swinub", "Piloswine", tpw = "psychic"},
["Zen Mind"] = {"Slowking", tpw = "psychic"}, 
["Mirror Coat"] = {"Wobbuffet", tpw = "psychic"},
["Lifesteal"] = {"Crobat", tpw = "normal"},
["Evasion"] = {"Scyther", "Scizor", "Hitmonlee", "Hitmonchan", "Hitmontop", "Tyrogue", "Shiny Scyther", "Shiny Hitmonchan", "Shiny Hitmonlee", "Shiny Hitmontop", "Ledian", "Ledyba", "Sneasel", tpw = "normal"},
["Foresight"] = {"Machamp", "Shiny Hitmonchan", "Shiny Hitmonlee", "Shiny Hitmontop", "Hitmontop", "Hitmonlee", "Hitmonchan", tpw = "fighting"},
["Levitate"] = {"Gengar", "Haunter", "Gastly", "Misdreavus", "Weezing", "Koffing", "Unown", "Shiny Gengar", tpw = "ghost"},
}

local function resolveBaseNameForTM(pokeName)
  if TM and TM.aliasToBase and TM.aliasToBase[pokeName] then
    return TM.aliasToBase[pokeName]
  end
  return pokeName
end

local function getKnownMovesSet(pokeName)
  local known = {}
  local tbl = movestable[pokeName]
  if not tbl then return known end

  for i = 1, 12 do
    local slot = tbl["move"..i]
    if slot and slot.name then
      known[slot.name] = true
    end
  end
  return known
end
local function buildLearnableTMsList(pokeName)
  if not TM or not TM.learnsetByMove then return {} end

  local base = resolveBaseNameForTM(pokeName)
  local known = getKnownMovesSet(pokeName)

  local learnable = {}
  for moveName, learners in pairs(TM.learnsetByMove) do
    if isInArray(learners, base) then
      if not known[moveName] then
        table.insert(learnable, moveName)
      end
    end
  end

  table.sort(learnable, function(a,b) return a < b end)
  return learnable
end

function doShowPokedexRegistration(cid, pokemon, ball)
local item2 = pokemon
local virtual = false
   if type(pokemon) == "string" then
      virtual = true
   end
local myball = ball
local name = virtual and pokemon or getCreatureName(item2.uid)

local v = fotos[name]
local stt = {}

table.insert(stt, "Name: "..name.."\n")

if pokes[name].type2 and pokes[name].type2 ~= "no type" then
   table.insert(stt, "Type: "..pokes[name].type.."/"..pokes[name].type2)
else
    table.insert(stt, "Type: "..pokes[name].type)
end

if virtual then
   table.insert(stt, "\nRequired level: "..pokes[name].level.."\n")
else
   table.insert(stt, "\nRequired level: ".. getPokemonLevel(item2.uid, true) .."\n") 
end

table.insert(stt, "\n"..getPokemonEvolutionDescription(name).."\n")

table.insert(stt, "\n" .. getBaseStatsBlock(name) .. "\n")

table.insert(stt, "\nMoves:")

if name == "Ditto" then
   if virtual then
      table.insert(stt, "\nIt doesn't use any moves until transformed.")
   elseif getPlayerStorageValue(item2.uid, 1010) == "Ditto" or getPlayerStorageValue(item2.uid, 1010) == -1 then
      table.insert(stt, "\nIt doesn't use any moves until transformed.")
   else
      for a = 1, 15 do
         table.insert(stt, getMoveDexDescr(item2.uid, getPlayerStorageValue(item2.uid, 1010), a))
      end
   end
else
   for a = 1, 15 do
      table.insert(stt, getMoveDexDescr(item2.uid, name, a))
   end
end

for e, f in pairs(passivas) do
   if isInArray(passivas[e], name) then
      local tpw = passivas[e].tpw
      if name == "Pineco" and passivas[e] == "Giroball" then
         tpw = "bug"
      end
      table.insert(stt, "\n"..e.." - passive - "..tpw)
   end
end

local tms = buildLearnableTMsList(name)
table.insert(stt, "\n")
table.insert(stt, "\n")
table.insert(stt, "\n")
if #tms > 0 then
  table.insert(stt, "TMs aprendiveis:\n- " .. table.concat(tms, "\n- "))
else
  table.insert(stt, "TMs aprendiveis:\n- (nenhum)")
end
            
table.insert(stt, "\n\nAbility:\n") 
local abilityNONE = true                   --alterado v1.8 \/
			
for b, c in pairs(skills) do
   if isInArray(skillcheck, b) then
      if isInArray(c, name) then
         table.insert(stt, (b == "levitate_fly" and "Levitate" or doCorrectString(b)).."\n")
         abilityNONE = false
      end
   end
end
if abilityNONE then
   table.insert(stt, "None")
end
		
if string.len(table.concat(stt)) > 8192 then
   print("Error while making pokedex info with pokemon named "..name..".\n   Pokedex registration has more than 8192 letters (it has "..string.len(stt).." letters), it has been blocked to prevent fatal error.")
   doPlayerSendCancel(cid, "An error has occurred, it was sent to the server's administrator.") 
return true
end	

doShowTextDialog(cid, v, table.concat(stt))
end