local signal = require("scripts/classes/signal")

local input_manager = {}

input_manager.events = {}

input_manager.events.mousePressed = signal.new()

function input_manager.mousepressed(x, y, button, istouch)
    input_manager.events.mousePressed:fire(x,y,button,istouch)
end

function input_manager.keypressed(key)

end

return input_manager