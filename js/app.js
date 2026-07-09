/* ============================================================
   MINYARA — SHARED APP UTILITIES v2.0
   ============================================================ */

// ─── Dark Mode ────────────────────────────────────────────────
function initDarkMode() {
    const saved = localStorage.getItem('minyara_theme') || 'light';
    document.documentElement.setAttribute('data-theme', saved);
    const toggle = document.getElementById('darkModeToggle');
    if (toggle) toggle.checked = (saved === 'dark');
}

function toggleDarkMode(isDark) {
    const theme = isDark ? 'dark' : 'light';
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('minyara_theme', theme);
}

// ─── Sidebar Collapse ─────────────────────────────────────────
function initSidebarCollapse() {
    const sidebar = document.querySelector('.sidebar');
    const main = document.querySelector('.main');
    if (!sidebar) return;

    const saved = localStorage.getItem('minyara_sidebar') || 'expanded';
    if (saved === 'collapsed') {
        sidebar.classList.add('collapsed');
        if (main) main.classList.add('sidebar-collapsed');
    }

    const btn = sidebar.querySelector('.sidebar-collapse-btn');
    if (btn) {
        btn.addEventListener('click', () => {
            sidebar.classList.toggle('collapsed');
            if (main) main.classList.toggle('sidebar-collapsed');
            localStorage.setItem('minyara_sidebar',
                sidebar.classList.contains('collapsed') ? 'collapsed' : 'expanded');
        });
    }

    // Tooltip on collapsed sidebar items
    sidebar.querySelectorAll('.nav-link').forEach(link => {
        const text = link.querySelector('.nav-link-text');
        if (text) link.setAttribute('title', text.textContent.trim());
    });
}

// ─── Current Page Detection ───────────────────────────────────
function setActivePage() {
    const page = window.location.pathname.split('/').pop() || 'index.html';
    document.querySelectorAll('.nav-link').forEach(a => {
        a.classList.toggle('active', a.getAttribute('href') === page);
    });
}

// ─── Live Clock ───────────────────────────────────────────────
function initClock() {
    function updateClock() {
        const now = new Date();
        const timeEl = document.getElementById('sidebarTime');
        const dateEl = document.getElementById('sidebarDate');
        if (timeEl) timeEl.textContent = now.toLocaleTimeString('en-US', {
            timeZone: 'Asia/Colombo',
            hour: '2-digit', minute: '2-digit', second: '2-digit'
        });
        if (dateEl) dateEl.textContent = now.toLocaleDateString('en-US', {
            timeZone: 'Asia/Colombo',
            weekday: 'short', month: 'short', day: 'numeric', year: 'numeric'
        });
    }
    updateClock();
    setInterval(updateClock, 1000);
}

// ─── Header Greeting ──────────────────────────────────────────
function initGreeting(shopName) {
    const el = document.getElementById('headerGreeting');
    if (!el) return;
    const h = new Date().getHours();
    const greet = h < 12 ? 'Good Morning' : h < 17 ? 'Good Afternoon' : 'Good Evening';
    const name = shopName || localStorage.getItem('minyara_shop_name') || 'Minyara';
    el.textContent = `${greet}, ${name}! 👋`;
}

// ─── Toast Notifications — Premium with Progress Bar ──────────
function toast(type = 'info', title = '', message = '', duration = 3500) {
    let container = document.getElementById('toastContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toastContainer';
        container.className = 'toast-container';
        document.body.appendChild(container);
    }
    const icons = { success: '✅', error: '❌', info: 'ℹ️', warning: '⚠️' };
    const el = document.createElement('div');
    el.className = `toast ${type}`;
    el.innerHTML = `
        <span class="toast-icon">${icons[type] || '🔔'}</span>
        <div class="toast-body">
          <div class="toast-title">${title}</div>
          ${message ? `<div class="toast-msg">${message}</div>` : ''}
        </div>
        <span class="toast-close-btn" onclick="this.parentElement.remove()">✕</span>
        <div class="toast-progress" style="animation-duration:${duration}ms;"></div>
    `;
    container.appendChild(el);
    const timer = setTimeout(() => {
        el.style.animation = 'toastOut 0.35s ease forwards';
        setTimeout(() => el.remove(), 350);
    }, duration);
    el.querySelector('.toast-close-btn').addEventListener('click', () => {
        clearTimeout(timer);
        el.style.animation = 'toastOut 0.35s ease forwards';
        setTimeout(() => el.remove(), 350);
    });
}

