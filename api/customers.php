<?php
require_once __DIR__ . '/../db.php';

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];
$id = isset($_GET['id']) ? (int)$_GET['id'] : null;

switch ($method) {
    case 'GET':
        if ($id) {
            // Get single customer details with their bills history
            $stmt = $db->prepare("
                SELECT c.*, 
                       COUNT(b.id) AS total_bills,
                       COALESCE(SUM(b.total), 0) AS total_spent
                FROM customers c
                LEFT JOIN bills b ON b.customer_id = c.id
                WHERE c.id = ?
                GROUP BY c.id
            ");
            $stmt->execute([$id]);
            $customer = $stmt->fetch();
            
            if (!$customer) {
                respond(['error' => 'Customer not found'], 404);
            }
            
            // Fetch recent 10 bills for this customer
            $stmtBills = $db->prepare("
                SELECT id, bill_no, total, payment_method, status, created_at 
                FROM bills 
                WHERE customer_id = ? 
                ORDER BY created_at DESC 
                LIMIT 10
            ");
            $stmtBills->execute([$id]);
            $customer['recent_bills'] = $stmtBills->fetchAll();
            
            respond($customer);
        } else {
            // List all or search customers
            $search = $_GET['search'] ?? '';
            
            $sql = "
                SELECT c.*, 
                       COUNT(b.id) AS total_bills,
                       COALESCE(SUM(b.total), 0) AS total_spent
                FROM customers c
                LEFT JOIN bills b ON b.customer_id = c.id
            ";
            
            $params = [];
            if (!empty($search)) {
                $sql .= " WHERE c.name LIKE ? OR c.phone LIKE ? ";
                $params[] = "%$search%";
                $params[] = "%$search%";
            }
            
            $sql .= " GROUP BY c.id ORDER BY c.created_at DESC";
            
            $stmt = $db->prepare($sql);
            $stmt->execute($params);
            respond($stmt->fetchAll());
        }
        break;

    case 'POST':
        $body = getBody();
        $name = trim($body['name'] ?? '');
        $phone = trim($body['phone'] ?? '');
        $email = trim($body['email'] ?? '');
        $address = trim($body['address'] ?? '');
        $notes = trim($body['notes'] ?? '');
        $image = trim($body['image'] ?? '');

        if (empty($name)) {
            respond(['error' => 'Customer name is required'], 400);
        }

        // Check unique phone if not empty
        if (!empty($phone)) {
            $stmt = $db->prepare("SELECT id FROM customers WHERE phone = ?");
            $stmt->execute([$phone]);
            if ($stmt->fetch()) {
                respond(['error' => 'A customer with this phone number already exists'], 400);
            }
        }

        try {
            $stmt = $db->prepare("INSERT INTO customers (name, phone, email, address, notes, image) VALUES (?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $name,
                empty($phone) ? null : $phone,
                empty($email) ? null : $email,
                empty($address) ? null : $address,
                empty($notes) ? null : $notes,
                empty($image) ? null : $image
            ]);
            $customerId = $db->lastInsertId();
            respond(['id' => $customerId, 'message' => 'Customer created successfully'], 201);
        } catch (Exception $e) {
            respond(['error' => 'Failed to create customer: ' . $e->getMessage()], 500);
        }
        break;

    case 'PUT':
    case 'PATCH':
        if (!$id) {
            respond(['error' => 'Customer ID required'], 400);
        }
        
        $body = getBody();
        
        // Fetch existing
        $stmt = $db->prepare("SELECT * FROM customers WHERE id = ?");
        $stmt->execute([$id]);
        $customer = $stmt->fetch();
        if (!$customer) {
            respond(['error' => 'Customer not found'], 404);
        }

        $name = isset($body['name']) ? trim($body['name']) : $customer['name'];
        $phone = isset($body['phone']) ? trim($body['phone']) : $customer['phone'];
        $email = isset($body['email']) ? trim($body['email']) : $customer['email'];
        $address = isset($body['address']) ? trim($body['address']) : $customer['address'];
        $notes = isset($body['notes']) ? trim($body['notes']) : $customer['notes'];
        $image = isset($body['image']) ? trim($body['image']) : $customer['image'];

        if (empty($name)) {
            respond(['error' => 'Customer name is required'], 400);
        }

        // Check if phone number is taken by another customer
        if (!empty($phone) && $phone !== $customer['phone']) {
            $stmt = $db->prepare("SELECT id FROM customers WHERE phone = ? AND id != ?");
            $stmt->execute([$phone, $id]);
            if ($stmt->fetch()) {
                respond(['error' => 'A customer with this phone number already exists'], 400);
            }
        }

        try {
            $stmt = $db->prepare("UPDATE customers SET name = ?, phone = ?, email = ?, address = ?, notes = ?, image = ? WHERE id = ?");
            $stmt->execute([
                $name,
                empty($phone) ? null : $phone,
                empty($email) ? null : $email,
                empty($address) ? null : $address,
                empty($notes) ? null : $notes,
                empty($image) ? null : $image,
                $id
            ]);
            respond(['message' => 'Customer updated successfully']);
        } catch (Exception $e) {
            respond(['error' => 'Failed to update customer: ' . $e->getMessage()], 500);
        }
        break;

    case 'DELETE':
        if (!$id) {
            respond(['error' => 'Customer ID required'], 400);
        }

        // Set customer_id = NULL in bills table for bills associated with this customer
        $db->beginTransaction();
        try {
            $stmtBills = $db->prepare("UPDATE bills SET customer_id = NULL WHERE customer_id = ?");
            $stmtBills->execute([$id]);

            $stmtCust = $db->prepare("DELETE FROM customers WHERE id = ?");
            $stmtCust->execute([$id]);

            $db->commit();
            respond(['message' => 'Customer deleted successfully']);
        } catch (Exception $e) {
            $db->rollBack();
            respond(['error' => 'Failed to delete customer: ' . $e->getMessage()], 500);
        }
        break;

    default:
        respond(['error' => 'Method not allowed'], 405);
}
