/* ============================================================
   MINYARA — Supabase API Layer (Vercel + GitHub compatible)
   ============================================================ */

const sb = window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY);

function unwrap(result) {
    if (result.error) throw new Error(result.error.message);
    return result.data;
}

function mapBillItem(item) {
    if (!item) return item;
    return {
        ...item,
        qty: item.quantity ?? item.qty,
        total: parseFloat(item.total_price ?? item.total ?? 0)
    };
}

function mapBill(bill) {
    if (!bill) return bill;
    const mapped = { ...bill };
    if (mapped.items) mapped.items = mapped.items.map(mapBillItem);
    return mapped;
}

function mapProduct(row, categoryMap = null) {
    if (!row) return row;
    const p = { ...row };
    if (categoryMap && p.category_id) p.category_name = categoryMap[p.category_id] || null;
    delete p.categories;
    return p;
}

async function getCategoryMap() {
    const cats = unwrap(await sb.from('categories').select('id, name'));
    return Object.fromEntries(cats.map(c => [c.id, c.name]));
}

async function attachProductImages(items) {
    const prodIds = [...new Set(items.filter(i => i.product_id).map(i => i.product_id))];
    if (!prodIds.length) return items.map(i => ({ ...mapBillItem(i), product_image: null }));
    const prods = unwrap(await sb.from('products').select('id, image').in('id', prodIds));
    const imageMap = Object.fromEntries(prods.map(p => [p.id, p.image]));
    return items.map(i => ({ ...mapBillItem(i), product_image: imageMap[i.product_id] || null }));
}

async function uploadToBucket(bucket, file) {
    const ext = (file.name.split('.').pop() || 'jpg').toLowerCase();
    const allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    if (!allowed.includes(ext)) throw new Error('Invalid file type. Only JPG, PNG, GIF, and WebP are allowed.');
    if (file.size > 2 * 1024 * 1024) throw new Error('File size too large. Max 2MB allowed.');
    const filename = `${bucket}_${Date.now()}_${Math.random().toString(36).slice(2)}.${ext}`;
    unwrap(await sb.storage.from(bucket).upload(filename, file, { cacheControl: '3600', upsert: false }));
    const { data: { publicUrl } } = sb.storage.from(bucket).getPublicUrl(filename);
    return { message: 'Upload successful', path: publicUrl, url: publicUrl };
}

const DEFAULT_SETTINGS = {
    shop_name: 'MINYARA Printing',
    shop_tagline: 'A MOMENTS OF TECHNOLOGY',
    shop_address: '143/7, Church rd, Welivita, Kaduwela',
    shop_phone: '0786763999',
    shop_email: 'minyara.team.lk@gmail.com',
    currency: 'Rs.',
    bill_prefix: 'MIN-',
    invoice_footer: ''
};

function parseDBDate(str) {
    if (!str) return new Date();
    if (str instanceof Date) return str;
    let formatted = str;
    if (!str.includes('Z') && !/[+-]\d{2}(:\d{2})?$/.test(str)) {
        if (!str.includes('T')) {
            formatted = str.replace(' ', 'T');
        }
        formatted += 'Z';
    }
    return new Date(formatted);
}

function toColomboDate(date) {
    const d = parseDBDate(date);
    return new Date(d.toLocaleString('en-US', { timeZone: 'Asia/Colombo' }));
}

function localToUTCString(dateStr, timeStr) {
    if (!dateStr) return '';
    try {
        const date = new Date(`${dateStr}T${timeStr}+05:30`);
        return date.toISOString().replace(/\.\d+Z$/, '').replace('Z', '');
    } catch(e) {
        return `${dateStr}T${timeStr}`;
    }
}

function getLocalDateString(date) {
    const d = toColomboDate(date);
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
}

