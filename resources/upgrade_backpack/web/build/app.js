// Global variables
let currentInventory = [];
let currentConfig = {};
let selectedUpgradeItem = null;
let selectedTransferSource = null;
let selectedTransferDest = null;
let selectedRecycleItem = null;

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeTabs();
    initializeEventListeners();
});

// Initialize tab functionality
function initializeTabs() {
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabPanels = document.querySelectorAll('.tab-panel');

    tabBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const targetTab = this.getAttribute('data-tab');
            
            // Remove active class from all tabs and panels
            tabBtns.forEach(b => b.classList.remove('active'));
            tabPanels.forEach(p => p.classList.remove('active'));
            
            // Add active class to clicked tab and corresponding panel
            this.classList.add('active');
            document.getElementById(targetTab + '-tab').classList.add('active');
            
            // Clear selections when switching tabs
            clearSelections();
            
            // Refresh content based on tab
            if (targetTab === 'ranking') {
                loadRanking();
            }
        });
    });
}

// Initialize event listeners
function initializeEventListeners() {
    // Listen for messages from game
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch (data.action) {
            case 'showNUI':
                showNUI(data.inventory, data.config);
                break;
            case 'hideNUI':
                hideNUI();
                break;
            case 'updateInventory':
                updateInventory(data.inventory);
                break;
        }
    });
    
    // ESC key to close
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeNUI();
        }
    });
}

// Show NUI
function showNUI(inventory, config) {
    currentInventory = inventory || [];
    currentConfig = config || {};
    
    document.getElementById('app').classList.remove('hidden');
    
    // Set default tab
    const defaultTab = config.defaultTab || 'upgrade';
    switchToTab(defaultTab);
    
    // Populate inventory
    updateInventory(currentInventory);
}

// Hide NUI
function hideNUI() {
    document.getElementById('app').classList.add('hidden');
    clearSelections();
}

