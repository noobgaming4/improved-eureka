local system = require("scripts/systems/system")
local vector2 = require("scripts/classes/vector2")

local GRAVITY = vector2.new(0,100)

local SHAPES = {
    RECTANGLE = "rectangle",
    CIRCLE = "circle"
}

local SYSTEM_ID = "PHYSICS_SYSTEM"

local function circleToCircle(circleInst1, circleInst2)
    
end

local function getRotatedCorners(rectangleInstance)
    local hx = rectangleInstance.size.x * 0.5
    local hy = rectangleInstance.size.y * 0.5
    local c = math.cos(rectangleInstance.rotation)
    local s = math.sin(rectangleInstance.rotation)
    local pos = rectangleInstance.position

    -- Top Right (hx, hy)
    local tr = vector2.new(pos.x + (hx * c - hy * s), pos.y + (hx * s + hy * c))
    
    -- Top Left (-hx, hy)
    local tl = vector2.new(pos.x + (-hx * c - hy * s), pos.y + (-hx * s + hy * c))
    
    -- Bottom Left (-hx, -hy)
    local bl = vector2.new(pos.x + (-hx * c - -hy * s), pos.y + (-hx * s + -hy * c))
    
    -- Bottom Right (hx, -hy)
    local br = vector2.new(pos.x + (hx * c - -hy * s), pos.y + (hx * s + -hy * c))

    return tr, tl, bl, br
end

local function isInsideCircle(circlePosition, circleRadius, position)
    return (circlePosition - position):getMagnitude() <= circleRadius
end

local function isInsideRectangle(position, rectangleInstance)
    local position_relative = position - rectangleInstance.position
    local rotatedPoint = position_relative:rotate(-rectangleInstance.rotation)

    return math.abs(rotatedPoint.x) <= rectangleInstance.size.x/2 and math.abs(rotatedPoint.y) <= rectangleInstance.size.y/2
end

local function circleToRectangle(circleInstance, rectangleInstance)
    local topRight,topLeft,bottomLeft,bottomRight = getRotatedCorners(rectangleInstance)

    local circleRadius = circleInstance.size.x
    local circlePosition = circleInstance.position

    local axis = (circlePosition - rectangleInstance.position):getUnit()

    local vertexes = {topRight, topLeft, bottomLeft, bottomRight}
    for i,v in ipairs(vertexes) do
        if isInsideCircle(circlePosition, circleRadius, v) then
            return true,axis
        end    
    end

    if isInsideRectangle(circlePosition, rectangleInstance) then
        return true,axis
    end

    return false
end

local function projectPositionToAxis(position,axis)
    return vector2.dot(position,axis)
end

local function getProjectionRange(axis, ...)
    local minimum = math.huge
    local maximum = -math.huge
    for i,v in ipairs({...}) do
        local projected = projectPositionToAxis(v,axis)
        if projected <= minimum then
            minimum = projected
        end

        if projected >= maximum then
            maximum = projected
        end
    end

    return minimum,maximum
end

local function checkCollisionOnLine(min1,max1, min2,max2)
    return max1 >= min2 and min1 <= max2 -- TODO: EXAMINE LOGIC
end

local function getRectangleNormalAxises(topRight,topLeft,bottomLeft) -- returns: width normal, heigth normal

    local rectangle1_vector1 = topRight - topLeft
    local rectangle1_normal1 = rectangle1_vector1:getUnit():getPerpendicularCounterClockwise()
    
    local rectangle1_vector2 = topLeft - bottomLeft
    local rectangle1_normal2 = rectangle1_vector2:getUnit():getPerpendicularCounterClockwise()

    return rectangle1_normal1, rectangle1_normal2
end

local function rectangleToRectangle(rectangleInstance1, rectangleInstance2)
    local topRight1,topLeft1,bottomLeft1,bottomRight1 = getRotatedCorners(rectangleInstance1)
    local topRight2,topLeft2,bottomLeft2,bottomRight2 = getRotatedCorners(rectangleInstance2)

    local axis1,axis2 = getRectangleNormalAxises(topRight1,topLeft1,bottomLeft1)
    local axis3,axis4 = getRectangleNormalAxises(topRight2,topLeft2,bottomLeft2)
    
    local axis_list = {axis1,axis2,axis3,axis4}

    local colliding = true
    local colliding_axis = nil
    
    local smallest_overlap = math.huge

    for i,axis in ipairs(axis_list) do
        local min1,max1 = getProjectionRange(axis, topRight1,topLeft1,bottomLeft1,bottomRight1)
        local min2,max2 = getProjectionRange(axis, topRight2,topLeft2,bottomLeft2,bottomRight2)
        
        

        if not checkCollisionOnLine(min1,max1,min2,max2) then
            return false
        else
            local diff = math.min(max1,max2) - math.max(min1,min2)
            if diff <= smallest_overlap then
                smallest_overlap = diff
                colliding_axis = axis
            end
            
        end
    end

    local difference_vector = rectangleInstance2.position - rectangleInstance1.position
    if vector2.dot(difference_vector, colliding_axis) < 0 then
        colliding_axis = colliding_axis *-1
    end

    local collision_point = (rectangleInstance1.position + rectangleInstance2.position)/2

    return colliding,colliding_axis,collision_point