function startOfDay(d) { const x = toColomboDate(d); x.setHours(0, 0, 0, 0); return x; }
function isSameDay(a, b) { return startOfDay(a).getTime() === startOfDay(b).getTime(); }
function isSameWeek(a, b) {
    const da = startOfDay(a), db = startOfDay(b);
    const dayA = (da.getDay() + 6) % 7, dayB = (db.getDay() + 6) % 7;
    const monA = new Date(da); monA.setDate(da.getDate() - dayA);
    const monB = new Date(db); monB.setDate(db.getDate() - dayB);
    return monA.getTime() === monB.getTime();
}
function isSameMonth(a, b) {
    const da = toColomboDate(a), db = toColomboDate(b);
    return da.getFullYear() === db.getFullYear() && da.getMonth() === db.getMonth();
}
function isSameYear(a, b) {
    const da = toColomboDate(a), db = toColomboDate(b);
    return da.getFullYear() === db.getFullYear();
}
function paidBills(bills) { return bills.filter(b => b.status === 'paid'); }
function sumTotal(bills) { return bills.reduce((s, b) => s + parseFloat(b.total || 0), 0); }
function monthLabel(date) { return toColomboDate(date).toLocaleString('en-US', { month: 'short', year: 'numeric' }); }
function getISOWeek(date) {
    const colombo = toColomboDate(date);
    const d = new Date(Date.UTC(colombo.getFullYear(), colombo.getMonth(), colombo.getDate()));
    d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
}

async function fetchBillItemsForBills(billIds) {
    if (!billIds.length) return [];
    return unwrap(await sb.from('bill_items').select('*').in('bill_id', billIds));
}

async function attachCustomerStats(customers) {
    const bills = unwrap(await sb.from('bills').select('customer_id, total'));
    return customers.map(c => {
        const custBills = bills.filter(b => b.customer_id === c.id);
        return {
            ...c,
            total_bills: custBills.length,
            total_spent: custBills.reduce((s, b) => s + parseFloat(b.total || 0), 0)
        };
    });
}

// ─── Categories ───────────────────────────────────────────────
const CategoriesAPI = {
    list: async () => {
        const cats = unwrap(await sb.from('categories').select('*').order('name'));
        const products = unwrap(await sb.from('products').select('id, category_id').eq('is_active', true));
        const counts = {};
        products.forEach(p => { if (p.category_id) counts[p.category_id] = (counts[p.category_id] || 0) + 1; });
        return cats.map(c => ({ ...c, product_count: counts[c.id] || 0 }));
    },
    get: async (id) => unwrap(await sb.from('categories').select('*').eq('id', id).maybeSingle()),
    create: async (data) => {
        const row = unwrap(await sb.from('categories').insert({ name: data.name, description: data.description || '' }).select('id').single());
        return { id: row.id, message: 'Category created' };
    },
    update: async (id, data) => {
        unwrap(await sb.from('categories').update({ name: data.name, description: data.description || '' }).eq('id', id));
        return { message: 'Category updated' };
    },
    delete: async (id) => {
        unwrap(await sb.from('products').update({ category_id: null }).eq('category_id', id));
        unwrap(await sb.from('categories').delete().eq('id', id));
        return { message: 'Category deleted' };
    }
};

// ─── Products ─────────────────────────────────────────────────
const ProductsAPI = {
    list: async (params = {}) => {
        let q = sb.from('products').select('*').eq('is_active', true).order('name');
        if (params.category) q = q.eq('category_id', parseInt(params.category, 10));
        let rows = unwrap(await q);
        if (params.search) {
            const s = params.search.toLowerCase();
            rows = rows.filter(p => (p.name || '').toLowerCase().includes(s) || (p.sku || '').toLowerCase().includes(s));
        }
        if (params.low_stock === '1') rows = rows.filter(p => p.stock_qty <= p.min_stock);
        const categoryMap = await getCategoryMap();
        return rows.map(p => mapProduct(p, categoryMap));
    },
    get: async (id) => {
        const row = unwrap(await sb.from('products').select('*').eq('id', id).maybeSingle());
        if (!row) return null;
        const categoryMap = await getCategoryMap();
        return mapProduct(row, categoryMap);
    },
    create: async (data) => {
        let sku = data.sku;
        if (!sku) {
            const prefix = (data.name || '').replace(/[^a-z]/gi, '').substring(0, 3).toUpperCase();
            sku = prefix + '-' + Math.random().toString(36).substring(2, 10).toUpperCase();
        }
        const row = unwrap(await sb.from('products').insert({
            category_id: data.category_id || null, name: data.name, sku,
            unit: data.unit || 'pcs', cost_price: data.cost_price ?? 0, sell_price: data.sell_price,
            stock_qty: data.stock_qty ?? 0, min_stock: data.min_stock ?? 5,
            description: data.description || '', color: data.color || null, image: data.image || null, is_active: true
        }).select('id').single());
        if ((data.stock_qty ?? 0) > 0) {
            unwrap(await sb.from('stock_adjustments').insert({ product_id: row.id, type: 'in', quantity: data.stock_qty, note: 'Initial stock' }));
        }
        return { id: row.id, message: 'Product created' };
    },
    update: async (id, data) => {
        unwrap(await sb.from('products').update({
            category_id: data.category_id ?? null, name: data.name, sku: data.sku || '',
            unit: data.unit || 'pcs', cost_price: data.cost_price ?? 0, sell_price: data.sell_price,
            min_stock: data.min_stock ?? 5, description: data.description || '',
            color: data.color ?? null, is_active: data.is_active !== undefined ? !!data.is_active : true, image: data.image ?? null
        }).eq('id', id));
        return { message: 'Product updated' };
    },
    delete: async (id) => {
        unwrap(await sb.from('products').update({ is_active: false }).eq('id', id));
        return { message: 'Product deactivated' };
    },
    uploadImage: (file) => uploadToBucket('products', file)
};

