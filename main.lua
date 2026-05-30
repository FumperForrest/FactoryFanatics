local beltHandler = require("src/belts")
local woodUnitHandler = require("src/woodUnits")
local woodCompactorHandler = require("src/woodCompactors")
local itemContainerHandler = require("src/itemContainers")
local ironMineHandler = require("src/ironMines")
local json = require("libraries/dkjson")
local camera = require("libraries/camera")

tileSize = 32
building = false
deleting = false
buildRotation = 0
block = nil

iteration = 0
maxIterate = 10

local cam
local camSpeed = 350

function love.load()
  
  print(love.filesystem.getSaveDirectory() .. "/save.json")
  
  love.graphics.setDefaultFilter("nearest", "nearest")
  cam = camera()
  
  beltImage = love.graphics.newImage("assets/belt.png")
  beltFrames = {}
  table.insert(beltFrames, love.graphics.newQuad(0,0, 32, 32, 64, 32))
  table.insert(beltFrames, love.graphics.newQuad(32,0, 32, 32, 64, 32))
  
  currentBeltFrame = 1
  
  belts = {}
  beltSpeed = .15
  beltCooldown = 0
  
  placeButtonImage = love.graphics.newImage("assets/placeButton.png")
  placeButtonFrames = {}
  table.insert(placeButtonFrames, love.graphics.newQuad(0,0, 32, 32, 64, 32))
  table.insert(placeButtonFrames, love.graphics.newQuad(32,0, 32, 32, 64, 32))
  placeButtonState = 1
  
  trashcanImage = love.graphics.newImage("assets/trashcan.png")
  trashcanFrames = {}
  table.insert(trashcanFrames, love.graphics.newQuad(0,0, 32, 32, 64, 32))
  table.insert(trashcanFrames, love.graphics.newQuad(32,0, 32, 32, 64, 32))
  trashcanState = 1
  
  woodUnitImage = love.graphics.newImage("assets/woodUnit.png")
  woodUnitFrames = {}
  table.insert(woodUnitFrames, love.graphics.newQuad(0,0, 32, 32, 128, 32))
  table.insert(woodUnitFrames, love.graphics.newQuad(32,0, 32, 32, 128, 32))
  table.insert(woodUnitFrames, love.graphics.newQuad(64,0, 32, 32, 128, 32))
  table.insert(woodUnitFrames, love.graphics.newQuad(96,0, 32, 32, 128, 32))
  
  currentWoodUnitFrame = 1
  
  woodUnits = {}
  
  ironMineImage = love.graphics.newImage("assets/ironMine.png")
  ironMineFrames = {}
  table.insert(ironMineFrames, love.graphics.newQuad(0,0, 32, 32, 64, 32))
  table.insert(ironMineFrames, love.graphics.newQuad(32,0, 32, 32, 64, 32))
  
  ironMines = {}
  
  woodCompactorImage = love.graphics.newImage("assets/woodCompactor.png")
  woodCompactorFrames = {}
  table.insert(woodCompactorFrames, love.graphics.newQuad(0,0, 32, 32, 128, 32))
  table.insert(woodCompactorFrames, love.graphics.newQuad(32,0, 32, 32, 128, 32))
  table.insert(woodCompactorFrames, love.graphics.newQuad(64,0, 32, 32, 128, 32))
  table.insert(woodCompactorFrames, love.graphics.newQuad(96,0, 32, 32, 128, 32))
  
  currentWoodCompactorFrame = 1
  
  woodCompactors = {}
  
  itemContainerImage = love.graphics.newImage("assets/itemContainer.png")
  itemContainerFrames = {}
  table.insert(itemContainerFrames, love.graphics.newQuad(0,0, 32, 32, 96, 32))
  table.insert(itemContainerFrames, love.graphics.newQuad(32,0, 32, 32, 96, 32))
  table.insert(itemContainerFrames, love.graphics.newQuad(64,0, 32, 32, 96, 32))
  
  currentItemContainerFrame = 1
  
  itemContainers = {}
  containerGroups = {}
  
  tiles = {}
  
  woodImage = love.graphics.newImage("assets/wood.png")
  woodPlankImage = love.graphics.newImage("assets/woodPlank.png")
  rawIronImage = love.graphics.newImage("assets/rawIron.png")
  hotbarImage = love.graphics.newImage("assets/hotbar.png")
  
  itemImages = {
    woodImage = woodImage,
    woodPlankImage = woodPlankImage,
    rawIronImage = rawIronImage,
  }
  
  if love.filesystem.getInfo("save.json") then
    local contents = love.filesystem.read("save.json")
    
    local data = json.decode(contents)
    
    for _, v in pairs(data.belts) do
      table.insert(belts, {
        x = v.x,
        y = v.y,
        direction = v.direction,
        
        adjacentBelts = {},
        
        item = v.item
      })
    end
    
    for _, v in pairs(data.woodUnits) do
      table.insert(woodUnits, {
        x = v.x,
        y = v.y,
        state = v.state,
        woodProduced = v.woodProduced,
        
        adjacentBelts = {},
      })
    end

    for i,v in pairs(data.ironMines) do
      table.insert(ironMines, {
        x = v.x,
        y = v.y,
        state = v.state,
        direction = v.direction,
        ironProduced = v.ironProduced,
        
        adjacentBelts = {},
      })
    end
    
    for _, v in pairs(data.woodCompactors) do
      table.insert(woodCompactors, {
        x = v.x,
        y = v.y,
        state = v.state,
        woodStorage = v.woodStorage,
        neededResources = 2,
        
        inputBelts = {},
        outputBelts = {},
      })
    end
    
    for _, v in pairs(data.itemContainers) do
      local container = {
        x = v.x,
        y = v.y,
        storage = v.storage,
        items = {},
        currentFrame = 1,
        
        adjacentContainers = {},
        inputBelts = {},
        outputBelts = {},
        
        groupid = v.groupid,
      }
      
      if not containerGroups[v.groupid] then
        containerGroups[v.groupid] = {
          items = {},
          storage = 0,
          members = {},
        }
      end
      
      container.group = containerGroups[v.groupid]
      
      table.insert(container.group.members, container)
      table.insert(itemContainers, container)
    end
    
    for i,v in pairs(data.groupInventories) do
      if containerGroups[i] then
        containerGroups[i].items = v
      end
    end
  end
