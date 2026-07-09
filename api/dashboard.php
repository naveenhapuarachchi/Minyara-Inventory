<?php
require_once __DIR__ . '/../db.php';

$db = getDB();

$totalProducts = $db->query("SELECT COUNT(*) FROM products WHERE is_active = true")->fetchColumn() ?: 0;
$lowStock = $db->query("SELECT COUNT(*) FROM products WHERE is_active = true AND stock_qty <= min_stock")->fetchColumn() ?: 0;
$stockValue = $db->query("SELECT COALESCE(SUM(CASE WHEN cost_price > 0 THEN cost_price ELSE sell_price END * stock_qty), 0) FROM products WHERE is_active = true")->fetchColumn() ?: 0.00;

$todaySales = $db->query("SELECT COALESCE(SUM(total), 0) FROM bills WHERE created_at::date = CURRENT_DATE AND status='paid'")->fetchColumn() ?: 0.00;
$weekSales  = $db->query("SELECT COALESCE(SUM(total), 0) FROM bills WHERE date_trunc('week', created_at) = date_trunc('week', CURRENT_DATE) AND status='paid'")->fetchColumn() ?: 0.00;
$monthSales = $db->query("SELECT COALESCE(SUM(total), 0) FROM bills WHERE date_trunc('month', created_at) = date_trunc('month', CURRENT_DATE) AND status='paid'")->fetchColumn() ?: 0.00;
$yearSales  = $db->query("SELECT COALESCE(SUM(total), 0) FROM bills WHERE date_trunc('year', created_at) = date_trunc('year', CURRENT_DATE) AND status='paid'")->fetchColumn() ?: 0.00;

$todayBillCount = $db->query("SELECT COUNT(*) FROM bills WHERE created_at::date = CURRENT_DATE")->fetchColumn() ?: 0;

$chartDailyRaw = $db->query("
    SELECT EXTRACT(DOW FROM created_at)::int AS dow, COALESCE(SUM(total), 0) AS value
    FROM bills WHERE status='paid' AND date_trunc('week', created_at) = date_trunc('week', CURRENT_DATE)
    GROUP BY dow
")->fetchAll(PDO::FETCH_ASSOC);

$salesMap = [];
foreach ($chartDailyRaw as $row) {
    $salesMap[(int)$row['dow']] = $row['value'];
}

$daysOfWeek = [
    0 => 'Sunday',
    1 => 'Monday',
    2 => 'Tuesday',
    3 => 'Wednesday',
    4 => 'Thursday',
    5 => 'Friday',
    6 => 'Saturday'
];

$chartDaily = [];
foreach ($daysOfWeek as $dow => $name) {
    $chartDaily[] = [
        'label' => $name,
        'value' => isset($salesMap[$dow]) ? $salesMap[$dow] : 0
    ];
}

$chartMonthly = $db->query("
    SELECT TO_CHAR(date_trunc('month', MIN(created_at)), 'Mon YYYY') AS label, COALESCE(SUM(total), 0) AS value
    FROM bills WHERE status='paid' AND created_at >= (CURRENT_DATE - INTERVAL '11 months')
    GROUP BY date_trunc('month', created_at) ORDER BY date_trunc('month', created_at)
")->fetchAll();

$chartYearly = $db->query("
    SELECT EXTRACT(YEAR FROM created_at)::text AS label, COALESCE(SUM(total), 0) AS value
    FROM bills WHERE status='paid' AND created_at >= (CURRENT_DATE - INTERVAL '4 years')
    GROUP BY EXTRACT(YEAR FROM created_at) ORDER BY EXTRACT(YEAR FROM created_at)
")->fetchAll();

$recentBills = $db->query("SELECT id, bill_no, customer_name, total, status, created_at FROM bills ORDER BY created_at DESC LIMIT 10")->fetchAll();
$lowStockProducts = $db->query("SELECT p.name, p.stock_qty, p.min_stock, c.name AS category FROM products p LEFT JOIN categories c ON c.id = p.category_id WHERE p.is_active = true AND p.stock_qty <= p.min_stock ORDER BY p.stock_qty ASC LIMIT 8")->fetchAll();
$topProducts = $db->query("
    SELECT bi.product_name, SUM(bi.quantity) AS total_sold, SUM(bi.total_price) AS revenue
    FROM bill_items bi JOIN bills b ON b.id = bi.bill_id
    WHERE b.status='paid' AND b.created_at >= (NOW() - INTERVAL '30 days')
    GROUP BY bi.product_name ORDER BY total_sold DESC LIMIT 5
")->fetchAll();

respond([
    'total_products'   => (int)$totalProducts,
    'low_stock_count'  => (int)$lowStock,
    'stock_value'      => round((float)$stockValue, 2),
    'sales_today'      => round((float)$todaySales, 2),
    'sales_week'       => round((float)$weekSales, 2),
    'sales_month'      => round((float)$monthSales, 2),
    'sales_year'       => round((float)$yearSales, 2),
    'today_bill_count' => (int)$todayBillCount,
    'chart_daily'      => $chartDaily,
    'chart_monthly'    => $chartMonthly,
    'chart_yearly'     => $chartYearly,
    'recent_bills'     => $recentBills,
    'low_stock_items'  => $lowStockProducts,
    'top_products'     => $topProducts,
]);
