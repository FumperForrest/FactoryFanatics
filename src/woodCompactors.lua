local woodCompactor = {}

function woodCompactorUpdate()
  
end

function woodCompactor.updateAdjacentBelts()
  for i,v in pairs(woodCompactors) do
    v.adjacentBelts = {}
    v.inputBelts = {}
    v.outputBelts = {}
    
    for k,l in pairs(belts) do
      targetX = v.x
      targetY = v.y
      
      -- 0 = right
      -- 1 = down
      -- 2 = left
      -- 3 = up
      
      if targetX + 32 == l.x and targetY == l.y and l.direction == 2 then
        table.insert(v.inputBelts, l)
      elseif targetX - 32 == l.x and targetY == l.y and l.direction == 0 then
        table.insert(v.inputBelts, l)
      elseif targetY + 32 == l.y and targetX == l.x and l.direction == 1 then
        table.insert(v.outputBelts, l)
      elseif targetY - 32 == l.y and targetX == l.x and l.direction == 3 then
        table.insert(v.outputBelts, l)
      end
    end
    
    for _,input in pairs(v.inputBelts) do
      if input.item and v.state and v.woodStorage < v.neededResources then
        v.woodStorage = v.woodStorage + 1
        input.item = nil
          
        if v.woodStorage >= v.neededResources and #v.outputBelts > 0 then
          for _, output in pairs(v.outputBelts) do
            if not output.item then
              v.woodStorage = 0
              
              output.item = woodPlankImage
            end
          end
        end
      end
    end
  end
end

return woodCompactor
