local character = {}

local signal = require("scripts/classes/signal")
local instance = require("scripts/classes/instance")
local vector2 = require("scripts/classes/vector2")

local instance_manager = require("scripts/instance_manager")
local input_manager = require("scripts/input_manager")

function character.new(position, size, image)
    local self = instance.new(position, size)

    self.image = image

    local width,heigth = image:getDimensions()
    local scale1 = size.x/width
    local scale2 = size.y/heigth

    local widthHalf = width*0.5
    local heigthHalf = heigth*0.5

    function self:update(dt)
        
    end

    function self:draw()
        love.graphics.draw(self.image  ,self.position.x, self.position.y, self.rotation,scale1,scale2, widthHalf, heigthHalf )
    end

    
    instance_manager.subscribeToSystem(self, instance_manager.systems.PHYSICS)

    return self
end


return character