// ─── Stock ────────────────────────────────────────────────────
const StockAPI = {
    adjust: async (data) => {
        const result = unwrap(await sb.rpc('adjust_product_stock', {
            p_product_id: parseInt(data.product_id, 10), p_type: data.type,
            p_quantity: parseInt(data.quantity, 10), p_note: data.note || ''
        }));
        return { message: 'Stock adjusted', new_stock: result.new_stock };
    }
};

// ─── Customers ────────────────────────────────────────────────
const CustomersAPI = {
    list: async (params = {}) => {
        let rows = unwrap(await sb.from('customers').select('*').order('created_at', { ascending: false }));
        if (params.search) {
            const s = params.search.toLowerCase();
            rows = rows.filter(c => (c.name || '').toLowerCase().includes(s) || (c.phone || '').toLowerCase().includes(s));
        }
        return attachCustomerStats(rows);
    },
    get: async (id) => {
        const customer = unwrap(await sb.from('customers').select('*').eq('id', id).maybeSingle());
        if (!customer) throw new Error('Customer not found');
        const [stats] = await attachCustomerStats([customer]);
        const recent_bills = unwrap(await sb.from('bills').select('id, bill_no, total, payment_method, status, created_at')
            .eq('customer_id', id).order('created_at', { ascending: false }).limit(10));
        return { ...stats, recent_bills };
    },
    create: async (data) => {
        const name = (data.name || '').trim();
        if (!name) throw new Error('Customer name is required');
        const phone = (data.phone || '').trim() || null;
        if (phone) {
            const existing = unwrap(await sb.from('customers').select('id').eq('phone', phone).maybeSingle());
            if (existing) throw new Error('A customer with this phone number already exists');
        }
        const row = unwrap(await sb.from('customers').insert({
            name, phone, email: (data.email || '').trim() || null,
            address: (data.address || '').trim() || null, notes: (data.notes || '').trim() || null,
            image: (data.image || '').trim() || null
        }).select('id').single());
        return { id: row.id, message: 'Customer created successfully' };
    },
    update: async (id, data) => {
        const current = unwrap(await sb.from('customers').select('*').eq('id', id).maybeSingle());
        if (!current) throw new Error('Customer not found');
        const name = data.name !== undefined ? (data.name || '').trim() : current.name;
        const phone = data.phone !== undefined ? ((data.phone || '').trim() || null) : current.phone;
        if (!name) throw new Error('Customer name is required');
        if (phone && phone !== current.phone) {
            const existing = unwrap(await sb.from('customers').select('id').eq('phone', phone).neq('id', id).maybeSingle());
            if (existing) throw new Error('A customer with this phone number already exists');
        }
        unwrap(await sb.from('customers').update({
            name, phone,
            email: data.email !== undefined ? ((data.email || '').trim() || null) : current.email,
            address: data.address !== undefined ? ((data.address || '').trim() || null) : current.address,
            notes: data.notes !== undefined ? ((data.notes || '').trim() || null) : current.notes,
            image: data.image !== undefined ? ((data.image || '').trim() || null) : current.image
        }).eq('id', id));
        return { message: 'Customer updated successfully' };
    },
    delete: async (id) => {
        unwrap(await sb.from('bills').update({ customer_id: null }).eq('customer_id', id));
        unwrap(await sb.from('customers').delete().eq('id', id));
        return { message: 'Customer deleted successfully' };
    },
    uploadImage: (file) => uploadToBucket('products', file)
};

