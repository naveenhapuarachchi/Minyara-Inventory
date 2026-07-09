<?php
require_once __DIR__ . '/../db.php';
$db = getDB();

$period = $_GET['period'] ?? 'year';

$whereQ = "1=1";
if ($period === 'today') {
    $whereQ = "b.created_at::date = CURRENT_DATE";
} else if ($period === 'week') {
    $whereQ = "date_trunc('week', b.created_at) = date_trunc('week', CURRENT_DATE)";
} else if ($period === 'month') {
    $whereQ = "date_trunc('month', b.created_at) = date_trunc('month', CURRENT_DATE)";
} else if ($period === 'year') {
    $whereQ = "date_trunc('year', b.created_at) = date_trunc('year', CURRENT_DATE)";
}

if ($period === 'today') {
    $trendQ = "SELECT EXTRACT(HOUR FROM MIN(b.created_at))::text || ':00' as label, COALESCE(SUM(b.total), 0) as value FROM bills b WHERE b.status='paid' AND {$whereQ} GROUP BY EXTRACT(HOUR FROM b.created_at) ORDER BY EXTRACT(HOUR FROM b.created_at)";
} else if ($period === 'week') {
    $trendQ = "SELECT TO_CHAR(MIN(b.created_at), 'Day') as label, COALESCE(SUM(b.total), 0) as value FROM bills b WHERE b.status='paid' AND {$whereQ} GROUP BY EXTRACT(DOW FROM b.created_at) ORDER BY EXTRACT(DOW FROM b.created_at)";
} else if ($period === 'month') {
    $trendQ = "SELECT EXTRACT(DAY FROM MIN(b.created_at))::text as label, COALESCE(SUM(b.total), 0) as value FROM bills b WHERE b.status='paid' AND {$whereQ} GROUP BY EXTRACT(DAY FROM b.created_at) ORDER BY EXTRACT(DAY FROM b.created_at)";
} else {
    $trendQ = "SELECT TO_CHAR(MIN(b.created_at), 'Month') as label, COALESCE(SUM(b.total), 0) as value FROM bills b WHERE b.status='paid' AND {$whereQ} GROUP BY EXTRACT(MONTH FROM b.created_at) ORDER BY EXTRACT(MONTH FROM b.created_at)";
}
$revenue_trend = $db->query($trendQ)->fetchAll() ?: [];

$sales_by_category = $db->query("
    SELECT c.name as label, SUM(bi.total_price) as value
    FROM bill_items bi
    JOIN products p ON p.id = bi.product_id
    JOIN categories c ON c.id = p.category_id
    JOIN bills b ON b.id = bi.bill_id
    WHERE b.status='paid' AND {$whereQ}
    GROUP BY c.id, c.name
    ORDER BY value DESC
")->fetchAll() ?: [];

$top_products_qty = $db->query("
    SELECT bi.product_name as label, SUM(bi.quantity) as value
    FROM bill_items bi
    JOIN bills b ON b.id = bi.bill_id
    WHERE b.status='paid' AND {$whereQ}
    GROUP BY bi.product_name
    ORDER BY value DESC
    LIMIT 6
")->fetchAll() ?: [];

$revenue_by_product = $db->query("
    SELECT bi.product_name as label, SUM(bi.total_price) as value
    FROM bill_items bi
    JOIN bills b ON b.id = bi.bill_id
    WHERE b.status='paid' AND {$whereQ}
    GROUP BY bi.product_name
    ORDER BY value DESC
    LIMIT 8
")->fetchAll() ?: [];

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
