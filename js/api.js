/* ============================================================
   MINYARA — BASE API URL
   ============================================================ */
// apiFetch uses relative paths, so no BASE/API variable needed.

// ─── Generic fetch wrapper ────────────────────────────────────
async function apiFetch(endpoint, options = {}) {
    const url = `api/${endpoint}`;
    const defaults = {
        headers: { 'Content-Type': 'application/json' },
    };
    const config = { ...defaults, ...options };
    if (config.body && typeof config.body === 'object') {
        config.body = JSON.stringify(config.body);
    }
    try {
        const res = await fetch(url, config);
        if (!res.ok) {
            const err = await res.json().catch(() => ({ error: `HTTP ${res.status}` }));
            throw new Error(err.error || `HTTP ${res.status}`);
        }
        return await res.json();
    } catch (e) {
        if (e.name !== 'AbortError') throw e;
    }
}

// ─── Categories ───────────────────────────────────────────────
const CategoriesAPI = {
    list: ()         => apiFetch('categories.php'),
    get:  (id)       => apiFetch(`categories.php?id=${id}`),
    create: (data)   => apiFetch('categories.php', { method: 'POST', body: data }),
    update: (id, d)  => apiFetch(`categories.php?id=${id}`, { method: 'PUT', body: d }),
    delete: (id)     => apiFetch(`categories.php?id=${id}`, { method: 'DELETE' }),
};

// ─── Products ─────────────────────────────────────────────────
const ProductsAPI = {
    list: (params={}) => {
        const q = new URLSearchParams(params).toString();
        return apiFetch('products.php' + (q ? '?' + q : ''));
    },
    get:    (id)      => apiFetch(`products.php?id=${id}`),
    create: (data)    => apiFetch('products.php', { method: 'POST', body: data }),
    update: (id, d)   => apiFetch(`products.php?id=${id}`, { method: 'PUT', body: d }),
    delete: (id)      => apiFetch(`products.php?id=${id}`, { method: 'DELETE' }),
    uploadImage: (file) => {
        const formData = new FormData();
        formData.append('image', file);
        return fetch('api/upload.php', {
            method: 'POST',
            body: formData
        }).then(res => res.json().then(data => {
            if (!res.ok) throw new Error(data.error || 'Upload failed');
            return data;
        }));
    }
};

// ─── Stock ────────────────────────────────────────────────────
const StockAPI = {
    adjust: (data) => apiFetch('stock.php', { method: 'POST', body: data }),
};

// ─── Bills ────────────────────────────────────────────────────
const BillsAPI = {
    list: (params={}) => {
        const q = new URLSearchParams(params).toString();
        return apiFetch('bills.php' + (q ? '?' + q : ''));
    },
    get:    (id)    => apiFetch(`bills.php?id=${id}`),
    create: (data)  => apiFetch('bills.php', { method: 'POST', body: data }),
    updateStatus: (id, status) => apiFetch('bills.php?id=' + id, { method: 'PATCH', body: { status } }),
    delete: (id)    => apiFetch(`bills.php?id=${id}`, { method: 'DELETE' }),
};

// ─── Dashboard ────────────────────────────────────────────────
const DashboardAPI = {
    stats: () => apiFetch('dashboard.php'),
    manual: (period, dateVal) => apiFetch(`analytics.php?period=${period}&date=${dateVal}`),
    dailyChart: (month, year) => apiFetch(`daily_chart.php?month=${month}&year=${year}`),
};

// ─── Analytics ────────────────────────────────────────────────
const AnalyticsAPI = {
    charts: (period = 'year') => apiFetch(`charts.php?period=${period}`)
};

// ─── Settings ──────────────────────────────────────────────────
const SettingsAPI = {
    get: () => apiFetch('settings.php'),
    save: (data) => apiFetch('settings.php', { method: 'POST', body: data })
};

window.CategoriesAPI = CategoriesAPI;
window.ProductsAPI = ProductsAPI;
window.StockAPI = StockAPI;
window.BillsAPI = BillsAPI;
window.DashboardAPI = DashboardAPI;
window.AnalyticsAPI = AnalyticsAPI;
window.SettingsAPI = SettingsAPI;

