--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    self.level = level
    self.shinyCount = 2

    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            -- create a new tile at X,Y with a random color and variety
            if self.level > 6 then
                table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(18), math.random(6)))
            else
                table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(18), math.random(self.level)))
            end

            local shiny_random = math.random(30)

            if self.shinyCount > 0 and shiny_random == 1 then
                self.tiles[tileY][tileX].isShiny = true
                self.shinyCount = self.shinyCount - 1
            end
        end
    end

    while self:calculateMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local hasShiny = false

        for x = 1, 8 do
            if self.tiles[y][x].isShiny  and self.tiles[y][x].shinyMatch  then
                hasShiny = true
            end
        end

        if hasShiny == true then
            matchNum = 8
        else
            local colorToMatch = self.tiles[y][1].color

            matchNum = 1
            
            -- every horizontal tile
            for x = 2, 8 do
                
                -- if this is the same color as the one we're trying to match...
                if self.tiles[y][x].color == colorToMatch then
                    matchNum = matchNum + 1
                else
                    
                    -- set this as the new color we want to watch for
                    colorToMatch = self.tiles[y][x].color

                    -- if we have a match of 3 or more up to now, add it to our matches table
                    if matchNum >= 3 then
                        local match = {}

                        -- go backwards from here by matchNum
                        for x2 = x - 1, x - matchNum, -1 do
                            
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end

                        -- add this match to our total matches table
                        table.insert(matches, match)
                    end

                    matchNum = 1

                    -- don't need to check last two if they won't be in a match
                    if x >= 7 then
                        break
                    end
                end
            end

        end


        
        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do

            if self.tiles[tile.gridY][tile.gridX].isShiny == true then
                self.shinyCount = self.shinyCount + 1
            end
            
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and varietyif self.level > 6 then

                local tile = self.level > 6 and Tile(x, y, math.random(18), math.random(6)) or Tile(x, y, math.random(18), math.random(self.level))

                local random_shiny = math.random(30)

                if self.shinyCount > 0 and random_shiny == 1 then
                    tile.isShiny = true
                    self.shinyCount = self.shinyCount - 1
                end
                
                --local tile = Tile(x, y, math.random(18), math.random(6))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:existMatch(x, y)
    local solutions = {}

    local same_colors = {}

    local middle_color = self.tiles[y][x].color

    local right = x+1 < 9 and true or false
    local left = x-1 > 0 and true or false
    local down = y+1 < 9 and true or false
    local up = y-1 > 0 and true or false

    if self.tiles[y][x].isShiny then
        table.insert(solutions, "right")
        table.insert(solutions, "left")
        table.insert(solutions, "up")
        table.insert(solutions, "down")
    end

    if right and up then
        if self.tiles[y-1][x+1].color == middle_color then
            table.insert(same_colors, "ru")

            if y-2 > 0 then 
                if self.tiles[y-2][x+1].color == middle_color then
                    table.insert(solutions, "right")
                end
            end

            if x+2 < 9 then
                if self.tiles[y-1][x+2].color == middle_color then
                    table.insert(solutions, "up")
                end
            end
        end

        if x+3 < 9 then
            if self.tiles[y][x+2].color == middle_color then
                if self.tiles[y][x+3].color == middle_color then
                    table.insert(solutions, "right")
                end
            end
        end

        if y-3 > 0 then
            if self.tiles[y-2][x].color == middle_color then
                if self.tiles[y-3][x].color == middle_color then
                    table.insert(solutions, "up")
                end
            end
        end
    end

    if right and down then
        if self.tiles[y+1][x+1].color == middle_color then
            table.insert(same_colors, "rd")

            if y+2 < 9 then
                if self.tiles[y+2][x+1].color == middle_color then
                    table.insert(solutions, "right")
                end
            end

            if x+2 < 9 then
                if self.tiles[y+1][x+2].color == middle_color then
                    table.insert(solutions, "down")
                end
            end
        end

        if x+3 < 9 then
            if self.tiles[y][x+2].color == middle_color then
                if self.tiles[y][x+3].color == middle_color then
                    table.insert(solutions, "right")
                end
            end
        end

        if y+3 < 9 then
            if self.tiles[y+2][x].color == middle_color then
                if self.tiles[y+3][x].color == middle_color then
                    table.insert(solutions, "down")
                end
            end
        end

    end

    if left and up then
        if self.tiles[y-1][x-1].color == middle_color then
            table.insert(same_colors, "lu")

            if y-2 > 0 then 
                if self.tiles[y-2][x-1].color == middle_color then
                    table.insert(solutions, "left")
                end
            end

            if x-2 > 0 then
                if self.tiles[y-1][x-2].color == middle_color then
                    table.insert(solutions, "up")
                end
            end
        end

        if x-3 > 0 then
            if self.tiles[y][x-2].color == middle_color then
                if self.tiles[y][x-3].color == middle_color then
                    table.insert(solutions, "left")
                end
            end
        end

        if y-3 > 0 then
            if self.tiles[y-2][x].color == middle_color then
                if self.tiles[y-3][x].color == middle_color then
                    table.insert(solutions, "up")
                end
            end
        end
    end

    if left and down then
        if self.tiles[y+1][x-1].color == middle_color then
            table.insert(same_colors, "ld")

            if y+2 < 9 then
                if self.tiles[y+2][x-1].color == middle_color then
                    table.insert(solutions, "left")
                end
            end

            if x-2 > 0 then
                if self.tiles[y+1][x-2].color == middle_color then
                    table.insert(solutions, "down")
                end
            end
        end

        if x-3 > 0 then
            if self.tiles[y][x-2].color == middle_color then
                if self.tiles[y][x-3].color == middle_color then
                    table.insert(solutions, "left")
                end
            end
        end

        if y+3 < 9 then
            if self.tiles[y+2][x].color == middle_color then
                if self.tiles[y+3][x].color == middle_color then
                    table.insert(solutions, "down")
                end
            end
        end
    end

    for i=1, #same_colors do
        for j=2, #same_colors do
            -- right up
            if same_colors[i] == "ru" then
                if same_colors[j] == "rd" then
                    table.insert(solutions, "right")
                end

                if same_colors[j] == "lu" then
                    table.insert(solutions, "up")
                end
            end

            --right down
            if same_colors[i] == "rd" then
                if same_colors[j] == "ru" then
                    table.insert(solutions, "right")
                end

                if same_colors[j] == "ld" then
                    table.insert(solutions, "down")
                end
            end


            --left up
            if same_colors[i] == "lu" then
                if same_colors[j] == "ru" then
                    table.insert(solutions, "up")
                end

                if same_colors[j] == "ld" then
                    table.insert(solutions, "left")
                end
            end


            --left down
            if same_colors[i] == "ld" then
                if same_colors[j] == "lu" then
                    table.insert(solutions, "left")
                end

                if same_colors[j] == "rd" then
                    table.insert(solutions, "down")
                end
            end
        end
    end


    return solutions

end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end