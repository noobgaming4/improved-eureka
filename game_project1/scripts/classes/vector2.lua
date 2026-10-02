local vector2 = {}

local meta = {}



function vector2.new(x,y)
    local self = {
        x = x,
        y = y
    }
    setmetatable(self, meta)

    return self
end

meta.__add = function(aVector, bVector)
    local result = vector2.new(
        aVector.x + bVector.x,
        aVector.y + bVector.y
    )

    return result
end

meta.__sub = function(aVector, bVector)
    local result = vector2.new(
        aVector.x - bVector.x,
        aVector.y - bVector.y
    )

    return result
end

meta.__mul = function(aVector, bNumber)
    local result = vector2.new(
        aVector.x * bNumber,
        aVector.y * bNumber
    )

    return result
end

meta.__div = function(aVector, bNumber)
    local result = vector2.new(
        aVector.x / bNumber,
        aVector.y / bNumber
    )

    return result
end

meta.__index = {
    getMagnitude = function(self)
        return math.sqrt( (self.x*self.x + self.y*self.y) )
    end,
    getUnit = function(self)
        local magnitude = self:getMagnitude()
        return vector2.new(self.x / magnitude, self.y / magnitude)
    end,
    getPerpendicularCounterClockwise = function(self)
        return vector2.new(-self.y, self.x)
    end,
    clear = function(self)
        self.x = 0
        self.y = 0
    end,
    rotate = function(self, rad)
        local c = math.cos(rad)
        local s = math.rad(rad)
        return vector2.new(  self.x*c - self.y*s, self.x*s + self.y*c )
    end,
    
}

function vector2.getDirectionTo(startPosition, endPosition)
    local diff = endPosition - startPosition
    return diff:getUnit()
end

function vector2.dot(pos1,pos2)
    return pos1.x*pos2.x + pos1.y*pos2.y
end

function vector2.cross(v1,v2)
    return v1.x * v2.y - v1.y * v2.x
end

return vector2