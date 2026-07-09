<?php
require_once __DIR__ . '/../db.php';

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];
$id = isset($_GET['id']) ? (int)$_GET['id'] : null;

switch ($method) {
    case 'GET':
        if ($id) {
            $stmt = $db->prepare("SELECT * FROM categories WHERE id = ?");
            $stmt->execute([$id]);
            $cat = $stmt->fetch();
            respond($cat ?: ['error' => 'Not found'], $cat ? 200 : 404);
        } else {
            $stmt = $db->query("
                SELECT c.*, COUNT(p.id) AS product_count
                FROM categories c
                LEFT JOIN products p ON p.category_id = c.id AND p.is_active = 1
                GROUP BY c.id ORDER BY c.name
            ");
            respond($stmt->fetchAll());
        }
        break;

    case 'POST':
        $body = getBody();
        if (empty($body['name'])) respond(['error' => 'Name required'], 400);
        $stmt = $db->prepare("INSERT INTO categories (name, description) VALUES (?, ?)");
        $stmt->execute([$body['name'], $body['description'] ?? '']);
        respond(['id' => $db->lastInsertId(), 'message' => 'Category created'], 201);
        break;

    case 'PUT':
        if (!$id) respond(['error' => 'ID required'], 400);
        $body = getBody();
        if (empty($body['name'])) respond(['error' => 'Name required'], 400);
        $stmt = $db->prepare("UPDATE categories SET name=?, description=? WHERE id=?");
        $stmt->execute([$body['name'], $body['description'] ?? '', $id]);
        respond(['message' => 'Category updated']);
        break;

    case 'DELETE':
        if (!$id) respond(['error' => 'ID required'], 400);
        // Nullify category on all products first to avoid orphaned references
        $db->prepare("UPDATE products SET category_id=NULL WHERE category_id=?")->execute([$id]);
        $stmt = $db->prepare("DELETE FROM categories WHERE id=?");
        $stmt->execute([$id]);
        respond(['message' => 'Category deleted']);
        break;

    default:
        respond(['error' => 'Method not allowed'], 405);
}
