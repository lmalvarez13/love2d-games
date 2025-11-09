

Powerup = Class{}

FALLING_SPEED = math.random(30, 70)

function Powerup:init(x, y, power)
	self.x = x
	self.y = y

	self.width = 15
	self.height = 15

	self.isVisible = false
	self.power = power
end

function Powerup:enable()
	self.isVisible = true
end

function Powerup:disable()
	self.isVisible = false
end

function Powerup:isEnabled()
	return self.isVisible
end


function Powerup:collides(target)

	if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end


function Powerup:update(dt)
	
	if self.isVisible then

		if self.power == 2 and self.y < VIRTUAL_HEIGHT - 32 then
			self.y = self.y + FALLING_SPEED * dt
		end

		if self.power == 1 then
			self.y = self.y + FALLING_SPEED * dt
		end
		
		if self.y >= VIRTUAL_HEIGHT then
			isVisible = false
		end 

	end	
	
end

function Powerup:render()

	if self.power == 1 and self.isVisible == true then
		love.graphics.draw(gTextures['main'], gFrames['powerups'][9], self.x, self.y )
	elseif self.power == 2 and self.isVisible == true then
		love.graphics.draw(gTextures['main'], gFrames['powerups'][10], self.x, self.y)
	end
	
end