local force = {}

local vector2 = require("scripts/classes/vector2")

function force.new(vector)
    local data = {
        vector = vector
    }

    return data
end

return force