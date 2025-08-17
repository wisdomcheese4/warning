-- warning.lua
-- Addon for Windower in Final Fantasy XI
-- Displays a persistent draggable menu with "No Threat Detected" in green. Changes to red with TP move or spell details when detected, each listed for 8 seconds.

_addon.name = 'warning'
_addon.author = 'Wisdomcheese4'
_addon.version = '1.0'
_addon.description = 'Warnings for mob TP moves and spells targeting player or party.'
_addon.commands = {'warn'}

require('coroutine')
require('tables')
require('sets')

res = require('resources')
texts = require('texts')
config = require('config')

-- Default settings
local defaults = {
    tp_text = {
        pos = {x = 100, y = 100},  -- Position for alert
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
    display_time = 8,  -- Seconds to display each alert
    tracked_spells = {}  -- List of spell names to track
}

settings = config.load(defaults)
local tracked_spells = S(settings.tracked_spells)

-- Create text object
local alert_text = texts.new('${content}', settings.tp_text)
alert_text:text('No Threat Detected')
alert_text:color(0, 255, 0, 255)
alert_text:show()  -- Always visible

-- Table to hold active alerts
local active_alerts = T{}

-- Function to update display
local function update_display()
    if #active_alerts > 0 then
        alert_text:text(table.concat(active_alerts, '\n'))
        alert_text:color(255, 0, 0, 255)
    else
        alert_text:text('No Threat Detected')
        alert_text:color(0, 255, 0, 255)
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

-- Register action event for detecting mob TP readies (category 7) and spell starts (category 8)
windower.register_event('action', function(act)
    local category = act.category
    if category == 7 or category == 8 then
        local actor = windower.ffxi.get_mob_by_id(act.actor_id)
        if actor and actor.is_npc and not actor.in_party and not actor.in_alliance then
            local ability_id
            local ability_res
            local ability_type
            if #act.targets > 0 and #act.targets[1].actions > 0 then
                ability_id = act.targets[1].actions[1].param
                if category == 7 then
                    ability_res = res.monster_abilities
                    ability_type = 'TP Move'
                else  -- category 8
                    ability_res = res.spells
                    ability_type = 'Spell'
                end
                local ability = ability_res[ability_id]
                if ability and (category == 7 or tracked_spells:contains(ability.en)) then
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
    end
end)

-- Optional commands for reloading, adjusting positions, and managing tracked spells
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
            alert_text:pos(settings.tp_text.pos.x, settings.tp_text.pos.y)
            windower.add_to_chat(207, 'warning position updated.')
        end
    elseif command == 'add' then
        local args = {...}
        local spell_name = table.concat(args, ' ')
        local spell = res.spells:with('en', spell_name)
        if spell then
            tracked_spells:add(spell.en)
            settings.tracked_spells = T(tracked_spells):sort()
            config.save(settings)
            windower.add_to_chat(207, 'Added spell to track: ' .. spell.en)
        else
            windower.add_to_chat(207, 'Spell not found: ' .. spell_name)
        end
    elseif command == 'remove' then
        local args = {...}
        local spell_name = table.concat(args, ' ')
        if tracked_spells:contains(spell_name) then
            tracked_spells:remove(spell_name)
            settings.tracked_spells = T(tracked_spells):sort()
            config.save(settings)
            windower.add_to_chat(207, 'Removed spell: ' .. spell_name)
        else
            windower.add_to_chat(207, 'Spell not tracked: ' .. spell_name)
        end
    elseif command == 'list' then
        if #tracked_spells > 0 then
            windower.add_to_chat(207, 'Tracked spells: ' .. table.concat(T(tracked_spells):sort(), ', '))
        else
            windower.add_to_chat(207, 'No spells tracked.')
        end
    end
end)

-- Initialization
windower.register_event('load', function()
    windower.add_to_chat(207, 'warning loaded. Place alert.wav in addon folder for sound.')
    active_alerts = T{}  -- Clear alerts
    update_display()  -- Ensure starting state
end)