--[[
    GD50
    Breakout Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]

-- global patterns (used to make the entire map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- per-row patterns
SOLID = 1           -- all colors the same in this row
ALTERNATE = 2       -- alternate colors
SKIP = 3            -- skip every other block
NONE = 4            -- no blocks this row

LevelMaker = Class{}

--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]
function LevelMaker.createMap(level)
    local bricks = {}

    -- randomly choose the number of rows
    local numRows = math.random(1, 5)

    -- randomly choose the number of columns, ensuring odd
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    -- highest possible spawned brick color in this level; ensure we
    -- don't go above 3
    local highestTier = math.min(3, math.floor(level / 5))

    -- highest color of the highest tier, no higher than 5
    local highestColor = math.min(5, level % 5 + 3)


    local lockedBricks = math.random(0, 1)
    -- lay out bricks such that they touch each other and fill the space
    for y = 1, numRows do
        -- whether we want to enable skipping for this row
        local skipPattern = math.random(1, 2) == 1 and true or false

        -- whether we want to enable alternating colors for this row
        local alternatePattern = math.random(1, 2) == 1 and true or false
        
        -- choose two colors to alternate between
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)
        
        -- used only when we want to skip a block, for skip pattern
        local skipFlag = math.random(2) == 1 and true or false

        -- used only when we want to alternate a block, for alternate pattern
        local alternateFlag = math.random(2) == 1 and true or false

        -- solid color we'll use if we're not skipping or alternating
        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)

        for x = 1, numCols do
            local skipAll = false
            -- if skipping is turned on and we're on a skip iteration...
            if skipPattern and skipFlag then
                -- turn skipping off for the next iteration
                skipFlag = not skipFlag

                -- Lua doesn't have a continue statement, so this is the workaround
                skipAll = true
            else
                -- flip the flag to true on an iteration we don't use it
                skipFlag = not skipFlag
            end

            if not skipAll then

                b = Brick(
                    -- x-coordinate
                    (x-1)                   -- decrement x by 1 because tables are 1-indexed, coords are 0
                    * 32                    -- multiply by 32, the brick width
                    + 8                     -- the screen should have 8 pixels of padding; we can fit 13 cols + 16 pixels total
                    + (13 - numCols) * 16,  -- left-side padding for when there are fewer than 13 columns
                    
                    -- y-coordinate
                    y * 16                  -- just use y * 16, since we need top padding anyway
                )

                if lockedBricks == 1 and math.random(1, 2) == 1 then
                    b.isKey = true
                    b.isLocked = true
                    b.color = 6
                    b.tier = 0
                    lockedBricks = 0
                else
                    if alternatePattern and alternateFlag then
                        b.color = alternateColor1
                        b.tier = alternateTier1
                        alternateFlag = not alternateFlag
                    else
                        b.color = alternateColor2
                        b.tier = alternateTier2
                        alternateFlag = not alternateFlag
                    end

                    -- if not alternating and we made it here, use the solid color/tier
                    if not alternatePattern then
                        b.color = solidColor
                        b.tier = solidTier
                    end 
                end

                -- if we're alternating, figure out which color/tier we're on
                
                table.insert(bricks, b)

            else
                -- Lua's version of the 'continue' statement
                --::continue::
            end
        end
    end 

    -- in the event we didn't generate any bricks, try again
    if #bricks == 0 then
        return self.createMap(level)
    else
        return bricks
    end
end

function LevelMaker.createPowerups(bricks)
    local powerups = {}

    local numPowerups = math.random(1, 3)

    local hasKeyBrick = false
    local keyBrick_k = 0

    for k, brick in pairs(bricks) do
        if brick.isKey == true then
            hasKeyBrick = true
            keyBrick_k = k
            numPowerups = numPowerups + 1
        end
    end

    for k, brick in pairs(bricks) do

        local random = math.random(1, 4)

        if numPowerups > 0 and random == 1 then

            if hasKeyBrick == true and k ~= keyBrick_k then
                powerups[brick.id] = Powerup(brick.x + 8.5, brick.y, 2)
                hasKeyBrick = false
            else
                powerups[brick.id] = Powerup(brick.x + 8.5, brick.y, 1)
            end

            numPowerups = numPowerups - 1
        end

    end

    
    return powerups

end