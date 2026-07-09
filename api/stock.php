<?php
require_once __DIR__ . '/../db.php';

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];

if ($method !== 'POST') respond(['error' => 'Method not allowed'], 405);

$body = getBody();
$productId = (int)($body['product_id'] ?? 0);
$type      = $body['type'] ?? '';   // 'in' or 'out'
$quantity  = (int)($body['quantity'] ?? 0);
$note      = $body['note'] ?? '';

if (!$productId || !in_array($type, ['in','out']) || $quantity <= 0) {
    respond(['error' => 'product_id, type (in/out), and quantity > 0 are required'], 400);
}

// Check product exists and get current stock
$stmt = $db->prepare("SELECT id, name, stock_qty FROM products WHERE id=? AND is_active=1");
$stmt->execute([$productId]);
$product = $stmt->fetch();
if (!$product) respond(['error' => 'Product not found'], 404);

if ($type === 'out' && $product['stock_qty'] < $quantity) {
    respond(['error' => 'Insufficient stock. Available: ' . $product['stock_qty']], 400);
}

$delta = $type === 'in' ? $quantity : -$quantity;

$db->beginTransaction();
try {
    $db->prepare("UPDATE products SET stock_qty = stock_qty + ? WHERE id=?")
       ->execute([$delta, $productId]);

    $db->prepare("INSERT INTO stock_adjustments (product_id, type, quantity, note) VALUES (?, ?, ?, ?)")
       ->execute([$productId, $type, $quantity, $note]);

    $db->commit();

    $newStock = $product['stock_qty'] + $delta;
    respond(['message' => 'Stock adjusted', 'new_stock' => $newStock]);
} catch (Exception $e) {
    $db->rollBack();
    respond(['error' => 'Failed: ' . $e->getMessage()], 500);
}
