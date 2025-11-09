

PlayerWalkPotState = Class{__includes = BaseState}

function PlayerWalkPotState:init(player, dungeon)
	self.player = player
	self.dungeon = dungeon

	self.player:changeAnimation('walk-pot-' .. self.player.direction)

end

function PlayerWalkPotState:update(dt)
	if love.keyboard.isDown('left') then
        self.player.direction = 'left'
        self.player:changeAnimation('walk-pot-left')
    elseif love.keyboard.isDown('right') then
        self.player.direction = 'right'
        self.player:changeAnimation('walk-pot-right')
    elseif love.keyboard.isDown('up') then
        self.player.direction = 'up'
        self.player:changeAnimation('walk-pot-up')
    elseif love.keyboard.isDown('down') then
        self.player.direction = 'down'
        self.player:changeAnimation('walk-pot-down')
    else
        self.player:changeState('idle-pot')
    end


    if self.player.direction == 'left' then
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
        
        if self.player.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then 
            self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
        end

    elseif self.player.direction == 'right' then
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt

        if self.player.x + self.player.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
        end
    elseif self.player.direction == 'up' then
        self.player.y = self.player.y - PLAYER_WALK_SPEED * dt

        if self.player.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.player.height / 2 then 
            self.player.y = self.player.y + PLAYER_WALK_SPEED * dt
        end
    elseif self.player.direction == 'down' then
        self.player.y = self.player.y + PLAYER_WALK_SPEED * dt

        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

        if self.player.y + self.player.height >= bottomEdge then
            self.player.y = self.player.y - PLAYER_WALK_SPEED * dt
        end
    end

    
    --check collision with every object
    local objs = self.dungeon.currentRoom.objects
    for k, object in pairs(objs) do

        if self.player:collides(object) and object.solid then

            if self.player.direction == 'left' then
                self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
            elseif self.player.direction == 'right' then
                self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
            elseif self.player.direction == 'up' then
                self.player.y = self.player.y + PLAYER_WALK_SPEED * dt
            else
                self.player.y = self.player.y - PLAYER_WALK_SPEED * dt
            end
        end
    end

end

function PlayerWalkPotState:render()
	local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end