local market = {
	{emeralds = 10, changeName = true},	
	{emeralds = 70, kit = 3}, -- Combo - Shiny Charm 30 dias + Experience Booster 6
	{emeralds = 25, itemId = 19274, count = 1}, -- Shiny Charm - 7 Dias
	{emeralds = 50, itemId = 19277, count = 1}, -- Shiny Charm - 30 dias
	{emeralds = 2, itemId = 19268, count = 1}, -- Experience Booster 1
	{emeralds = 4, itemId = 19269, count = 1}, -- Experience Booster 2
	{emeralds = 2, blessings = 1},
	{emeralds = 3, blessings = 2},
	{emeralds = 5, blessings = 3},
	{emeralds = 3, blessings = 4},
	{emeralds = 4, blessings = 5},
	{emeralds = 6, blessings = 6},
	{emeralds = 5, changeSex = true},
}

local outfits = {
	{emeralds = 3, outfitSto = 181654, multigender = true}, -- assassin
	{emeralds = 3, outfitSto = 181657, multigender = false, gender = 1}, -- drhouse
	{emeralds = 5, outfitSto = 181658, multigender = false, gender = 1}, -- iron man
	{emeralds = 5, outfitSto = 99990, multigender = true}, -- legendary
	{emeralds = 3, outfitSto = 181649, multigender = false, gender = 0}, -- playboy
	{emeralds = 3, outfitSto = 181661, multigender = true}, -- rabbit
	{emeralds = 3, outfitSto = 181648, multigender = false, gender = 1}, -- slash
	{emeralds = 3, outfitSto = 181653, multigender = true}, -- veteran trainer
	{emeralds = 3, outfitSto = 181650, multigender = false, gender = 1}, -- vingança
}

local items = { -- special stones
	{emeralds = 5, itemId = 19203, count = 1}, -- shiny stone

}

local bless = {
	[1] = {percent = 20, valueBetween = {1, 200}},
	[2] = {percent = 50, valueBetween = {1, 200}},
	[3] = {percent = 100, valueBetween = {1, 200}},
	[4] = {percent = 20, valueBetween = {200}},
	[5] = {percent = 50, valueBetween = {200}},
	[6] = {percent = 100, valueBetween = {200}},
}

local addons = {
    {emeralds = 3, itemId = 19251, count = 1}, -- Predator Mask (magmar)
    {emeralds = 3, itemId = 19250, count = 1}, -- Guitar (electabuzz)
    {emeralds = 3, itemId = 19245, count = 1}, -- Thor Costume (electabuzz)
	{emeralds = 3, itemId = 19253, count = 1}, -- Bandit Mask (electabuzz)
	{emeralds = 1, itemId = 19260, count = 1}, -- Metal Pack (electabuzz)
	{emeralds = 1, itemId = 19252, count = 1}, -- Medic Costume (exegggutor)
	{emeralds = 1, itemId = 19246, count = 1}, -- Warrior Costume (charizard)
	{emeralds = 3, itemId = 19249, count = 1}, -- Witch Costume (jynx)
	{emeralds = 3, itemId = 19256, count = 1}, -- Wedding Dress (jynx)
	{emeralds = 1, itemId = 19255, count = 1}, -- Emerald Turban (hypno)
	{emeralds = 1, itemId = 19258, count = 1}, -- Reaper Costume (marowak)
	{emeralds = 1, itemId = 19257, count = 1}, -- Pumpkin Pack (marowak)
}

local OPCODE_EMERALD_SHOP = opcodes.OPCODE_EMERALD_SHOP

