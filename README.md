-- warning.lua
-- Addon for Windower in Final Fantasy XI
-- Displays a persistent draggable menu with "No TP Move Detected" in green. Changes to red with TP move details when detected, each listed for 8 seconds.

_addon.name = 'warning'
_addon.author = 'Wisdomcheese4'
_addon.version = '1.0'
_addon.description = 'Warnings for mob TP moves targeting player or party.'
_addon.commands = {'warn'}

require('coroutine')
require('tables')

res = require('resources')
texts = require('texts')
config = require('config')

-- Default settings
local defaults = {
    tp_text = {
        pos = {x = 100, y = 100},  -- Position for TP alert
        text = {
            font = 'Arial',
            size = 18,  -- 30% larger than default 14
            red = 0,  -- Default green
            green = 255,
            blue = 0,
            alpha = 255,
            bold = true,
            stroke = {width = 2, red = 50, green = 50, blue = 50, alpha = 255}
        },
        flags = {draggable = true},
        bg = {visible = true, red = 0, green = 0, blue = 0, alpha = 150}
    },
    sound = 'alert.wav',  -- Place an 'alert.wav' file in the addon folder for audio cue
    display_time = 8  -- Seconds to display each TP alert
}

settings = config.load(defaults)

-- Create text object
local tp_alert_text = texts.new('${content}', settings.tp_text)
tp_alert_text:text('No TP Move Detected')
tp_alert_text:color(0, 255, 0, 255)
tp_alert_text:show()  -- Always visible

-- Table to hold active alerts
local active_alerts = T{}

-- Function to update display
local function update_display()
    if #active_alerts > 0 then
        tp_alert_text:text(table.concat(active_alerts, '\n'))
        tp_alert_text:color(255, 0, 0, 255)
    else
        tp_alert_text:text('No TP Move Detected')
        tp_alert_text:color(0, 255, 0, 255)
    end
end

-- Function to remove a specific alert
local function remove_alert(msg)
    for i, v in ipairs(active_alerts) do
        if v == msg then
            table.remove(active_alerts, i)
            break
        end
    end
    update_display()
end

-- Function to check if a name is the player or a party member
local function is_party_member(name)
    local player = windower.ffxi.get_player()
    if name == player.name then return true end
    
    local party = windower.ffxi.get_party()
    for i = 0, 5 do
        local key = 'p' .. i
        if party[key] and party[key].name == name then return true end
    end
    return false
end

-- Register action event for detecting mob TP uses (category 11)
windower.register_event('action', function(act)
    if act.category == 11 then
        local ability = res.monster_abilities[act.param]
        if ability then
            local actor = windower.ffxi.get_mob_by_id(act.actor_id)
            if actor and actor.is_npc then
                local party_targeted = false
                local targets_list = {}
                for _, target in ipairs(act.targets) do
                    local tgt_mob = windower.ffxi.get_mob_by_id(target.id)
                    if tgt_mob and is_party_member(tgt_mob.name) then
                        party_targeted = true
                        table.insert(targets_list, tgt_mob.name)
                    end
                end
                
                if party_targeted then
                    -- Build alert message
                    local targets_str = table.concat(targets_list, ', ')
                    local msg = string.format('%s --> %s', ability.en, targets_str)
                    table.insert(active_alerts, msg)
                    update_display()
                    
                    -- Schedule removal
                    coroutine.schedule(function() remove_alert(msg) end, settings.display_time)
                    
                    -- Play sound if configured
                    if settings.sound then
                        local sound_path = (windower.addon_path .. settings.sound):gsub('\\', '/')
                        if windower.file_exists(sound_path) then
                            windower.play_sound(sound_path)
                        end
                    end
                end
            end
        end
    end
end)

-- Optional commands for reloading or adjusting positions
windower.register_event('addon command', function(command, ...)
    if command == 'reload' then
        config.reload(settings)
        windower.add_to_chat(207, 'warning settings reloaded.')
    elseif command == 'pos' then
        local args = {...}
        if #args == 2 then
            settings.tp_text.pos.x = tonumber(args[1])
            settings.tp_text.pos.y = tonumber(args[2])
            config.save(settings)
            tp_alert_text:pos(settings.tp_text.pos.x, settings.tp_text.pos.y)
            windower.add_to_chat(207, 'warning position updated.')
        end
    end
end)

-- Initialization
windower.register_event('load', function()
    windower.add_to_chat(207, 'warning loaded. Place alert.wav in addon folder for sound.')
    active_alerts = T{}  -- Clear alerts
    update_display()  -- Ensure starting state

end)