end

function love.update(dt)
  if iteration < maxIterate then
    iteration = iteration + 1
  else
    iteration = 0
    
    if currentWoodUnitFrame >= 4 then
      currentWoodUnitFrame = 1
    else
      currentWoodUnitFrame = currentWoodUnitFrame + 1
    end
    
    if currentWoodCompactorFrame >= 4 then
      currentWoodCompactorFrame = 1
    else
      currentWoodCompactorFrame = currentWoodCompactorFrame + 1
    end
  end
  
  beltCooldown = beltCooldown + beltSpeed
    
  if beltCooldown > 10 then
    woodUnitHandler.updateAdjacentBelts()
    ironMineHandler.updateAdjacentBelts()
    woodCompactorHandler.updateAdjacentBelts()
    itemContainerHandler.updateAdjacentTiles()
    beltHandler.updateAdjacentBelts()
    
    
    if currentBeltFrame == 1 then
      currentBeltFrame = 2
    else
      currentBeltFrame = 1
    end
    
    beltCooldown = 0
  end
  
  if love.keyboard.isDown("w") then
    cam:move(0, -camSpeed * dt)
  elseif love.keyboard.isDown("a") then
    cam:move(-camSpeed * dt, 0)
  elseif love.keyboard.isDown("s") then
    cam:move(0, camSpeed * dt)
  elseif love.keyboard.isDown("d") then
    cam:move(camSpeed * dt, 0)
  end
  
  if love.keyboard.isDown("=") then
    cam:zoom(1 + 1.5 * dt)
  elseif love.keyboard.isDown("-") then
    cam:zoom(1 - 1.5 * dt)
  end
end

