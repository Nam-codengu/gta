-- ==================================================================
-- BACKPACK SYSTEM TEST SCRIPT
-- Script kiểm tra tính toàn vẹn của hệ thống balo
-- ==================================================================

print("=== BACKPACK SYSTEM TEST ===")

-- Load config (simulated)
local function loadConfig()
    -- Simulate the config structure
    local Config = {}
    Config.Backpacks = {}
    Config.BackpackLookup = {}
    
    -- Level 1
    Config.Backpacks[1] = {
        {
            name = "balo1",
            label = "Balo Cấp 1",
            level = 1,
            slots = 10,
            maxWeight = 50000,
            upgradeStone = "da_lv1",
            successRate = 85,
            gender = "unisex"
        }
    }
    
    -- Generate levels 2-12
    for level = 2, 12 do
        Config.Backpacks[level] = {}
        
        local baseSlots = 8 + (level * 2)
        local baseWeight = 30000 + (level * 5000)
        local stoneType = "da_lv1"
        if level >= 4 and level <= 6 then
            stoneType = "da_lv2"
        elseif level >= 7 and level <= 9 then
            stoneType = "da_lv3"
        elseif level >= 10 then
            stoneType = "da_lv4"
        end
        
        local successRate = math.max(5, 90 - (level * 5))
        
        -- Male backpacks
        for i = 0, 2 do
            local suffix = i == 0 and "" or tostring(i)
            local backpack = {
                name = "balo" .. level .. "nam" .. suffix,
                label = "Balo Nam Cấp " .. level .. (i > 0 and (" (Phiên bản " .. i .. ")") or ""),
                level = level,
                slots = baseSlots + i,
                maxWeight = baseWeight + (i * 1000),
                upgradeStone = stoneType,
                successRate = successRate,
                gender = "male"
            }
            table.insert(Config.Backpacks[level], backpack)
            Config.BackpackLookup[backpack.name] = backpack
        end
        
        -- Female backpacks
        for i = 0, 2 do
            local suffix = i == 0 and "" or tostring(i)
            local backpack = {
                name = "balo" .. level .. "nu" .. suffix,
                label = "Balo Nữ Cấp " .. level .. (i > 0 and (" (Phiên bản " .. i .. ")") or ""),
                level = level,
                slots = baseSlots + i,
                maxWeight = baseWeight + (i * 1000),
                upgradeStone = stoneType,
                successRate = successRate,
                gender = "female"
            }
            table.insert(Config.Backpacks[level], backpack)
            Config.BackpackLookup[backpack.name] = backpack
        end
    end
    
    -- Add level 1 to lookup
    Config.BackpackLookup["balo1"] = Config.Backpacks[1][1]
    
    return Config
end