// ─── Modal Helpers ────────────────────────────────────────────
function openModal(id) {
    const el = document.getElementById(id);
    if (el) { el.classList.add('open'); document.body.style.overflow = 'hidden'; }
}
function closeModal(id) {
    const el = document.getElementById(id);
    if (el) { el.classList.remove('open'); document.body.style.overflow = ''; }
}
function closeAllModals() {
    document.querySelectorAll('.modal-backdrop.open').forEach(m => m.classList.remove('open'));
    document.body.style.overflow = '';
}

// ─── Custom Confirm Dialog ────────────────────────────────────
function confirmAction(message, title = 'Confirm Action', confirmText = 'Confirm', type = 'danger') {
    return new Promise(resolve => {
        const id = 'minyaraConfirmModal';
        let modal = document.getElementById(id);
        if (!modal) {
            modal = document.createElement('div');
            modal.id = id;
            modal.className = 'modal-backdrop';
            modal.innerHTML = `
              <div class="modal" style="max-width:420px">
                <div class="modal-header">
                  <div class="modal-title" id="confirmTitle">⚠️ Confirm Action</div>
                </div>
                <div class="modal-body">
                  <p id="confirmMsg" style="color:var(--text-secondary);font-size:14px;line-height:1.6;"></p>
                </div>
                <div class="modal-footer">
                  <button class="btn btn-secondary" id="confirmNoBtn">✕ Cancel</button>
                  <button class="btn btn-danger" id="confirmYesBtn">Confirm</button>
                </div>
              </div>`;
            document.body.appendChild(modal);
        }
        document.getElementById('confirmTitle').innerHTML = `⚠️ ${title}`;
        document.getElementById('confirmMsg').textContent = message;
        const yesBtn = document.getElementById('confirmYesBtn');
        yesBtn.textContent = confirmText;
        yesBtn.className = `btn btn-${type}`;
        openModal(id);
        const yes = () => { closeModal(id); cleanup(); resolve(true); };
        const no  = () => { closeModal(id); cleanup(); resolve(false); };
        const cleanup = () => {
            yesBtn.removeEventListener('click', yes);
            document.getElementById('confirmNoBtn').removeEventListener('click', no);
        };
        yesBtn.addEventListener('click', yes);
        document.getElementById('confirmNoBtn').addEventListener('click', no);
    });
}

// ─── Escape ESC to close modal ────────────────────────────────
document.addEventListener('keydown', e => {
    if (e.key === 'Escape') {
        // Close global search first
        const gs = document.getElementById('globalSearchOverlay');
        if (gs && gs.classList.contains('open')) {
            closeGlobalSearch(); return;
        }
        closeAllModals();
    }
});

// ─── Click backdrop to close ──────────────────────────────────
document.addEventListener('click', e => {
    if (e.target.classList.contains('modal-backdrop')) closeAllModals();
});

// ─── Global Keyboard Shortcuts ────────────────────────────────
document.addEventListener('keydown', e => {
    const tag = document.activeElement?.tagName?.toLowerCase();
    const isInput = ['input','textarea','select'].includes(tag);

    // Ctrl+K or Cmd+K — Global Search
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        openGlobalSearch();
        return;
    }

    if (isInput) return; // Don't fire nav shortcuts in inputs

    // Alt + key navigation
    if (e.altKey) {
        const routes = {
            'd': 'index.html',
            'b': 'billing.html',
            'i': 'inventory.html',
            'h': 'bills.html',
            'a': 'analytics.html',
            'c': 'categories.html',
            's': 'settings.html',
        };
        if (routes[e.key]) {
            e.preventDefault();
            window.location.href = routes[e.key];
        }
    }
});

// ─── Ripple Effect on buttons ─────────────────────────────────
document.addEventListener('click', e => {
    const btn = e.target.closest('.btn');
    if (!btn) return;
    const ripple = document.createElement('span');
    ripple.className = 'ripple';
    const rect = btn.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    ripple.style.cssText = `width:${size}px;height:${size}px;left:${e.clientX-rect.left-size/2}px;top:${e.clientY-rect.top-size/2}px`;
    btn.appendChild(ripple);
    setTimeout(() => ripple.remove(), 600);
});

// ─── Global Search (Ctrl+K) ───────────────────────────────────
let globalSearchProducts = [];
let globalSearchBills = [];
let selectedSearchIdx = -1;

