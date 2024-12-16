
function have_light_source(state) 
    return state:has("Lantern") or (state:has("Stick") and state:has("Boots"))
end

function have_bombs(state) 
    return state:has("Bombs")
end


function have_all_orbs(state) 
    return state:has("Orb", 4)
end

function have_all_bats(state) 
    return state:has("Bat Statue", 4)
end

function have_all_vamps(state) 
    return state:has("Vamp Statue", 8)
end

function have_special_weapon_damage(state) 
    return (
        state:has_any(("Bombs", "Shock Wand", "Cactus", "Boomerang", "Whoopee", "Hot Pants"))
    )
end

function have_special_weapon_bullet(state) 
    return (
        state:has_any(("Bombs", "Ice Spear", "Cactus", "Boomerang", "Whoopee", "Hot Pants"))
    )
end

function have_special_weapon_range_damage(state) 
    return (
        state:has_any(("Bombs", "Shock Wand", "Cactus", "Boomerang"))
    )
end

function have_special_weapon_through_walls(state) 
    return (
        state:has_any(("Bombs", "Shock Wand", "Whoopee"))
       )
end

function can_cleanse_crypts(state) 
    return (have_light_source(state) and can_enter_zombiton(state) and have_special_weapon_range_damage(
        state))
    end

# these will get removed in favor of region access reqs eventually
function can_enter_zombiton(state) 
    return state:has("Boots")
end

function can_enter_rocky_cliffs(state) 
    return state:has("Big Gem")
end

function can_enter_vampy(state) 
    return can_enter_rocky_cliffs(state) and have_light_source(state)
end

function can_enter_vampy_ii(state) 
    return can_enter_vampy(state) and state:has("Skull Key")
end

function can_enter_vampy_iii(state) 
    return can_enter_vampy_ii(state) and state:has("Bat Key")
end

function can_enter_vampy_iv(state) 
    return can_enter_vampy_iii(state) and state:has("Pumpkin Key")
end