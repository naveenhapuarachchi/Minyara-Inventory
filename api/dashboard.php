<?php
require_once __DIR__ . '/../db.php';

$db = getDB();

// Default values to respond if empty
$totalProducts = $db->query("SELECT COUNT(*) FROM products WHERE is_active=1")->fetchColumn() ?: 0;
$lowStock = $db->query("SELECT COUNT(*) FROM products WHERE is_active=1 AND stock_qty <= min_stock")->fetchColumn() ?: 0;
$stockValue = $db->query("SELECT COALESCE(SUM(IF(cost_price > 0, cost_price, sell_price) * stock_qty), 0) FROM products WHERE is_active=1")->fetchColumn() ?: 0.00;

// Temporal Revenue queries 
// (Week starts Sunday as per MySQL default YEARWEEK mode 0, adjustable with mode if needed)
$todaySales = $db->query("SELECT COALESCE(SUM(total), 0) FROM bills WHERE DATE(created_at) = CURDATE() AND status='paid'")->fetchColumn() ?: 0.00;
$weekSales  = $db->query("SELECT COALESCE(SUM(total), 0) FROM bills WHERE YEARWEEK(created_at, 1) = YEARWEEK(CURDATE(), 1) AND status='paid'")->fetchColumn() ?: 0.00;
$monthSales = $db->query("SELECT COALESCE(SUM(total), 0) FROM bills WHERE MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE()) AND status='paid'")->fetchColumn() ?: 0.00;
$yearSales  = $db->query("SELECT COALESCE(SUM(total), 0) FROM bills WHERE YEAR(created_at) = YEAR(CURDATE()) AND status='paid'")->fetchColumn() ?: 0.00;

$todayBillCount = $db->query("SELECT COUNT(*) FROM bills WHERE DATE(created_at) = CURDATE()")->fetchColumn() ?: 0;

// 1. Current Week (Sunday to Saturday)
$chartDailyRaw = $db->query("
    SELECT DAYOFWEEK(created_at) AS dow, COALESCE(SUM(total), 0) AS value
    FROM bills WHERE status='paid' AND YEARWEEK(created_at, 0) = YEARWEEK(CURDATE(), 0)
    GROUP BY dow
")->fetchAll(PDO::FETCH_ASSOC);

$salesMap = [];
foreach ($chartDailyRaw as $row) {
    $salesMap[$row['dow']] = $row['value'];
}

$daysOfWeek = [
    1 => 'Sunday',
    2 => 'Monday',
    3 => 'Tuesday',
    4 => 'Wednesday',
    5 => 'Thursday',
    6 => 'Friday',
    7 => 'Saturday'
];

$chartDaily = [];
foreach ($daysOfWeek as $dow => $name) {
    $chartDaily[] = [
        'label' => $name,
        'value' => isset($salesMap[$dow]) ? $salesMap[$dow] : 0
    ];
}

// 2. Last 12 Months
$chartMonthly = $db->query("
    SELECT DATE_FORMAT(MIN(created_at), '%b %Y') AS label, COALESCE(SUM(total), 0) AS value
    FROM bills WHERE status='paid' AND created_at >= DATE_SUB(CURDATE(), INTERVAL 11 MONTH)
    GROUP BY YEAR(created_at), MONTH(created_at) ORDER BY MIN(created_at)
")->fetchAll();

// 3. Yearly (Last 5 Years)
$chartYearly = $db->query("
    SELECT YEAR(created_at) AS label, COALESCE(SUM(total), 0) AS value
    FROM bills WHERE status='paid' AND created_at >= DATE_SUB(CURDATE(), INTERVAL 4 YEAR)
    GROUP BY YEAR(created_at) ORDER BY MIN(created_at)
")->fetchAll();

// Other Data
$recentBills = $db->query("SELECT id, bill_no, customer_name, total, status, created_at FROM bills ORDER BY created_at DESC LIMIT 10")->fetchAll();
$lowStockProducts = $db->query("SELECT p.name, p.stock_qty, p.min_stock, c.name AS category FROM products p LEFT JOIN categories c ON c.id = p.category_id WHERE p.is_active=1 AND p.stock_qty <= p.min_stock ORDER BY p.stock_qty ASC LIMIT 8")->fetchAll();
$topProducts = $db->query("SELECT bi.product_name, SUM(bi.qty) AS total_sold, SUM(bi.total) AS revenue FROM bill_items bi JOIN bills b ON b.id = bi.bill_id WHERE b.status='paid' AND b.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) GROUP BY bi.product_name ORDER BY total_sold DESC LIMIT 5")->fetchAll();


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