// ─── Bills ────────────────────────────────────────────────────
const BillsAPI = {
    list: async (params = {}) => {
        let q = sb.from('bills').select('*').order('created_at', { ascending: false }).limit(200);
        if (params.from) q = q.gte('created_at', localToUTCString(params.from, '00:00:00'));
        if (params.to) q = q.lte('created_at', localToUTCString(params.to, '23:59:59'));
        if (params.payment_method) q = q.eq('payment_method', params.payment_method);
        if (params.status) q = q.eq('status', params.status);
        let rows = unwrap(await q);
        if (params.search) {
            const s = params.search.toLowerCase();
            rows = rows.filter(b => 
                (b.bill_no || '').toLowerCase().includes(s) || 
                (b.customer_name || '').toLowerCase().includes(s) || 
                (b.customer_phone || '').toLowerCase().includes(s)
            );
        }
        return rows;
    },
    get: async (id) => {
        const bill = unwrap(await sb.from('bills').select('*').eq('id', id).maybeSingle());
        if (!bill) throw new Error('Bill not found');
        const items = unwrap(await sb.from('bill_items').select('*').eq('bill_id', id));
        bill.items = await attachProductImages(items);
        return mapBill(bill);
    },
    create: async (data) => {
        const items = data.items || [];
        if (!items.length) throw new Error('Bill must have at least one item');
        const billNo = 'MIN-' + new Date().toISOString().slice(0, 10).replace(/-/g, '') + '-' + String(Math.floor(Math.random() * 9999) + 1).padStart(4, '0');
        let subtotal = 0;
        items.forEach(item => { subtotal += parseFloat(item.qty) * parseFloat(item.unit_price); });
        const discount = parseFloat(data.discount || 0);
        const tax = parseFloat(data.tax || 0);
        const total = subtotal - discount + tax;
        const paidAmount = parseFloat(data.paid_amount ?? total);
        const change = Math.max(0, paidAmount - total);
        let status = data.status || 'paid';
        if (paidAmount < total && !data.status) status = 'unpaid';
        const result = unwrap(await sb.rpc('create_bill_with_items', {
            p_bill_no: billNo, p_customer_name: data.customer_name || '', p_customer_phone: data.customer_phone || '',
            p_subtotal: subtotal, p_discount: discount, p_tax: tax, p_total: total,
            p_paid_amount: paidAmount, p_change_amount: change,
            p_payment_method: data.payment_method || 'cash', p_status: status, p_notes: data.notes || '', p_items: items
        }));
        return { id: result.id, bill_no: result.bill_no, total: result.total, change: result.change };
    },
    update: async (id, data) => BillsAPI.updateStatus(id, data.status),
    updateStatus: async (id, status) => {
        if (!['paid', 'unpaid', 'cancelled'].includes(status)) throw new Error('Invalid status');
        unwrap(await sb.from('bills').update({ status }).eq('id', id));
        return { message: 'Status updated successfully', status };
    },
    delete: async (id) => {
        unwrap(await sb.rpc('delete_bill_restore_stock', { p_bill_id: parseInt(id, 10) }));
        return { message: 'Bill deleted and stock restored' };
    }
};

