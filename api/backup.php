<?php
require_once __DIR__ . '/../db.php';

$db = getDB();

$tables = [];
$query = $db->query('SHOW TABLES');
while ($row = $query->fetch(PDO::FETCH_NUM)) {
    $tables[] = $row[0];
}

$sql = "-- MINYARA Database Backup\n";
$sql .= "-- Generated: " . date('Y-m-d H:i:s') . "\n\n";
$sql .= "SET FOREIGN_KEY_CHECKS = 0;\n\n";

foreach ($tables as $table) {
    // Table structure
    $query = $db->query("SHOW CREATE TABLE `$table`");
    $row = $query->fetch(PDO::FETCH_NUM);
    $sql .= "DROP TABLE IF EXISTS `$table`;\n";
    $sql .= $row[1] . ";\n\n";

    // Table data
    $query = $db->query("SELECT * FROM `$table`");
    $rows  = $query->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        $keys = array_keys($rows[0]);
        $sql .= "INSERT INTO `$table` (`" . implode("`, `", $keys) . "`) VALUES\n";
        
        $values = [];
        foreach ($rows as $row) {
            $rowValues = array_map(function($val) use ($db) {
                if ($val === null) return 'NULL';
                return $db->quote($val);
            }, $row);
            $values[] = "(" . implode(", ", $rowValues) . ")";
        }
        $sql .= implode(",\n", $values) . ";\n\n";
    }
}

$sql .= "SET FOREIGN_KEY_CHECKS = 1;\n";

// Output standard headers for exact download
$filename = 'minyara_backup_' . date('Ymd_His') . '.sql';

header('Content-Type: application/octet-stream');
header('Content-Disposition: attachment; filename="' . basename($filename) . '"');
header('Expires: 0');
header('Cache-Control: must-revalidate');
header('Pragma: public');
header('Content-Length: ' . strlen($sql));

echo $sql;
exit;
