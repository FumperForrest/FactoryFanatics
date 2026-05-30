local itemContainer = {}

function itemContainer.updateAdjacentTiles()
  for i,v in pairs(itemContainers) do
    v.currentFrame = 1
    
    v.inputBelts = {}
    v.outputBelts = {}
    
    for k,l in pairs(itemContainers) do
      if (l.x == v.x + tileSize and l.y == v.y) or (l.x == v.x - tileSize and l.y == v.y) or (l.x == v.x and l.y == v.y  + tileSize) or (l.x == v.x and l.y == v.y  - tileSize) then
        if l.group ~= v.group then
          table.insert(v.group.members, l)
          l.group = v.group
          l.groupid = v.groupid
        end
      end
    end
    
    for k,l in pairs(belts) do
      targetX = v.x
      targetY = v.y
      
      -- 0 = right
      -- 1 = down
      -- 2 = left
      -- 3 = up
      
      if targetX + 32 == l.x and targetY == l.y then
        if l.direction == 0 then
          table.insert(v.outputBelts, l)
        elseif l.direction == 2 then
          table.insert(v.inputBelts, l)
        end
      elseif targetX - 32 == l.x and targetY == l.y then
        if l.direction == 0 then
          table.insert(v.inputBelts, l)
        elseif l.direction == 2 then
          table.insert(v.outputBelts, l)
        end
      elseif targetY + 32 == l.y and targetX == l.x then
        if l.direction == 1 then
          table.insert(v.outputBelts, l)
        elseif l.direction == 3 then
          table.insert(v.inputBelts, l)
        end
      elseif targetY - 32 == l.y and targetX == l.x then
        if l.direction == 1 then
          table.insert(v.inputBelts, l)
        elseif l.direction == 3 then
          table.insert(v.outputBelts, l)
        end
      end
    end
    
    v.group.storage = 0
    for _, member in pairs(v.group.members) do
      v.group.storage = v.group.storage + (member.storage or 0)
    end
    
    for _,input in pairs(v.inputBelts) do
      if input.item and #v.group.items < v.group.storage then
        table.insert(v.group.items, input.item)
        input.item = nil
        
        v.currentFrame = 2
      end
    end
    
    for _,output in pairs(v.outputBelts) do
      if not output.item and #v.group.items > 0 then
        output.item = table.remove(v.group.items, 1)
        
        v.currentFrame = 3
      end
    end
    
    if not v.groupid then
      v.groupid = #containerGroups
    end
  end
end

return itemContainer