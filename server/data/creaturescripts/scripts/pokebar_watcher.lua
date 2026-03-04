local watchers = watchers or {}

local function sortBalls(cid)
  return sortBallsForBar(cid)
end


local function makeSignature(cid)
  if not isCreature(cid) then return "" end
  local parts, balls = {}, sortBalls(cid)
  for i = 1, math.min(#balls, 6) do
    local name = getItemAttribute(balls[i].uid, "poke") or ""
    parts[#parts+1] = name .. "#" .. balls[i].uid
  end
  return table.concat(parts, ";")
end

local function tick(cid)
  if not isCreature(cid) then return end
  local w = watchers[cid]
  if not w then return end

  local nowSig = makeSignature(cid)
  if nowSig ~= w.sig then
    w.sig = nowSig
    sendAllPokemonsBarPoke(cid)
  end
  w.eid = addEvent(tick, 500, cid)
end

function onLogin(cid)
  watchers[cid] = { sig = "", eid = nil }
  addEvent(function()
    if not isCreature(cid) then return end
    watchers[cid].sig = makeSignature(cid)
    sendAllPokemonsBarPoke(cid)
    tick(cid)
  end, 150)
  return true
end

function onLogout(cid)
  local w = watchers[cid]
  if w and w.eid then
    stopEvent(w.eid)
  end
  watchers[cid] = nil
  doPlayerSendCancel(cid, "BarClosed")
  return true
end