end

local collisionIdToFunction = {
    [SHAPES.RECTANGLE .. SHAPES.RECTANGLE] = rectangleToRectangle, 
    [SHAPES.CIRCLE .. SHAPES.RECTANGLE] = circleToRectangle,-- TODO 
    [SHAPES.RECTANGLE .. SHAPES.CIRCLE] = function(rectangleInstance, circleInstance)
        circleToRectangle(circleInstance, rectangleInstance) -- TODO
    end
}

local function getInstanceSystemData(instance)
    return instance.system_data[SYSTEM_ID] 
end

local function isColliding(instance1, instance2)
    local s1 = getInstanceSystemData(instance1)
    local s2 = getInstanceSystemData(instance2)

    local colliding,colliding_axis,collision_point = collisionIdToFunction[s1.shape .. s2.shape](instance1, instance2)

    return colliding,colliding_axis,collision_point
end

local function applyForceAtPoint(targetInstance, forceVector, point)
    local inst_data = getInstanceSystemData(targetInstance)
    


    local vector_to_point = point - targetInstance.position
        
    local torque = -vector2.cross(vector_to_point, forceVector)
    inst_data.torque = inst_data.torque + torque

    inst_data.net_force = inst_data.net_force + forceVector
end

local function calculateCollisionsForInstance(physicInstances, physicInstance, dt)
    for i,v in ipairs(physicInstances) do
       
        if not (v == physicInstance) then
            local colliding,colliding_axis,collision_point =  isColliding(physicInstance, v)

            if colliding then
                local inst_data = getInstanceSystemData(physicInstance)
                local collider_data = getInstanceSystemData(v)
                
                local relative_velocity = inst_data.velocity - collider_data.velocity

                local velocity_component_size = vector2.dot(relative_velocity, colliding_axis)
                
                if velocity_component_size >= 0 then
                    local final_force = colliding_axis*velocity_component_size*(inst_data.mass/dt*-1)

                             

                    applyForceAtPoint(physicInstance, final_force * (1 + inst_data.bounciness) , collision_point)
                end
            end
           
        end
    end

end

local function getInertia(shape, instance, inst_data)
    local inst_data = inst_data or getInstanceSystemData(instance)
    if shape == SHAPES.RECTANGLE then
        return inst_data.mass * (instance.size.x*instance.size.x + instance.size.y*instance.size.y)/12
    end
end

local physics_system = {}

function physics_system.new()
    local data = system.new()

    data.system_id = SYSTEM_ID

    function data:initSystemData(tab, instance)
       tab.net_force = vector2.new(0,0)
       tab.velocity = vector2.new(0,0)
       tab.mass = 1 
       tab.shape = SHAPES.RECTANGLE
       tab.anchored = false
       tab.torque = 0
       tab.inertia = getInertia(tab.shape, instance, tab)
       tab.rotation_speed = 0
       tab.bounciness = 0.2
    end
    
    

    function data:update(dt)
        for i,instance in ipairs(self.subscribers) do
            local inst_data = self:getInstanceSystemData(instance)

            if not inst_data.anchored then
                inst_data.net_force:clear()
                inst_data.net_force = inst_data.net_force + GRAVITY*inst_data.mass
                
                inst_data.torque = 0

                calculateCollisionsForInstance(self.subscribers, instance, dt)

                inst_data.velocity = inst_data.velocity + inst_data.net_force*(1/inst_data.mass)*dt
                instance.position = instance.position + inst_data.velocity*dt

                local rotational_acceleration = inst_data.torque / inst_data.inertia
                
                inst_data.rotation_speed = inst_data.rotation_speed + rotational_acceleration*dt
                instance.rotation = (instance.rotation + inst_data.rotation_speed*dt) % math.rad(360)
            end
            
            
        end
    end

    function data:setInstanceSystemProperty(instance, propertyName, value)
        local inst_data = self:getInstanceSystemData(instance)
        inst_data[propertyName] = value
    end

    function data:setAnchored(instance, value)
        local inst_data = self:getInstanceSystemData(instance)
        inst_data.anchored = value
    end

    function data:setShape(instance, shape)
        local inst_data = self:getInstanceSystemData(instance)
        inst_data.shape = shape
        inst_data.inertia = getInertia(shape, instance)
        
    end

    data.SHAPES = SHAPES

    return data
end


return physics_system