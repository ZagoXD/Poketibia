-- Mega Charm System (based on Shiny Charm)
MEGA_CHARM = {
    ITEMID = 14166,
    DURATION = 3 * 24 * 60 * 60, -- 3 days
    CHANCE = 15, -- 15%
    SPAWN_MESSAGE = "A Mega Pokemon has appeared!",
    MEGAS = {
        ["Venusaur"] = "Mega Venusaur",
        ["Charizard"] = {"Mega Charizard X", "Mega Charizard Y"},
        ["Blastoise"] = "Mega Blastoise",
        ["Alakazam"] = "Mega Alakazam",
        ["Gengar"] = "Mega Gengar",
        ["Kangaskhan"] = "Mega Kangaskhan",
        ["Pinsir"] = "Mega Pinsir",
        ["Gyarados"] = "Mega Gyarados",
        ["Beedrill"] = "Mega Beedrill",
        ["Pidgeot"] = "Mega Pidgeot",
    }
}

function megaCharmActivate(cid, duration)
    local remaining = tonumber(getCreatureStorage(cid, 1416601)) or 0
    local new_remaining = (remaining > 0 and remaining or 0) + duration
    doCreatureSetStorage(cid, 1416601, new_remaining)
    doCreatureSetStorage(cid, 1416602, os.time() + new_remaining)
    return true
end

function megaCharmGetRemaining(cid)
    local expiry = tonumber(getCreatureStorage(cid, 1416602)) or 0
    if expiry == 0 then return 0 end
    local remaining = expiry - os.time()
    return remaining > 0 and remaining or 0
end

function megaCharmPauseOnLogout(cid)
    local rem = megaCharmGetRemaining(cid)
    if rem > 0 then
        doCreatureSetStorage(cid, 1416601, rem)
        doCreatureSetStorage(cid, 1416602, 0)
    end
end

function megaCharmResumeOnLogin(cid)
    local rem = tonumber(getCreatureStorage(cid, 1416601)) or 0
    if rem > 0 then
        doCreatureSetStorage(cid, 1416602, os.time() + rem)
    end
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

function megaCharmOnKill(cid, mname)
    if megaCharmGetRemaining(cid) <= 0 then return end
    
    local mega = MEGA_CHARM.MEGAS[mname]
    if not mega then return end
    
    if math.random(1, 100) <= MEGA_CHARM.CHANCE then
        local target_mega = ""
        if type(mega) == "table" then
            target_mega = mega[math.random(1, #mega)]
        else
            target_mega = mega
        end
        
        doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Um " .. target_mega .. " ira aparecer em 5 segundos!")

        addEvent(function()
            local pos = getCreaturePosition(cid) -- Spawn at player's position for now or near it
            local monster = doCreateMonster(target_mega, pos)
            if monster then
                local p = getThingPos(monster)
                doSendMagicEffect({ x = p.x + 1, y = p.y + 1, z = p.z }, 665)
            end
        end, 5000)
    end
end

function megaCharmPrettyRemaining(cid)
    local rem = megaCharmGetRemaining(cid)
    return _fmtTimePT(rem)
end
