ConfigBackpacks = {}

-- Backpack configuration with +6 slots and +10kg per level
-- 3 male and 3 female variations per level
ConfigBackpacks.Backpacks = {
    -- Level 1 Backpacks
    ['backpack_m1_lv1'] = { type = 'backpack', level = 1, gender = 'male', variant = 1, slots = 26, weight = 50 },
    ['backpack_m2_lv1'] = { type = 'backpack', level = 1, gender = 'male', variant = 2, slots = 26, weight = 50 },
    ['backpack_m3_lv1'] = { type = 'backpack', level = 1, gender = 'male', variant = 3, slots = 26, weight = 50 },
    ['backpack_f1_lv1'] = { type = 'backpack', level = 1, gender = 'female', variant = 1, slots = 26, weight = 50 },
    ['backpack_f2_lv1'] = { type = 'backpack', level = 1, gender = 'female', variant = 2, slots = 26, weight = 50 },
    ['backpack_f3_lv1'] = { type = 'backpack', level = 1, gender = 'female', variant = 3, slots = 26, weight = 50 },
    
    -- Level 2 Backpacks (+6 slots, +10kg)
    ['backpack_m1_lv2'] = { type = 'backpack', level = 2, gender = 'male', variant = 1, slots = 32, weight = 60 },
    ['backpack_m2_lv2'] = { type = 'backpack', level = 2, gender = 'male', variant = 2, slots = 32, weight = 60 },
    ['backpack_m3_lv2'] = { type = 'backpack', level = 2, gender = 'male', variant = 3, slots = 32, weight = 60 },
    ['backpack_f1_lv2'] = { type = 'backpack', level = 2, gender = 'female', variant = 1, slots = 32, weight = 60 },
    ['backpack_f2_lv2'] = { type = 'backpack', level = 2, gender = 'female', variant = 2, slots = 32, weight = 60 },
    ['backpack_f3_lv2'] = { type = 'backpack', level = 2, gender = 'female', variant = 3, slots = 32, weight = 60 },
    
    -- Level 3 Backpacks (+6 slots, +10kg)
    ['backpack_m1_lv3'] = { type = 'backpack', level = 3, gender = 'male', variant = 1, slots = 38, weight = 70 },
    ['backpack_m2_lv3'] = { type = 'backpack', level = 3, gender = 'male', variant = 2, slots = 38, weight = 70 },
    ['backpack_m3_lv3'] = { type = 'backpack', level = 3, gender = 'male', variant = 3, slots = 38, weight = 70 },
    ['backpack_f1_lv3'] = { type = 'backpack', level = 3, gender = 'female', variant = 1, slots = 38, weight = 70 },
    ['backpack_f2_lv3'] = { type = 'backpack', level = 3, gender = 'female', variant = 2, slots = 38, weight = 70 },
    ['backpack_f3_lv3'] = { type = 'backpack', level = 3, gender = 'female', variant = 3, slots = 38, weight = 70 },
    
    -- Level 4 Backpacks (+6 slots, +10kg)
    ['backpack_m1_lv4'] = { type = 'backpack', level = 4, gender = 'male', variant = 1, slots = 44, weight = 80 },
    ['backpack_m2_lv4'] = { type = 'backpack', level = 4, gender = 'male', variant = 2, slots = 44, weight = 80 },
    ['backpack_m3_lv4'] = { type = 'backpack', level = 4, gender = 'male', variant = 3, slots = 44, weight = 80 },
    ['backpack_f1_lv4'] = { type = 'backpack', level = 4, gender = 'female', variant = 1, slots = 44, weight = 80 },
    ['backpack_f2_lv4'] = { type = 'backpack', level = 4, gender = 'female', variant = 2, slots = 44, weight = 80 },
    ['backpack_f3_lv4'] = { type = 'backpack', level = 4, gender = 'female', variant = 3, slots = 44, weight = 80 },
    
    -- Level 5 Backpacks (+6 slots, +10kg)
    ['backpack_m1_lv5'] = { type = 'backpack', level = 5, gender = 'male', variant = 1, slots = 50, weight = 90 },
    ['backpack_m2_lv5'] = { type = 'backpack', level = 5, gender = 'male', variant = 2, slots = 50, weight = 90 },
    ['backpack_m3_lv5'] = { type = 'backpack', level = 5, gender = 'male', variant = 3, slots = 50, weight = 90 },
    ['backpack_f1_lv5'] = { type = 'backpack', level = 5, gender = 'female', variant = 1, slots = 50, weight = 90 },
    ['backpack_f2_lv5'] = { type = 'backpack', level = 5, gender = 'female', variant = 2, slots = 50, weight = 90 },
    ['backpack_f3_lv5'] = { type = 'backpack', level = 5, gender = 'female', variant = 3, slots = 50, weight = 90 },
}

-- Upgrade stones required for each level
ConfigBackpacks.UpgradeStones = {
    [1] = 'da_nang_cap_1', -- Stone for level 1 -> 2
    [2] = 'da_nang_cap_2', -- Stone for level 2 -> 3
    [3] = 'da_nang_cap_3', -- Stone for level 3 -> 4
    [4] = 'da_nang_cap_4', -- Stone for level 4 -> 5
}

-- Success rates for each upgrade level
ConfigBackpacks.UpgradeRates = {
    [1] = 85, -- 85% success rate for level 1 -> 2
    [2] = 70, -- 70% success rate for level 2 -> 3
    [3] = 55, -- 55% success rate for level 3 -> 4
    [4] = 40, -- 40% success rate for level 4 -> 5
}

-- Function to get backpack info by name
function ConfigBackpacks.GetBackpackInfo(itemName)
    return ConfigBackpacks.Backpacks[itemName]
end

-- Function to get next level backpack
function ConfigBackpacks.GetNextLevelBackpack(itemName)
    local current = ConfigBackpacks.Backpacks[itemName]
    if not current or current.level >= 5 then return nil end
    
    local nextLevel = current.level + 1
    local gender = current.gender == 'male' and 'm' or 'f'
    local variant = current.variant
    
    return string.format('backpack_%s%d_lv%d', gender, variant, nextLevel)
end

-- Function to check if two backpacks are same type (gender and variant)
function ConfigBackpacks.IsSameType(itemName1, itemName2)
    local info1 = ConfigBackpacks.Backpacks[itemName1]
    local info2 = ConfigBackpacks.Backpacks[itemName2]
    
    if not info1 or not info2 then return false end
    
    return info1.gender == info2.gender and info1.variant == info2.variant
end

-- Function to get required stone for upgrade
function ConfigBackpacks.GetRequiredStone(currentLevel)
    return ConfigBackpacks.UpgradeStones[currentLevel]
end

-- Function to get success rate for upgrade
function ConfigBackpacks.GetUpgradeRate(currentLevel)
    return ConfigBackpacks.UpgradeRates[currentLevel] or 0
end