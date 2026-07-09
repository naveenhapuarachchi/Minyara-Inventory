<?php
require_once __DIR__ . '/../db.php';
$db = getDB();

$period = $_GET['period'] ?? 'year';

$whereQ = "1=1";
if ($period === 'today') {
    $whereQ = "DATE(b.created_at) = CURDATE()";
} else if ($period === 'week') {
    $whereQ = "YEARWEEK(b.created_at, 1) = YEARWEEK(CURDATE(), 1)";
} else if ($period === 'month') {
    $whereQ = "YEAR(b.created_at) = YEAR(CURDATE()) AND MONTH(b.created_at) = MONTH(CURDATE())";
} else if ($period === 'year') {
    $whereQ = "YEAR(b.created_at) = YEAR(CURDATE())";
}

// 1. Revenue Trend - Line Chart
$trendQ = "";
if ($period === 'today') {
    $trendQ = "SELECT CONCAT(HOUR(MIN(b.created_at)), ':00') as label, COALESCE(SUM(b.total), 0) as value FROM bills b WHERE b.status='paid' AND {$whereQ} GROUP BY HOUR(b.created_at) ORDER BY HOUR(b.created_at)";
} else if ($period === 'week') {
    $trendQ = "SELECT DAYNAME(MIN(b.created_at)) as label, COALESCE(SUM(b.total), 0) as value FROM bills b WHERE b.status='paid' AND {$whereQ} GROUP BY DAYOFWEEK(b.created_at) ORDER BY DAYOFWEEK(b.created_at)";
} else if ($period === 'month') {
    $trendQ = "SELECT DAY(MIN(b.created_at)) as label, COALESCE(SUM(b.total), 0) as value FROM bills b WHERE b.status='paid' AND {$whereQ} GROUP BY DAY(b.created_at) ORDER BY DAY(b.created_at)";
} else {
    $trendQ = "SELECT MONTHNAME(MIN(b.created_at)) as label, COALESCE(SUM(b.total), 0) as value FROM bills b WHERE b.status='paid' AND {$whereQ} GROUP BY MONTH(b.created_at) ORDER BY MONTH(b.created_at)";
}
$revenue_trend = $db->query($trendQ)->fetchAll() ?: [];

// 2. Sales by Category - Doughnut Chart
$sales_by_category = $db->query("
    SELECT c.name as label, SUM(bi.total) as value
    FROM bill_items bi
    JOIN products p ON p.id = bi.product_id
    JOIN categories c ON c.id = p.category_id
    JOIN bills b ON b.id = bi.bill_id
    WHERE b.status='paid' AND {$whereQ}
    GROUP BY c.id
    ORDER BY value DESC
")->fetchAll() ?: [];

// 3. Top Products by Quantity - Bar Chart
$top_products_qty = $db->query("
    SELECT bi.product_name as label, SUM(bi.qty) as value
    FROM bill_items bi
    JOIN bills b ON b.id = bi.bill_id
    WHERE b.status='paid' AND {$whereQ}
    GROUP BY bi.product_name
    ORDER BY value DESC
    LIMIT 6
")->fetchAll() ?: [];

// 4. Highest Revenue Products - Bar Chart
$revenue_by_product = $db->query("
    SELECT bi.product_name as label, SUM(bi.total) as value
    FROM bill_items bi
    JOIN bills b ON b.id = bi.bill_id
    WHERE b.status='paid' AND {$whereQ}
    GROUP BY bi.product_name
    ORDER BY value DESC
    LIMIT 8
")->fetchAll() ?: [];

// 5. Payment Methods - Doughnut Chart
$payment_methods = $db->query("
    SELECT UPPER(payment_method) as label, COUNT(b.id) as value
    FROM bills b
    WHERE b.status='paid' AND {$whereQ}
    GROUP BY b.payment_method
")->fetchAll() ?: [];

respond([
    'revenue_trend' => $revenue_trend,
    'sales_by_category' => $sales_by_category,
    'top_products_qty' => $top_products_qty,
    'revenue_by_product' => $revenue_by_product,
    'payment_methods' => $payment_methods
]);
