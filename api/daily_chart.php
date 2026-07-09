<?php
require_once __DIR__ . '/../db.php';

$db = getDB();

$month = isset($_GET['month']) ? (int)$_GET['month'] : (int)date('n');
$year  = isset($_GET['year'])  ? (int)$_GET['year']  : (int)date('Y');

if ($month < 1 || $month > 12) $month = (int)date('n');
if ($year < 2000 || $year > 2100) $year = (int)date('Y');

$daysInMonth = cal_days_in_month(CAL_GREGORIAN, $month, $year);

$stmt = $db->prepare("
    SELECT EXTRACT(DAY FROM created_at)::int AS day, COALESCE(SUM(total), 0) AS revenue
    FROM bills
    WHERE status = 'paid'
      AND EXTRACT(MONTH FROM created_at) = :month
      AND EXTRACT(YEAR FROM created_at)  = :year
    GROUP BY EXTRACT(DAY FROM created_at)
");
$stmt->execute([':month' => $month, ':year' => $year]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

$map = [];
foreach ($rows as $row) {
    $map[(int)$row['day']] = (float)$row['revenue'];
}

$data = [];
for ($d = 1; $d <= $daysInMonth; $d++) {
    $data[] = [
        'label'   => $d,
        'revenue' => isset($map[$d]) ? round($map[$d], 2) : 0
    ];
}

respond([
    'month'         => $month,
    'year'          => $year,
    'days_in_month' => $daysInMonth,
    'data'          => $data
]);