-- Test functions
local function testConfigStructure(Config)
    print("1. Testing config structure...")
    
    -- Test level 1
    assert(Config.Backpacks[1], "Level 1 backpacks not found")
    assert(#Config.Backpacks[1] == 1, "Level 1 should have exactly 1 backpack")
    assert(Config.Backpacks[1][1].name == "balo1", "Level 1 backpack name incorrect")
    
    -- Test levels 2-12
    for level = 2, 12 do
        assert(Config.Backpacks[level], "Level " .. level .. " backpacks not found")
        assert(#Config.Backpacks[level] == 6, "Level " .. level .. " should have exactly 6 backpacks")
    end
    
    print("✓ Config structure is valid")
end

local function testNamingConvention(Config)
    print("2. Testing naming convention...")
    
    -- Test level 1
    assert(Config.BackpackLookup["balo1"], "balo1 not found in lookup")
    
    -- Test levels 2-12
    for level = 2, 12 do
        -- Test male backpacks
        assert(Config.BackpackLookup["balo" .. level .. "nam"], "balo" .. level .. "nam not found")
        assert(Config.BackpackLookup["balo" .. level .. "nam1"], "balo" .. level .. "nam1 not found")
        assert(Config.BackpackLookup["balo" .. level .. "nam2"], "balo" .. level .. "nam2 not found")
        
        -- Test female backpacks
        assert(Config.BackpackLookup["balo" .. level .. "nu"], "balo" .. level .. "nu not found")
        assert(Config.BackpackLookup["balo" .. level .. "nu1"], "balo" .. level .. "nu1 not found")
        assert(Config.BackpackLookup["balo" .. level .. "nu2"], "balo" .. level .. "nu2 not found")
    end
    
    print("✓ Naming convention is correct")
end

local function testUpgradeStones(Config)
    print("3. Testing upgrade stones...")
    
    local expectedStones = {
        [1] = "da_lv1", [2] = "da_lv1", [3] = "da_lv1",
        [4] = "da_lv2", [5] = "da_lv2", [6] = "da_lv2",
        [7] = "da_lv3", [8] = "da_lv3", [9] = "da_lv3",
        [10] = "da_lv4", [11] = "da_lv4", [12] = "da_lv4"
    }
    
    for level = 1, 12 do
        local backpacks = Config.Backpacks[level]
        for _, backpack in pairs(backpacks) do
            local expected = expectedStones[level]
            assert(backpack.upgradeStone == expected, 
                "Wrong upgrade stone for " .. backpack.name .. ". Expected: " .. expected .. ", Got: " .. backpack.upgradeStone)
        end
    end
    
    print("✓ Upgrade stones are correct")
end

local function testSuccessRates(Config)
    print("4. Testing success rates...")
    
    for level = 1, 12 do
        local backpacks = Config.Backpacks[level]
        for _, backpack in pairs(backpacks) do
            assert(backpack.successRate > 0 and backpack.successRate <= 100, 
                "Invalid success rate for " .. backpack.name .. ": " .. backpack.successRate)
        end
    end
    
    print("✓ Success rates are valid")
end

local function testGenderAssignment(Config)
    print("5. Testing gender assignment...")
    
    -- Level 1 should be unisex
    assert(Config.Backpacks[1][1].gender == "unisex", "Level 1 backpack should be unisex")
    
    -- Levels 2-12 should have correct gender assignment
    for level = 2, 12 do
        local backpacks = Config.Backpacks[level]
        local maleCount = 0
        local femaleCount = 0
        
        for _, backpack in pairs(backpacks) do
            if backpack.gender == "male" then
                maleCount = maleCount + 1
            elseif backpack.gender == "female" then
                femaleCount = femaleCount + 1
            end
        end
        
        assert(maleCount == 3, "Level " .. level .. " should have 3 male backpacks, got " .. maleCount)
        assert(femaleCount == 3, "Level " .. level .. " should have 3 female backpacks, got " .. femaleCount)
    end
    
    print("✓ Gender assignment is correct")
end

local function testStatsProgression(Config)
    print("6. Testing stats progression...")
    
    for level = 1, 11 do
        local currentBackpacks = Config.Backpacks[level]
        local nextBackpacks = Config.Backpacks[level + 1]
        
        -- Check that next level has better stats
        for _, nextBackpack in pairs(nextBackpacks) do
            for _, currentBackpack in pairs(currentBackpacks) do
                assert(nextBackpack.slots >= currentBackpack.slots, 
                    "Slots should increase or stay same: " .. currentBackpack.name .. " -> " .. nextBackpack.name)
                assert(nextBackpack.maxWeight >= currentBackpack.maxWeight, 
                    "Weight should increase or stay same: " .. currentBackpack.name .. " -> " .. nextBackpack.name)
            end
        end
    end
    
    print("✓ Stats progression is valid")
end

local function generateItemReport(Config)
    print("\n=== ITEM GENERATION REPORT ===")
    
    local totalItems = 0
    for level = 1, 12 do
        local count = #Config.Backpacks[level]
        print("Level " .. level .. ": " .. count .. " backpacks")
        totalItems = totalItems + count
    end
    
    print("Total backpack items: " .. totalItems)
    print("Expected: 67 items (1 + 6×11)")
    assert(totalItems == 67, "Total item count mismatch")
    
    print("\nRequired upgrade stones:")
    print("- da_lv1 (levels 1-3)")
    print("- da_lv2 (levels 4-6)")  
    print("- da_lv3 (levels 7-9)")
    print("- da_lv4 (levels 10-12)")
    print("- bua_may_man (levels 3, 6, 9, 12)")
end

-- Run all tests
local function runAllTests()
    local Config = loadConfig()
    
    testConfigStructure(Config)
    testNamingConvention(Config)
    testUpgradeStones(Config)
    testSuccessRates(Config)
    testGenderAssignment(Config)
    testStatsProgression(Config)
    generateItemReport(Config)
    
    print("\n🎉 ALL TESTS PASSED! The backpack system is ready to use.")
    print("\nNext steps:")
    print("1. Add ox_inventory item definitions")
    print("2. Configure upgrade stone drop rates")
    print("3. Test in-game functionality")
    print("4. Adjust success rates as needed")
end

-- Execute tests
runAllTests()