function openGlobalSearch() {
    let overlay = document.getElementById('globalSearchOverlay');
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.id = 'globalSearchOverlay';
        overlay.className = 'global-search-overlay';
        overlay.innerHTML = `
          <div class="global-search-box">
            <div class="global-search-input-wrap">
              <span class="search-icon">🔍</span>
              <input type="text" class="global-search-input" id="globalSearchInput"
                placeholder="Search products, bills, pages... (Ctrl+K)" autocomplete="off">
              <span style="font-size:11px;color:var(--text-muted);white-space:nowrap;">ESC to close</span>
            </div>
            <div class="global-search-results" id="globalSearchResults">
              <div style="padding:20px;text-align:center;color:var(--text-muted);font-size:13px;">
                Start typing to search...
              </div>
            </div>
            <div class="global-search-footer">
              <span><kbd>↑↓</kbd> Navigate</span>
              <span><kbd>Enter</kbd> Open</span>
              <span><kbd>ESC</kbd> Close</span>
              <span><kbd>Alt+B</kbd> Billing | <kbd>Alt+I</kbd> Inventory</span>
            </div>
          </div>`;
        overlay.addEventListener('click', e => { if (e.target === overlay) closeGlobalSearch(); });
        document.body.appendChild(overlay);
    }
    overlay.classList.add('open');
    const input = document.getElementById('globalSearchInput');
    input.value = '';
    input.focus();
    showGlobalSearchDefault();

    input.addEventListener('input', debounce(runGlobalSearch, 200));
    input.addEventListener('keydown', handleSearchNav);
}

function closeGlobalSearch() {
    const el = document.getElementById('globalSearchOverlay');
    if (el) el.classList.remove('open');
    selectedSearchIdx = -1;
}

function showGlobalSearchDefault() {
    const pages = [
        { icon: '📊', name: 'Dashboard', url: 'index.html', sub: 'Main overview & analytics' },
        { icon: '🧾', name: 'POS / Billing', url: 'billing.html', sub: 'Create new bills' },
        { icon: '📋', name: 'Bills History', url: 'bills.html', sub: 'View past transactions', shortcut: 'Alt+H' },
        { icon: '📦', name: 'Inventory', url: 'inventory.html', sub: 'Manage products & stock', shortcut: 'Alt+I' },
        { icon: '🏷️', name: 'Categories', url: 'categories.html', sub: 'Manage categories', shortcut: 'Alt+C' },
        { icon: '📈', name: 'Analytics', url: 'analytics.html', sub: 'Reports & charts', shortcut: 'Alt+A' },
        { icon: '⚙️', name: 'Settings', url: 'settings.html', sub: 'System configuration', shortcut: 'Alt+S' },
    ];
    const results = document.getElementById('globalSearchResults');
    results.innerHTML = `
      <div class="global-search-group-label">📌 Quick Navigation</div>
      ${pages.map((p, i) => `
        <div class="global-search-result" data-url="${p.url}" tabindex="-1">
          <span class="global-search-result-icon">${p.icon}</span>
          <div class="global-search-result-info">
            <div class="global-search-result-name">${p.name}</div>
            <div class="global-search-result-sub">${p.sub}</div>
          </div>
          ${p.shortcut ? `<span class="global-search-result-badge" style="font-size:10px;background:var(--border);padding:2px 6px;border-radius:4px;font-family:monospace;">${p.shortcut}</span>` : ''}
        </div>
      `).join('')}`;
    results.querySelectorAll('.global-search-result').forEach(r => {
        r.addEventListener('click', () => { window.location.href = r.dataset.url; });
    });
}

