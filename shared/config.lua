Config = {}

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