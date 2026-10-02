local vector2 = require("scripts/classes/vector2")
local signal = require("scripts/classes/signal")

local instance_manager = require("scripts/instance_manager")

local instance = {}

function instance.new(position, size, rotation)
    local self = {
        position = position,
        size = size,
        rotation = rotation or 0,

        system_data = {}
    }

    function self:update(deltaTime)

    end

    function self:draw()

    end

    function self:destroy()
        self.destroying:fire()
        self.destroying:destroy()
    end

    self.destroying = signal.new()

    instance_manager.register(self)

    return self
end



return instance