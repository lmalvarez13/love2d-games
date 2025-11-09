
PlayerIdlePotState = Class{__includes = BaseState}

function PlayerIdlePotState:init(player, dungeon)
	self.player = player
	self.dungeon = dungeon

	self.player:changeAnimation('take-pot-' .. self.player.direction)

	self.player.offsetY = 5
    self.player.offsetX = 0
end	

function PlayerIdlePotState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.player:changeState('walk-pot')
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then

     	for k, obj in pairs(self.dungeon.currentRoom.objects) do
     		if obj.wasTaken == true then
     			obj.wasTaken = false
     			obj.isProjectile = true
     			obj:Fire(self.player.direction)
     		end
     	end

     	self.player:changeState('idle')
    end
end

function PlayerIdlePotState:render()
	local anim = self.player.currentAnimation
	

	if self.player.currentAnimation.timesPlayed > 0 then
		if self.player.direction == "down" then
			love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][3],
			math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
		elseif self.player.direction == "right" then
			love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][6],
			math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
		elseif self.player.direction == "up" then
			love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][9],
			math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
		else
			love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][12],
			math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
		end
		
	else
		love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
		math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
	end
	

end