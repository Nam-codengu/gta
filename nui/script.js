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