-- ==================================================================
-- OX_INVENTORY ITEM DEFINITIONS FOR BACKPACK SYSTEM
-- Định nghĩa items cho ox_inventory
-- ==================================================================

--[[
    HƯỚNG DẪN SỬ DỤNG:
    1. Thêm nội dung file này vào ox_inventory/data/items.lua
    2. Hoặc import vào database của bạn
    3. Restart ox_inventory
    
    LƯU Ý:
    - Điều chỉnh weight và slots theo nhu cầu server
    - Có thể thay đổi icon và description
    - Đảm bảo tên item khớp với config
]]

-- BACKPACK ITEMS (BALO)
return {
    -- Level 1 Backpack
    ['balo1'] = {
        label = 'Balo Cơ Bản Cấp 1',
        weight = 500,
        stack = false,
        close = true,
        description = 'Balo cơ bản dành cho người mới bắt đầu. Có thể nâng cấp lên cấp cao hơn.',
        client = {
            image = 'backpack.png',
        }
    },

    -- Level 2 Backpacks (Male)
    ['balo2nam'] = {
        label = 'Balo Nam Cấp 2',
        weight = 400,
        stack = false,
        close = true,
        description = 'Balo nam cấp 2 với thiết kế mạnh mẽ và sức chứa tốt hơn.',
        client = {
            image = 'backpack_male.png',
        }
    },
    ['balo2nam1'] = {
        label = 'Balo Nam Cấp 2 (Phiên bản 1)',
        weight = 400,
        stack = false,
        close = true,
        description = 'Balo nam cấp 2 phiên bản nâng cấp với không gian bổ sung.',
        client = {
            image = 'backpack_male_v1.png',
        }
    },
    ['balo2nam2'] = {
        label = 'Balo Nam Cấp 2 (Phiên bản 2)',
        weight = 400,
        stack = false,
        close = true,
        description = 'Balo nam cấp 2 phiên bản cao cấp với tính năng đặc biệt.',
        client = {
            image = 'backpack_male_v2.png',
        }
    },

    -- Level 2 Backpacks (Female)
    ['balo2nu'] = {
        label = 'Balo Nữ Cấp 2',
        weight = 400,
        stack = false,
        close = true,
        description = 'Balo nữ cấp 2 với thiết kế tinh tế và màu sắc hài hòa.',
        client = {
            image = 'backpack_female.png',
        }
    },
    ['balo2nu1'] = {
        label = 'Balo Nữ Cấp 2 (Phiên bản 1)',
        weight = 400,
        stack = false,
        close = true,
        description = 'Balo nữ cấp 2 phiên bản nâng cấp với không gian bổ sung.',
        client = {
            image = 'backpack_female_v1.png',
        }
    },
    ['balo2nu2'] = {
        label = 'Balo Nữ Cấp 2 (Phiên bản 2)',
        weight = 400,
        stack = false,
        close = true,
        description = 'Balo nữ cấp 2 phiên bản cao cấp với thiết kế sang trọng.',
        client = {
            image = 'backpack_female_v2.png',
        }
    },

    -- UPGRADE STONES (ĐÁ NÂNG CẤP)
    ['da_lv1'] = {
        label = 'Đá Nâng Cấp Cấp 1',
        weight = 50,
        stack = true,
        close = true,
        description = 'Đá nâng cấp cơ bản, dùng để nâng cấp từ cấp 1-3.',
        client = {
            image = 'upgrade_stone_1.png',
        }
    },
    ['da_lv2'] = {
        label = 'Đá Nâng Cấp Cấp 2',
        weight = 50,
        stack = true,
        close = true,
        description = 'Đá nâng cấp trung cấp, dùng để nâng cấp từ cấp 4-6.',
        client = {
            image = 'upgrade_stone_2.png',
        }
    },
    ['da_lv3'] = {
        label = 'Đá Nâng Cấp Cấp 3',
        weight = 50,
        stack = true,
        close = true,
        description = 'Đá nâng cấp cao cấp, dùng để nâng cấp từ cấp 7-9.',
        client = {
            image = 'upgrade_stone_3.png',
        }
    },
    ['da_lv4'] = {
        label = 'Đá Nâng Cấp Cấp 4',
        weight = 50,
        stack = true,
        close = true,
        description = 'Đá nâng cấp tối cao, dùng để nâng cấp từ cấp 10-12.',
        client = {
            image = 'upgrade_stone_4.png',
        }
    },

    -- TALISMAN (BÙA MAY MẮN)
    ['bua_may_man'] = {
        label = 'Bùa May Mắn',
        weight = 10,
        stack = true,
        close = true,
        description = 'Bùa may mắn hiếm có, cần thiết để nâng cấp lên một số cấp đặc biệt.',
        client = {
            image = 'lucky_charm.png',
        }
    },

    --[[
        AUTO-GENERATED BACKPACK ITEMS FOR LEVELS 3-12
        
        Để tạo đầy đủ các item cho cấp 3-12, sử dụng pattern sau:
        
        -- Level X Male Backpacks
        ['baloXnam'] = { ... },
        ['baloXnam1'] = { ... },
        ['baloXnam2'] = { ... },
        
        -- Level X Female Backpacks  
        ['baloXnu'] = { ... },
        ['baloXnu1'] = { ... },
        ['baloXnu2'] = { ... },
        
        Với X từ 3 đến 12
        
        VÍ DỤ CHO CẤP 3:
    ]]
    
    -- Level 3 Backpacks (Example)
    ['balo3nam'] = {
        label = 'Balo Nam Cấp 3',
        weight = 350,
        stack = false,
        close = true,
        description = 'Balo nam cấp 3 với khả năng chứa đựng vượt trội.',
        client = {
            image = 'backpack_male_lv3.png',
        }
    },
    ['balo3nu'] = {
        label = 'Balo Nữ Cấp 3',
        weight = 350,
        stack = false,
        close = true,
        description = 'Balo nữ cấp 3 với thiết kế tinh xảo và chất lượng cao.',
        client = {
            image = 'backpack_female_lv3.png',
        }
    },

    --[[
        SCRIPT TỰ ĐỘNG TẠO ITEMS:
        
        Để tạo tự động tất cả items từ cấp 4-12, có thể sử dụng script Lua sau:
        
        local items = {}
        for level = 4, 12 do
            local weight = math.max(100, 500 - level * 30)
            
            -- Male backpacks
            for variant = 0, 2 do
                local suffix = variant == 0 and '' or tostring(variant)
                local variantText = variant == 0 and '' or (' (Phiên bản ' .. variant .. ')')
                
                items['balo' .. level .. 'nam' .. suffix] = {
                    label = 'Balo Nam Cấp ' .. level .. variantText,
                    weight = weight,
                    stack = false,
                    close = true,
                    description = 'Balo nam cấp ' .. level .. ' với thiết kế hiện đại.',
                    client = {
                        image = 'backpack_male_lv' .. level .. (variant > 0 and ('_v' .. variant) or '') .. '.png',
                    }
                }
                
                items['balo' .. level .. 'nu' .. suffix] = {
                    label = 'Balo Nữ Cấp ' .. level .. variantText,
                    weight = weight,
                    stack = false,
                    close = true,
                    description = 'Balo nữ cấp ' .. level .. ' với thiết kế tinh tế.',
                    client = {
                        image = 'backpack_female_lv' .. level .. (variant > 0 and ('_v' .. variant) or '') .. '.png',
                    }
                }
            end
        end
        
        return items
    ]]
}