// ─── Dashboard ────────────────────────────────────────────────
const DashboardAPI = {
    stats: async () => {
        const now = new Date();
        const colomboNow = toColomboDate(now);
        const products = unwrap(await sb.from('products').select('*').eq('is_active', true));
        const bills = unwrap(await sb.from('bills').select('*').order('created_at', { ascending: false }));
        const paid = paidBills(bills);
        const lowStockProducts = products.filter(p => p.stock_qty <= p.min_stock);
        const stockValue = products.reduce((s, p) => {
            const price = parseFloat(p.cost_price) > 0 ? parseFloat(p.cost_price) : parseFloat(p.sell_price);
            return s + price * (p.stock_qty || 0);
        }, 0);
        const todayPaid = paid.filter(b => isSameDay(b.created_at, colomboNow));
        const weekPaid = paid.filter(b => isSameWeek(b.created_at, colomboNow));
        const monthPaid = paid.filter(b => isSameMonth(b.created_at, colomboNow));
        const yearPaid = paid.filter(b => isSameYear(b.created_at, colomboNow));
        const daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        const weekTotals = Array(7).fill(0);
        weekPaid.forEach(b => { weekTotals[toColomboDate(b.created_at).getDay()] += parseFloat(b.total || 0); });
        const chartDaily = daysOfWeek.map((label, i) => ({ label, value: weekTotals[i] }));
        const monthlyMap = {};
        const twelveMonthsAgo = new Date(colomboNow.getFullYear(), colomboNow.getMonth() - 11, 1);
        paid.filter(b => toColomboDate(b.created_at) >= twelveMonthsAgo).forEach(b => {
            const d = toColomboDate(b.created_at);
            const key = d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0');
            monthlyMap[key] = (monthlyMap[key] || 0) + parseFloat(b.total || 0);
        });
        const chartMonthly = Object.keys(monthlyMap).sort().map(key => {
            const [y, m] = key.split('-').map(Number);
            return { label: monthLabel(new Date(y, m - 1, 1)), value: monthlyMap[key] };
        });
        const yearlyMap = {};
        paid.filter(b => toColomboDate(b.created_at).getFullYear() >= colomboNow.getFullYear() - 4).forEach(b => {
            const y = toColomboDate(b.created_at).getFullYear();
            yearlyMap[y] = (yearlyMap[y] || 0) + parseFloat(b.total || 0);
        });
        const chartYearly = Object.keys(yearlyMap).sort().map(y => ({ label: y, value: yearlyMap[y] }));
        const recentBills = bills.slice(0, 10).map(b => ({ id: b.id, bill_no: b.bill_no, customer_name: b.customer_name, total: b.total, status: b.status, created_at: b.created_at }));
        const cats = unwrap(await sb.from('categories').select('id, name'));
        const catMap = Object.fromEntries(cats.map(c => [c.id, c.name]));
        const lowStockItems = lowStockProducts.sort((a, b) => a.stock_qty - b.stock_qty).slice(0, 8)
            .map(p => ({ name: p.name, stock_qty: p.stock_qty, min_stock: p.min_stock, category: catMap[p.category_id] || '' }));
        const thirtyDaysAgo = new Date(colomboNow); thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        const recentPaidIds = paid.filter(b => toColomboDate(b.created_at) >= thirtyDaysAgo).map(b => b.id);
        const recentItems = await fetchBillItemsForBills(recentPaidIds);
        const topMap = {};
        recentItems.forEach(i => {
            if (!topMap[i.product_name]) topMap[i.product_name] = { total_sold: 0, revenue: 0 };
            topMap[i.product_name].total_sold += i.quantity;
            topMap[i.product_name].revenue += parseFloat(i.total_price || 0);
        });
        const topProducts = Object.entries(topMap).map(([product_name, v]) => ({ product_name, total_sold: v.total_sold, revenue: v.revenue }))
            .sort((a, b) => b.total_sold - a.total_sold).slice(0, 5);
        return {
            total_products: products.length, low_stock_count: lowStockProducts.length,
            stock_value: Math.round(stockValue * 100) / 100,
            sales_today: Math.round(sumTotal(todayPaid) * 100) / 100,
            sales_week: Math.round(sumTotal(weekPaid) * 100) / 100,
            sales_month: Math.round(sumTotal(monthPaid) * 100) / 100,
            sales_year: Math.round(sumTotal(yearPaid) * 100) / 100,
            today_bill_count: bills.filter(b => isSameDay(b.created_at, colomboNow)).length,
            chart_daily: chartDaily, chart_monthly: chartMonthly, chart_yearly: chartYearly,
            recent_bills: recentBills, low_stock_items: lowStockItems, top_products: topProducts
        };
    },
    manual: (period, dateVal) => AnalyticsAPI.manual(period, dateVal),
    dailyChart: async (month, year) => {
        const m = parseInt(month, 10) || (new Date().getMonth() + 1);
        const y = parseInt(year, 10) || new Date().getFullYear();
        const daysInMonth = new Date(y, m, 0).getDate();
        const from = localToUTCString(`${y}-${String(m).padStart(2, '0')}-01`, '00:00:00');
        const to = localToUTCString(`${y}-${String(m).padStart(2, '0')}-${String(daysInMonth).padStart(2, '0')}`, '23:59:59');
        const bills = unwrap(await sb.from('bills').select('total, created_at, status').eq('status', 'paid').gte('created_at', from).lte('created_at', to));
        const map = {};
        bills.forEach(b => { const day = toColomboDate(b.created_at).getDate(); map[day] = (map[day] || 0) + parseFloat(b.total || 0); });
        const data = [];
        for (let d = 1; d <= daysInMonth; d++) data.push({ label: d, revenue: Math.round((map[d] || 0) * 100) / 100 });
        return { month: m, year: y, days_in_month: daysInMonth, data };
    }
};

