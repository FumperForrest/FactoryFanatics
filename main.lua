local beltHandler = require("src/belts")
local woodUnitHandler = require("src/woodUnits")

function love.load()
  tileSize = 32
  iteration = 0
  maxIterate = 10
  
  building = false
  buildRotation = 0
  block = nil
  
  beltImage = love.graphics.newImage("assets/belt.png")
  beltFrames = {}
  table.insert(beltFrames, love.graphics.newQuad(0,0, 32, 32, 64, 32))
  table.insert(beltFrames, love.graphics.newQuad(32,0, 32, 32, 64, 32))
  
  currentBeltFrame = 1
  
  belts = {}
  beltSpeed = .15
  beltCooldown = 0
  
  placeButtonImage = love.graphics.newImage("assets/placeButton.png")
  placeButtonStates = {}
  table.insert(placeButtonStates, love.graphics.newQuad(0,0, 32, 32, 64, 32))
  table.insert(placeButtonStates, love.graphics.newQuad(32,0, 32, 32, 64, 32))
  
  buttonState = 1
  
  hotbarImage = love.graphics.newImage("assets/hotbar.png")
  
  woodUnitImage = love.graphics.newImage("assets/woodUnit.png")
  woodUnitFrames = {}
  table.insert(woodUnitFrames, love.graphics.newQuad(0,0, 32, 32, 128, 32))
  table.insert(woodUnitFrames, love.graphics.newQuad(32,0, 32, 32, 128, 32))
  table.insert(woodUnitFrames, love.graphics.newQuad(64,0, 32, 32, 128, 32))
  table.insert(woodUnitFrames, love.graphics.newQuad(96,0, 32, 32, 128, 32))
  
  currentWoodUnitFrame = 1
  
  woodUnits = {}
  
  woodImage = love.graphics.newImage("assets/wood.png")
end

function love.update(dt)
  if iteration < maxIterate then
    iteration = iteration + 1
  else
    iteration = 0
    
    if currentBeltFrame == 1 then
      currentBeltFrame = 2
    else
      currentBeltFrame = 1
    end
    
    if currentWoodUnitFrame >= 4 then
      currentWoodUnitFrame = 1
    else
      currentWoodUnitFrame = currentWoodUnitFrame + 1
    end
  end
  
  beltCooldown = beltCooldown + beltSpeed
    
  if beltCooldown > 10 then
    beltHandler.updateAdjacentBelts(belts)
    woodUnitHandler.updateAdjacentBelts(woodUnits, belts)
    
    beltCooldown = 0
  end
end

function love.draw()
  for i, v in pairs(belts) do
    drawRotation = math.rad(v.direction * 90)
    
    love.graphics.draw(beltImage, beltFrames[currentBeltFrame], v.x + tileSize/2, v.y + tileSize/2, drawRotation, 1, 1, tileSize/2, tileSize/2)
    if v.item then
      love.graphics.draw(v.item, v.x, v.y)
    end
  end
  
  for i, v in pairs(woodUnits) do
    if v.state == false then
      love.graphics.draw(woodUnitImage, woodUnitFrames[1], v.x, v.y)
    else
      love.graphics.draw(woodUnitImage, woodUnitFrames[currentWoodUnitFrame], v.x, v.y)
    end
  end
  
  love.graphics.draw(placeButtonImage, placeButtonStates[buttonState], 0, 0)
  
  if building then
    love.graphics.draw(hotbarImage, love.graphics:getWidth() / 2 - 64, love.graphics.getHeight() - 48)
    
    love.graphics.draw(beltImage, beltFrames[currentBeltFrame], love.graphics:getWidth() / 2 - 64, love.graphics.getHeight() - 48)
    love.graphics.draw(woodUnitImage, woodUnitFrames[currentWoodUnitFrame], love.graphics:getWidth() / 2 - 32, love.graphics.getHeight() - 48)
    
    if block then
      if block == beltImage then
        love.graphics.draw(beltImage, beltFrames[currentBeltFrame], love.mouse:getX(), love.mouse:getY(), math.rad(buildRotation * 90), 1, 1, tileSize / 2, tileSize / 2)
      elseif block == woodUnitImage then
        love.graphics.draw(woodUnitImage, woodUnitFrames[1], love.mouse:getX(), love.mouse:getY())
      else
        love.graphics.draw(block, love.mouse:getX(), love.mouse:getY())
      end
    end
  end
end

function love.mousepressed(mouseX,mouseY,button)
  if button == 1 then
    if mouseX > 0 and mouseX < 32 and mouseY > 0 and mouseY < 32 then
      buttonState = 3 - buttonState
      
      if buttonState == 2 then
        building = true
      else
        building = false
      end
    end
    
    --Belt Item Selection
    if mouseX > love.graphics:getWidth() / 2 - 64 and mouseX < love.graphics:getWidth() / 2 - 32 and mouseY > love.graphics.getHeight() - 48 and mouseY < love.graphics.getHeight() - 12 then
      block = beltImage
    end
    
    --Wood Unit Item Selection
    if mouseX > love.graphics:getWidth() / 2 - 32 and mouseX < love.graphics:getWidth() / 2 and mouseY > love.graphics.getHeight() - 48 and mouseY < love.graphics.getHeight() - 12 then
      block = woodUnitImage
    end
    
  elseif button == 2 then
    if building then
      tileX = math.floor(mouseX / tileSize) * tileSize
      tileY = math.floor(mouseY / tileSize) * tileSize
      
      for i,v in pairs(belts) do
        if v.x == tileX and v.y == tileY then
          return
        end
      end
      
      for i,v in pairs(woodUnits) do
        if v.x == tileX and v.y == tileY then
          return
        end
      end
      
      if block == beltImage then
        table.insert(belts, {
            x = tileX,
            y = tileY,
            item = nil,
            direction = buildRotation,
            adjacentBelts = {},
          })
      elseif block == woodUnitImage then
        table.insert(woodUnits, {
            x = tileX,
            y = tileY,
            state = false,
            adjacentBelts = {},
          })
      end
    else
      for i,v in pairs(woodUnits) do
        if mouseX > v.x and mouseX < v.x + tileSize and mouseY > v.y and mouseY < v.y + tileSize then
          v.state = not v.state
        end
      end
    end
  end
end

function love.keypressed(key)
  if key == "r" and building then
    if buildRotation == 0 then
      buildRotation = 3
    else
      buildRotation = buildRotation - 1
    end
  end
end