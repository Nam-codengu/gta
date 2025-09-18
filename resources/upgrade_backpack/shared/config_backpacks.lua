Config = {}

-- Backpack upgrade configuration
Config.UpgradeItems = {
    backpack = {
        label = "Balo",
        maxLevel = 15,
        slotPerLevel = 3,
        weightPerLevel = 15,
        upgradeStones = {
            [1] = "stone_lv1", [2] = "stone_lv1", [3] = "stone_lv1",
            [4] = "stone_lv2", [5] = "stone_lv2", [6] = "stone_lv2",
            [7] = "stone_lv3", [8] = "stone_lv3", [9] = "stone_lv3",
            [10] = "stone_lv4", [11] = "stone_lv4", [12] = "stone_lv4",
            [13] = "stone_lv5", [14] = "stone_lv5", [15] = "stone_lv5",
        },
        -- Success rates for each level (%)
        rates = {
            [1] = 35, [2] = 32, [3] = 30, [4] = 27, [5] = 25,
            [6] = 22, [7] = 20, [8] = 17, [9] = 15, [10] = 12,
            [11] = 10, [12] = 8, [13] = 6, [14] = 4, [15] = 2
        },
        -- Levels that require special talisman
        requireTalismanAt = {5, 10, 15}
    },
    -- Add more items here for future expansion
    weapon = {
        label = "Vũ khí",
        maxLevel = 10,
        slotPerLevel = 0,
        weightPerLevel = 0,
        upgradeStones = {
            [1] = "weapon_stone_lv1", [2] = "weapon_stone_lv1", [3] = "weapon_stone_lv1",
            [4] = "weapon_stone_lv2", [5] = "weapon_stone_lv2", [6] = "weapon_stone_lv2",
            [7] = "weapon_stone_lv3", [8] = "weapon_stone_lv3", [9] = "weapon_stone_lv3",
            [10] = "weapon_stone_lv4"
        },
        rates = {
            [1] = 40, [2] = 35, [3] = 30, [4] = 25, [5] = 20,
            [6] = 15, [7] = 12, [8] = 10, [9] = 7, [10] = 5
        },
        requireTalismanAt = {3, 6, 10}
    }
}

-- Ranking titles
Config.RankTitles = {
    top1 = "Thần Đập Đồ",
    top2 = "Cao Thủ Nâng Cấp", 
    top3 = "Bậc Thầy Rèn Luyện",
    lucky = "Đại Gia May Mắn",
    unlucky = "Thánh Xui",
    transfer_master = "Chuyên Gia Di Truyền",
    recycle_king = "Vua Tái Chế"
}

-- NUI settings
Config.NUI = {
    enableSound = true,
    enableEffects = true,
    defaultTab = "upgrade", -- upgrade, transfer, recycle, ranking
    closeKey = "ESC"
}

-- Database settings
Config.Database = {
    table = "backpack_upgrade_log",
    enableLogging = true
}

-- Effects and notifications
Config.Effects = {
    successEffect = "ent_dst_elec_fire_sp",
    failEffect = "ent_dst_gen_gobstop",
    transferEffect = "ent_sht_flame",
    recycleEffect = "ent_dst_inflate_ball"
}