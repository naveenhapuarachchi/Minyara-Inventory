<?php
require_once __DIR__ . '/../db.php';

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];
$id = isset($_GET['id']) ? (int)$_GET['id'] : null;

switch ($method) {
    case 'GET':
        if ($id) {
            // Single bill with items
            $stmt = $db->prepare("SELECT * FROM bills WHERE id=?");
            $stmt->execute([$id]);
            $bill = $stmt->fetch();
            if (!$bill) respond(['error' => 'Bill not found'], 404);

            $stmt2 = $db->prepare("
                SELECT bi.*, p.image AS product_image
                FROM bill_items bi
                LEFT JOIN products p ON p.id = bi.product_id
                WHERE bi.bill_id=?
            ");
            $stmt2->execute([$id]);
            $bill['items'] = $stmt2->fetchAll();
            respond($bill);
        } else {
            $search = $_GET['search'] ?? '';
            $from   = $_GET['from'] ?? '';
            $to     = $_GET['to'] ?? '';

            $sql = "SELECT * FROM bills WHERE 1=1";
            $params = [];

            if ($search) {
                $sql .= " AND (bill_no LIKE ? OR customer_name LIKE ?)";
                $params[] = "%$search%";
                $params[] = "%$search%";
            }
            if ($from) { $sql .= " AND DATE(created_at) >= ?"; $params[] = $from; }
            if ($to)   { $sql .= " AND DATE(created_at) <= ?"; $params[] = $to;   }

            $sql .= " ORDER BY created_at DESC LIMIT 200";

            $stmt = $db->prepare($sql);
            $stmt->execute($params);
            respond($stmt->fetchAll());
        }
        break;

    case 'POST':
        $body  = getBody();
        $items = $body['items'] ?? [];

        if (empty($items)) respond(['error' => 'Bill must have at least one item'], 400);

        // Generate unique bill number
        $billNo = 'MIN-' . date('Ymd') . '-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);

        $subtotal = 0;
        foreach ($items as $item) {
            $subtotal += (float)$item['qty'] * (float)$item['unit_price'];
        }

        $discount   = (float)($body['discount'] ?? 0);
        $tax        = (float)($body['tax'] ?? 0);
        $total      = $subtotal - $discount + $tax;
        $paidAmount = (float)($body['paid_amount'] ?? $total);
        $change     = $paidAmount - $total;

        $status = $body['status'] ?? 'paid';
        if ($paidAmount < $total && !isset($body['status'])) {
            $status = 'unpaid';
        }

        $db->beginTransaction();
        try {
            // Insert bill header
            $stmt = $db->prepare("
                INSERT INTO bills (bill_no, customer_name, customer_phone, subtotal, discount, tax, total,
                                   paid_amount, change_amount, payment_method, status, notes)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $billNo,
                $body['customer_name'] ?? '',
                $body['customer_phone'] ?? '',
                $subtotal, $discount, $tax, $total,
                $paidAmount, max(0, $change),
                $body['payment_method'] ?? 'cash',
                $status,
                $body['notes'] ?? '',
            ]);
            $billId = $db->lastInsertId();

            // Insert items and deduct stock
            foreach ($items as $item) {
                $qty       = (int)$item['qty'];
                $prodId    = isset($item['product_id']) ? (int)$item['product_id'] : null;
                $unitPrice = (float)$item['unit_price'];
                $lineTotal = $qty * $unitPrice;

                $db->prepare("
                    INSERT INTO bill_items (bill_id, product_id, product_name, unit, qty, unit_price, total)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                ")->execute([$billId, $prodId, $item['product_name'], $item['unit'] ?? 'pcs', $qty, $unitPrice, $lineTotal]);

                // Deduct stock
                if ($prodId) {
                    $db->prepare("UPDATE products SET stock_qty = GREATEST(0, stock_qty - ?) WHERE id=?")
                       ->execute([$qty, $prodId]);
                    $db->prepare("INSERT INTO stock_adjustments (product_id, type, quantity, note) VALUES (?, 'sale', ?, ?)")
                       ->execute([$prodId, $qty, 'Bill ' . $billNo]);
                }
            }

            $db->commit();
            respond(['id' => $billId, 'bill_no' => $billNo, 'total' => $total, 'change' => max(0, $change)], 201);
        } catch (Exception $e) {
            $db->rollBack();
            respond(['error' => 'Failed: ' . $e->getMessage()], 500);
        }
        break;

    case 'DELETE':
        if (!$id) respond(['error' => 'ID required'], 400);
        $db->beginTransaction();
        try {
            // Restore stock for each item
            $stmt = $db->prepare("SELECT * FROM bill_items WHERE bill_id=?");
            $stmt->execute([$id]);
            $items = $stmt->fetchAll();

            $stmtBill = $db->prepare("SELECT bill_no FROM bills WHERE id=?");
            $stmtBill->execute([$id]);
            $bill = $stmtBill->fetch();

            foreach ($items as $item) {
                if ($item['product_id']) {
                    $db->prepare("UPDATE products SET stock_qty = stock_qty + ? WHERE id=?")
                       ->execute([$item['qty'], $item['product_id']]);
                    $db->prepare("INSERT INTO stock_adjustments (product_id, type, quantity, note) VALUES (?, 'return', ?, ?)")
                       ->execute([$item['product_id'], $item['qty'], 'Cancelled Bill ' . ($bill['bill_no'] ?? '')]);
                }
            }

            $db->prepare("DELETE FROM bills WHERE id=?")->execute([$id]);
            $db->commit();
            respond(['message' => 'Bill deleted and stock restored']);
        } catch (Exception $e) {
            $db->rollBack();
            respond(['error' => $e->getMessage()], 500);
        }
        break;

    case 'PATCH':
        if (!$id) respond(['error' => 'ID required'], 400);
        $body = getBody();
        if (!isset($body['status'])) respond(['error' => 'Status required'], 400);
        
        $status = $body['status'];
        if (!in_array($status, ['paid', 'unpaid', 'cancelled'])) {
            respond(['error' => 'Invalid status'], 400);
        }

        try {
            $stmt = $db->prepare("UPDATE bills SET status=? WHERE id=?");
            $stmt->execute([$status, $id]);
            respond(['message' => 'Status updated successfully', 'status' => $status]);
        } catch (Exception $e) {
            respond(['error' => $e->getMessage()], 500);
        }
        break;

    default:
        respond(['error' => 'Method not allowed'], 405);
}