function love.draw()
  cam:attach()
  
  for i, v in pairs(belts) do
    drawRotation = math.rad(v.direction * 90)
    
    love.graphics.draw(beltImage, beltFrames[currentBeltFrame], v.x + tileSize/2, v.y + tileSize/2, drawRotation, 1, 1, tileSize/2, tileSize/2)
    if v.item then
      love.graphics.draw(itemImages[v.item], v.x, v.y)
    end
  end
  
  for i, v in pairs(woodUnits) do
    if v.state == false then
      love.graphics.draw(woodUnitImage, woodUnitFrames[1], v.x, v.y)
    else
      love.graphics.draw(woodUnitImage, woodUnitFrames[currentWoodUnitFrame], v.x, v.y)
    end
    
    love.graphics.print("wood produced: "..v.woodProduced, v.x - 30, v.y - 20)
  end
  
  for i, v in pairs(ironMines) do
    drawRotation = math.rad(v.direction * 90)
    
    if v.state == false then
      love.graphics.draw(ironMineImage, ironMineFrames[1], v.x + tileSize/2, v.y + tileSize/2, drawRotation, 1, 1, tileSize/2, tileSize/2)
    else
      love.graphics.draw(ironMineImage, ironMineFrames[2], v.x + tileSize/2, v.y + tileSize/2, drawRotation, 1, 1, tileSize/2, tileSize/2)
    end
    
    love.graphics.print("iron produced: "..v.ironProduced, v.x - 30, v.y - 20)
  end
  
  for i, v in pairs(woodCompactors) do
    if v.state == false then
      love.graphics.draw(woodCompactorImage, woodCompactorFrames[1], v.x, v.y)
    else
      love.graphics.draw(woodCompactorImage, woodCompactorFrames[currentWoodCompactorFrame], v.x, v.y)
    end
    
    love.graphics.print("wood storage: "..v.woodStorage, v.x - 30, v.y - 20)
  end
  
  local printedGroups = {}
  
  for i, v in pairs(itemContainers) do
    local frame = v.currentFrame or 1
    love.graphics.draw(itemContainerImage, itemContainerFrames[frame], v.x, v.y)
  end
  
  for i, v in pairs(itemContainers) do
    local g = v.group
    if g and not printedGroups[g] then
      printedGroups[g] = true

      local sumX, sumY = 0, 0
      
      for _, container in ipairs(g.members) do
        sumX = sumX + container.x
        sumY = sumY + container.y
      end

      love.graphics.print("group storage: "..g.storage, sumX/#g.members, sumY/#g.members)
      love.graphics.print("items: "..#g.items, sumX/#g.members, sumY/#g.members + 20)
    end
  end
  
  cam:detach()
  
  love.graphics.draw(placeButtonImage, placeButtonFrames[placeButtonState], 0, 0)
  love.graphics.draw(trashcanImage, trashcanFrames[trashcanState], love.graphics:getWidth()-32, 0)
  
  love.graphics.print("Rotation: "..buildRotation, 0, love.graphics:getHeight() - 32)
  
  if building then
    love.graphics.draw(hotbarImage, love.graphics:getWidth() / 2 - 64, love.graphics:getHeight() - 48)
    
    love.graphics.draw(beltImage, beltFrames[currentBeltFrame], love.graphics:getWidth() / 2 - 64, love.graphics:getHeight() - 48)
    love.graphics.draw(woodUnitImage, woodUnitFrames[currentWoodUnitFrame], love.graphics:getWidth() / 2 - 32, love.graphics:getHeight() - 48)
    love.graphics.draw(woodCompactorImage, woodCompactorFrames[currentWoodCompactorFrame], love.graphics:getWidth() / 2, love.graphics:getHeight() - 48)
    love.graphics.draw(itemContainerImage, itemContainerFrames[1], love.graphics:getWidth() / 2 + 32, love.graphics:getHeight() - 48)
    love.graphics.draw(ironMineImage, ironMineFrames[1], love.graphics:getWidth() / 2 + 64, love.graphics:getHeight() - 48)
    
    if block then
      if block == beltImage then
        love.graphics.draw(beltImage, beltFrames[currentBeltFrame], love.mouse:getX(), love.mouse:getY(), math.rad(buildRotation * 90), 1, 1, tileSize / 2, tileSize / 2)
      elseif block == woodUnitImage then
        love.graphics.draw(woodUnitImage, woodUnitFrames[1], love.mouse:getX(), love.mouse:getY(), 0, 1, 1, tileSize / 2, tileSize / 2)
      elseif block == woodCompactorImage then
        love.graphics.draw(woodCompactorImage, woodCompactorFrames[1], love.mouse:getX(), love.mouse:getY(), 0, 1, 1, tileSize / 2, tileSize / 2)
      elseif block == itemContainerImage then
        love.graphics.draw(itemContainerImage, itemContainerFrames[currentItemContainerFrame], love.mouse:getX(), love.mouse:getY(), 0, 1, 1, tileSize / 2, tileSize / 2)
      elseif block == ironMineImage then
        love.graphics.draw(ironMineImage, ironMineFrames[1], love.mouse:getX(), love.mouse:getY(), math.rad(buildRotation * 90), 1, 1, tileSize / 2, tileSize / 2)
      else
        love.graphics.draw(block, love.mouse:getX(), love.mouse:getY())
      end
    end
  end
end

function love.mousepressed(mouseX,mouseY,button)
  local worldX, worldY = cam:mousePosition()
  
  if button == 1 then
    if mouseX > 0 and mouseX < 32 and mouseY > 0 and mouseY < 32 then
      placeButtonState = 3 - placeButtonState
      
      if placeButtonState == 2 then
        building = true
        deleting = false
        
        trashcanState = 1
      else
        building = false
      end
    end
    
    if mouseX > love.graphics:getWidth() - 32 and mouseX < love.graphics:getWidth() and mouseY > 0 and mouseY < 32 then
      trashcanState = 3 - trashcanState
      
      if trashcanState == 2 then
        building = false
        deleting = true
        
        placeButtonState = 1
      else
        deleting = false
      end
    end
    
    if building then
      --Belt Placement Selection
      if mouseX > love.graphics:getWidth() / 2 - 64 and mouseX < love.graphics:getWidth() / 2 - 32 and mouseY > love.graphics:getHeight() - 48 and mouseY < love.graphics:getHeight() - 12 then
        block = beltImage
      end
      
      --Wood Unit Placement Selection
      if mouseX > love.graphics:getWidth() / 2 - 32 and mouseX < love.graphics:getWidth() / 2 and mouseY > love.graphics:getHeight() - 48 and mouseY < love.graphics:getHeight() - 12 then
        block = woodUnitImage
      end
      
      --Wood Compactor Placement Selection
      if mouseX > love.graphics:getWidth() / 2 and mouseX < love.graphics:getWidth() / 2 + 32 and mouseY > love.graphics:getHeight() - 48 and mouseY < love.graphics:getHeight() - 12 then
        block = woodCompactorImage
      end
      
      --Item Container Placement Selection
      if mouseX > love.graphics:getWidth() / 2 + 32 and mouseX < love.graphics:getWidth() / 2 + 64 and mouseY > love.graphics:getHeight() - 48 and mouseY < love.graphics:getHeight() - 12 then
        block = itemContainerImage
      end
      
      --Iron Mine Placement Selection
      if mouseX > love.graphics:getWidth() / 2 + 64 and mouseX < love.graphics:getWidth() / 2 + 96 and mouseY > love.graphics:getHeight() - 48 and mouseY < love.graphics:getHeight() - 12 then
        block = ironMineImage
      end
    end
    
    if building and not ((mouseX > love.graphics:getWidth() / 2 - 64 and mouseX < love.graphics:getWidth() / 2 - 32 and mouseY > love.graphics:getHeight() - 48 and mouseY < love.graphics:getHeight()) or (mouseX > love.graphics:getWidth() / 2 - 32 and mouseX < love.graphics:getWidth() / 2 and mouseY > love.graphics:getHeight() - 48 and mouseY < love.graphics:getHeight() - 12) or (mouseX > love.graphics:getWidth() / 2 and mouseX < love.graphics:getWidth() / 2 + 32 and mouseY > love.graphics:getHeight() - 48 and mouseY < love.graphics:getHeight() - 12) or (mouseX > love.graphics:getWidth() / 2 + 32 and mouseX < love.graphics:getWidth() / 2 + 64 and mouseY > love.graphics:getHeight() - 48 and mouseY < love.graphics:getHeight() - 12) or (mouseX > love.graphics:getWidth() - 32 and mouseX < love.graphics:getWidth() and mouseY > 0 and mouseY < 32) or (mouseX > 0 and mouseX < 32 and mouseY > 0 and mouseY < 32) or (mouseX > love.graphics:getWidth() / 2 + 64 and mouseX < love.graphics:getWidth() / 2 + 96 and mouseY > love.graphics:getHeight() - 48 and mouseY < love.graphics:getHeight() - 12)) then
      tileX = math.floor(worldX / tileSize) * tileSize
      tileY = math.floor(worldY / tileSize) * tileSize
      
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
      
      for i,v in pairs(woodCompactors) do
        if v.x == tileX and v.y == tileY then
          return
        end
      end
      
      for i,v in pairs(itemContainers) do
        if v.x == tileX and v.y == tileY then
          return
        end
      end
      
      for i,v in pairs(ironMines) do
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
            woodProduced = 0,
          })
      elseif block == ironMineImage then
        table.insert(ironMines, {
            x = tileX,
            y = tileY,
            state = false,
            direction = buildRotation,
            adjacentBelts = {},
            ironProduced = 0,
          })
      elseif block == woodCompactorImage then
        table.insert(woodCompactors, {
            x = tileX,
            y = tileY,
            state = false,
            inputBelts = {},
            outputBelts = {},
            woodStorage = 0,
            neededResources = 2,
          })
      elseif block == itemContainerImage then
        container = {
          x = tileX,
          y = tileY,
          adjacentContainers = {},
          inputBelts = {},
          outputBelts = {},
          storage = 20,
          groupid = 0,
          currentFrame = 1,
          lastItemCount = 0,
        }
          
        container.group = {container}
        
        container.group = {
          storage = 0,
          items = {},
          members = {container},
        }
        
        table.insert(containerGroups, container.group)
        container.groupid = #containerGroups
        
        table.insert(itemContainers, container)
        
      end
    else
      for i,v in pairs(woodUnits) do
        if worldX > v.x and worldX < v.x + tileSize and worldY > v.y and worldY < v.y + tileSize then
          v.state = not v.state
        end
      end
      
      for i,v in pairs(woodCompactors) do
        if worldX > v.x and worldX < v.x + tileSize and worldY > v.y and worldY < v.y + tileSize then
          v.state = not v.state
        end
      end
      
      for i,v in pairs(ironMines) do
        if worldX > v.x and worldX < v.x + tileSize and worldY > v.y and worldY < v.y + tileSize then
          v.state = not v.state
        end
      end
    end
    
    if deleting then
      for i,v in pairs(woodUnits) do
        if worldX > v.x and worldX < v.x + tileSize and worldY > v.y and worldY < v.y + tileSize - 12 then
          table.remove(woodUnits, i)
        end
      end
        
      for i,v in pairs(belts) do
        if worldX > v.x and worldX < v.x + tileSize and worldY > v.y and worldY < v.y + tileSize - 12 then
          table.remove(belts, i)
        end
      end
        
      for i,v in pairs(woodCompactors) do
        if worldX > v.x and worldX < v.x + tileSize and worldY > v.y and worldY < v.y + tileSize - 12 then
          table.remove(woodCompactors, i)
        end
      end
      
      for i,v in pairs(itemContainers) do
        if worldX > v.x and worldX < v.x + tileSize and worldY > v.y and worldY < v.y + tileSize - 12 then
          table.remove(itemContainers, i)
        end
      end
      
      for i,v in pairs(ironMines) do
        if worldX > v.x and worldX < v.x + tileSize and worldY > v.y and worldY < v.y + tileSize - 12 then
          table.remove(ironMines, i)
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

