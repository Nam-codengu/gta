// Global variables
let playerInventory = [];
let currentTab = 'upgrade';
let selectedUpgradeItem = null;
let selectedSourceItem = null;
let selectedTargetItem = null;
let selectedRecycleItem = null;

// Initialize when NUI is loaded
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch (data.action) {
        case 'openMenu':
            openMenu(data.playerInventory);
            break;
        case 'closeMenu':
            closeMenu();
            break;
        case 'upgradeResult':
            handleUpgradeResult(data);
            break;
        case 'transferResult':
            handleTransferResult(data);
            break;
        case 'recycleResult':
            handleRecycleResult(data);
            break;
        case 'rankingsResult':
            displayRankings(data.rankings);
            break;
    }
});

// Open menu function
function openMenu(inventory) {
    playerInventory = inventory || [];
    document.getElementById('app').style.display = 'block';
    document.body.style.overflow = 'hidden';
    
    // Load current tab content
    loadTabContent();
}

// Close menu function
function closeMenu() {
    document.getElementById('app').style.display = 'none';
    document.body.style.overflow = 'auto';
    
    // Send close callback to client
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

// Switch tabs
function switchTab(tabName) {
    // Remove active class from all tabs and contents
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    // Add active class to selected tab
    document.querySelector(`[onclick="switchTab('${tabName}')"]`).classList.add('active');
    document.getElementById(`${tabName}-tab`).classList.add('active');
    
    currentTab = tabName;
    loadTabContent();
}

// Load tab content based on current tab
function loadTabContent() {
    switch (currentTab) {
        case 'upgrade':
            loadUpgradeTab();
            break;
        case 'transfer':
            loadTransferTab();
            break;
        case 'recycle':
            loadRecycleTab();
            break;
        case 'ranking':
            loadRankings();
            break;
    }
}

// Load upgrade tab
function loadUpgradeTab() {
    const container = document.getElementById('upgrade-inventory');
    container.innerHTML = '';
    
    const upgradableItems = playerInventory.filter(item => 
        item.backpackInfo && item.backpackInfo.level < 5
    );
    
    if (upgradableItems.length === 0) {
        container.innerHTML = '<p style="text-align: center; color: rgba(255,255,255,0.5); grid-column: 1/-1;">Không có balo nào có thể nâng cấp</p>';
        return;
    }
    
    upgradableItems.forEach(item => {
        const itemDiv = createInventoryItem(item, 'upgrade');
        container.appendChild(itemDiv);
    });
}

// Load transfer tab
function loadTransferTab() {
    const sourceContainer = document.getElementById('transfer-source');
    const targetContainer = document.getElementById('transfer-target');
    
    sourceContainer.innerHTML = '';
    targetContainer.innerHTML = '';
    
    const backpacks = playerInventory.filter(item => item.backpackInfo);
    
    if (backpacks.length === 0) {
        sourceContainer.innerHTML = '<p style="text-align: center; color: rgba(255,255,255,0.5); grid-column: 1/-1;">Không có balo</p>';
        targetContainer.innerHTML = '<p style="text-align: center; color: rgba(255,255,255,0.5); grid-column: 1/-1;">Không có balo</p>';
        return;
    }
    
    backpacks.forEach(item => {
        const sourceItem = createInventoryItem(item, 'transfer-source');
        const targetItem = createInventoryItem(item, 'transfer-target');
        
        sourceContainer.appendChild(sourceItem);
        targetContainer.appendChild(targetItem);
    });
    
    updateTransferPreviews();
}

// Load recycle tab
function loadRecycleTab() {
    const container = document.getElementById('recycle-inventory');
    container.innerHTML = '';
    
    const recyclableItems = playerInventory.filter(item => 
        item.backpackInfo && item.backpackInfo.level > 1
    );
    
    if (recyclableItems.length === 0) {
        container.innerHTML = '<p style="text-align: center; color: rgba(255,255,255,0.5); grid-column: 1/-1;">Không có balo nào có thể tái chế</p>';
        return;
    }
    
    recyclableItems.forEach(item => {
        const itemDiv = createInventoryItem(item, 'recycle');
        container.appendChild(itemDiv);
    });
}

// Create inventory item element
function createInventoryItem(item, type) {
    const div = document.createElement('div');
    div.className = 'inventory-item';
    div.onclick = () => selectItem(item, type);
    
    const icon = document.createElement('div');
    icon.className = 'item-icon';
    icon.textContent = '🎒';
    
    const name = document.createElement('div');
    name.className = 'item-name';
    name.textContent = item.label || item.name;
    
    const level = document.createElement('div');
    level.className = 'item-level';
    level.textContent = `Cấp ${item.backpackInfo.level}`;
    
    div.appendChild(icon);
    div.appendChild(name);
    div.appendChild(level);
    
    return div;
}

// Select item
function selectItem(item, type) {
    // Remove previous selections for this type
    const container = document.getElementById(`${type.split('-')[0]}-inventory`) || 
                     document.getElementById(`${type}-inventory`) ||
                     document.getElementById(type);
    
    if (container) {
        container.querySelectorAll('.inventory-item').forEach(el => el.classList.remove('selected'));
    }
    
    // Add selection to clicked item
    event.target.closest('.inventory-item').classList.add('selected');
    
    switch (type) {
        case 'upgrade':
            selectedUpgradeItem = item;
            showUpgradeInfo(item);
            break;
        case 'transfer-source':
            selectedSourceItem = item;
            updateTransferPreviews();
            break;
        case 'transfer-target':
            selectedTargetItem = item;
            updateTransferPreviews();
            break;
        case 'recycle':
            selectedRecycleItem = item;
            showRecycleInfo(item);
            break;
    }
}

// Show upgrade info
function showUpgradeInfo(item) {
    const info = document.getElementById('upgrade-info');
    const preview = document.getElementById('upgrade-preview');
    const itemName = document.getElementById('upgrade-item-name');
    const currentLevel = document.getElementById('current-level');
    const nextLevel = document.getElementById('next-level');
    const successRate = document.getElementById('success-rate');
    const requiredStone = document.getElementById('required-stone');
    
    preview.textContent = '🎒';
    itemName.textContent = item.label || item.name;
    currentLevel.textContent = item.backpackInfo.level;
    nextLevel.textContent = item.backpackInfo.level + 1;
    
    // Get success rate from config (you'll need to pass this from client)
    const rates = {1: 85, 2: 70, 3: 55, 4: 40};
    successRate.textContent = rates[item.backpackInfo.level] || 0;
    
    // Get required stone
    const stones = {1: 'Đá nâng cấp 1', 2: 'Đá nâng cấp 2', 3: 'Đá nâng cấp 3', 4: 'Đá nâng cấp 4'};
    requiredStone.textContent = stones[item.backpackInfo.level] || 'Không xác định';
    
    info.style.display = 'block';
}

// Show recycle info
function showRecycleInfo(item) {
    const info = document.getElementById('recycle-info');
    const preview = document.getElementById('recycle-preview');
    const itemName = document.getElementById('recycle-item-name');
    const level = document.getElementById('recycle-level');
    const stones = document.getElementById('recycle-stones');
    
    preview.textContent = '🎒';
    itemName.textContent = item.label || item.name;
    level.textContent = item.backpackInfo.level;
    
    // Calculate stones returned (50% of stones used)
    const totalStones = item.backpackInfo.level - 1;
    const returnStones = Math.floor(totalStones * 0.5) || 1;
    stones.textContent = returnStones;
    
    info.style.display = 'block';
}

// Update transfer previews
function updateTransferPreviews() {
    const sourcePreview = document.getElementById('source-preview');
    const targetPreview = document.getElementById('target-preview');
    const transferBtn = document.querySelector('.transfer-btn');
    
    if (selectedSourceItem) {
        sourcePreview.innerHTML = `
            <strong>${selectedSourceItem.label}</strong><br>
            Cấp ${selectedSourceItem.backpackInfo.level}
        `;
        sourcePreview.classList.add('has-item');
    } else {
        sourcePreview.textContent = 'Chưa chọn balo nguồn';
        sourcePreview.classList.remove('has-item');
    }
    
    if (selectedTargetItem) {
        targetPreview.innerHTML = `
            <strong>${selectedTargetItem.label}</strong><br>
            Cấp ${selectedTargetItem.backpackInfo.level}
        `;
        targetPreview.classList.add('has-item');
    } else {
        targetPreview.textContent = 'Chưa chọn balo đích';
        targetPreview.classList.remove('has-item');
    }
    
    // Enable transfer button if both items selected and valid
    const canTransfer = selectedSourceItem && selectedTargetItem && 
                       selectedSourceItem.slot !== selectedTargetItem.slot &&
                       selectedSourceItem.backpackInfo.level > selectedTargetItem.backpackInfo.level &&
                       isSameBackpackType(selectedSourceItem, selectedTargetItem);
    
    transferBtn.disabled = !canTransfer;
}

// Check if two backpacks are same type
function isSameBackpackType(item1, item2) {
    return item1.backpackInfo.gender === item2.backpackInfo.gender &&
           item1.backpackInfo.variant === item2.backpackInfo.variant;
}

// Action functions
function upgradeItem() {
    if (!selectedUpgradeItem) return;
    
    showLoading();
    fetch(`https://${GetParentResourceName()}/upgradeBackpack`, {
        method: 'POST',
        body: JSON.stringify({
            slot: selectedUpgradeItem.slot
        })
    });
}

function transferLevel() {
    if (!selectedSourceItem || !selectedTargetItem) return;
    
    showLoading();
    fetch(`https://${GetParentResourceName()}/transferLevel`, {
        method: 'POST',
        body: JSON.stringify({
            sourceSlot: selectedSourceItem.slot,
            targetSlot: selectedTargetItem.slot
        })
    });
}

function recycleItem() {
    if (!selectedRecycleItem) return;
    
    showLoading();
    fetch(`https://${GetParentResourceName()}/recycleBackpack`, {
        method: 'POST',
        body: JSON.stringify({
            slot: selectedRecycleItem.slot
        })
    });
}

function loadRankings() {
    showLoading();
    fetch(`https://${GetParentResourceName()}/getRankings`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

// Result handlers
function handleUpgradeResult(data) {
    hideLoading();
    if (data.inventory) {
        playerInventory = data.inventory;
    }
    
    // Reset selections and reload
    selectedUpgradeItem = null;
    document.getElementById('upgrade-info').style.display = 'none';
    loadUpgradeTab();
    
    // Refresh inventory
    refreshInventory();
}

function handleTransferResult(data) {
    hideLoading();
    if (data.inventory) {
        playerInventory = data.inventory;
    }
    
    // Reset selections
    selectedSourceItem = null;
    selectedTargetItem = null;
    loadTransferTab();
    
    // Refresh inventory
    refreshInventory();
}

function handleRecycleResult(data) {
    hideLoading();
    if (data.inventory) {
        playerInventory = data.inventory;
    }
    
    // Reset selections
    selectedRecycleItem = null;
    document.getElementById('recycle-info').style.display = 'none';
    loadRecycleTab();
    
    // Refresh inventory
    refreshInventory();
}

function displayRankings(rankings) {
    hideLoading();
    
    const topContainer = document.getElementById('top-rankings');
    const unluckyContainer = document.getElementById('unlucky-player');
    const luckyContainer = document.getElementById('lucky-player');
    
    // Top rankings
    topContainer.innerHTML = '';
    if (rankings.top && rankings.top.length > 0) {
        rankings.top.forEach((player, index) => {
            const div = document.createElement('div');
            div.className = `ranking-item ${index < 3 ? `top-${index + 1}` : ''}`;
            div.innerHTML = `
                <strong>#${index + 1}</strong> ${player.name}<br>
                <span style="color: #4ecdc4;">Cấp tối đa: ${player.max_level}</span>
            `;
            topContainer.appendChild(div);
        });
    } else {
        topContainer.innerHTML = '<p style="text-align: center; color: rgba(255,255,255,0.5);">Chưa có dữ liệu</p>';
    }
    
    // Unlucky player
    if (rankings.unlucky) {
        unluckyContainer.innerHTML = `
            <strong>${rankings.unlucky.name}</strong><br>
            <span style="color: #ff6b6b;">${rankings.unlucky.fail_count} lần thất bại</span>
        `;
    } else {
        unluckyContainer.innerHTML = '<p style="text-align: center; color: rgba(255,255,255,0.5);">Chưa có dữ liệu</p>';
    }
    
    // Lucky player
    if (rankings.lucky) {
        luckyContainer.innerHTML = `
            <strong>${rankings.lucky.name}</strong><br>
            <span style="color: #4ecdc4;">${rankings.lucky.success_count} lần thành công</span>
        `;
    } else {
        luckyContainer.innerHTML = '<p style="text-align: center; color: rgba(255,255,255,0.5);">Chưa có dữ liệu</p>';
    }
}

// Utility functions
function showLoading() {
    document.getElementById('loading').style.display = 'flex';
}

function hideLoading() {
    document.getElementById('loading').style.display = 'none';
}

function refreshInventory() {
    fetch(`https://${GetParentResourceName()}/refreshInventory`, {
        method: 'POST',
        body: JSON.stringify({})
    }).then(response => response.json())
    .then(data => {
        if (data.inventory) {
            playerInventory = data.inventory;
            loadTabContent();
        }
    });
}

// ESC key handler
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});

// Prevent context menu
document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
});

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    // Hide loading initially
    hideLoading();
});