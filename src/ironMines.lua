local ironMine = {}

function ironMine.updateAdjacentBelts()
  for i,v in pairs(ironMines) do
    unitX = v.x
    unitY = v.y
    
    adjacentBelts = v.adjacentBelts
    
    for k,l in pairs(belts) do
      beltX = l.x
      beltY = l.y
      
      if beltX == unitX + tileSize and beltY == unitY  and l.direction == 0 and v.direction == 3 then
        table.insert(adjacentBelts, l)
      elseif beltX == unitX - tileSize and beltY == unitY and l.direction == 2 and v.direction == 1 then
        table.insert(adjacentBelts, l)
      elseif beltX == unitX and beltY == unitY + tileSize and l.direction == 1 and v.direction == 0 then
        table.insert(adjacentBelts, l)
      elseif beltX == unitX and beltY == unitY - tileSize and l.direction == 3 and v.direction == 2 then
        table.insert(adjacentBelts, l)
      end
    end
  end
  
  for i,v in pairs(ironMines) do
    for k, l in pairs(v.adjacentBelts) do
      if v.state and not l.item then
        l.item = "rawIronImage"
        v.ironProduced = v.ironProduced + 1
      end
    end
    
    v.adjacentBelts = {}
  end
end

return ironMine