// Close NUI (called from UI)
function closeNUI() {
    fetch(`https://${GetParentResourceName()}/closeNUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    });
}

// Switch to specific tab
function switchToTab(tabName) {
    const tabBtn = document.querySelector(`[data-tab="${tabName}"]`);
    if (tabBtn) {
        tabBtn.click();
    }
}

// Update inventory display
function updateInventory(inventory) {
    currentInventory = inventory;
    
    populateUpgradeInventory();
    populateTransferInventory();
    populateRecycleInventory();
}

// Populate upgrade tab inventory
function populateUpgradeInventory() {
    const container = document.getElementById('upgrade-inventory');
    container.innerHTML = '';
    
    currentInventory.forEach(item => {
        const slot = createItemSlot(item, 'upgrade');
        container.appendChild(slot);
    });
    
    if (currentInventory.length === 0) {
        container.innerHTML = '<p class="empty-message">Không có vật phẩm có thể nâng cấp</p>';
    }
}

// Populate transfer tab inventory
function populateTransferInventory() {
    const sourceContainer = document.getElementById('transfer-source');
    const destContainer = document.getElementById('transfer-dest');
    
    sourceContainer.innerHTML = '';
    destContainer.innerHTML = '';
    
    currentInventory.forEach(item => {
        if (item.level > 0) {
            const sourceSlot = createItemSlot(item, 'transfer-source');
            sourceContainer.appendChild(sourceSlot);
        }
        
        const destSlot = createItemSlot(item, 'transfer-dest');
        destContainer.appendChild(destSlot);
    });
    
    if (sourceContainer.children.length === 0) {
        sourceContainer.innerHTML = '<p class="empty-message">Không có vật phẩm cấp cao</p>';
    }
    if (destContainer.children.length === 0) {
        destContainer.innerHTML = '<p class="empty-message">Không có vật phẩm đích</p>';
    }
}

// Populate recycle tab inventory
function populateRecycleInventory() {
    const container = document.getElementById('recycle-inventory');
    container.innerHTML = '';
    
    const recyclableItems = currentInventory.filter(item => item.level > 1);
    
    recyclableItems.forEach(item => {
        const slot = createItemSlot(item, 'recycle');
        container.appendChild(slot);
    });
    
    if (recyclableItems.length === 0) {
        container.innerHTML = '<p class="empty-message">Không có vật phẩm có thể tái chế (cần cấp 2+)</p>';
    }
}

// Create item slot element
function createItemSlot(item, type) {
    const slot = document.createElement('div');
    slot.className = 'item-slot';
    slot.setAttribute('data-slot', item.slot);
    slot.setAttribute('data-name', item.name);
    slot.setAttribute('data-level', item.level);
    
    const progressPercent = (item.level / item.maxLevel) * 100;
    
    slot.innerHTML = `
        <div class="item-name">${item.label}</div>
        <div class="item-level">Cấp ${item.level}/${item.maxLevel}</div>
        <div class="item-progress">
            <div class="item-progress-fill" style="width: ${progressPercent}%"></div>
        </div>
    `;
    
    slot.addEventListener('click', function() {
        selectItem(item, type, this);
    });
    
    return slot;
}

// Select item based on tab type
function selectItem(item, type, element) {
    switch (type) {
        case 'upgrade':
            selectUpgradeItem(item, element);
            break;
        case 'transfer-source':
            selectTransferSource(item, element);
            break;
        case 'transfer-dest':
            selectTransferDest(item, element);
            break;
        case 'recycle':
            selectRecycleItem(item, element);
            break;
    }
}

// Select item for upgrade
function selectUpgradeItem(item, element) {
    // Clear previous selection
    document.querySelectorAll('#upgrade-inventory .item-slot').forEach(slot => {
        slot.classList.remove('selected');
    });
    
    element.classList.add('selected');
    selectedUpgradeItem = item;
    
    updateUpgradeInfo(item);
    document.getElementById('upgrade-btn').disabled = false;
}

// Select source item for transfer
function selectTransferSource(item, element) {
    document.querySelectorAll('#transfer-source .item-slot').forEach(slot => {
        slot.classList.remove('selected');
    });
    
    element.classList.add('selected');
    selectedTransferSource = item;
    
    updateTransferInfo();
    updateTransferButton();
}

// Select destination item for transfer
function selectTransferDest(item, element) {
    document.querySelectorAll('#transfer-dest .item-slot').forEach(slot => {
        slot.classList.remove('selected');
    });
    
    element.classList.add('selected');
    selectedTransferDest = item;
    
    updateTransferInfo();
    updateTransferButton();
}

// Select item for recycling
function selectRecycleItem(item, element) {
    document.querySelectorAll('#recycle-inventory .item-slot').forEach(slot => {
        slot.classList.remove('selected');
    });
    
    element.classList.add('selected');
    selectedRecycleItem = item;
    
    updateRecycleInfo(item);
    document.getElementById('recycle-btn').disabled = false;
}

// Update upgrade information
function updateUpgradeInfo(item) {
    const info = document.getElementById('upgrade-info');
    const config = currentConfig.upgradeItems[item.name];
    
    if (!config) {
        info.innerHTML = '<p>Không thể nâng cấp vật phẩm này</p>';
        return;
    }
    
    const nextLevel = item.level + 1;
    const requiredStone = config.upgradeStones[nextLevel];
    const successRate = config.rates[nextLevel];
    const needTalisman = config.requireTalismanAt.includes(nextLevel);
    
    if (nextLevel > config.maxLevel) {
        info.innerHTML = '<p style="color: #ffd700;">Vật phẩm đã đạt cấp tối đa!</p>';
        document.getElementById('upgrade-btn').disabled = true;
        return;
    }
    
    info.innerHTML = `
        <div class="upgrade-details">
            <p><strong>Nâng cấp từ cấp ${item.level} → ${nextLevel}</strong></p>
            <p>Cần: ${requiredStone}</p>
            <p>Tỷ lệ thành công: <span style="color: ${successRate > 50 ? '#4ade80' : successRate > 20 ? '#fbbf24' : '#ef4444'}">${successRate}%</span></p>
            ${needTalisman ? '<p style="color: #ffd700;">⚠️ Cần bùa may mắn</p>' : ''}
            ${config.slotPerLevel > 0 ? `<p>+${config.slotPerLevel} slot</p>` : ''}
            ${config.weightPerLevel > 0 ? `<p>+${config.weightPerLevel} kg</p>` : ''}
        </div>
    `;
}

// Update transfer information
function updateTransferInfo() {
    const info = document.getElementById('transfer-info');
    
    if (!selectedTransferSource && !selectedTransferDest) {
        info.innerHTML = '<p>Chọn vật phẩm nguồn và đích để di truyền cấp độ</p>';
        return;
    }
    
    if (!selectedTransferSource) {
        info.innerHTML = '<p>Chọn vật phẩm nguồn (cấp cao)</p>';
        return;
    }
    
    if (!selectedTransferDest) {
        info.innerHTML = '<p>Chọn vật phẩm đích (cấp thấp)</p>';
        return;
    }
    
    if (selectedTransferSource.name !== selectedTransferDest.name) {
        info.innerHTML = '<p style="color: #ef4444;">⚠️ Hai vật phẩm phải cùng loại!</p>';
        return;
    }
    
    if (selectedTransferSource.level <= selectedTransferDest.level) {
        info.innerHTML = '<p style="color: #ef4444;">⚠️ Cấp nguồn phải cao hơn cấp đích!</p>';
        return;
    }
    
    info.innerHTML = `
        <div class="transfer-details">
            <p><strong>Di truyền từ cấp ${selectedTransferSource.level} → cấp ${selectedTransferDest.level}</strong></p>
            <p>Vật phẩm đích sẽ nhận cấp ${selectedTransferSource.level}</p>
            <p style="color: #fbbf24;">⚠️ Có 15% khả năng mất 1 cấp khi di truyền</p>
            <p style="color: #ef4444;">⚠️ Vật phẩm nguồn sẽ bị tiêu hủy</p>
        </div>
    `;
}

// Update transfer button state
function updateTransferButton() {
    const btn = document.getElementById('transfer-btn');
    
    if (selectedTransferSource && selectedTransferDest && 
        selectedTransferSource.name === selectedTransferDest.name &&
        selectedTransferSource.level > selectedTransferDest.level) {
        btn.disabled = false;
    } else {
        btn.disabled = true;
    }
}

// Update recycle information
function updateRecycleInfo(item) {
    const info = document.getElementById('recycle-info');
    const config = currentConfig.upgradeItems[item.name];
    
    if (!config) {
        info.innerHTML = '<p>Không thể tái chế vật phẩm này</p>';
        return;
    }
    
    const refundStone = Math.floor(item.level * 0.6);
    const stoneType = config.upgradeStones[item.level];
    
    info.innerHTML = `
        <div class="recycle-details">
            <p><strong>Tái chế ${item.label} cấp ${item.level}</strong></p>
            <p>Nhận lại: ${refundStone}x ${stoneType}</p>
            <p style="color: #fbbf24;">⚠️ Hoàn trả 60% nguyên liệu đã sử dụng</p>
            <p style="color: #ef4444;">⚠️ Vật phẩm sẽ bị tiêu hủy</p>
        </div>
    `;
}

// Clear all selections
function clearSelections() {
    selectedUpgradeItem = null;
    selectedTransferSource = null;
    selectedTransferDest = null;
    selectedRecycleItem = null;
    
    document.querySelectorAll('.item-slot').forEach(slot => {
        slot.classList.remove('selected');
    });
    
    document.getElementById('upgrade-btn').disabled = true;
    document.getElementById('transfer-btn').disabled = true;
    document.getElementById('recycle-btn').disabled = true;
    
    // Reset info panels
    document.getElementById('upgrade-info').innerHTML = '<p>Chọn vật phẩm để xem thông tin nâng cấp</p>';
    document.getElementById('transfer-info').innerHTML = '<p>Chọn vật phẩm nguồn và đích để di truyền cấp độ</p>';
    document.getElementById('recycle-info').innerHTML = '<p>Chọn vật phẩm cấp cao để tái chế và nhận lại nguyên liệu</p>';
}

// Upgrade item action
function upgradeItem() {
    if (!selectedUpgradeItem) return;
    
    showLoading(true);
    
    fetch(`https://${GetParentResourceName()}/upgradeItem`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            slot: selectedUpgradeItem.slot,
            itemName: selectedUpgradeItem.name
        })
    })
    .then(response => response.json())
    .then(data => {
        showLoading(false);
        showNotification(data.message, data.success ? 'success' : 'error');
        
        if (data.success) {
            clearSelections();
        }
    })
    .catch(error => {
        showLoading(false);
        showNotification('Lỗi kết nối!', 'error');
    });
}

