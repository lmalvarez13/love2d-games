--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:enter(params)
    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)
    EntityIdleState.update(self, dt)
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk')
    end

    if love.keyboard.wasPressed('space') then
        self.entity:changeState('swing-sword')
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then

        local hitboxX, hitboxY, hitboxWidth, hitboxHeight

        if self.entity.direction == 'left' then
            hitboxWidth = 8
            hitboxHeight = 16
            hitboxX = self.entity.x - hitboxWidth
            hitboxY = self.entity.y + 2
        elseif self.entity.direction == 'right' then
            hitboxWidth = 8
            hitboxHeight = 16
            hitboxX = self.entity.x + self.entity.width
            hitboxY = self.entity.y + 2
        elseif self.entity.direction == 'up' then
            hitboxWidth = 16
            hitboxHeight = 8
            hitboxX = self.entity.x
            hitboxY = self.entity.y - hitboxHeight
        else
            hitboxWidth = 16
            hitboxHeight = 8
            hitboxX = self.entity.x
            hitboxY = self.entity.y + self.entity.height
        end

        local takeHitbox = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)
        local hit_something = false

        for k, obj in pairs(self.dungeon.currentRoom.objects) do
            if takeHitbox:collides(obj) and obj.type == "pot" then
                obj.onHand(self.entity, obj)
                obj.wasTaken = true
                hit_something = true
            end
        end

        if hit_something then
            self.entity:changeState('idle-pot')
        end
    end
end

