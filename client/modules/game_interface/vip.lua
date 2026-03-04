local OPCODE_VIP = 101
g_game.onExtendedOpcode(function(opcode, buffer)
  if opcode ~= OPCODE_VIP then return end
  local name, flag = buffer:match("^(.-)|(%d+)$")
  if not name then return end
  flag = tonumber(flag) or 0

  g_vipFlags = g_vipFlags or {}
  g_vipFlags[name] = (flag == 1)
end)
