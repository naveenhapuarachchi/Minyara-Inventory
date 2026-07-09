<?php
require_once __DIR__ . '/../db.php';
$db = getDB();

$period = $_GET['period'] ?? 'monthly';
$dateVal = $_GET['date'] ?? date('Y-m');

$whereQ = "1=1";

if ($period === 'daily') {
    if (empty($dateVal)) $dateVal = date('Y-m-d');
    $whereQ = "b.created_at::date = '{$dateVal}'";
} else if ($period === 'weekly') {
    if (empty($dateVal)) {
        $dateVal = date('o') . '-W' . date('W');
    }
    if (preg_match('/^(\d{4})-W(\d{2})$/', $dateVal, $m)) {
        $whereQ = "EXTRACT(ISOYEAR FROM b.created_at) = {$m[1]} AND EXTRACT(WEEK FROM b.created_at) = {$m[2]}";
    }
} else if ($period === 'monthly') {
    if (empty($dateVal)) $dateVal = date('Y-m');
    $parts = explode('-', $dateVal);
    $year = (int)($parts[0] ?? date('Y'));
    $month = (int)($parts[1] ?? date('m'));
    $whereQ = "EXTRACT(YEAR FROM b.created_at) = {$year} AND EXTRACT(MONTH FROM b.created_at) = {$month}";
} else if ($period === 'yearly') {
    if (empty($dateVal)) $dateVal = date('Y');
    $year = (int)$dateVal;
    $whereQ = "EXTRACT(YEAR FROM b.created_at) = {$year}";
}

$totalRevenue = $db->query("SELECT COALESCE(SUM(total), 0) FROM bills b WHERE status='paid' AND {$whereQ}")->fetchColumn() ?: 0.00;
$totalBills = $db->query("SELECT COUNT(*) FROM bills b WHERE status='paid' AND {$whereQ}")->fetchColumn() ?: 0;

$itemsSold = $db->query("
    SELECT bi.product_name, SUM(bi.quantity) AS total_qty, SUM(bi.total_price) AS total_revenue
    FROM bill_items bi
    JOIN bills b ON b.id = bi.bill_id
    WHERE b.status='paid' AND {$whereQ}
    GROUP BY bi.product_name
    ORDER BY total_revenue DESC
")->fetchAll() ?: [];

if ($period === 'daily') {
    $chartData = $db->query("
        SELECT EXTRACT(HOUR FROM MIN(b.created_at))::text || ':00' AS label, COALESCE(SUM(total), 0) AS value
        FROM bills b WHERE status='paid' AND {$whereQ}
        GROUP BY EXTRACT(HOUR FROM b.created_at) ORDER BY EXTRACT(HOUR FROM b.created_at)
    ")->fetchAll();
} else if ($period === 'monthly') {
    $chartData = $db->query("
        SELECT EXTRACT(DAY FROM MIN(b.created_at))::text AS label, COALESCE(SUM(total), 0) AS value
        FROM bills b WHERE status='paid' AND {$whereQ}
        GROUP BY EXTRACT(DAY FROM b.created_at) ORDER BY EXTRACT(DAY FROM b.created_at)
    ")->fetchAll();
} else if ($period === 'yearly') {
    $chartData = $db->query("
        SELECT TO_CHAR(MIN(b.created_at), 'Month') AS label, COALESCE(SUM(total), 0) AS value
        FROM bills b WHERE status='paid' AND {$whereQ}
        GROUP BY EXTRACT(MONTH FROM b.created_at) ORDER BY EXTRACT(MONTH FROM b.created_at)
    ")->fetchAll();
} else {
    $chartData = $db->query("
        SELECT TO_CHAR(MIN(b.created_at), 'Day') AS label, COALESCE(SUM(total), 0) AS value
        FROM bills b WHERE status='paid' AND {$whereQ}
        GROUP BY b.created_at::date ORDER BY b.created_at::date
    ")->fetchAll();
}

respond([
    'revenue' => round((float)$totalRevenue, 2),
    'bills'   => (int)$totalBills,
    'items'   => $itemsSold,
    'chart'   => $chartData ?: []
]);
