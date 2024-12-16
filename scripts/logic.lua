-- ap-style logic

-- set global DEBUG to true to get more output
DEBUG = true

-- TODO: use require; this will need a PopTracker update to make "nested" require() work better
ScriptHost:LoadScript("scripts/logic/helper.lua") -- load helper for AP-style logic
ScriptHost:LoadScript("scripts/logic/data/location_data.lua") -- load location_table
ScriptHost:LoadScript("scripts/logic/data/region_data.lua") -- load region_table

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

State.has = function(state, name)
    return state:count(name) > 0  -- use count to only implement the crazy mappings once
end

State.count = function(state, name)
    -- handle the ones that are simple lookups
    local code = codes[name]
    if code then
        return _count(state, code)
    end
    -- handle the ones that need special handling
    if DEBUG then
        print("Unknown item " .. name)
    end
    return _count(state, name)
end


-- logic resolvers (called from json locations)


function can_reach(location_name)
    return def:get_location(location_name):can_reach(state)
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


end

function create_regions()
    _create_regions(def)
end

ScriptHost:LoadScript("scripts/logic/data/rules_data.lua") -- load region_table
ScriptHost:LoadScript("scripts/logic/data/entrance_data.lua") -- load region_table

function set_rules()

    --set location rules
    for loc_name, rule_data in pairs(access_rule) do
        local location = def:get_location(loc_name)
        location:set_rule(rule_data)
    end

    for entry in pairs(loonyland_entrance_table) do
        local region = def:get_region(entry.Source)
        local dest = def:get_region(entry.Dest)
        region.connect(dest, rule=entry.rule)
    end
end

-- initialize logic
create_regions()  -- NOTE: we don't handle can_create for Locations, so this needs to only be run once
set_rules()

