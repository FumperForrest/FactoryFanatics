local wu = {}

function wu.updateAdjacentBelts()
  for i,v in pairs(woodUnits) do
    unitX = v.x
    unitY = v.y
    
    adjacentBelts = v.adjacentBelts
    
    for k,l in pairs(belts) do
      beltX = l.x
      beltY = l.y
      
      if beltX == unitX + tileSize and beltY == unitY  and l.direction == 0 then
        table.insert(adjacentBelts, l)
      elseif beltX == unitX - tileSize and beltY == unitY and l.direction == 2  then
        table.insert(adjacentBelts, l)
      elseif beltX == unitX and beltY == unitY + tileSize and l.direction == 1 then
        table.insert(adjacentBelts, l)
      elseif beltX == unitX and beltY == unitY - tileSize and l.direction == 3 then
        table.insert(adjacentBelts, l)
      end
    end
  end
  
  for i,v in pairs(woodUnits) do
    for k, l in pairs(v.adjacentBelts) do
      if v.state and not l.item then
        l.item = woodImage
        v.woodProduced = v.woodProduced + 1
      end
    end
    
    v.adjacentBelts = {}
  end
end

return wu