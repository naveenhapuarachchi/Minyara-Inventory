<?php
require_once __DIR__ . '/../db.php';

$db = getDB();

// Validate inputs
$month = isset($_GET['month']) ? (int)$_GET['month'] : (int)date('n');
$year  = isset($_GET['year'])  ? (int)$_GET['year']  : (int)date('Y');

if ($month < 1 || $month > 12) $month = (int)date('n');
if ($year < 2000 || $year > 2100) $year = (int)date('Y');

// Total days in this month/year
$daysInMonth = cal_days_in_month(CAL_GREGORIAN, $month, $year);

// Fetch actual sales grouped by day
$stmt = $db->prepare("
    SELECT DAY(created_at) AS day, COALESCE(SUM(total), 0) AS revenue
    FROM bills
    WHERE status = 'paid'
      AND MONTH(created_at) = :month
      AND YEAR(created_at)  = :year
    GROUP BY DAY(created_at)
");
$stmt->execute([':month' => $month, ':year' => $year]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Build lookup map: day => revenue
$map = [];
foreach ($rows as $row) {
    $map[(int)$row['day']] = (float)$row['revenue'];
}

// Build full day-by-day array (0 for missing days)
$data = [];
for ($d = 1; $d <= $daysInMonth; $d++) {
    $data[] = [
        'label'   => $d,        // day number as X label
        'revenue' => isset($map[$d]) ? round($map[$d], 2) : 0
    ];
}

respond([
    'month'        => $month,
    'year'         => $year,
    'days_in_month'=> $daysInMonth,
    'data'         => $data
]);
