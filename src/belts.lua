local belt = {}

function beltUpdate()
  
end

function belt.updateAdjacentBelts()
  local moves = {}
  local claimed = {}  -- track destinations already spoken for

  for i,v in pairs(belts) do
    if v.item then  -- no point checking belts without items
      local targetX = v.x
      local targetY = v.y
      
      if v.direction == 0 then
        targetX = targetX + tileSize
      elseif v.direction == 1 then
        targetY = targetY + tileSize
      elseif v.direction == 2 then
        targetX = targetX - tileSize
      elseif v.direction == 3 then
        targetY = targetY - tileSize
      end
      
      for k,l in pairs(belts) do
        if l.x == targetX and l.y == targetY and not l.item and not claimed[l] then
          table.insert(moves, {from = v, to = l})
          claimed[l] = true  -- reserve this destination
          break
        end
      end
    end
  end

  for _,move in pairs(moves) do
    move.to.item = move.from.item
    move.from.item = nil
  end
end

return belt
