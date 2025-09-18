Config = {}

Config.UpgradeItems = {
    backpack = {
        label = "Balo",
        icon = "backpack.png", -- Optional: icon file name in /nui/icons/
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
    },
    weapon_pistol = {
        label = "Súng Ngắn",
        icon = "pistol.png", -- Optional: icon file name in /nui/icons/
        maxLevel = 10,
        upgradeStones = {
            [1] = "da_lv1", [2] = "da_lv1", [3] = "da_lv2",
            [4] = "da_lv2", [5] = "da_lv3", [6] = "da_lv3",
            [7] = "da_lv4", [8] = "da_lv4", [9] = "da_lv5",
            [10] = "da_lv5"
        },
        rates = {
            [1] = 35, [2] = 32, [3] = 28, [4] = 25, [5] = 22,
            [6] = 18, [7] = 15, [8] = 12, [9] = 8, [10] = 5
        },
        requireTalismanAt = {3, 6, 9}
    },
    armor = {
        label = "Áo Giáp",
        -- No icon field - will display name only
        maxLevel = 8,
        upgradeStones = {
            [1] = "da_lv1", [2] = "da_lv1", [3] = "da_lv2",
            [4] = "da_lv2", [5] = "da_lv3", [6] = "da_lv3",
            [7] = "da_lv4", [8] = "da_lv4"
        },
        rates = {
            [1] = 40, [2] = 35, [3] = 30, [4] = 25,
            [5] = 20, [6] = 15, [7] = 10, [8] = 5
        },
        requireTalismanAt = {4, 8}
    }
}

Config.RankTitles = {
    top1 = "Thần Đập Đồ",
    lucky = "Đại Gia May Mắn",
    unlucky = "Thánh Xui"
}