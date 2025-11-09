--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local level_width = width
    local level_height = height
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    local placedLock = false
    local placedKey = false

    -- generating a random texture for both the lock and the key
    local lockTexture = math.random(5,8)

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
                
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )

            -- chance to generate a key
            elseif math.random(10) == 1 and not placedKey then
                table.insert(objects,
                    GameObject {
                        texture = 'keys-locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = lockTexture-4,
                        collidable = true,
                        consumable = true,
                        solid = false,
                        isKey = true,

                        onConsume = function(player,object)
                            gSounds['pickup']:play()
                        end

                    }
                )
                placedKey = true
            end

            -- chance to spawn a block
            if math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            -- chance to spawn a locked block when the key was already placed
            elseif math.random(10) == 2 and not placedLock and placedKey then
               
                table.insert(objects,

                    -- locked block
                    GameObject {
                        texture = 'keys-locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        -- random frame
                        frame = lockTexture,
                        collidable = true,
                        hit = false,
                        solid = true,
                        isLock = true,

                        -- collision function takes itself
                        onCollide = function(obj)
                            local existKey = false
                            -- checks if there's a key on the map
                            for k, object in pairs(objects) do
                                if object.isKey then
                                    existKey = true
                                end

                            end

                            -- if the key was already taken then ...
                            if not existKey then

                                local pole_x , pole_y
                                
                                -- find available ground to insert the pole and the flag
                                for i = level_width-3, 1, -1 do
                                    local pole_set = false
                                    for j = 1, level_height do
                                        if tiles[j][i].id == TILE_ID_GROUND then
                                            pole_set = true
                                            pole_x = (i-1)*TILE_SIZE
                                            pole_y = ((j-1)*TILE_SIZE)-48
                                            break
                                        end 
                                    end

                                    if pole_set then
                                        break
                                    end
                                end

                                -- spawns the pole
                                table.insert(objects,
                                    GameObject{
                                        texture = 'poles',
                                        x = pole_x,
                                        y = pole_y,
                                        width = 16,
                                        height = 48,

                                        -- make it a random variant
                                        frame = 1,
                                        collidable = false,
                                        hit = false,
                                        solid = false,

                                        onCollide = function(obj) end
                                    }
                                )

                                -- spawns the flag
                                table.insert(objects,
                                    GameObject{
                                        texture = 'flags',
                                        x = pole_x+(TILE_SIZE/2),
                                        y = pole_y+(TILE_SIZE/2),
                                        width = 16,
                                        height = 48,
                                        frame = 1,
                                        consumable = true,
                                        hit = false,
                                        solid = false,

                                        onConsume = function(player, object)
                                            gStateMachine:change('play', {
                                                width = level_width+50,
                                                score = player.score
                                                })
                                        end
                                    }
                                )

                                -- set itself as nil, so the "clear" function kills it
                                for k, object in pairs(objects) do
                                    if object.isLock then
                                        objects[k] = nil
                                        break
                                    end
                                end

                            end 
                        end
                    }
                )

                placedLock = true

            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end