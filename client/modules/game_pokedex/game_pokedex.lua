pokedexWindow = nil

local PREFIXES = {
  Shiny = true,
  Elder = true,
  Ancient = true,
  Shadow = true,
  Black = true,
  Mega = true,
  Green = true
}
local SUFFIXES = { MVP = true }

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function stripPrefixes(name)
  local n = trim(name or "")
  while true do
    local removed = false
    for p,_ in pairs(PREFIXES) do
      if n:sub(1, #p + 1) == (p .. " ") then
        n = trim(n:sub(#p + 2))
        removed = true
        break
      end
    end
    if not removed then break end
  end
  return n
end

local function stripSuffixes(name)
  local n = trim(name or "")
  while true do
    local removed = false
    for s,_ in pairs(SUFFIXES) do
      if n:sub(-(#s + 1)) == (" " .. s) then
        n = trim(n:sub(1, #n - #s - 1))
        removed = true
        break
      end
    end
    if not removed then break end
  end
  return n
end

local function normalizeNameForIcon(fullName)
  return stripSuffixes(stripPrefixes(fullName or ""))
end

local function fsExists(path)
  local f = io.open(path, "r")
  if f then f:close() return true end
  return false
end

local function closeDefaultDexWindows()
  local function nuke()
    local te = modules and modules.game_textedit
    if te and te.textEditWindow and te.textEditWindow.destroy then
      te.textEditWindow:destroy()
      te.textEditWindow = nil
    end

    local tw = modules and modules.game_textwindow
    if tw and tw.window and tw.window.destroy then
      tw.window:destroy()
      tw.window = nil
    end
    if tw and tw.textWindow and tw.textWindow.destroy then
      tw.textWindow:destroy()
      tw.textWindow = nil
    end

    local root = g_ui.getRootWidget and g_ui.getRootWidget()
    if root and root.recursiveGetChildById then
      for _, id in ipairs({'textEditWindow','textWindow','TextEditWindow','TextWindow'}) do
        local w = root:recursiveGetChildById(id)
        if w and w.destroy then w:destroy() end
      end
    end
  end

  nuke()
  scheduleEvent(nuke, 1)
  scheduleEvent(nuke, 50)
  scheduleEvent(nuke, 150)
  scheduleEvent(nuke, 350)
end

Painel = {
  pokedex = {
    ['pnlDescricao']   = "",
    ['pnlAtaques']     = "",
    ['pnlHabilidades'] = ""
  }
}
openedDex = {}
dexMax = 0

function init()
  connect(g_game, { onEditText = showPokemonDescription, onGameEnd = hide })
end

function terminate()
  disconnect(g_game, { onEditText = showPokemonDescription, onGameEnd = hide })
end

function showPokedex()
  if pokedexWindow and pokedexWindow.destroy then
    pokedexWindow:destroy()
  end
  pokedexWindow = g_ui.displayUI('game_pokedex')
end

function hide()
  if pokedexWindow and pokedexWindow.destroy then
    pokedexWindow:destroy()
    pokedexWindow = nil
  end
  closeDefaultDexWindows()
end

function Painel.show(childName)
  if not pokedexWindow then return end
  pokedexWindow:getChildById('pnlDescricao'):getChildById('lblConteudo'):setText(Painel.pokedex['pnlDescricao'])
  pokedexWindow:getChildById('pnlAtaques'):getChildById('lblConteudo'):setText(Painel.pokedex['pnlAtaques'])
  pokedexWindow:getChildById('pnlHabilidades'):getChildById('lblConteudo'):setText(Painel.pokedex['pnlHabilidades'])

  pokedexWindow:getChildById('pnlDescricao'):setVisible(false)
  pokedexWindow:getChildById('scrDescricao'):setVisible(false)
  pokedexWindow:getChildById('pnlAtaques'):setVisible(false)
  pokedexWindow:getChildById('scrAtaques'):setVisible(false)
  pokedexWindow:getChildById('pnlHabilidades'):setVisible(false)
  pokedexWindow:getChildById('scrHabilidades'):setVisible(false)

  pokedexWindow:getChildById(childName):setVisible(true)
  pokedexWindow:getChildById('scr' .. childName:sub(4, #childName)):setVisible(true)
end

function showPokemonDescription(id, itemId, maxLength, texto, writter, time)
  if not g_game.isOnline() then return end

  local name = texto:match('Name: (.-)\n')
  local typeStr = texto:match('Type: (.-)\n')
  if not (name and typeStr) then
    return
  end

  closeDefaultDexWindows()

  showPokedex()
  if not pokedexWindow then return end

  local requiredLevel = texto:match('Required level: (.-)\n')
  local evoDesc       = texto:match('\nEvolutions:\n(.-)\n')
  local baseStats    = texto:match('\nBase Stats:\n(.-)\n\nMoves:')
  local moves         = texto:match('\nMoves:\n(.-)\nAbility:')
  local ability       = texto:sub((texto:find('Ability:\n') or 0) + 9)

  pokedexWindow:getChildById('lblPokeName'):setText(name)
  if name:find("^Shiny ") then
    pokedexWindow:getChildById('lblPokeName'):setColor("red")
  else
    pokedexWindow:getChildById('lblPokeName'):setColor("blue")
  end

  local baseName = normalizeNameForIcon(name)
  local diskVar  = "modules/game_pokedex/imagens/pokemons/" .. name     .. ".png"
  local diskBase = "modules/game_pokedex/imagens/pokemons/" .. baseName .. ".png"
  local uiVar    = "/game_pokedex/imagens/pokemons/" .. name     .. ".png"
  local uiBase   = "/game_pokedex/imagens/pokemons/" .. baseName .. ".png"

  local chosenUi
  if fsExists(diskVar) then
    chosenUi = uiVar
  elseif fsExists(diskBase) then
    chosenUi = uiBase
  else
    print(string.format("[Pokedex] Image not found: '%s' (tried: '%s' and '%s')", name, diskVar, diskBase))
  end
  if chosenUi then
    pokedexWindow:getChildById('imgPokemon'):setImage(chosenUi)
  end

  Painel.pokedex["pnlDescricao"] = string.format(
    "Tipo: %s\nNivel Requerido: %s\n\nEvolucoes:\n%s\n\nBase Stats:\n%s",
    tostring(typeStr or "?"),
    tostring(requiredLevel or "?"),
    tostring(evoDesc or "-"),
    tostring(baseStats or "-")
  )
  Painel.pokedex["pnlAtaques"]     = tostring(moves   or "-")
  Painel.pokedex["pnlHabilidades"] = tostring(ability or "-")

  Painel.show('pnlDescricao')

  closeDefaultDexWindows()
end
