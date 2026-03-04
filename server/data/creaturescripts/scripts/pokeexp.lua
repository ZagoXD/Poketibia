local EXPBOOST_STOR_REMAIN = 92020
local EXPBOOST_MULT = 2

local function expBoostActive(cid)
  local r = getPlayerStorageValue(cid, EXPBOOST_STOR_REMAIN)
  if r == -1 then r = 0 end
  return r > 0
end

local function resolvePlayerCid(cid)
  if isPlayer(cid) then return cid end
  if isCreature(cid) then
    local m = getCreatureMaster(cid)
    if m and isPlayer(m) then return m end
  end
  return nil
end

local function playerAddExp(targetCid, exp, sourceName)
  local pid = resolvePlayerCid(targetCid)
  if not pid then return end

  local mult  = expBoostActive(pid) and EXPBOOST_MULT or 1
  local final = math.floor(exp * mult)

  local before = getPlayerExperience(pid) or 0
  doPlayerAddExp(pid, final)
  local after  = getPlayerExperience(pid) or before
  local gained = after - before

  doSendAnimatedText(getThingPos(pid), final, 215)

--   print(string.format(
--     "[ExpBoost] %s base=%d x%.1f => enviado=%d | entrou_na_barra=%d%s",
--     getCreatureName(pid), exp, mult, final, gained,
--     sourceName and (" de "..sourceName) or ""
--   ))
end


function onDeath(cid, corpse, deathList)
        
	if isSummon(cid) or not deathList or getCreatureName(cid) == "Evolution" then return true end --alterado v1.8

    -------------Edited Golden Arena-------------------------   
    if getPlayerStorageValue(cid, 22546) == 1 then
       setGlobalStorageValue(22548, getGlobalStorageValue(22548)-1)
       if corpse.itemid ~= 0 then doItemSetAttribute(corpse.uid, "golden", 1) end  --alterado v1.8    
    end   
    if getPlayerStorageValue(cid, 22546) == 1 and getGlobalStorageValue(22548) == 0 then
       local wave = getGlobalStorageValue(22547)
       for _, sid in ipairs(getPlayersOnline()) do
           if isPlayer(sid) and getPlayerStorageValue(sid, 22545) == 1 then
              if getGlobalStorageValue(22547) < #wavesGolden+1 then
                 doPlayerSendTextMessage(sid, 20, "Wave "..wave.." will begin in "..timeToWaves.."seconds!")   
                 doPlayerSendTextMessage(sid, 28, "Wave "..wave.." will begin in "..timeToWaves.."seconds!") 
                 addEvent(creaturesInGolden, 100, GoldenUpper, GoldenLower, false, true, true)
                 addEvent(doWave, timeToWaves*1000)
              elseif getGlobalStorageValue(22547) == #wavesGolden+1 then
                 doPlayerSendTextMessage(sid, 20, "You have win the golden arena! Take your reward!")
                 doPlayerAddItem(sid, 2160, getPlayerStorageValue(sid, 22551)*2)    --premio
                 setPlayerStorageValue(sid, 22545, -1)
                 doTeleportThing(sid, getClosestFreeTile(sid, posBackGolden), false) 
                 setPlayerRecordWaves(sid)
              end
           end
       end
       if getGlobalStorageValue(22547) == #wavesGolden+1 then
          endGoldenArena()
       end
    end   
    ---------------------------------------------------   /\/\
	local givenexp = getWildPokemonExp(cid)  

if givenexp > 0 then
  for a = 1, #deathList do
    local pk = deathList[a]
    local pid = resolvePlayerCid(pk)
    if pid then
      local expTotal = math.floor(givenexp) -- (mantém tua base)
      local party = getPartyMembers(pid)
      local list = getSpectators(getThingPosWithDebug(pid), 30, 30, false)

      if isInParty(pid) and getPlayerStorageValue(pid, 4875498) <= -1 then
        local share = math.max(1, #party)
        expTotal = math.floor(expTotal / share)
        for i = 1, #party do
          local mate = party[i]
          if isInArray(list, mate) then
            playerAddExp(mate, expTotal)
          end
        end
      else
        playerAddExp(pid, expTotal)
      end
    end
  end
end

	if isNpcSummon(cid) then
		local master = getCreatureMaster(cid)
		doSendMagicEffect(getThingPos(cid), getPlayerStorageValue(cid, 10000))
		doCreatureSay(master, getPlayerStorageValue(cid, 10001), 1)
		doRemoveCreature(cid)
	return false
	end

if corpse.itemid ~= 0 then   --alterado v1.8
   doItemSetAttribute(corpse.uid, "level", getPokemonLevel(cid))
   doItemSetAttribute(corpse.uid, "gender", getPokemonGender(cid))  
end
return true
end