--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- default empty collision callback
    self.onCollide = function() end

    self.consumable = def.consumable
    self.wasConsumed = false
    self.onConsume = def.onConsume

    self.wasTaken = false
    self.player_link = nil
    self.onHand = def.onHand

    self.isProjectile = false

    self.deleted = false

    Event.on('fire', function(obj, dx, dy)
        Timer.tween(1, {
            [obj] = {x = obj.x + (64 * dx), y = obj.y + (64 * dy)}
        }):finish(function()
            obj.deleted = true
         end)
    end)

end

function GameObject:update(dt)

    if self.type == 'pot' and self.wasTaken then
        self.x = self.player_link.x 
        self.y = self.player_link.y - 11
    end

end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    
    if self.type == 'heart' then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
    elseif self.type == 'switch' then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
    elseif self.type == 'pot' then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
    end
end

function GameObject:Fire(direction)

    if direction == 'left' then
        Event.dispatch('fire', self, -1, 0)
    elseif direction == 'down' then
        Event.dispatch('fire', self, 0, 1)
    elseif direction == 'up' then
        Event.dispatch('fire', self, 0, -1)
    else
        Event.dispatch('fire', self, 1, 0)
    end
end