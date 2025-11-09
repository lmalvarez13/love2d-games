--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        consumable = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ['pot'] = {
        type = 'pot',
        texture = 'tiles',
        frame = 14,
        width = 16,
        height = 16,
        solid = true,
        consumable = false,
        onHand = function(player, obj)
            obj.solid = false
            obj.player_link = player
        end
    },
    ['heart'] = {
       type = 'heart',
       texture = 'hearts',
       frame = 5,
       width = 16,
       height = 16,
       solid = false,
       consumable = true,
       onConsume = function(player, obj)
            if player.health <= 4 then
                player.health = player.health + 2
            elseif player.health == 5 then
                player.health = player.health + 1
            end

        end
    }
}