
local game_state = require("scripts/game_state")
local instance_manager = require("scripts/instance_manager")
local input_manager = require("scripts/input_manager")

function love.load()
    game_state.setState(game_state.STATES.STATE_MENU)
end

function love.update(dt)
    game_state.update(dt)
    instance_manager.update(dt)
end

function love.draw()
    instance_manager.draw()
end

function love.mousepressed(x, y, button, istouch)
    input_manager.mousepressed(x,y,button,istouch)
end