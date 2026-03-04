MEGA_CFG = MEGA_CFG or {
  [24] = { names = { "gengar", "shiny gengar" } },
  [25] = { names = { "blastoise", "shiny blastoise" } },
  [26] = { names = { "charizard", "shiny charizard" } }, -- Charizardite Y
  [27] = { names = { "charizard", "shiny charizard" } }, -- Charizardite X
  [28] = { names = { "venusaur", "shiny venusaur" } },
  [29] = { names = { "pidgeot", "shiny pidgeot" } },
  [30] = { names = { "kangaskhan", "shiny kangaskhan" } },
  [31] = { names = { "alakazam", "shiny alakazam" } },
  [32] = { names = { "gyarados", "shiny gyarados" } },
  [33] = { names = { "beedrill", "shiny beedrill" } },
  [34] = { names = { "pinsir", "shiny pinsir" } },
}

MEGA_OUTFITS = {
  [24] = {
    ["Gengar"]        = 3562,
    ["Shiny Gengar"]  = 3558,
  },
  [25] = {
    ["Blastoise"]        = 3560,
    ["Shiny Blastoise"]  = 3571,
  },
  [26] = {
    ["Charizard"]        = 3565,
    ["Shiny Charizard"]  = 3569,
  },
  [27] = {
    ["Charizard"]        = 3564,
    ["Shiny Charizard"]  = 3570,
  },
  [28] = {
    ["Venusaur"]        = 3574,
    ["Shiny Venusaur"]  = 3575,
  },
  [29] = {
    ["Pidgeot"]         = 3578,
    ["Shiny Pidgeot"]   = 3579,
  },
  [30] = {
    ["Kangaskhan"]      = 3576,
    ["Shiny Kangaskhan"]= 3577,
  },
  [31] = {
    ["Alakazam"]        = 3556,
    ["Shiny Alakazam"]  = 3555,
  },
  [32] = {
    ["Gyarados"]        = 3585,
    ["Shiny Gyarados"]  = 3582,
  },
  [33] = {
    ["Beedrill"]        = 3580,
    ["Shiny Beedrill"]  = 3581,
  },
  [34] = {
    ["Pinsir"]        = 3584,
    ["Shiny Pinsir"]  = 3583,
  },
}

local function _norm(s) return tostring(s or ""):lower() end
local STORAGE_MEGA_OLD_LOOK = 90001
local _MEGA_NAMESETS

local function _buildSets()
  _MEGA_NAMESETS = {}
  for ident, cfg in pairs(MEGA_CFG) do
    local set = {}
    for _, nm in ipairs(cfg.names or {}) do set[_norm(nm)] = true end
    _MEGA_NAMESETS[ident] = set
  end
end

function megaGetBallIdent(ball)
  if not ball or ball.uid <= 0 then return 0 end
  return tonumber(getItemAttribute(ball.uid, "orb") or 0) or 0
end

local function _baseName(creature)
  if isTransformed and isTransformed(creature) then
    local v = getPlayerStorageValue(creature, 1010)
    if v == -1 or v == nil then v = getCreatureName(creature) end
    return _norm(v)
  end
  return _norm(getCreatureName(creature))
end

function megaIsEligible(summon, ball)
  if not summon or not isCreature(summon) then return false end
  if not _MEGA_NAMESETS then _buildSets() end
  local ident = megaGetBallIdent(ball)
  local allowed = _MEGA_NAMESETS[ident]
  if not allowed then return false end
  return allowed[_baseName(summon)] == true
end

local function megaTargetOutfit(name, ident)
  local byIdent = MEGA_OUTFITS[ident or 0]
  return byIdent and byIdent[name or ""] or nil
end

function megaApplyVisuals(summon, ballUid, isActive)
  if not isCreature(summon) then return end

  local p = getThingPos(summon)
  doSendMagicEffect({ x = p.x + 1, y = p.y + 1, z = p.z }, 665)

  local name  = getCreatureName(summon)
  local ident = megaGetBallIdent({ uid = ballUid })

  local IDENT_TO_MEGA_FORM = {
    [27] = MEGA_X,
    [26] = MEGA_Y,
    [32] = MEGA_SINGLE,
    [34] = MEGA_SINGLE,
  }

  local tgt = megaTargetOutfit(name, ident)
  if not tgt then
    if not isActive then
      setMegaForm(summon, MEGA_NONE)
    else
      setMegaForm(summon, IDENT_TO_MEGA_FORM[ident] or MEGA_NONE)
    end
    return
  end

  if isActive then
    local cur = getCreatureOutfit(summon).lookType
    setPlayerStorageValue(summon, STORAGE_MEGA_OLD_LOOK, cur)
    doSetCreatureOutfit(summon, { lookType = tgt }, -1)

    setMegaForm(summon, IDENT_TO_MEGA_FORM[ident] or MEGA_NONE)
  else
    local old = tonumber(getPlayerStorageValue(summon, STORAGE_MEGA_OLD_LOOK) or 0) or 0
    if old > 0 then
      doSetCreatureOutfit(summon, { lookType = old }, -1)
      setPlayerStorageValue(summon, STORAGE_MEGA_OLD_LOOK, -1)
    else
      local base = tonumber(getPokemonXMLOutfit(name) or 0)
      if base and base > 0 then
        doSetCreatureOutfit(summon, { lookType = base }, -1)
      end
    end

    setMegaForm(summon, MEGA_NONE)
  end
end
