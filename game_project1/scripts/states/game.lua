local state = {}

local character = require("scripts/classes/character")
local vector2 = require("scripts/classes/vector2")
local button = require("scripts/classes/button")

local instance_manager = require("scripts/instance_manager")
local input_manager = require("scripts/input_manager")

local debugChar
local debugChar3 

local mouseC = nil

function state.enter()
    local image = love.graphics.newImage("assets/character/ankara_kare.jpg")
    debugChar = character.new(vector2.new(0,0), vector2.new(32,32), image)


    instance_manager.systems.PHYSICS:setInstanceSystemProperty(debugChar, "mass", 100)
    --instance_manager.systems.PHYSICS:setShape(debugChar, instance_manager.systems.PHYSICS.SHAPES.CIRCLE)

    local dirt = love.graphics.newImage("assets/map/dirt.png")

    local debugChar2 = character.new(vector2.new(400,600), vector2.new(72,1000), dirt)
    debugChar2.rotation = math.rad(90)
    instance_manager.systems.PHYSICS:setAnchored(debugChar2, true)

    debugChar3 = character.new(vector2.new(400,25), vector2.new(72,100), dirt)
    instance_manager.systems.PHYSICS:setInstanceSystemProperty(debugChar, "mass", 20)

    for i = 1,math.random(1,10) do
        local randomChar = character.new(vector2.new(math.random(0,800), math.random(100,700) ), vector2.new(math.random(30,70), math.random(30,60)), image )
        instance_manager.systems.PHYSICS:setInstanceSystemProperty(randomChar, "mass", math.random(100,200))
    end

    mouseC = input_manager.events.mousePressed:connect(function(x,y,button,istouch)
        debugChar.position = vector2.new(x,y)
    end)
end

function state.update(deltaTime)
    
end

function state.exit()
    mouseC:disconnect()
end

return state