async function runGlobalSearch() {
    const q = document.getElementById('globalSearchInput').value.trim().toLowerCase();
    if (!q) { showGlobalSearchDefault(); return; }

    const results = document.getElementById('globalSearchResults');
    results.innerHTML = `<div style="padding:20px;text-align:center"><span class="spinner spinner-dark"></span></div>`;

    try {
        const [prods, bills] = await Promise.allSettled([
            window.ProductsAPI ? ProductsAPI.list({ search: q }) : Promise.resolve([]),
            window.BillsAPI ? BillsAPI.list({ search: q, limit: 5 }) : Promise.resolve([])
        ]);

        const prodList = (prods.value || []).slice(0, 6);
        const billList = (bills.value || []).slice(0, 4);

        let html = '';
        if (prodList.length) {
            html += `<div class="global-search-group-label">📦 Products</div>`;
            html += prodList.map(p => `
              <div class="global-search-result" data-url="inventory.html" onclick="window.location.href='inventory.html'">
                <span class="global-search-result-icon">${p.image ? `<img src="${p.image}" style="width:24px;height:24px;border-radius:4px;object-fit:cover;">` : '📦'}</span>
                <div class="global-search-result-info">
                  <div class="global-search-result-name">${p.name}</div>
                  <div class="global-search-result-sub">SKU: ${p.sku} | Stock: ${p.stock_qty}</div>
                </div>
                <span class="global-search-result-badge">${formatCurrency(p.sell_price)}</span>
              </div>`).join('');
        }
        if (billList.length) {
            html += `<div class="global-search-group-label">🧾 Bills</div>`;
            html += billList.map(b => `
              <div class="global-search-result" onclick="window.location.href='bills.html'">
                <span class="global-search-result-icon">🧾</span>
                <div class="global-search-result-info">
                  <div class="global-search-result-name">${b.bill_no}</div>
                  <div class="global-search-result-sub">${b.customer_name || 'Walk-in'} • ${formatDate(b.created_at)}</div>
                </div>
                <span class="global-search-result-badge">${formatCurrency(b.total_amount)}</span>
              </div>`).join('');
        }
        if (!html) {
            html = `<div style="padding:32px;text-align:center;color:var(--text-muted);font-size:13px;">
              <div style="font-size:32px;margin-bottom:8px;">🔍</div>
              No results for "<strong>${q}</strong>"
            </div>`;
        }
        results.innerHTML = html;
    } catch (e) {
        results.innerHTML = `<div style="padding:20px;text-align:center;color:var(--text-muted);">Search unavailable</div>`;
    }
}

function handleSearchNav(e) {
    const items = document.querySelectorAll('#globalSearchResults .global-search-result');
    if (e.key === 'ArrowDown') {
        e.preventDefault();
        selectedSearchIdx = Math.min(selectedSearchIdx + 1, items.length - 1);
    } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        selectedSearchIdx = Math.max(selectedSearchIdx - 1, -1);
    } else if (e.key === 'Enter' && selectedSearchIdx >= 0) {
        e.preventDefault();
        items[selectedSearchIdx]?.click();
        return;
    }
    items.forEach((item, i) => item.classList.toggle('selected', i === selectedSearchIdx));
    if (selectedSearchIdx >= 0) items[selectedSearchIdx]?.scrollIntoView({ block: 'nearest' });
}

