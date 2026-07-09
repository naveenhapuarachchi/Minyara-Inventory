<?php
require_once __DIR__ . '/../db.php';

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];
$id = isset($_GET['id']) ? (int)$_GET['id'] : null;

switch ($method) {
    case 'GET':
        if ($id) {
            $stmt = $db->prepare("
                SELECT p.*, c.name AS category_name
                FROM products p
                LEFT JOIN categories c ON c.id = p.category_id
                WHERE p.id = ?
            ");
            $stmt->execute([$id]);
            $product = $stmt->fetch();
            respond($product ?: ['error' => 'Not found'], $product ? 200 : 404);
        } else {
            $search = $_GET['search'] ?? '';
            $cat    = $_GET['category'] ?? '';
            $low    = $_GET['low_stock'] ?? '';

            $sql = "
                SELECT p.*, c.name AS category_name
                FROM products p
                LEFT JOIN categories c ON c.id = p.category_id
                WHERE p.is_active = 1
            ";
            $params = [];

            if ($search) {
                $sql .= " AND (p.name LIKE ? OR p.sku LIKE ?)";
                $params[] = "%$search%";
                $params[] = "%$search%";
            }
            if ($cat) {
                $sql .= " AND p.category_id = ?";
                $params[] = (int)$cat;
            }
            if ($low === '1') {
                $sql .= " AND p.stock_qty <= p.min_stock";
            }
            $sql .= " ORDER BY p.name";

            $stmt = $db->prepare($sql);
            $stmt->execute($params);
            respond($stmt->fetchAll());
        }
        break;

    case 'POST':
        $body = getBody();
        if (empty($body['name'])) respond(['error' => 'Name required'], 400);
        if (!isset($body['sell_price'])) respond(['error' => 'Sell price required'], 400);

        // Auto-generate SKU if not provided
        if (empty($body['sku'])) {
            $prefix = strtoupper(substr(preg_replace('/[^a-z]/i', '', $body['name']), 0, 3));
            $body['sku'] = $prefix . '-' . strtoupper(uniqid());
        }

        $stmt = $db->prepare("
            INSERT INTO products (category_id, name, sku, unit, cost_price, sell_price, stock_qty, min_stock, description, color, image)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $body['category_id'] ?? null,
            $body['name'],
            $body['sku'],
            $body['unit'] ?? 'pcs',
            $body['cost_price'] ?? 0,
            $body['sell_price'],
            $body['stock_qty'] ?? 0,
            $body['min_stock'] ?? 5,
            $body['description'] ?? '',
            $body['color'] ?? null,
            $body['image'] ?? null,
        ]);
        $newId = $db->lastInsertId();

        // Log initial stock if any
        if (($body['stock_qty'] ?? 0) > 0) {
            $stmt2 = $db->prepare("INSERT INTO stock_adjustments (product_id, type, quantity, note) VALUES (?, 'in', ?, 'Initial stock')");
            $stmt2->execute([$newId, $body['stock_qty']]);
        }

        respond(['id' => $newId, 'message' => 'Product created'], 201);
        break;

    case 'PUT':
        if (!$id) respond(['error' => 'ID required'], 400);
        $body = getBody();
        $stmt = $db->prepare("
            UPDATE products SET
                category_id=?, name=?, sku=?, unit=?, cost_price=?, sell_price=?,
                min_stock=?, description=?, color=?, is_active=?, image=?
            WHERE id=?
        ");
        $stmt->execute([
            $body['category_id'] ?? null,
            $body['name'],
            $body['sku'] ?? '',
            $body['unit'] ?? 'pcs',
            $body['cost_price'] ?? 0,
            $body['sell_price'],
            $body['min_stock'] ?? 5,
            $body['description'] ?? '',
            $body['color'] ?? null,
            $body['is_active'] ?? 1,
            $body['image'] ?? null,
            $id,
        ]);
        respond(['message' => 'Product updated']);
        break;

    case 'DELETE':
        if (!$id) respond(['error' => 'ID required'], 400);
        $stmt = $db->prepare("UPDATE products SET is_active=0 WHERE id=?");
        $stmt->execute([$id]);
        respond(['message' => 'Product deactivated']);
        break;

    default:
        respond(['error' => 'Method not allowed'], 405);
}
