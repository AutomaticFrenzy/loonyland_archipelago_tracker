-- ap-style logic

-- set global DEBUG to true to get more output
DEBUG = true

-- TODO: use require; this will need a PopTracker update to make "nested" require() work better
ScriptHost:LoadScript("scripts/helper.lua") -- load helper for AP-style logic
ScriptHost:LoadScript("scripts/data/game_data.lua") -- load region_table
--ScriptHost:LoadScript("scripts/rules.lua") -- load region_table

-- shorthand names from imports
local Definition = helper.Definition
local State = helper.State
local Region = helper.Region
local Location = helper.Location

-- state and world definition variables
local def = Definition:new()  -- "world" definition for logic
local state = State:new(def)  -- TODO: add caching and update in watch for code

-- patch up State.has and State.count to match the codes
local _count = State.count


-- logic resolvers (called from json locations)

function have_light_source() 
    return state:has("Lantern") or (state:has("Stick") and state:has("Boots"))
end

function have_bombs() 
    return state:has("Bombs")
end


function have_all_orbs() 
    return state:has("Orb", 4)
end


function have_all_bats() 
    return state:has("Bat Statue", 4)
end

function have_all_vamps() 
    return state:has("Vamp Statue", 8)
end

function have_special_weapon_damage() 
    
    return (   
    state:has_any{"Bombs", "Shock Wand", "Cactus", "Boomerang", "Whoopee", "Hot Pants"}
    )
end

function have_special_weapon_bullet() 
    return true
    --return (
    --    state:has_any {"Bombs","Ice Spear", "Cactus", "Boomerang", "Whoopee", "Hot Pants"}
    --)
end

function have_special_weapon_range_damage() 
    return (
        state:has_any{"Bombs", "Shock Wand", "Cactus", "Boomerang"}
    )
end

function have_special_weapon_through_walls() 
    return (
        state:has_any("Bombs", "Shock Wand", "Whoopee")
       )
end

function can_cleanse_crypts() 
    return have_light_source() and can_enter_zombiton() and have_special_weapon_bullet(
        )
    end

function can_enter_zombiton() 
    return state:has("Boots")
end

function can_enter_rocky_cliffs() 
    return state:has("Big Gem")
end

function can_enter_vampy() 
    return can_enter_rocky_cliffs() and have_light_source()
end

function can_enter_vampy_ii() 
    return can_enter_vampy() and state:has("Skull Key")
end

function can_enter_vampy_iii() 
    return can_enter_vampy_ii() and state:has("Bat Key")
end

function can_enter_vampy_iv() 
    return can_enter_vampy_iii() and state:has("Pumpkin Key")
end

function hundred_percent()
    return false
end

function have_39_badges()
    return false -- state.has_from_list_unique(state.multiworld.worlds[player].item_name_groups["cheats"], player, 39)
end

function have_all_weapons()
    return false -- state.has_all(state.multiworld.worlds[player].item_name_groups["special_weapons"], player)
end

function access(location_name)
    --print(location_name)
    local loc = def:get_location(location_name)
    --print(loc:can_reach(state))
    return loc:can_reach(state)
end

function sequence_break(location_name)
    return access(location_name)
end

function peek(location_name)
    return false
end

function can_reach(location_name)
    if not hasAnyWatch then
        state.stale = true
    end
    local loc = def:get_region(location_name)
    return loc:can_reach(state)
end

function _create_regions(def)
    def.regions:clear()  -- allow running _create_regions multiple times
    
    for region_name, _ in pairs(loonyland_region_table) do
        def.regions:append(Region:new(region_name, def))
    end

    for loc_name, loc_data in pairs(loonyland_location_table) do
        -- if not loc_data.can_create() ...
        local region = def:get_region(loc_data.region)
        local new_loc = Location:new(loc_name, loc_data.id, region)
        region.locations:append(new_loc)
    end

    for _, entry in ipairs(loonyland_entrance_table) do
        local region = def:get_region(entry.source)
        local dest = def:get_region(entry.dest)

        region:connect(dest, entry.source .. " -> " .. entry.dest, entry.rule)
    end


end

function create_regions()
    _create_regions(def)
end

function set_rules()

    --set location rules
    for loc_name, rule_data in pairs(access_rules) do
        local location = def:get_location(loc_name)
        location:set_rule(rule_data)
    end

    --entrance rules
    for _, entry in ipairs(loonyland_entrance_table) do
        local entrance = def:get_entrance(entry.source .. " -> " .. entry.dest)
        if entrance then
            entrance:set_rule(entry.rule)
        else
            print("Missing entrance: " .. entry.source)
        end
    end
    

end

function stateChanged(code)  -- run by watch for code "*" (any)
    if DEBUG then
        if code ~= "obscure" and code:find("^logic") == nil then
            print(code .. " changed")
        end
    end
    state.stale = true
end


-- initialize logic
create_regions()  -- NOTE: we don't handle can_create for Locations, so this needs to only be run once
set_rules()


ScriptHost:AddWatchForCode("stateChanged", "*", stateChanged)
