local system = {}

local SYSTEM_ID = "GENERIC_SYSTEM"


function system.new()
    local data = {
        subscribers = {},
        system_id = SYSTEM_ID
    }

    function data:initSystemData(system_data)
        
    end

    function data:getInstanceSystemData(instance)
        return instance.system_data[self.system_id]
    end

    function data:subscribe(instance)
        local remove_connection = instance.destroying:connect(function()
            self:unsubscribe(instance)
        end)

        local system_data = {}
        system_data.remove_connection = remove_connection

        self:initSystemData(system_data, instance)
        
        instance.system_data[self.system_id] = system_data

        table.insert(self.subscribers, instance)
    end

    function data:unsubscribe(instance)
        local system_data = instance.system_data[self.system_id]

        system_data.remove_connection:disconnect()

        instance.system_data[self.system_id] = nil

        for i = #self.subscribers, 1, -1 do
            if self.subscribers[i] == instance then
                table.remove(self.subscribers, i)
                break
            end
        end


    end

    function data:update(dt)
        
    end

    return data
end


return system