// Transfer level action
function transferLevel() {
    if (!selectedTransferSource || !selectedTransferDest) return;
    
    showLoading(true);
    
    fetch(`https://${GetParentResourceName()}/transferLevel`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            srcSlot: selectedTransferSource.slot,
            dstSlot: selectedTransferDest.slot
        })
    })
    .then(response => response.json())
    .then(data => {
        showLoading(false);
        showNotification(data.message, data.success ? 'success' : 'error');
        
        if (data.success) {
            clearSelections();
        }
    })
    .catch(error => {
        showLoading(false);
        showNotification('Lỗi kết nối!', 'error');
    });
}

// Recycle item action
function recycleItem() {
    if (!selectedRecycleItem) return;
    
    showLoading(true);
    
    fetch(`https://${GetParentResourceName()}/recycleItem`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            slot: selectedRecycleItem.slot
        })
    })
    .then(response => response.json())
    .then(data => {
        showLoading(false);
        showNotification(data.message, data.success ? 'success' : 'error');
        
        if (data.success) {
            clearSelections();
        }
    })
    .catch(error => {
        showLoading(false);
        showNotification('Lỗi kết nối!', 'error');
    });
}

// Load ranking data
function loadRanking() {
    fetch(`https://${GetParentResourceName()}/getRanking`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        displayRanking(data);
    })
    .catch(error => {
        console.error('Error loading ranking:', error);
    });
}

