function isPosEqual(pos1, pos2)
      if pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z then
         return true
      end	
return false
end

function isPosInArray(array, pos)
if not next(array) then return false end
for i = 1, #array do
    if isPosEqual(pos, array[i]) then
       return true
    end
end
return false
end

function moveTravel(cid, posFinal, oldPos)
if not isPlayer(cid) then return true end
local pos = getThingPos(cid)
local oldPos = oldPos or {}
if isPosEqual(pos, posFinal) then 
   moveTravel(cid, {x=0, y=0, z=0}, oldPos)
   doRemoveCondition(cid, CONDITION_OUTFIT)
   doSendMagicEffect(getThingPos(cid), 21)
   mayNotMove(cid, false)
   setPlayerStorageValue(cid, 75846, -1)
   return true
end
for i = 0, 7 do
    local newPos = getPosByDir(pos, i)                                  
    if not isPosInArray(oldPos, newPos) and getTileInfo(newPos).nologout then
       doTeleportThing(cid, newPos, true)
       table.insert(oldPos, pos)
       if isPosEqual({x=0, y=0, z=0}, posFinal) then return true end
       addEvent(moveTravel, 150, cid, posFinal, oldPos)
       return true
    end
end
return false
end