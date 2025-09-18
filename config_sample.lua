-- ==================================================================
-- BACKPACK CONFIGURATION SAMPLE FILE
-- Tệp cấu hình mẫu cho hệ thống nâng cấp balo
-- ==================================================================

--[[
    HỆ THỐNG BALO NÂNG CẤP

    QUY TẮC:
    - Cấp 1: Chỉ có 1 balo mặc định (balo1)
    - Cấp 2-12: Mỗi cấp có 3 balo nam và 3 balo nữ
    
    CẤU TRÚC TÊN BALO:
    - Cấp 1: balo1
    - Cấp 2+: balo[cấp][giới tính][phiên bản]
      * Nam: balo2nam, balo2nam1, balo2nam2
      * Nữ: balo2nu, balo2nu1, balo2nu2
    
    THÔNG TIN MỖI BALO:
    - label: Tên hiển thị
    - level: Cấp balo (1-12)
    - slots: Số ô chứa đồ
    - maxWeight: Trọng lượng tối đa (tính bằng gram)
    - upgradeStone: Loại đá cần để nâng cấp
    - successRate: Tỉ lệ thành công (%)
    - gender: Giới tính (male/female/unisex)
]]

Config.BackpackSample = {
    -- LEVEL 1: Default backpack only
    [1] = {
        {
            name = "balo1",
            label = "Balo Cơ Bản Cấp 1",
            level = 1,
            slots = 10,
            maxWeight = 50000, -- 50kg
            upgradeStone = "da_lv1",
            successRate = 85,
            gender = "unisex"
        }
    },
    
    -- LEVEL 2: 3 Male + 3 Female backpacks
    [2] = {
        -- Male backpacks
        {
            name = "balo2nam",
            label = "Balo Nam Cấp 2",
            level = 2,
            slots = 12,
            maxWeight = 55000,
            upgradeStone = "da_lv1",
            successRate = 80,
            gender = "male"
        },
        {
            name = "balo2nam1",
            label = "Balo Nam Cấp 2 (Phiên bản 1)",
            level = 2,
            slots = 13,
            maxWeight = 56000,
            upgradeStone = "da_lv1",
            successRate = 80,
            gender = "male"
        },
        {
            name = "balo2nam2",
            label = "Balo Nam Cấp 2 (Phiên bản 2)",
            level = 2,
            slots = 14,
            maxWeight = 57000,
            upgradeStone = "da_lv1",
            successRate = 80,
            gender = "male"
        },
        -- Female backpacks
        {
            name = "balo2nu",
            label = "Balo Nữ Cấp 2",
            level = 2,
            slots = 12,
            maxWeight = 55000,
            upgradeStone = "da_lv1",
            successRate = 80,
            gender = "female"
        },
        {
            name = "balo2nu1",
            label = "Balo Nữ Cấp 2 (Phiên bản 1)",
            level = 2,
            slots = 13,
            maxWeight = 56000,
            upgradeStone = "da_lv1",
            successRate = 80,
            gender = "female"
        },
        {
            name = "balo2nu2",
            label = "Balo Nữ Cấp 2 (Phiên bản 2)",
            level = 2,
            slots = 14,
            maxWeight = 57000,
            upgradeStone = "da_lv1",
            successRate = 80,
            gender = "female"
        }
    },
    
    -- LEVEL 3: Example with talisman requirement
    [3] = {
        -- Male backpacks
        {
            name = "balo3nam",
            label = "Balo Nam Cấp 3",
            level = 3,
            slots = 14,
            maxWeight = 60000,
            upgradeStone = "da_lv1",
            successRate = 75,
            gender = "male",
            requireTalisman = true -- Cấp này cần bùa may mắn
        },
        {
            name = "balo3nam1",
            label = "Balo Nam Cấp 3 (Phiên bản 1)",
            level = 3,
            slots = 15,
            maxWeight = 61000,
            upgradeStone = "da_lv1",
            successRate = 75,
            gender = "male",
            requireTalisman = true
        },
        {
            name = "balo3nam2",
            label = "Balo Nam Cấp 3 (Phiên bản 2)",
            level = 3,
            slots = 16,
            maxWeight = 62000,
            upgradeStone = "da_lv1",
            successRate = 75,
            gender = "male",
            requireTalisman = true
        },
        -- Female backpacks
        {
            name = "balo3nu",
            label = "Balo Nữ Cấp 3",
            level = 3,
            slots = 14,
            maxWeight = 60000,
            upgradeStone = "da_lv1",
            successRate = 75,
            gender = "female",
            requireTalisman = true
        },
        {
            name = "balo3nu1",
            label = "Balo Nữ Cấp 3 (Phiên bản 1)",
            level = 3,
            slots = 15,
            maxWeight = 61000,
            upgradeStone = "da_lv1",
            successRate = 75,
            gender = "female",
            requireTalisman = true
        },
        {
            name = "balo3nu2",
            label = "Balo Nữ Cấp 3 (Phiên bản 2)",
            level = 3,
            slots = 16,
            maxWeight = 62000,
            upgradeStone = "da_lv1",
            successRate = 75,
            gender = "female",
            requireTalisman = true
        }
    }
    
    -- Pattern continues for levels 4-12...
    -- Level 4-6: Use da_lv2
    -- Level 7-9: Use da_lv3  
    -- Level 10-12: Use da_lv4
    -- Success rates decrease as level increases
}

--[[
    UPGRADE STONES (Đá nâng cấp):
    - da_lv1: Đá cấp 1 (dùng cho cấp 1-3)
    - da_lv2: Đá cấp 2 (dùng cho cấp 4-6)
    - da_lv3: Đá cấp 3 (dùng cho cấp 7-9)
    - da_lv4: Đá cấp 4 (dùng cho cấp 10-12)
    
    TALISMAN REQUIREMENTS (Bùa may mắn):
    - Cần bùa may mắn ở cấp: 3, 6, 9, 12
    - Item name: bua_may_man
    
    SUCCESS RATES (Tỉ lệ thành công):
    - Cấp 1: 85%
    - Cấp 2: 80%
    - Cấp 3: 75%
    - ...giảm dần theo cấp
    - Cấp 12: 30%
    
    BACKPACK STATS (Thông số balo):
    - Slots: Tăng 2 ô mỗi cấp (cơ bản), phiên bản 1,2 có thêm 1-2 ô
    - Weight: Tăng 5kg mỗi cấp (cơ bản), phiên bản 1,2 có thêm 1-2kg
]]