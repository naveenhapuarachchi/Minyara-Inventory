<?php
require_once __DIR__ . '/db.php';
$db = getDB();

try {
    $db->exec("ALTER TABLE products ADD COLUMN image VARCHAR(255) DEFAULT NULL AFTER color");
    echo "Database updated successfully with 'image' column.\n";
} catch (PDOException $e) {
    if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
        echo "Column 'image' already exists.\n";
    } else {
        echo "Error updating database: " . $e->getMessage() . "\n";
    }
}
?>
