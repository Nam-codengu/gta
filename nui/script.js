// Global variables
let currentBackpacks = [];
let selectedBackpack = null;
let upgradeOptions = [];

// Handle messages from client
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openUpgrade') {
        currentBackpacks = data.backpacks || [];
        showBackpackMenu();
    } else if (data.action === 'close') {
        closeAllMenus();
    }
});

// Show/hide menus
function showMenu(menuId) {
    // Hide all menus first
    document.querySelectorAll('[id$="Menu"]').forEach(menu => {
        menu.style.display = 'none';
    });
    // Show requested menu
    document.getElementById(menuId).style.display = 'block';
}

function closeAllMenus() {
    document.querySelectorAll('[id$="Menu"]').forEach(menu => {
        menu.style.display = 'none';
    });
    fetch(`https://${GetParentResourceName()}/closeMenu`, { method: 'POST' });
}

function closeMenu() {
    closeAllMenus();
}

// Backpack upgrade functions
function openBackpackUpgrade() {
    fetch(`https://${GetParentResourceName()}/getBackpacks`, { method: 'POST' })
    .then(res => res.json())
    .then(data => {
        currentBackpacks = data.backpacks || [];
        showBackpackMenu();
    })
    .catch(err => {
        console.error('Error getting backpacks:', err);
        showBackpackMenu();
    });
}

function showBackpackMenu() {
    const backpackList = document.getElementById('backpackList');
    backpackList.innerHTML = '';
    
    if (currentBackpacks.length === 0) {
        backpackList.innerHTML = '<p class="no-items">Không có balo trong túi đồ</p>';
    } else {
        currentBackpacks.forEach(backpack => {
            const config = backpack.config;
            const div = document.createElement('div');
            div.className = 'backpack-item';
            div.innerHTML = `
                <div class="item-info">
                    <h4>${config.label}</h4>
                    <p>Cấp: ${config.level} | Slots: ${config.slots} | Trọng lượng: ${(config.maxWeight/1000).toFixed(1)}kg</p>
                    <p>Tỷ lệ nâng cấp: ${config.successRate}%</p>
                </div>
                <button onclick="selectBackpack(${backpack.slot})" ${config.level >= 12 ? 'disabled' : ''}>
                    ${config.level >= 12 ? 'Cấp tối đa' : 'Nâng cấp'}
                </button>
            `;
            backpackList.appendChild(div);
        });
    }
    
    showMenu('backpackMenu');
}

function selectBackpack(slot) {
    selectedBackpack = currentBackpacks.find(bp => bp.slot === slot);
    if (!selectedBackpack) return;
    
    // Get upgrade options for this backpack
    fetch(`https://${GetParentResourceName()}/getUpgradeOptions`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ backpackName: selectedBackpack.item.name })
    })
    .then(res => res.json())
    .then(data => {
        upgradeOptions = data.options || [];
        showUpgradeMenu();
    })
    .catch(err => {
        console.error('Error getting upgrade options:', err);
        upgradeOptions = [];
        showUpgradeMenu();
    });
}

function showUpgradeMenu() {
    const currentDiv = document.getElementById('currentBackpack');
    const optionsDiv = document.getElementById('upgradeOptions');
    
    // Show current backpack info
    const config = selectedBackpack.config;
    currentDiv.innerHTML = `
        <div class="current-backpack">
            <h4>Balo hiện tại: ${config.label}</h4>
            <p>Cấp: ${config.level} | Slots: ${config.slots} | Trọng lượng: ${(config.maxWeight/1000).toFixed(1)}kg</p>
            <p>Đá cần thiết: ${config.upgradeStone}</p>
        </div>
    `;
    
    // Show upgrade options
    optionsDiv.innerHTML = '';
    if (upgradeOptions.length === 0) {
        optionsDiv.innerHTML = '<p class="no-options">Không có tùy chọn nâng cấp</p>';
        document.getElementById('normalUpgrade').disabled = true;
        document.getElementById('smashUpgrade').disabled = true;
    } else {
        optionsDiv.innerHTML = '<h4>Chọn balo mới:</h4>';
        upgradeOptions.forEach((option, index) => {
            const div = document.createElement('div');
            div.className = 'upgrade-option';
            div.innerHTML = `
                <label>
                    <input type="radio" name="upgradeOption" value="${index}">
                    <div class="option-info">
                        <h5>${option.label}</h5>
                        <p>Cấp: ${option.level} | Slots: ${option.slots} | Trọng lượng: ${(option.maxWeight/1000).toFixed(1)}kg</p>
                        <p>Tỷ lệ thành công: ${option.successRate}% | Đá: ${option.upgradeStone}</p>
                    </div>
                </label>
            `;
            optionsDiv.appendChild(div);
        });
        
        document.getElementById('normalUpgrade').disabled = false;
        document.getElementById('smashUpgrade').disabled = false;
    }
    
    showMenu('upgradeMenu');
}

function getSelectedUpgradeOption() {
    const selected = document.querySelector('input[name="upgradeOption"]:checked');
    return selected ? upgradeOptions[parseInt(selected.value)] : null;
}

function performUpgrade() {
    const targetOption = getSelectedUpgradeOption();
    if (!targetOption) {
        alert('Vui lòng chọn balo muốn nâng cấp!');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/upgradeBackpack`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            slot: selectedBackpack.slot,
            targetBackpack: targetOption.name
        })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            closeAllMenus();
        }
    })
    .catch(err => console.error('Upgrade error:', err));
}

function performSmash() {
    if (!confirm('Đập balo có rủi ro cao! Thất bại sẽ mất hoàn toàn balo. Bạn có chắc chắn?')) {
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/smashBackpack`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            slot: selectedBackpack.slot
        })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            closeAllMenus();
        }
    })
    .catch(err => console.error('Smash error:', err));
}

function closeBackpackMenu() {
    showMenu('mainMenu');
}

function closeUpgradeMenu() {
    showMenu('backpackMenu');
}

// Existing functions
function openRanking() {
    fetch(`https://${GetParentResourceName()}/getRanking`, { method: 'POST' })
    .then(res => res.json())
    .then(data => {
        let html = "<b>Top cấp cao nhất:</b><ul>";
        data.top.forEach(e => html += `<li>${e.name} - cấp ${e.level}</li>`);
        html += "</ul>";
        html += `<b>Thánh xui:</b> ${data.unlucky?.name || "Chưa có"}<br>`;
        html += `<b>Đại gia may mắn:</b> ${data.lucky?.name || "Chưa có"}`;
        document.getElementById('rankings').innerHTML = html;
        showMenu('rankingMenu');
    });
}

function closeRanking() {
    showMenu('mainMenu');
}

function openTransfer() {
    // Placeholder for transfer functionality
    alert('Tính năng di truyền cấp sẽ được thêm sau');
}

function openRecycle() {
    // Placeholder for recycle functionality
    alert('Tính năng tái chế sẽ được thêm sau');
}

// Close menu when ESC is pressed
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeAllMenus();
    }
});