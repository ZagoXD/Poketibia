function onExtendedOpcode(cid, opcode, buffer)
  if opcode ~= 77 then return true end
  local tag, val = buffer:match("^([BUN]):(.+)$")
  if not tag then return true end

  if tag == "B" then
    doSendPokemon(cid, "B:" .. val)
  elseif tag == "U" then
    doSendPokemon(cid, val)
  elseif tag == "N" then
    doSendPokemon(cid, val)
  end
  return true
end