function onExtendedOpcode(cid, opcode, buffer)
	local t = string.explode(buffer, "|")
	if opcode == 103 then
		if t[1] == "Market" then
			local cost = market[tonumber(t[2])].emeralds 
			if getPlayerItemCount(cid, 14130) >= cost then
				local shop = market[tonumber(t[2])]
				if shop.kit then					
					if shop.kit == 3 then
						doPlayerAddItem(cid, 19273, 1) -- Experience Booster 6
						doPlayerAddItem(cid, 19277, 1) -- Shiny Charm 30 dias
					end
				elseif shop.itemId then
					doPlayerAddItem(cid, shop.itemId, shop.count)
				elseif shop.pokemon then
					local ball = createBall(cid, shop.pokemon, 0, false)
					if shop.pokemon == "Ditto" then
						doItemSetAttribute(ball, "memory", "without")
					elseif shop.pokemon == "Shiny Ditto" then
					    doItemSetAttribute(ball, "memory", 2)
					end
				elseif shop.blessings then
					local bles = bless[shop.blessings]
					
					if getPlayerStorageValue(cid, 50405) ~= -1 then
						return doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, "You already have the blessing.")
					end
					
					if #bles.valueBetween > 1 then
						if isValueBetween(getPlayerLevel(cid), bles.valueBetween[1], bles.valueBetween[2]) then
							setPlayerStorageValue(cid, 50405, bles.percent)
						else
							return doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, 'You need to be level between '..bles.valueBetween[1]..' and '..bles.valueBetween[2]..'.')
						end
					else
						if getPlayerLevel(cid) >= bles.valueBetween[1] then
							setPlayerStorageValue(cid, 50405, bles.percent)
						else
							return doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, 'You need to be level greater than or iqual to '..bles.valueBetween[1]..'.')
						end						
					end
				elseif shop.changeSex then
					doPlayerSetSex(cid, (getPlayerSex(cid) == 0 and 1 or 0))
					addEvent(function() 
						local playerGuid = getPlayerGUID(cid)
						doRemoveCreature(cid) 
						addEvent(function() 
							if isPlayer(getPlayerByGUID(playerGuid)) then
								doSendPlayerExtendedOpcode(getPlayerByGUID(playerGuid), OPCODE_EMERALD_SHOP, "True") 
							end
						end, 2000)
					end, 5)
				end
				--doSendMagicEffect(getThingPos(cid), 173)
				return doPlayerRemoveItem(cid, 14130, cost) and doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, "True")
			else
				return doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, 'You don\'t have enough rubies.')
			end
		elseif t[1] == "ChangeNick" then
		
			local newName = t[2]
			
			if not newName then return true end
			
			if getPlayerItemCount(cid, 14130) >= 10 then
				if(db.getResult("SELECT `id` FROM `players` WHERE `name` = " .. db.escapeString(newName) .. ";"):getID() == 1) then
					return doPlayerSendCancel(cid, "O nome (" .. newName .. ") ja esta em uso.")
				end	
				
				local table = {"'", '"', "!", "ã", "õ", "ç", "Ž", "`", "á", "à", "ó", "ò", "é", "è", "í", "ì", "ú", "ù", "¹", "²", "³", "£", "¢", "¬", "§", "°", "º", "ª", "", "|", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}


				for a = 1, #table do
					if string.find(newName, table[a]) then
						return doPlayerSendCancel(cid, "Este nome (" .. newName .. ") e invalido.")
					end
				end

				if string.len(newName) < 4 then
					return doPlayerSendCancel(cid, "Este nome (" .. newName .. ") e curto demais.")
				elseif string.len(newName) > 15 then
					return doPlayerSendCancel(cid, "Este nome (" .. newName .. ") e longo demais.")
				end
				
				setPlayerStorageValue(cid, 9134, getCreatureName(cid))
				db.executeQuery("UPDATE `players` SET `name` = '" .. newName .. "' WHERE name = '" .. getCreatureName(cid) .. "';")
				doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, 'You will be log out to change te name in 3 seconds.')
				addEvent(function() 
					if isCreature(cid) then
						doRemoveCreature(cid)
					end
				end, 3000)
				
				return doPlayerRemoveItem(cid, 14130, 10)
			else
				return doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, 'You don\'t have enough rubies.')
			end
			
			return true
		elseif t[1] == "Items" then
			local cost = items[tonumber(t[2])].emeralds
			if getPlayerItemCount(cid, 14130) >= cost then
				local shop = items[tonumber(t[2])]
				doPlayerAddItem(cid, shop.itemId, shop.count)
				return doPlayerRemoveItem(cid, 14130, cost) and doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, "True")
			else
				return doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, 'You don\'t have enough rubies.')
			end
		elseif t[1] == "Addons" then
			local cost = addons[tonumber(t[2])].emeralds
			if getPlayerItemCount(cid, 14130) >= cost then
				local shop = addons[tonumber(t[2])]
					doPlayerAddItem(cid, shop.itemId, 1)
				return doPlayerRemoveItem(cid, 14130, cost) and doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, "True")
			else
				return doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, 'You don\'t have enough rubies.')
			end			
		elseif t[1] == "Outfits" then
			local cost = outfits[tonumber(t[2])].emeralds
			if getPlayerItemCount(cid, 14130) >= cost then
				local shop = outfits[tonumber(t[2])]
				if shop.multigender == false and getPlayerSex(cid) ~= shop.gender then
					return doPlayerSendCancel(cid, "Voce nao pode comprar essa outfit!")
				end
				setPlayerStorageValue(cid, shop.outfitSto, 1)
				return doPlayerRemoveItem(cid, 14130, cost) and doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, "True")
			else
				return doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, 'You don\'t have enough rubies.')
			end			
		end
		return doPlayerRemoveItem(cid, 14130, cost) and doSendPlayerExtendedOpcode(cid, OPCODE_EMERALD_SHOP, "True")
	end
end