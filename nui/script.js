let upgradeItemsData = {};

// Listen for messages from client
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'openMenu') {
        upgradeItemsData = data.upgradeItems;
        displayUpgradeItems();
        document.getElementById('mainMenu').style.display = 'block';
    } else if (data.type === 'closeMenu') {
        closeMenu();
    }
});

function displayUpgradeItems() {
    const container = document.getElementById('upgradeItems');
    let html = '';
    
    for (const [itemKey, itemData] of Object.entries(upgradeItemsData)) {
        const iconPath = itemData.icon ? `icons/${itemData.icon}` : null;
        
        html += `
            <div class="upgrade-item">
                ${iconPath ? `<img src="${iconPath}" alt="${itemData.label}" class="item-icon" onerror="this.style.display='none'">` : ''}
                <div class="item-info">
                    <span class="item-label">${itemData.label}</span>
                    <span class="item-details">Max cấp: ${itemData.maxLevel}</span>
                </div>
            </div>
        `;
    }
    
    container.innerHTML = html;
}

function closeMenu() {
    document.getElementById('mainMenu').style.display = 'none';
    document.getElementById('rankingMenu').style.display = 'none';
    
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

// Close menu on ESC key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});

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
        document.getElementById('rankingMenu').style.display = 'block';
    });
}

function closeRanking() {
    document.getElementById('rankingMenu').style.display = 'none';
}

function openTransfer() {
    // Placeholder for transfer functionality
    console.log('Transfer function will be implemented');
}

function openRecycle() {
    // Placeholder for recycle functionality  
    console.log('Recycle function will be implemented');
}