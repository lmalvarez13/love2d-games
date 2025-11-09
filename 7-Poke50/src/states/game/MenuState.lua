--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

MenuState = Class{__includes = BaseState}

function MenuState:init(def, onSelect)
	self.battleState = def.battleState

	self.menu = Menu({
		x = VIRTUAL_WIDTH - 144,
        y = VIRTUAL_HEIGHT - 176,
        width = 144,
        height = 112,
        cursorEnabled = false,
        items = def.items
    })
end

function MenuState:update(dt)
	self.menu:update(dt)
end

function MenuState:render()
	self.menu:render()
end