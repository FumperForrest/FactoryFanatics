local belt = {}

function beltUpdate()
  
end

function belt.updateAdjacentBelts(belts)
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
      if l.x == targetX and l.y == targetY then
        table.insert(v.adjacentBelts, l)
        break
      end
    end
  end
  
  for i,v in pairs(belts) do
    for k, l in pairs(v.adjacentBelts) do
      if not l.item then
        l.item = v.item
        v.item = nil
      end
    end
    
    v.adjacentBelts = {}
  end
end

return belt
