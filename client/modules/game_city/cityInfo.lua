local areas = {
	{from = {x = 1016, y = 1019, z = 7}, to = {x = 1030, y = 1030, z = 7}, priority = 1, name = 'Pokemon Center'},
	{from = {x = 827, y = 1021, z = 7}, to = {x = 841, y = 1032, z = 7}, priority = 1, name = 'Pokemon Center'},
	-- Cidade 1 - 
	{from = {x = 1011, y = 1015, z = 7}, to = {x = 1033, y = 1034, z = 7}, priority = 0, name = 'Cerulean City'},
	{from = {x = 1028, y = 1067, z = 4}, to = {x = 1043, y = 1079, z = 4}, priority = 0, name = 'Battlefield'},
	{from = {x = 1364, y = 914, z = 7}, to = {x = 1411, y = 872, z = 7}, priority = 0, name = 'Area Iniciante'},

	}
local area = nil
local intervalo = 1
local duracao = 5
local retorno = 0
local eventAnimation = nil
local check = true
function isInRange(pos, fromPos, toPos)
    return
        pos.x>=fromPos.x and
        pos.y>=fromPos.y and
        pos.z>=fromPos.z and
        pos.x<=toPos.x and
        pos.y<=toPos.y and
        pos.z<=toPos.z
end

function init()
	placa = g_ui.displayUI('cityInfo', modules.game_interface.getRootPanel())
	placa:setVisible(false) 
	
	placaLabel = placa:getChildById('nome')
	
	connect(g_game, { onGameStart = updatePosition})
	connect(g_game, { onGameStart = AdjustSize})
	
	connect(LocalPlayer, {
		onPositionChange = updatePosition
	})
end
function AdjustSize()
	local top = (g_window.getHeight()/2) - 65
	placa:setMarginTop(-top)
end

function terminate()
	placa:destroy()
end

function updatePosition()
	local player = g_game.getLocalPlayer()
	if not player then
		return 
	end
	local pos = player:getPosition()
	if not pos then return end
	check = false
	local prioridade = nil
	for i = 1, #areas do
		if isInRange(pos, areas[i].from, areas[i].to) then
			if prioridade == nil then
				prioridade = areas[i].priority
				Table = areas[i]
			end
			
			if areas[i].priority > prioridade then
				Table = areas[i]
				prioridade = areas[i].priority
			end
			check = true
		end
	end
	if check == true then
		if Table.name == area then
			return false
		else
			reset()
			area = Table.name
			retorno = 1
			placaLabel:setText(area)
			placa:setVisible(true) 
			eventAnimation = cycleEvent(function() showPlaca(retorno) end, 200)
			check = true
		end
	else
		reset()	
	end
end

function reset()
	area = nil
	removeEvent(eventAnimation)
	removeEvent(placa.fadeEvent)
	g_effects.fadeOut(placa, 0) 
	placa:setVisible(false)	
end
function showPlaca()
	if retorno == 1 then
		g_effects.fadeIn(placa, 1100)
		retorno = 2
		removeEvent(eventAnimation)
		eventAnimation = cycleEvent(function() showPlaca(retorno) end, 2500)
		return
	elseif retorno == 2 then
		g_effects.fadeOut(placa, 1100)
		retorno = 0
		removeEvent(eventAnimation)
	end
end
