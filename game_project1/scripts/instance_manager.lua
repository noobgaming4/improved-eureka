local manager = {}

local instances = {}

local physicsModule = require("scripts/systems/physics_system")

manager.systems = {
    PHYSICS = physicsModule.new()
}

local function remove_instance(instance)
    for i = #instances, 1, -1 do
        if instances[i] == instance then
            table.remove(instances, i)
            break
        end
    end
end

function manager.register(instance)
    instance.destroying:connect(function()
        remove_instance(instance)
    end)

    table.insert(instances, instance)
end

function manager.update(dt)
    manager.systems.PHYSICS:update(dt)

    for i,v in ipairs(instances) do
        v:update(dt)
    end
end

function manager.draw()
    for i,v in ipairs(instances) do
        v:draw()
    end
end

function manager.getInstances()
    return instances
end

function manager.subscribeToSystem(instance, system)
    system:subscribe(instance)
end

return manager