function love.quit()
  local data = {
    belts = {},
    woodUnits = {},
    ironMines = {},
    woodCompactors = {},
    itemContainers = {},
    groupInventories = {},
  }
  
  for i,v in pairs(belts) do
    table.insert(data.belts, {
      x = v.x,
      y = v.y,
      direction = v.direction,
      
      item = v.item,
    })
  end
  
  for i,v in pairs(woodUnits) do
    table.insert(data.woodUnits, {
      x = v.x,
      y = v.y,
      state = v.state,
      woodProduced = v.woodProduced,
    })
  end
  
  for i,v in pairs(ironMines) do
    table.insert(data.ironMines, {
      x = v.x,
      y = v.y,
      state = v.state,
      direction = v.direction,
      ironProduced = v.ironProduced,
    })
  end
  
  for i,v in pairs(woodCompactors) do
    table.insert(data.woodCompactors, {
      x = v.x,
      y = v.y,
      state = v.state,
      woodStorage = v.woodStorage,
    })
  end 
  
  for i,v in pairs(itemContainers) do
    table.insert(data.itemContainers, {
      x = v.x,
      y = v.y,
      storage = v.storage,
      groupid = v.groupid,
    })
  end
  
  for i,v in pairs(containerGroups) do
    table.insert(data.groupInventories, v.items)
  end
  
  local encoded = json.encode(data)
  
  love.filesystem.write("save.json", encoded)
end