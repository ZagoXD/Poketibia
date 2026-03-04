local sto = 5648454 
local iscas = {
--[id da isca] = lvl de fishing pra usar ela,
[3976] =                  {fish = 15, level = 15}, -- Worm        
[12855] =                 {fish = 20, level = 20},   -- Seaweed
[12854] =                 {fish = 25, level = 25},  -- Fish
[12858] =                 {fish = 30, level = 30},   -- Shrimp
[12857] =                 {fish = 35, level = 40},  -- Kept    
[12860] =                 {fish = 38, level = 50},   -- Steak
[12859] =                 {fish = 42, level = 65},   -- Special Lure
[12856] =                 {fish = 42, level = 65},  -- Misty's Special Lure
[12853] =                 {fish = 50, level = 75},   -- Big Steak
}

--[[function onUse(cid, item, frompos, item2, topos)
   if not iscas[item.itemid] then return true end
   
   local fishNEED = iscas[item.itemid].fish
   if getPlayerSkillLevel(cid, 6) < iscas[item.itemid].fish then
      return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa de fishing "..fishNEED.." para usar essa isca.")
   end
   
   local level = iscas[item.itemid].level
   if getPlayerLevel(cid) < iscas[item.itemid].level then
      return doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa de level "..level.." para usar essa isca.")
   end
      
   if getPlayerStorageValue(cid, sto) == -1 then
      setPlayerStorageValue(cid, sto, item.itemid)
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, 'A sua isca foi colocada na vara de pesca.')
   else
      setPlayerStorageValue(cid, sto, -1)
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, 'A sua isca foi retirada da vara de pesca.')
   end
return true
end]]--
function onUse(cid, item, frompos, item2, topos)
	if not iscas[item.itemid] then return true end
	
	if getPlayerStorageValue(cid, 55006) >= 1 then 
		doPlayerSendCancel(cid, "Você não pode pescar enquanto está em duel.")
		return true
	end
	
	local fishNEED = iscas[item.itemid].fish
	if getPlayerSkillLevel(cid, 6) < iscas[item.itemid].fish then
	    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa de fishing "..fishNEED.." para usar essa isca.")
		return doPlayerSendCancel(cid, "Você precisa de fishing "..fishNEED.." para usar essa isca.")
	end
	
	local level = iscas[item.itemid].level
	if getPlayerLevel(cid) < iscas[item.itemid].level then
	    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa de level "..level.." para usar essa isca.")
		return doPlayerSendCancel(cid, "Você precisa de level "..level.." para usar essa isca.")
	end
	
	if getPlayerStorageValue(cid, 154585) == 1 then
	    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você não pode alterar a isca enquanto pesca!")
		doPlayerSendCancel(cid, "Você não pode alterar a isca enquanto pesca!")
		return true
	end
	
	if getPlayerStorageValue(cid, sto) == -1 then
		setPlayerStorageValue(cid, sto, item.itemid)
		doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, 'A '..getItemNameById(item.itemid)..' foi colocada na vara de pesca.')
		doPlayerSendCancel(cid, 'A '..getItemNameById(item.itemid)..' foi colocada na vara de pesca.')
	elseif getPlayerStorageValue(cid, sto) == item.itemid then
	    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, 'A '..getItemNameById(item.itemid)..' foi removida na vara de pesca.')
		doPlayerSendCancel(cid, 'A '..getItemNameById(item.itemid)..' foi removida na vara de pesca.')
		setPlayerStorageValue(cid, sto, -1)
	else
	    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, 'A '..getItemNameById(getPlayerStorageValue(cid, sto))..' foi substituida na vara de pesca por sua '..getItemNameById(item.itemid)..'.')
		doPlayerSendCancel(cid, 'A '..getItemNameById(getPlayerStorageValue(cid, sto))..' foi substituida na vara de pesca por sua '..getItemNameById(item.itemid)..'.')
		setPlayerStorageValue(cid, sto, item.itemid)	
	end
	return true
end