// Display ranking data
function displayRanking(data) {
    const topRanking = document.getElementById('top-ranking');
    const specialTitles = document.getElementById('special-titles');
    
    // Top ranking
    topRanking.innerHTML = '';
    if (data.top && data.top.length > 0) {
        data.top.forEach((player, index) => {
            const rankItem = document.createElement('div');
            rankItem.className = `ranking-item rank-${index + 1}`;
            rankItem.innerHTML = `
                <span>${index + 1}. ${player.name}</span>
                <span>Cấp ${player.level}</span>
            `;
            topRanking.appendChild(rankItem);
        });
    } else {
        topRanking.innerHTML = '<p class="empty-message">Chưa có dữ liệu</p>';
    }
    
    // Special titles
    specialTitles.innerHTML = '';
    
    const titles = [
        { key: 'lucky', title: currentConfig.rankTitles?.lucky || 'Đại Gia May Mắn', data: data.lucky },
        { key: 'unlucky', title: currentConfig.rankTitles?.unlucky || 'Thánh Xui', data: data.unlucky },
        { key: 'transfer_master', title: currentConfig.rankTitles?.transfer_master || 'Chuyên Gia Di Truyền', data: data.transfer_master },
        { key: 'recycle_king', title: currentConfig.rankTitles?.recycle_king || 'Vua Tái Chế', data: data.recycle_king }
    ];
    
    titles.forEach(titleInfo => {
        const titleItem = document.createElement('div');
        titleItem.className = 'title-item';
        titleItem.innerHTML = `
            <div class="title-name">${titleInfo.title}</div>
            <div class="title-player">${titleInfo.data?.name || 'Chưa có'}</div>
        `;
        specialTitles.appendChild(titleItem);
    });
}

// Refresh ranking data
function refreshRanking() {
    loadRanking();
    showNotification('Đã làm mới bảng xếp hạng!', 'success');
}

// Show/hide loading overlay
function showLoading(show) {
    const loading = document.getElementById('loading');
    if (show) {
        loading.classList.remove('hidden');
    } else {
        loading.classList.add('hidden');
    }
}

// Show notification
function showNotification(message, type = 'info') {
    const notification = document.getElementById('notification');
    const text = document.getElementById('notification-text');
    
    text.textContent = message;
    notification.classList.remove('hidden');
    
    // Apply different styles based on type
    notification.style.background = type === 'success' ? 
        'linear-gradient(90deg, #10b981, #059669)' : 
        type === 'error' ? 
        'linear-gradient(90deg, #ef4444, #dc2626)' : 
        'linear-gradient(90deg, #3b82f6, #2563eb)';
    
    // Auto hide after 3 seconds
    setTimeout(() => {
        notification.classList.add('hidden');
    }, 3000);
}

// Utility function to get parent resource name
function GetParentResourceName() {
    return window.location.hostname;
}