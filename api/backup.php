<?php
require_once __DIR__ . '/../db.php';

$db = getDB();

$tables = ['categories', 'products', 'customers', 'bills', 'bill_items', 'stock_adjustments', 'app_settings'];

$sql = "-- MINYARA Database Backup (PostgreSQL / Supabase)\n";
$sql .= "-- Generated: " . date('Y-m-d H:i:s') . "\n\n";

foreach ($tables as $table) {
    $sql .= "-- Table: $table\n";
    $query = $db->query("SELECT * FROM \"$table\"");
    $rows  = $query->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        $keys = array_keys($rows[0]);
        $sql .= "INSERT INTO \"$table\" (\"" . implode('", "', $keys) . "\") VALUES\n";
        $values = [];
        foreach ($rows as $row) {
            $rowValues = array_map(function($val) use ($db) {
                if ($val === null) return 'NULL';
                if (is_bool($val)) return $val ? 'true' : 'false';
                return $db->quote($val);
            }, $row);
            $values[] = '(' . implode(', ', $rowValues) . ')';
        }
        $sql .= implode(",\n", $values) . ";\n\n";
    } else {
        $sql .= "-- (empty)\n\n";
    }
}

$filename = 'minyara_backup_' . date('Ymd_His') . '.sql';

header('Content-Type: application/octet-stream');
header('Content-Disposition: attachment; filename="' . basename($filename) . '"');
header('Expires: 0');
header('Cache-Control: must-revalidate');
header('Pragma: public');
header('Content-Length: ' . strlen($sql));

echo $sql;
exit;
