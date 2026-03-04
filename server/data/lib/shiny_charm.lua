SHINY_CHARM = SHINY_CHARM or {}

SHINY_CHARM.DURATION = 3 * 24 * 60 * 60
SHINY_CHARM.CHANCE_PERCENT = 15
SHINY_CHARM.SPAWN_DELAY_MS = 5000

SHINY_CHARM.STOR = {
    ACTIVE_UNTIL = 90450,
    PAUSED_FLAG = 90451,
    REMAINING_SEC = 90452
}

local function _now()
    return os.time()
end
local function rng(percent)
    return math.random(100) <= (percent or 0)
end

local function isShinyBaseName(name)
    return name and name:match("^%s*Shiny[%s%-_]+")
end

local function baseNameFrom(name)
    if not name then
        return ""
    end
    name = tostring(name)
    name = name:gsub("^%s*Shiny[%s%-_]+", "")
    return string.upper(name:sub(1, 1)) .. string.lower(name:sub(2))
end

local function shinyVariantExists(baseName)
    if type(pokes) ~= "table" then
        return false
    end
    local shinyKey = "Shiny " .. baseName
    return pokes[shinyKey] ~= nil
end

local function getClosestSpawnPosNearPlayer(cid)
    local p = getCreaturePosition(cid)
    if not p then
        return nil
    end
    local free = getClosestFreeTile(cid, p, false, true)
    if free then
        return free
    end
    local deltas = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}}
    for _, d in ipairs(deltas) do
        local pos = {
            x = p.x + d[1],
            y = p.y + d[2],
            z = p.z
        }
        return pos
    end
    return p
end

local function _getUntil(cid)
    return tonumber(getPlayerStorageValue(cid, SHINY_CHARM.STOR.ACTIVE_UNTIL)) or 0
end

local function _setUntil(cid, v)
    setPlayerStorageValue(cid, SHINY_CHARM.STOR.ACTIVE_UNTIL, tonumber(v) or 0)
end

local function _getPaused(cid)
    return getPlayerStorageValue(cid, SHINY_CHARM.STOR.PAUSED_FLAG) == 1
end

local function _setPaused(cid, flag)
    setPlayerStorageValue(cid, SHINY_CHARM.STOR.PAUSED_FLAG, flag and 1 or 0)
end

local function _getRemainingPaused(cid)
    return tonumber(getPlayerStorageValue(cid, SHINY_CHARM.STOR.REMAINING_SEC)) or 0
end

local function _setRemainingPaused(cid, sec)
    setPlayerStorageValue(cid, SHINY_CHARM.STOR.REMAINING_SEC, math.max(0, tonumber(sec) or 0))
end

local function _p(n, s, pl) return n == 1 and s or pl end
local function _fmtTimePT(sec)
  if sec <= 0 then return "alguns instantes" end
  local days  = math.floor(sec / 86400)
  local rem   = sec % 86400
  local hours = math.floor(rem / 3600)
  local mins  = math.ceil((rem % 3600) / 60)

  if mins == 60 then hours = hours + 1; mins = 0 end
  if hours == 24 then days = days + 1; hours = 0 end

  if days > 0 and hours > 0 and mins > 0 then
    return string.format("%d %s, %d %s e %d %s", days, _p(days,"dia","dias"), hours, _p(hours,"hora","horas"), mins, _p(mins,"minuto","minutos"))
  elseif days > 0 and hours > 0 then
    return string.format("%d %s e %d %s", days, _p(days,"dia","dias"), hours, _p(hours,"hora","horas"))
  elseif days > 0 then
    return string.format("%d %s", days, _p(days,"dia","dias"))
  elseif hours > 0 and mins > 0 then
    return string.format("%d %s e %d %s", hours, _p(hours,"hora","horas"), mins, _p(mins,"minuto","minutos"))
  elseif hours > 0 then
    return string.format("%d %s", hours, _p(hours,"hora","horas"))
  else
    return string.format("%d %s", mins, _p(mins,"minuto","minutos"))
  end
end

function shinyCharmPrettyRemaining(cid)
  local rem = shinyCharmGetRemaining(cid)
  return _fmtTimePT(rem)
end

function shinyCharmGetRemaining(cid)
    if _getPaused(cid) then
        return _getRemainingPaused(cid)
    end
    local untilTs = _getUntil(cid)
    return math.max(0, untilTs - _now())
end

function shinyCharmIsActive(cid)
    return shinyCharmGetRemaining(cid) > 0
end

function shinyCharmActivate(cid, seconds)
    local add = seconds or SHINY_CHARM.DURATION
    local rem = shinyCharmGetRemaining(cid)
    local newTotal = rem + add

    _setPaused(cid, false)
    _setRemainingPaused(cid, 0)
    _setUntil(cid, _now() + newTotal)

    return _getUntil(cid)
end

function shinyCharmPauseOnLogout(cid)

    if _getPaused(cid) then
        return
    end
    local rem = shinyCharmGetRemaining(cid)
    if rem > 0 then
        _setRemainingPaused(cid, rem)
        _setPaused(cid, true)
        _setUntil(cid, 0)
    end
end

function shinyCharmResumeOnLogin(cid)
    if not _getPaused(cid) then
        return
    end
    local rem = _getRemainingPaused(cid)
    if rem > 0 then
        _setUntil(cid, _now() + rem)
    end
    _setPaused(cid, false)
    _setRemainingPaused(cid, 0)
end

function shinyCharmOnKill(cid, monsterName)
    if not shinyCharmIsActive(cid) then
        return false
    end
    if not monsterName or monsterName == "" then
        return false
    end
    if _getPaused(cid) then
        return false
    end

    if getPlayerStorageValue(cid, 990) >= 1 then
        return false
    end

    if isShinyBaseName(monsterName) then
        return false
    end

    local base = baseNameFrom(monsterName)
    if base == "" then
        return false
    end
    if not shinyVariantExists(base) then
        return false
    end

    if not rng(SHINY_CHARM.CHANCE_PERCENT) then
        return false
    end

    local shinyName = "Shiny " .. base
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Um " .. shinyName .. " ira aparecer em 5 segundos!")

    addEvent(function(pcid, pname)
        if not isPlayer(pcid) then
            return
        end
        if not shinyCharmIsActive(pcid) then
            return
        end

        local pos = getClosestSpawnPosNearPlayer(pcid) or getCreaturePosition(pcid)
        if not pos then
            return
        end

        local spawned = doCreateMonster(pname, pos, false)
        if tonumber(spawned) == nil then
            doSendMagicEffect(pos, CONST_ME_POFF)
            return
        end

        doSendMagicEffect(pos, CONST_ME_MAGIC_RED)

        local spos = getCreaturePosition(spawned)
        if spos then
            doSendMagicEffect(spos, 18)
        end
    end, SHINY_CHARM.SPAWN_DELAY_MS, cid, shinyName)

    return true
end
