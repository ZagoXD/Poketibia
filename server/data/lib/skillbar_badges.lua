STORAGE_BADGE_BASE = 9100 -- 9101..9108 (1=boulder ... 8=earth)

local function buildBadgesString(cid)
  local t = {}
  for i = 1, 8 do
    t[i] = (getPlayerStorageValue(cid, STORAGE_BADGE_BASE + i) > 0) and 1 or 0
  end
  return table.concat(t, ';')
end

local function getSkillBarStats(cid)
  local s0 = math.max(0, getPlayerStorageValue(cid, 9200)) -- Casino Coins
  local s1 = math.max(0, getPlayerStorageValue(cid, 9201)) -- Kanto Catches
  local s2 = math.max(0, getPlayerStorageValue(cid, 9202)) -- Total Catches
  local s3 = math.max(0, getPlayerStorageValue(cid, 9203)) -- Wins
  local s4 = math.max(0, getPlayerStorageValue(cid, 9204)) -- Loses
  local s5 = math.max(0, getPlayerStorageValue(cid, 9205)) -- Official Wins
  local s6 = math.max(0, getPlayerStorageValue(cid, 9206)) -- Official Loses
  local s7 = math.max(0, getPlayerStorageValue(cid, 9207)) -- PVP Score
  return s0,s1,s2,s3,s4,s5,s6,s7
end

function OTCSendSkillBar(cid)
  if not isPlayer(cid) then return false end

  local badgesStr = buildBadgesString(cid)
  local clanIcon = "default"

  local s0,s1,s2,s3,s4,s5,s6,s7 = getSkillBarStats(cid)

  local payload = string.format("%s|%d|%d|%d|%d|%d|%d|%d|%d|%s",
    clanIcon, s0,s1,s2,s3,s4,s5,s6,s7, badgesStr
  )

  doSendPlayerExtendedOpcode(cid, opcodes.OPCODE_SKILL_BAR, payload)
  return true
end
