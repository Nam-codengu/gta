Config = {}

-- Backpack Configuration System
Config.Backpacks = {
    -- Level 1: Default backpack only
    [1] = {
        {
            name = "balo1",
            label = "Balo Cấp 1",
            level = 1,
            slots = 10,
            maxWeight = 50000, -- 50kg in grams
            upgradeStone = "da_lv1",
            successRate = 85,
            gender = "unisex"
        }
    },
    
    -- Level 2-12: 3 male + 3 female backpacks each level
}

-- Auto-generate level 2-12 backpacks
for level = 2, 12 do
    Config.Backpacks[level] = {}
    
    -- Base stats for this level
    local baseSlots = 8 + (level * 2) -- Increasing slots per level
    local baseWeight = 30000 + (level * 5000) -- Increasing weight per level
    local stoneType = "da_lv1"
    if level >= 4 and level <= 6 then
        stoneType = "da_lv2"
    elseif level >= 7 and level <= 9 then
        stoneType = "da_lv3"
    elseif level >= 10 then
        stoneType = "da_lv4"
    end
    
    local successRate = math.max(5, 90 - (level * 5)) -- Decreasing success rate
    
    -- Male backpacks (3 variants)
    table.insert(Config.Backpacks[level], {
        name = "balo" .. level .. "nam",
        label = "Balo Nam Cấp " .. level,
        level = level,
        slots = baseSlots,
        maxWeight = baseWeight,
        upgradeStone = stoneType,
        successRate = successRate,
        gender = "male"
    })
    
    table.insert(Config.Backpacks[level], {
        name = "balo" .. level .. "nam1",
        label = "Balo Nam Cấp " .. level .. " (Phiên bản 1)",
        level = level,
        slots = baseSlots + 1,
        maxWeight = baseWeight + 1000,
        upgradeStone = stoneType,
        successRate = successRate,
        gender = "male"
    })
    
    table.insert(Config.Backpacks[level], {
        name = "balo" .. level .. "nam2",
        label = "Balo Nam Cấp " .. level .. " (Phiên bản 2)",
        level = level,
        slots = baseSlots + 2,
        maxWeight = baseWeight + 2000,
        upgradeStone = stoneType,
        successRate = successRate,
        gender = "male"
    })
    
    -- Female backpacks (3 variants)
    table.insert(Config.Backpacks[level], {
        name = "balo" .. level .. "nu",
        label = "Balo Nữ Cấp " .. level,
        level = level,
        slots = baseSlots,
        maxWeight = baseWeight,
        upgradeStone = stoneType,
        successRate = successRate,
        gender = "female"
    })
    
    table.insert(Config.Backpacks[level], {
        name = "balo" .. level .. "nu1",
        label = "Balo Nữ Cấp " .. level .. " (Phiên bản 1)",
        level = level,
        slots = baseSlots + 1,
        maxWeight = baseWeight + 1000,
        upgradeStone = stoneType,
        successRate = successRate,
        gender = "female"
    })
    
    table.insert(Config.Backpacks[level], {
        name = "balo" .. level .. "nu2",
        label = "Balo Nữ Cấp " .. level .. " (Phiên bản 2)",
        level = level,
        slots = baseSlots + 2,
        maxWeight = baseWeight + 2000,
        upgradeStone = stoneType,
        successRate = successRate,
        gender = "female"
    })
end

-- Create a lookup table for quick backpack info access
Config.BackpackLookup = {}
for level, backpacks in pairs(Config.Backpacks) do
    for _, backpack in pairs(backpacks) do
        Config.BackpackLookup[backpack.name] = backpack
    end
end

-- Upgrade Requirements
Config.UpgradeRequirements = {
    stoneAmount = 1, -- Number of upgrade stones required
    requireTalisman = {3, 6, 9, 12}, -- Levels that require talisman
    talismanItem = "bua_may_man", -- Talisman item name
}

-- Legacy support for existing upgrade items
Config.UpgradeItems = {
    backpack = {
        label = "Balo",
        maxLevel = 12,
        slotPerLevel = 2,
        weightPerLevel = 10,
        upgradeStones = {
            [1] = "da_lv1", [2] = "da_lv1", [3] = "da_lv1",
            [4] = "da_lv2", [5] = "da_lv2", [6] = "da_lv2",
            [7] = "da_lv3", [8] = "da_lv3", [9] = "da_lv3",
            [10] = "da_lv4", [11] = "da_lv4", [12] = "da_lv4",
        },
        rates = {
            [1] = 30, [2] = 28, [3] = 25, [4] = 22, [5] = 20,
            [6] = 18, [7] = 15, [8] = 12, [9] = 10, [10] = 8,
            [11] = 6, [12] = 3
        },
        requireTalismanAt = {3, 6, 9, 12}
    }
}

Config.RankTitles = {
    top1 = "Thần Đập Đồ",
    lucky = "Đại Gia May Mắn",
    unlucky = "Thánh Xui"
}

Config.RankTitles = {
    top1 = "Thần Đập Đồ",
    lucky = "Đại Gia May Mắn",
    unlucky = "Thánh Xui"
}