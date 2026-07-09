<?php
require_once __DIR__ . '/../db.php';

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];

if ($method !== 'POST') respond(['error' => 'Method not allowed'], 405);

$body = getBody();
$productId = (int)($body['product_id'] ?? 0);
$type      = $body['type'] ?? '';
$quantity  = (int)($body['quantity'] ?? 0);
$note      = $body['note'] ?? '';

if (!$productId || !in_array($type, ['in','out']) || $quantity <= 0) {
    respond(['error' => 'product_id, type (in/out), and quantity > 0 are required'], 400);
}

try {
    $stmt = $db->prepare("SELECT adjust_product_stock(?, ?, ?, ?) AS result");
    $stmt->execute([$productId, $type, $quantity, $note]);
    $result = json_decode($stmt->fetchColumn(), true);
    respond(['message' => 'Stock adjusted', 'new_stock' => $result['new_stock']]);
} catch (Exception $e) {
    respond(['error' => 'Failed: ' . $e->getMessage()], 500);
}