// ─── Animated KPI Counter ─────────────────────────────────────
function animateCounter(el, targetValue, prefix = '', suffix = '', duration = 1200) {
    if (!el) return;
    const start = performance.now();
    const startVal = 0;

    function update(now) {
        const progress = Math.min((now - start) / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3); // ease-out cubic
        const current = startVal + (targetValue - startVal) * eased;

        if (typeof targetValue === 'number' && !Number.isInteger(targetValue)) {
            el.textContent = prefix + current.toLocaleString('en-LK', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + suffix;
        } else {
            el.textContent = prefix + Math.round(current).toLocaleString() + suffix;
        }

        if (progress < 1) requestAnimationFrame(update);
        else el.textContent = prefix + (typeof targetValue === 'number' && !Number.isInteger(targetValue)
            ? targetValue.toLocaleString('en-LK', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
            : targetValue.toLocaleString()) + suffix;
    }
    requestAnimationFrame(update);
}

// ─── Discount Calculator ──────────────────────────────────────
function calcDiscountedTotal(subtotal, discountVal, discountMode) {
    const val = parseFloat(discountVal) || 0;
    if (discountMode === 'percent') {
        const pct = Math.min(val, 100);
        return { discountAmount: (subtotal * pct) / 100, total: subtotal * (1 - pct / 100) };
    } else {
        const disc = Math.min(val, subtotal);
        return { discountAmount: disc, total: Math.max(0, subtotal - disc) };
    }
}

// ─── Format Currency (LKR) ────────────────────────────────────
function formatCurrency(val) {
    return 'Rs. ' + parseFloat(val || 0).toLocaleString('en-LK', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

// ─── Format Date ─────────────────────────────────────────────
function formatDate(str) {
    if (!str) return '-';
    const isoStr = str.includes('T') ? str : str.replace(' ', 'T') + '+05:30';
    return new Date(isoStr).toLocaleDateString('en-US', { timeZone: 'Asia/Colombo', day: '2-digit', month: 'short', year: 'numeric' });
}
function formatDateTime(str) {
    if (!str) return '-';
    const isoStr = str.includes('T') ? str : str.replace(' ', 'T') + '+05:30';
    return new Date(isoStr).toLocaleString('en-US', { timeZone: 'Asia/Colombo', day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

// ─── Debounce ─────────────────────────────────────────────────
function debounce(fn, delay = 300) {
    let t;
    return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), delay); };
}

// ─── Stock badge helper ───────────────────────────────────────
function stockBadge(qty, minStock) {
    if (qty === 0)        return `<span class="stock-badge zero">📦 Out of Stock</span>`;
    if (qty <= minStock)  return `<span class="stock-badge low">⚠️ ${qty}</span>`;
    return `<span class="stock-badge good">✅ ${qty}</span>`;
}

// ─── Stock progress bar ───────────────────────────────────────
function stockProgressBar(qty, minStock, maxRef = null) {
    const max = maxRef || Math.max(qty * 1.5, minStock * 3, 10);
    const pct = Math.min((qty / max) * 100, 100);
    let cls = 'good';
    if (qty === 0 || qty < minStock * 0.5) cls = 'danger';
    else if (qty <= minStock) cls = 'warning';
    return `
      <div class="stock-bar-wrap">
        <div class="stock-bar-bg"><div class="stock-bar-fill ${cls}" style="width:${pct}%"></div></div>
        <span style="font-size:11px;font-weight:700;color:var(--text-${cls === 'good' ? 'primary' : cls === 'warning' ? 'muted' : 'primary'});min-width:28px;text-align:right">${qty}</span>
      </div>`;
}

// ─── Bill Status Badge ────────────────────────────────────────
function statusBadge(status) {
    const map  = { paid: 'badge-success', unpaid: 'badge-warning', cancelled: 'badge-danger' };
    const text = { paid: '✅ Paid', unpaid: '⏳ Pending', cancelled: '❌ Cancelled' };
    return `<span class="badge ${map[status] || 'badge-muted'}">${text[status] || status}</span>`;
}

// ─── Export to CSV ────────────────────────────────────────────
function exportToCSV(headers, rows, filename = 'export.csv') {
    const escape = v => `"${String(v ?? '').replace(/"/g, '""')}"`;
    const lines = [
        headers.map(escape).join(','),
        ...rows.map(r => r.map(escape).join(','))
    ];
    const blob = new Blob(['\uFEFF' + lines.join('\n')], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url; a.download = filename; a.click();
    URL.revokeObjectURL(url);
    toast('success', 'Exported', `Saved as ${filename}`);
}

// ─── Skeleton loader builders ─────────────────────────────────
function skeletonKpiGrid(count = 4) {
    return `<div class="kpi-grid">${Array(count).fill('<div class="skeleton skeleton-kpi"></div>').join('')}</div>`;
}
function skeletonTable(rows = 5, cols = 5) {
    return `<table><thead><tr>${Array(cols).fill('<th></th>').join('')}</tr></thead><tbody>
    ${Array(rows).fill(`<tr>${Array(cols).fill('<td><div class="skeleton skeleton-table-row"></div></td>').join('')}</tr>`).join('')}
    </tbody></table>`;
}

// ─── Notification badge loader ────────────────────────────────
async function loadSidebarBadges() {
    try {
        const data = await (window.DashboardAPI ? DashboardAPI.stats() : Promise.reject());
        const lowStock = data?.low_stock_count || 0;
        const pendingBills = data?.pending_bill_count || 0;

        const invBadge = document.getElementById('navBadgeInventory');
        const billBadge = document.getElementById('navBadgeBills');
        if (invBadge) { invBadge.textContent = lowStock; invBadge.style.display = lowStock > 0 ? 'inline-flex' : 'none'; }
        if (billBadge) { billBadge.textContent = pendingBills; billBadge.style.display = pendingBills > 0 ? 'inline-flex' : 'none'; }

        // Update header notification bell
        const notifCount = document.getElementById('headerNotifCount');
        const total = lowStock + pendingBills;
        if (notifCount) {
            notifCount.textContent = total;
            notifCount.style.display = total > 0 ? 'flex' : 'none';
        }

        // Fill notification panel
        const panel = document.getElementById('notifPanelItems');
        if (panel) {
            let html = '';
            if (lowStock > 0) html += `<div class="notif-item"><span class="notif-item-icon">⚠️</span><div><div class="notif-item-title">${lowStock} Low Stock Items</div><div class="notif-item-msg">Some products need restocking</div></div></div>`;
            if (pendingBills > 0) html += `<div class="notif-item"><span class="notif-item-icon">🧾</span><div><div class="notif-item-title">${pendingBills} Pending Bills</div><div class="notif-item-msg">Awaiting payment collection</div></div></div>`;
            if (!html) html = `<div class="notif-item"><span class="notif-item-icon">✅</span><div><div class="notif-item-title">All Good!</div><div class="notif-item-msg">No active alerts at this time</div></div></div>`;
            panel.innerHTML = html;
        }
    } catch (e) { /* silent fail */ }
}

// ─── Notification bell toggle ─────────────────────────────────
function toggleNotifPanel() {
    const panel = document.getElementById('notifPanel');
    if (panel) panel.classList.toggle('open');
}
document.addEventListener('click', e => {
    if (!e.target.closest('#notifWrapper')) {
        const panel = document.getElementById('notifPanel');
        if (panel) panel.classList.remove('open');
    }
});

// ─── Generate Bill Number Preview ─────────────────────────────
function generateBillNo() {
    const dStr = new Date().toLocaleString('en-US', { timeZone: 'Asia/Colombo' });
    const d = new Date(dStr);
    const pad = n => String(n).padStart(2, '0');
    const prefix = localStorage.getItem('minyara_bill_prefix') || 'MIN-';
    return `${prefix}${d.getFullYear()}${pad(d.getMonth()+1)}${pad(d.getDate())}-${String(Math.floor(Math.random()*9999)).padStart(4,'0')}`;
}

// ─── PIN Lock ─────────────────────────────────────────────────
function initPinLock() {
    const pin = localStorage.getItem('minyara_pin');
    if (!pin) return; // No PIN set, skip

    const sessionKey = 'minyara_pin_unlocked_' + new Date().toDateString();
    if (sessionStorage.getItem(sessionKey)) return; // Already unlocked today

    const overlay = document.createElement('div');
    overlay.className = 'pin-lock-overlay';
    overlay.innerHTML = `
      <div class="pin-lock-logo">🔐</div>
      <div class="pin-lock-title">Minyara is Locked</div>
      <div class="pin-lock-sub">Enter your 4-digit PIN to continue</div>
      <div class="pin-dots" id="pinDots">
        ${Array(4).fill('<div class="pin-dot"></div>').join('')}
      </div>
      <div class="pin-keypad">
        ${[1,2,3,4,5,6,7,8,9,'✕',0,'⌫'].map(k => `
          <button class="pin-key" onclick="pinKeyPress('${k}')">${k}</button>`).join('')}
      </div>
      <div id="pinError" class="pin-error" style="display:none">Incorrect PIN. Try again.</div>`;
    document.body.appendChild(overlay);
    window._pinEntry = '';
}

function pinKeyPress(key) {
    const pin = localStorage.getItem('minyara_pin');
    if (key === '✕') { window._pinEntry = ''; }
    else if (key === '⌫') { window._pinEntry = window._pinEntry.slice(0, -1); }
    else if (window._pinEntry.length < 4) { window._pinEntry += key; }

    const dots = document.querySelectorAll('.pin-dot');
    dots.forEach((d, i) => d.classList.toggle('filled', i < window._pinEntry.length));

    if (window._pinEntry.length === 4) {
        if (window._pinEntry === pin) {
            sessionStorage.setItem('minyara_pin_unlocked_' + new Date().toDateString(), '1');
            const overlay = document.querySelector('.pin-lock-overlay');
            if (overlay) { overlay.style.opacity = '0'; overlay.style.transition = 'opacity 0.3s'; setTimeout(() => overlay.remove(), 300); }
        } else {
            document.getElementById('pinError').style.display = 'block';
            document.querySelector('.pin-keypad').style.animation = 'shake 0.4s ease';
            setTimeout(() => {
                window._pinEntry = '';
                dots.forEach(d => d.classList.remove('filled'));
                document.querySelector('.pin-keypad').style.animation = '';
            }, 800);
        }
    }
}

// ─── Init ─────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    initDarkMode();
    initPinLock();
    setActivePage();
    initClock();
    initSidebarCollapse();

    // Dark mode toggle in sidebar
    const toggle = document.getElementById('darkModeToggle');
    if (toggle) toggle.addEventListener('change', () => toggleDarkMode(toggle.checked));

    // Load sidebar badges after a small delay (API may not be ready)
    setTimeout(loadSidebarBadges, 500);

    // Add Ctrl+K hint button in header if search btn exists
    const searchBtn = document.getElementById('globalSearchBtn');
    if (searchBtn) searchBtn.addEventListener('click', openGlobalSearch);
});
