local connection = {}

function connection.new(connectedSignal, func)
    local data = {}

    connectedSignal.connected[data] = func

    function data:disconnect()
        connectedSignal.connected[self] = nil
    end

    return data
end

local signal = {}


function signal.new(ownerInstance)
    local data = {
        connected = {}
    }

    function data:connect(func)
        return connection.new(self, func)
    end

    function data:fire(...)
        for i,v in pairs(self.connected) do
            v(...)
        end
    end

    function data:destroy()
        self.connected = {}
    end

    if ownerInstance and ownerInstance.destroying and ownerInstance.destroying ~= data then
        ownerInstance.destroying:connect(function()
            data:destroy()
        end)
    end

    return data
end


return signal