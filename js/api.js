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

function mapProduct(row) {
    if (!row) return row;
    const p = { ...row };
    if (row.categories && row.categories.name) p.category_name = row.categories.name;
    delete p.categories;
    return p;
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

function startOfDay(d) {
    const x = new Date(d);
    x.setHours(0, 0, 0, 0);
    return x;
}

function isSameDay(a, b) {
    return startOfDay(a).getTime() === startOfDay(b).getTime();
}

function isSameWeek(a, b) {
    const da = startOfDay(a);
    const db = startOfDay(b);
    const dayA = (da.getDay() + 6) % 7;
    const dayB = (db.getDay() + 6) % 7;
    const monA = new Date(da);
    monA.setDate(da.getDate() - dayA);
    const monB = new Date(db);
    monB.setDate(db.getDate() - dayB);
    return monA.getTime() === monB.getTime();
}

function isSameMonth(a, b) {
    return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth();
}

function isSameYear(a, b) {
    return a.getFullYear() === b.getFullYear();
}

function paidBills(bills) {
    return bills.filter(b => b.status === 'paid');
}

function sumTotal(bills) {
    return bills.reduce((s, b) => s + parseFloat(b.total || 0), 0);
}

function monthLabel(date) {
    return date.toLocaleString('en-US', { month: 'short', year: 'numeric' });
}

async function fetchPaidBillsInRange(fromIso, toIso) {
    let q = sb.from('bills').select('*').eq('status', 'paid').order('created_at', { ascending: false });
    if (fromIso) q = q.gte('created_at', fromIso);
    if (toIso) q = q.lte('created_at', toIso);
    return unwrap(await q);
}

async function fetchBillItemsForBills(billIds) {
    if (!billIds.length) return [];
    return unwrap(await sb.from('bill_items').select('*').in('bill_id', billIds));
}

// ─── Categories ───────────────────────────────────────────────
const CategoriesAPI = {
    list: async () => {
        const cats = unwrap(await sb.from('categories').select('*').order('name'));
        const products = unwrap(await sb.from('products').select('id, category_id').eq('is_active', true));
        const counts = {};
        products.forEach(p => {
            if (p.category_id) counts[p.category_id] = (counts[p.category_id] || 0) + 1;
        });
        return cats.map(c => ({ ...c, product_count: counts[c.id] || 0 }));
    },
    get: async (id) => unwrap(await sb.from('categories').select('*').eq('id', id).maybeSingle()),
    create: async (data) => {
        const row = unwrap(await sb.from('categories').insert({
            name: data.name,
            description: data.description || ''
        }).select('id').single());
        return { id: row.id, message: 'Category created' };
    },
    update: async (id, data) => {
        unwrap(await sb.from('categories').update({
            name: data.name,
            description: data.description || ''
        }).eq('id', id));
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
        let q = sb.from('products').select('*, categories(name)').eq('is_active', true).order('name');
        if (params.category) q = q.eq('category_id', parseInt(params.category, 10));
        let rows = unwrap(await q);
        if (params.search) {
            const s = params.search.toLowerCase();
            rows = rows.filter(p =>
                (p.name || '').toLowerCase().includes(s) ||
                (p.sku || '').toLowerCase().includes(s)
            );
        }
        if (params.low_stock === '1') {
            rows = rows.filter(p => p.stock_qty <= p.min_stock);
        }
        return rows.map(mapProduct);
    },
    get: async (id) => {
        const row = unwrap(await sb.from('products').select('*, categories(name)').eq('id', id).maybeSingle());
        return mapProduct(row);
    },
    create: async (data) => {
        let sku = data.sku;
        if (!sku) {
            const prefix = (data.name || '').replace(/[^a-z]/gi, '').substring(0, 3).toUpperCase();
            sku = prefix + '-' + Math.random().toString(36).substring(2, 10).toUpperCase();
        }
        const row = unwrap(await sb.from('products').insert({
            category_id: data.category_id || null,
            name: data.name,
            sku,
            unit: data.unit || 'pcs',
            cost_price: data.cost_price ?? 0,
            sell_price: data.sell_price,
            stock_qty: data.stock_qty ?? 0,
            min_stock: data.min_stock ?? 5,
            description: data.description || '',
            color: data.color || null,
            image: data.image || null,
            is_active: true
        }).select('id').single());

        if ((data.stock_qty ?? 0) > 0) {
            unwrap(await sb.from('stock_adjustments').insert({
                product_id: row.id,
                type: 'in',
                quantity: data.stock_qty,
                note: 'Initial stock'
            }));
        }
        return { id: row.id, message: 'Product created' };
    },
    update: async (id, data) => {
        unwrap(await sb.from('products').update({
            category_id: data.category_id ?? null,
            name: data.name,
            sku: data.sku || '',
            unit: data.unit || 'pcs',
            cost_price: data.cost_price ?? 0,
            sell_price: data.sell_price,
            min_stock: data.min_stock ?? 5,
            description: data.description || '',
            color: data.color ?? null,
            is_active: data.is_active !== undefined ? !!data.is_active : true,
            image: data.image ?? null
        }).eq('id', id));
        return { message: 'Product updated' };
    },
    delete: async (id) => {
        unwrap(await sb.from('products').update({ is_active: false }).eq('id', id));
        return { message: 'Product deactivated' };
    },
    uploadImage: async (file) => {
        const ext = (file.name.split('.').pop() || 'jpg').toLowerCase();
        const allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
        if (!allowed.includes(ext)) throw new Error('Invalid file type. Only JPG, PNG, GIF, and WebP are allowed.');
        if (file.size > 2 * 1024 * 1024) throw new Error('File size too large. Max 2MB allowed.');

        const filename = `prod_${Date.now()}_${Math.random().toString(36).slice(2)}.${ext}`;
        unwrap(await sb.storage.from('products').upload(filename, file, {
            cacheControl: '3600',
            upsert: false
        }));
        const { data: { publicUrl } } = sb.storage.from('products').getPublicUrl(filename);
        return { message: 'Upload successful', path: publicUrl, url: publicUrl };
    }
};

// ─── Stock ────────────────────────────────────────────────────
const StockAPI = {
    adjust: async (data) => {
        const result = unwrap(await sb.rpc('adjust_product_stock', {
            p_product_id: parseInt(data.product_id, 10),
            p_type: data.type,
            p_quantity: parseInt(data.quantity, 10),
            p_note: data.note || ''
        }));
        return { message: 'Stock adjusted', new_stock: result.new_stock };
    }
};

// ─── Bills ────────────────────────────────────────────────────
const BillsAPI = {
    list: async (params = {}) => {
        let q = sb.from('bills').select('*').order('created_at', { ascending: false }).limit(200);
        if (params.from) q = q.gte('created_at', params.from + 'T00:00:00');
        if (params.to) q = q.lte('created_at', params.to + 'T23:59:59');
        let rows = unwrap(await q);
        if (params.search) {
            const s = params.search.toLowerCase();
            rows = rows.filter(b =>
                (b.bill_no || '').toLowerCase().includes(s) ||
                (b.customer_name || '').toLowerCase().includes(s)
            );
        }
        return rows;
    },
    get: async (id) => {
        const bill = unwrap(await sb.from('bills').select('*').eq('id', id).maybeSingle());
        if (!bill) throw new Error('Bill not found');
        const items = unwrap(await sb.from('bill_items').select('*, products(image)').eq('bill_id', id));
        bill.items = items.map(i => ({
            ...mapBillItem(i),
            product_image: i.products?.image || null
        }));
        return mapBill(bill);
    },
    create: async (data) => {
        const items = data.items || [];
        if (!items.length) throw new Error('Bill must have at least one item');

        const billNo = 'MIN-' + new Date().toISOString().slice(0, 10).replace(/-/g, '') + '-' +
            String(Math.floor(Math.random() * 9999) + 1).padStart(4, '0');

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
            p_bill_no: billNo,
            p_customer_name: data.customer_name || '',
            p_customer_phone: data.customer_phone || '',
            p_subtotal: subtotal,
            p_discount: discount,
            p_tax: tax,
            p_total: total,
            p_paid_amount: paidAmount,
            p_change_amount: change,
            p_payment_method: data.payment_method || 'cash',
            p_status: status,
            p_notes: data.notes || '',
            p_items: items
        }));

        return { id: result.id, bill_no: result.bill_no, total: result.total, change: result.change };
    },
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
        const products = unwrap(await sb.from('products').select('*').eq('is_active', true));
        const bills = unwrap(await sb.from('bills').select('*').order('created_at', { ascending: false }));
        const paid = paidBills(bills);

        const totalProducts = products.length;
        const lowStockProducts = products.filter(p => p.stock_qty <= p.min_stock);
        const stockValue = products.reduce((s, p) => {
            const price = parseFloat(p.cost_price) > 0 ? parseFloat(p.cost_price) : parseFloat(p.sell_price);
            return s + price * (p.stock_qty || 0);
        }, 0);

        const todayPaid = paid.filter(b => isSameDay(new Date(b.created_at), now));
        const weekPaid = paid.filter(b => isSameWeek(new Date(b.created_at), now));
        const monthPaid = paid.filter(b => isSameMonth(new Date(b.created_at), now));
        const yearPaid = paid.filter(b => isSameYear(new Date(b.created_at), now));

        const todayBillCount = bills.filter(b => isSameDay(new Date(b.created_at), now)).length;

        const daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        const weekTotals = Array(7).fill(0);
        weekPaid.forEach(b => {
            weekTotals[new Date(b.created_at).getDay()] += parseFloat(b.total || 0);
        });
        const chartDaily = daysOfWeek.map((label, i) => ({ label, value: weekTotals[i] }));

        const monthlyMap = {};
        const twelveMonthsAgo = new Date(now.getFullYear(), now.getMonth() - 11, 1);
        paid.filter(b => new Date(b.created_at) >= twelveMonthsAgo).forEach(b => {
            const d = new Date(b.created_at);
            const key = d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0');
            monthlyMap[key] = (monthlyMap[key] || 0) + parseFloat(b.total || 0);
        });
        const chartMonthly = Object.keys(monthlyMap).sort().map(key => {
            const [y, m] = key.split('-').map(Number);
            return { label: monthLabel(new Date(y, m - 1, 1)), value: monthlyMap[key] };
        });

        const yearlyMap = {};
        const fiveYearsAgo = now.getFullYear() - 4;
        paid.filter(b => new Date(b.created_at).getFullYear() >= fiveYearsAgo).forEach(b => {
            const y = new Date(b.created_at).getFullYear();
            yearlyMap[y] = (yearlyMap[y] || 0) + parseFloat(b.total || 0);
        });
        const chartYearly = Object.keys(yearlyMap).sort().map(y => ({ label: y, value: yearlyMap[y] }));

        const recentBills = bills.slice(0, 10).map(b => ({
            id: b.id,
            bill_no: b.bill_no,
            customer_name: b.customer_name,
            total: b.total,
            status: b.status,
            created_at: b.created_at
        }));

        const cats = unwrap(await sb.from('categories').select('id, name'));
        const catMap = Object.fromEntries(cats.map(c => [c.id, c.name]));
        const lowStockItems = lowStockProducts
            .sort((a, b) => a.stock_qty - b.stock_qty)
            .slice(0, 8)
            .map(p => ({
                name: p.name,
                stock_qty: p.stock_qty,
                min_stock: p.min_stock,
                category: catMap[p.category_id] || ''
            }));

        const thirtyDaysAgo = new Date(now);
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        const recentPaidIds = paid
            .filter(b => new Date(b.created_at) >= thirtyDaysAgo)
            .map(b => b.id);
        const recentItems = await fetchBillItemsForBills(recentPaidIds);
        const topMap = {};
        recentItems.forEach(i => {
            if (!topMap[i.product_name]) topMap[i.product_name] = { total_sold: 0, revenue: 0 };
            topMap[i.product_name].total_sold += i.quantity;
            topMap[i.product_name].revenue += parseFloat(i.total_price || 0);
        });
        const topProducts = Object.entries(topMap)
            .map(([product_name, v]) => ({ product_name, total_sold: v.total_sold, revenue: v.revenue }))
            .sort((a, b) => b.total_sold - a.total_sold)
            .slice(0, 5);

        return {
            total_products: totalProducts,
            low_stock_count: lowStockProducts.length,
            stock_value: Math.round(stockValue * 100) / 100,
            sales_today: Math.round(sumTotal(todayPaid) * 100) / 100,
            sales_week: Math.round(sumTotal(weekPaid) * 100) / 100,
            sales_month: Math.round(sumTotal(monthPaid) * 100) / 100,
            sales_year: Math.round(sumTotal(yearPaid) * 100) / 100,
            today_bill_count: todayBillCount,
            chart_daily: chartDaily,
            chart_monthly: chartMonthly,
            chart_yearly: chartYearly,
            recent_bills: recentBills,
            low_stock_items: lowStockItems,
            top_products: topProducts
        };
    },
    manual: (period, dateVal) => AnalyticsAPI.manual(period, dateVal),
    dailyChart: async (month, year) => {
        const m = parseInt(month, 10) || (new Date().getMonth() + 1);
        const y = parseInt(year, 10) || new Date().getFullYear();
        const daysInMonth = new Date(y, m, 0).getDate();
        const from = `${y}-${String(m).padStart(2, '0')}-01T00:00:00`;
        const to = `${y}-${String(m).padStart(2, '0')}-${String(daysInMonth).padStart(2, '0')}T23:59:59`;

        const bills = paidBills(unwrap(await sb.from('bills').select('total, created_at').eq('status', 'paid').gte('created_at', from).lte('created_at', to)));
        const map = {};
        bills.forEach(b => {
            const day = new Date(b.created_at).getDate();
            map[day] = (map[day] || 0) + parseFloat(b.total || 0);
        });

        const data = [];
        for (let d = 1; d <= daysInMonth; d++) {
            data.push({ label: d, revenue: Math.round((map[d] || 0) * 100) / 100 });
        }
        return { month: m, year: y, days_in_month: daysInMonth, data };
    }
};

