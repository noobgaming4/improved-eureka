local button = {}

local signal = require("scripts/classes/signal")
local instance = require("scripts/classes/instance")
local vector2 = require("scripts/classes/vector2")

local input_manager = require("scripts/input_manager")

function button.new(position, size, image, defaultQuad, hoverQuad)
    local self = instance.new(position, size)

    self.image = image
    self.defaultQuad = defaultQuad
    self.hoverQuad = hoverQuad
    self.mouseHovering = false

    function self:update(dt)
        local x,y = love.mouse.getPosition()
        
        local half = size*0.5
        local top_left_corner = position - half
        local bottom_right_corner = position + half


        local colliding = 
            (top_left_corner.x <= x  ) and ( x <= bottom_right_corner.x)
            and
            (top_left_corner.y <= y ) and (y <= bottom_right_corner.y)
        
        
        self.mouseHovering = colliding
    end

    function self:draw()

        love.graphics.draw(self.image, self.mouseHovering and self.hoverQuad or self.defaultQuad  ,self.position.x, self.position.y, self.rotation)
    end

    input_manager.events.mousePressed:connect(function()
        if self.mouseHovering then
            self.clicked:fire()
        end
    end)

    self.clicked = signal.new(self)

    return self
end


return button