// ─── Analytics ────────────────────────────────────────────────
const AnalyticsAPI = {
    charts: async (period = 'year') => {
        const now = new Date();
        const colomboNow = toColomboDate(now);
        const bills = unwrap(await sb.from('bills').select('*').eq('status', 'paid'));
        const filtered = bills.filter(b => {
            const d = toColomboDate(b.created_at);
            if (period === 'today') return isSameDay(b.created_at, colomboNow);
            if (period === 'week') return isSameWeek(b.created_at, colomboNow);
            if (period === 'month') return isSameMonth(b.created_at, colomboNow);
            if (period === 'year') return isSameYear(b.created_at, colomboNow);
            return true;
        });
        const items = await fetchBillItemsForBills(filtered.map(b => b.id));
        const products = unwrap(await sb.from('products').select('id, category_id'));
        const categories = unwrap(await sb.from('categories').select('id, name'));
        const prodCat = Object.fromEntries(products.map(p => [p.id, p.category_id]));
        const catName = Object.fromEntries(categories.map(c => [c.id, c.name]));
        let revenueTrend = [];
        if (period === 'today') {
            const hours = {};
            filtered.forEach(b => { const h = toColomboDate(b.created_at).getHours(); hours[h] = (hours[h] || 0) + parseFloat(b.total || 0); });
            revenueTrend = Object.keys(hours).sort((a, b) => a - b).map(h => ({ label: h + ':00', value: hours[h] }));
        } else if (period === 'week') {
            const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
            const vals = Array(7).fill(0);
            filtered.forEach(b => { vals[toColomboDate(b.created_at).getDay()] += parseFloat(b.total || 0); });
            revenueTrend = days.map((label, i) => ({ label, value: vals[i] }));
        } else if (period === 'month') {
            const days = {};
            filtered.forEach(b => { const day = toColomboDate(b.created_at).getDate(); days[day] = (days[day] || 0) + parseFloat(b.total || 0); });
            revenueTrend = Object.keys(days).sort((a, b) => a - b).map(d => ({ label: d, value: days[d] }));
        } else {
            const months = {};
            filtered.forEach(b => { const key = toColomboDate(b.created_at).getMonth(); months[key] = (months[key] || 0) + parseFloat(b.total || 0); });
            revenueTrend = Object.keys(months).sort((a, b) => a - b).map(m => ({ label: new Date(2000, parseInt(m, 10), 1).toLocaleString('en-US', { month: 'long' }), value: months[m] }));
        }
        const catSales = {};
        items.forEach(i => { const name = catName[prodCat[i.product_id]] || 'Uncategorized'; catSales[name] = (catSales[name] || 0) + parseFloat(i.total_price || 0); });
        const qtyMap = {}, revMap = {};
        items.forEach(i => {
            qtyMap[i.product_name] = (qtyMap[i.product_name] || 0) + i.quantity;
            revMap[i.product_name] = (revMap[i.product_name] || 0) + parseFloat(i.total_price || 0);
        });
        return {
            revenue_trend: revenueTrend,
            sales_by_category: Object.entries(catSales).map(([label, value]) => ({ label, value })).sort((a, b) => b.value - a.value),
            top_products_qty: Object.entries(qtyMap).map(([label, value]) => ({ label, value })).sort((a, b) => b.value - a.value).slice(0, 6),
            revenue_by_product: Object.entries(revMap).map(([label, value]) => ({ label, value })).sort((a, b) => b.value - a.value).slice(0, 8),
            payment_methods: Object.entries(filtered.reduce((m, b) => { const l = (b.payment_method || 'cash').toUpperCase(); m[l] = (m[l] || 0) + 1; return m; }, {})).map(([label, value]) => ({ label, value }))
        };
    },
    manual: async (period = 'monthly', dateVal = '') => {
        const now = new Date();
        const colomboNow = toColomboDate(now);
        let filtered = unwrap(await sb.from('bills').select('*').eq('status', 'paid'));
        if (period === 'daily') {
            const d = dateVal || getLocalDateString(colomboNow);
            filtered = filtered.filter(b => getLocalDateString(b.created_at) === d);
        } else if (period === 'weekly') {
            let weekVal = dateVal || `${colomboNow.getFullYear()}-W${String(getISOWeek(colomboNow)).padStart(2, '0')}`;
            const matchYear = parseInt(weekVal.slice(0, 4), 10);
            const matchWeek = parseInt(weekVal.split('W')[1], 10);
            filtered = filtered.filter(b => { const d = toColomboDate(b.created_at); return d.getFullYear() === matchYear && getISOWeek(d) === matchWeek; });
        } else if (period === 'monthly') {
            const val = dateVal || `${colomboNow.getFullYear()}-${String(colomboNow.getMonth() + 1).padStart(2, '0')}`;
            const [y, m] = val.split('-').map(Number);
            filtered = filtered.filter(b => { const d = toColomboDate(b.created_at); return d.getFullYear() === y && d.getMonth() + 1 === m; });
        } else if (period === 'yearly') {
            const y = parseInt(dateVal || colomboNow.getFullYear(), 10);
            filtered = filtered.filter(b => toColomboDate(b.created_at).getFullYear() === y);
        }
        const items = await fetchBillItemsForBills(filtered.map(b => b.id));
        const itemMap = {};
        items.forEach(i => {
            if (!itemMap[i.product_name]) itemMap[i.product_name] = { total_qty: 0, total_revenue: 0 };
            itemMap[i.product_name].total_qty += i.quantity;
            itemMap[i.product_name].total_revenue += parseFloat(i.total_price || 0);
        });
        const itemsSold = Object.entries(itemMap).map(([product_name, v]) => ({ product_name, total_qty: v.total_qty, total_revenue: v.total_revenue }))
            .sort((a, b) => b.total_revenue - a.total_revenue);
        let chart = [];
        if (period === 'daily') {
            const hours = {};
            filtered.forEach(b => { const h = toColomboDate(b.created_at).getHours(); hours[h] = (hours[h] || 0) + parseFloat(b.total || 0); });
            chart = Object.keys(hours).sort((a, b) => a - b).map(h => ({ label: h + ':00', value: hours[h] }));
        } else if (period === 'monthly') {
            const days = {};
            filtered.forEach(b => { const day = toColomboDate(b.created_at).getDate(); days[day] = (days[day] || 0) + parseFloat(b.total || 0); });
            chart = Object.keys(days).sort((a, b) => a - b).map(d => ({ label: d, value: days[d] }));
        } else if (period === 'yearly') {
            const months = {};
            filtered.forEach(b => { const m = toColomboDate(b.created_at).getMonth(); months[m] = (months[m] || 0) + parseFloat(b.total || 0); });
            chart = Object.keys(months).sort((a, b) => a - b).map(m => ({ label: new Date(2000, parseInt(m, 10), 1).toLocaleString('en-US', { month: 'long' }), value: months[m] }));
        } else {
            const dayMap = {};
            filtered.forEach(b => { const key = getLocalDateString(b.created_at); dayMap[key] = (dayMap[key] || 0) + parseFloat(b.total || 0); });
            chart = Object.keys(dayMap).sort().map(k => {
                const d = new Date(k + 'T12:00:00');
                return { label: d.toLocaleDateString('en-US', { weekday: 'long' }), value: dayMap[k] };
            });
        }
        return { revenue: Math.round(sumTotal(filtered) * 100) / 100, bills: filtered.length, items: itemsSold, chart };
    }
};

// ─── Settings ──────────────────────────────────────────────────
const SettingsAPI = {
    get: async () => {
        const row = unwrap(await sb.from('app_settings').select('settings').eq('id', 1).maybeSingle());
        return { ...DEFAULT_SETTINGS, ...(row?.settings || {}) };
    },
    save: async (data) => {
        const current = await SettingsAPI.get();
        const merged = { ...current, ...data };
        unwrap(await sb.from('app_settings').upsert({ id: 1, settings: merged, updated_at: new Date().toISOString() }));
        return { message: 'Settings saved successfully' };
    }
};

window.CategoriesAPI = CategoriesAPI;
window.ProductsAPI = ProductsAPI;
window.StockAPI = StockAPI;
window.CustomersAPI = CustomersAPI;
window.BillsAPI = BillsAPI;
window.DashboardAPI = DashboardAPI;
window.AnalyticsAPI = AnalyticsAPI;
window.SettingsAPI = SettingsAPI;