// ─── Analytics ────────────────────────────────────────────────
const AnalyticsAPI = {
    charts: async (period = 'year') => {
        const now = new Date();
        const bills = unwrap(await sb.from('bills').select('*').eq('status', 'paid'));
        const filtered = bills.filter(b => {
            const d = new Date(b.created_at);
            if (period === 'today') return isSameDay(d, now);
            if (period === 'week') return isSameWeek(d, now);
            if (period === 'month') return isSameMonth(d, now);
            if (period === 'year') return isSameYear(d, now);
            return true;
        });
        const billIds = filtered.map(b => b.id);
        const items = await fetchBillItemsForBills(billIds);
        const products = unwrap(await sb.from('products').select('id, category_id'));
        const categories = unwrap(await sb.from('categories').select('id, name'));
        const prodCat = Object.fromEntries(products.map(p => [p.id, p.category_id]));
        const catName = Object.fromEntries(categories.map(c => [c.id, c.name]));

        let revenueTrend = [];
        if (period === 'today') {
            const hours = {};
            filtered.forEach(b => {
                const h = new Date(b.created_at).getHours();
                hours[h] = (hours[h] || 0) + parseFloat(b.total || 0);
            });
            revenueTrend = Object.keys(hours).sort((a, b) => a - b).map(h => ({ label: h + ':00', value: hours[h] }));
        } else if (period === 'week') {
            const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
            const vals = Array(7).fill(0);
            filtered.forEach(b => { vals[new Date(b.created_at).getDay()] += parseFloat(b.total || 0); });
            revenueTrend = days.map((label, i) => ({ label, value: vals[i] }));
        } else if (period === 'month') {
            const days = {};
            filtered.forEach(b => {
                const day = new Date(b.created_at).getDate();
                days[day] = (days[day] || 0) + parseFloat(b.total || 0);
            });
            revenueTrend = Object.keys(days).sort((a, b) => a - b).map(d => ({ label: d, value: days[d] }));
        } else {
            const months = {};
            filtered.forEach(b => {
                const d = new Date(b.created_at);
                const key = d.getMonth();
                months[key] = (months[key] || 0) + parseFloat(b.total || 0);
            });
            revenueTrend = Object.keys(months).sort((a, b) => a - b).map(m => ({
                label: new Date(2000, parseInt(m, 10), 1).toLocaleString('en-US', { month: 'long' }),
                value: months[m]
            }));
        }

        const catSales = {};
        items.forEach(i => {
            const cid = prodCat[i.product_id];
            const name = catName[cid] || 'Uncategorized';
            catSales[name] = (catSales[name] || 0) + parseFloat(i.total_price || 0);
        });
        const salesByCategory = Object.entries(catSales).map(([label, value]) => ({ label, value })).sort((a, b) => b.value - a.value);

        const qtyMap = {};
        const revMap = {};
        items.forEach(i => {
            qtyMap[i.product_name] = (qtyMap[i.product_name] || 0) + i.quantity;
            revMap[i.product_name] = (revMap[i.product_name] || 0) + parseFloat(i.total_price || 0);
        });
        const topProductsQty = Object.entries(qtyMap).map(([label, value]) => ({ label, value }))
            .sort((a, b) => b.value - a.value).slice(0, 6);
        const revenueByProduct = Object.entries(revMap).map(([label, value]) => ({ label, value }))
            .sort((a, b) => b.value - a.value).slice(0, 8);

        const payMap = {};
        filtered.forEach(b => {
            const label = (b.payment_method || 'cash').toUpperCase();
            payMap[label] = (payMap[label] || 0) + 1;
        });
        const paymentMethods = Object.entries(payMap).map(([label, value]) => ({ label, value }));

        return {
            revenue_trend: revenueTrend,
            sales_by_category: salesByCategory,
            top_products_qty: topProductsQty,
            revenue_by_product: revenueByProduct,
            payment_methods: paymentMethods
        };
    },

    manual: async (period = 'monthly', dateVal = '') => {
        const now = new Date();
        let filtered = unwrap(await sb.from('bills').select('*').eq('status', 'paid'));

        if (period === 'daily') {
            const d = dateVal || now.toISOString().slice(0, 10);
            filtered = filtered.filter(b => b.created_at.slice(0, 10) === d);
        } else if (period === 'weekly') {
            let weekVal = dateVal;
            if (!weekVal) {
                const w = String(getISOWeek(now)).padStart(2, '0');
                weekVal = `${now.getFullYear()}-W${w}`;
            }
            const matchYear = parseInt(weekVal.slice(0, 4), 10);
            const matchWeek = parseInt(weekVal.split('W')[1], 10);
            filtered = filtered.filter(b => {
                const d = new Date(b.created_at);
                return d.getFullYear() === matchYear && getISOWeek(d) === matchWeek;
            });
        } else if (period === 'monthly') {
            const val = dateVal || `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
            const [y, m] = val.split('-').map(Number);
            filtered = filtered.filter(b => {
                const d = new Date(b.created_at);
                return d.getFullYear() === y && d.getMonth() + 1 === m;
            });
        } else if (period === 'yearly') {
            const y = parseInt(dateVal || now.getFullYear(), 10);
            filtered = filtered.filter(b => new Date(b.created_at).getFullYear() === y);
        }

        const billIds = filtered.map(b => b.id);
        const items = await fetchBillItemsForBills(billIds);
        const itemMap = {};
        items.forEach(i => {
            if (!itemMap[i.product_name]) itemMap[i.product_name] = { total_qty: 0, total_revenue: 0 };
            itemMap[i.product_name].total_qty += i.quantity;
            itemMap[i.product_name].total_revenue += parseFloat(i.total_price || 0);
        });
        const itemsSold = Object.entries(itemMap).map(([product_name, v]) => ({
            product_name,
            total_qty: v.total_qty,
            total_revenue: v.total_revenue
        })).sort((a, b) => b.total_revenue - a.total_revenue);

        let chart = [];
        if (period === 'daily') {
            const hours = {};
            filtered.forEach(b => {
                const h = new Date(b.created_at).getHours();
                hours[h] = (hours[h] || 0) + parseFloat(b.total || 0);
            });
            chart = Object.keys(hours).sort((a, b) => a - b).map(h => ({ label: h + ':00', value: hours[h] }));
        } else if (period === 'monthly') {
            const days = {};
            filtered.forEach(b => {
                const day = new Date(b.created_at).getDate();
                days[day] = (days[day] || 0) + parseFloat(b.total || 0);
            });
            chart = Object.keys(days).sort((a, b) => a - b).map(d => ({ label: d, value: days[d] }));
        } else if (period === 'yearly') {
            const months = {};
            filtered.forEach(b => {
                const m = new Date(b.created_at).getMonth();
                months[m] = (months[m] || 0) + parseFloat(b.total || 0);
            });
            chart = Object.keys(months).sort((a, b) => a - b).map(m => ({
                label: new Date(2000, parseInt(m, 10), 1).toLocaleString('en-US', { month: 'long' }),
                value: months[m]
            }));
        } else {
            const dayMap = {};
            filtered.forEach(b => {
                const key = b.created_at.slice(0, 10);
                dayMap[key] = (dayMap[key] || 0) + parseFloat(b.total || 0);
            });
            chart = Object.keys(dayMap).sort().map(k => ({
                label: new Date(k + 'T12:00:00').toLocaleDateString('en-US', { weekday: 'long' }),
                value: dayMap[k]
            }));
        }

        return {
            revenue: Math.round(sumTotal(filtered) * 100) / 100,
            bills: filtered.length,
            items: itemsSold,
            chart
        };
    }
};

function getISOWeek(date) {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
}

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
window.BillsAPI = BillsAPI;
window.DashboardAPI = DashboardAPI;
window.AnalyticsAPI = AnalyticsAPI;
window.SettingsAPI = SettingsAPI;
