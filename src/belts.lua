local belt = {}

function beltUpdate()
  
end

function belt.updateAdjacentBelts(belts)
  local moves = {}
  
  for i,v in pairs(belts) do
    targetX = v.x
    targetY = v.y
    
    -- 0 = right
    -- 1 = down
    -- 2 = left
    -- 3 = up
    
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
      if l.x == targetX and l.y == targetY and not l.item then
        table.insert(moves, {from = v, to = l})
        break
      end
    end
  end
  
  local hadItem = {}
  for _,move in pairs(moves) do
    hadItem[move.from] = move.from.item
    hadItem[move.to] = move.to.item
  end
  
  for _,move in pairs(moves) do
    if hadItem[move.from] and not hadItem[move.to] then
      move.to.item = move.from.item
      move.from.item = nil
    end
  end
end

return belt
