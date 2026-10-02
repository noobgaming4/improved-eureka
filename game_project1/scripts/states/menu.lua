local state = {}

local instance = require("scripts/classes/instance")
local vector2 = require("scripts/classes/vector2")
local button = require("scripts/classes/button")


local debug_button 
local debug_button_connection

function state.enter()
    local image = love.graphics.newImage("assets/menu/testbutton.png")
    local width,heigth = image:getDimensions()

    local defaultQuad = love.graphics.newQuad(0, 0, 80, 40, width, heigth)
    local hoverQuad = love.graphics.newQuad(80, 0, 80, 40, width, heigth)
    debug_button = button.new( vector2.new(100,100), vector2.new(width,heigth),  image, defaultQuad, hoverQuad)

    debug_button_connection = debug_button.clicked:connect(function()
        debug_button:destroy()
        debug_button = nil

        changeGameState("STATE_GAME")
    end)
end

function state.update(deltaTime)
    
end

function state.exit()
    debug_button = nil
    debug_button_connection:disconnect()
end

return state