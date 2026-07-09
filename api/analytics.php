<?php
require_once __DIR__ . '/../db.php';
$db = getDB();

$period = $_GET['period'] ?? 'monthly';
$dateVal = $_GET['date'] ?? date('Y-m');

$whereQ = "1=1";

if ($period === 'daily') {
    // Exact date matching: YYYY-MM-DD
    if (empty($dateVal)) $dateVal = date('Y-m-d');
    $whereQ = "DATE(b.created_at) = '{$dateVal}'";
} else if ($period === 'weekly') {
    // $_GET['date'] format from <input type="week"> is "2026-W12"
    if (empty($dateVal)) {
        $week = date('W');
        $year = date('Y');
        $dateVal = "{$year}-W{$week}";
    }
    $dbVal = str_replace('-W', '', $dateVal); 
    // This removes -W, so 2026-W12 becomes 202612 which matches YEARWEEK mode 1 (Monday starts the week)
    $whereQ = "YEARWEEK(b.created_at, 1) = '{$dbVal}'";
} else if ($period === 'monthly') {
    // Exact month matching: YYYY-MM
    if (empty($dateVal)) $dateVal = date('Y-m');
    $parts = explode('-', $dateVal);
    $year = (int)($parts[0] ?? date('Y'));
    $month = (int)($parts[1] ?? date('m'));
    $whereQ = "YEAR(b.created_at) = {$year} AND MONTH(b.created_at) = {$month}";
} else if ($period === 'yearly') {
    // Exact year matching: YYYY
    if (empty($dateVal)) $dateVal = date('Y');
    $year = (int)$dateVal;
    $whereQ = "YEAR(b.created_at) = {$year}";
}

// Analytics Queries
// 1. Total Revenue for period
$totalRevenue = $db->query("SELECT COALESCE(SUM(total), 0) FROM bills b WHERE status='paid' AND {$whereQ}")->fetchColumn() ?: 0.00;

// 2. Total Bills for period
$totalBills = $db->query("SELECT COUNT(*) FROM bills b WHERE status='paid' AND {$whereQ}")->fetchColumn() ?: 0;

// 3. Items Sold with individual Revenue generated in this period
$itemsSold = $db->query("
    SELECT bi.product_name, SUM(bi.qty) AS total_qty, SUM(bi.total) AS total_revenue
    FROM bill_items bi
    JOIN bills b ON b.id = bi.bill_id
    WHERE b.status='paid' AND {$whereQ}
    GROUP BY bi.product_name
    ORDER BY total_revenue DESC
")->fetchAll() ?: [];

// 4. Trend Chart Data over the period
if ($period === 'daily') {
    // Graph by hour of the day
    $chartData = $db->query("
        SELECT CONCAT(HOUR(MIN(b.created_at)), ':00') AS label, COALESCE(SUM(total), 0) AS value
        FROM bills b WHERE status='paid' AND {$whereQ}
        GROUP BY HOUR(b.created_at) ORDER BY HOUR(b.created_at)
    ")->fetchAll();
} else if ($period === 'monthly') {
    // Graph by day of the month
    $chartData = $db->query("
        SELECT DAY(MIN(b.created_at)) AS label, COALESCE(SUM(total), 0) AS value
        FROM bills b WHERE status='paid' AND {$whereQ}
        GROUP BY DAY(b.created_at) ORDER BY DAY(b.created_at)
    ")->fetchAll();
} else if ($period === 'yearly') {
    // Graph by month of the year
    $chartData = $db->query("
        SELECT MONTHNAME(MIN(b.created_at)) AS label, COALESCE(SUM(total), 0) AS value
        FROM bills b WHERE status='paid' AND {$whereQ}
        GROUP BY MONTH(b.created_at) ORDER BY MONTH(b.created_at)
    ")->fetchAll();
} else {
    // Graph weekly by day name
    $chartData = $db->query("
        SELECT DATE_FORMAT(MIN(b.created_at), '%W') AS label, COALESCE(SUM(total), 0) AS value
        FROM bills b WHERE status='paid' AND {$whereQ}
        GROUP BY DATE(b.created_at) ORDER BY DATE(b.created_at)
    ")->fetchAll();
}

respond([
    'revenue' => round((float)$totalRevenue, 2),
    'bills'   => (int)$totalBills,
    'items'   => $itemsSold,
    'chart'   => $chartData ?: []
]);
