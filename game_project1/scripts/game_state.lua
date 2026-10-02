local game_states = {}

--[[

STATE = {

    enter()
    update(deltaTime)
    exit()
}

--]]

game_states.STATES = {
    STATE_MENU = require("scripts/states/menu"),
    STATE_GAME = require("scripts/states/game")
}

local currentState = nil

function game_states.setState(state)
    if currentState then
        currentState.exit()
    end
    currentState = state
    state.enter()
end

function game_states.update(deltaTime)
    if not currentState then return end

    currentState.update(deltaTime)
end

function changeGameState(stateName)
    game_states.setState( game_states.STATES[stateName] )
end

return game_states