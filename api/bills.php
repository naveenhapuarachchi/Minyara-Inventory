<?php
require_once __DIR__ . '/../db.php';

$db = getDB();
$method = $_SERVER['REQUEST_METHOD'];
$id = isset($_GET['id']) ? (int)$_GET['id'] : null;

function mapBillItemRow($row) {
    $row['qty'] = $row['quantity'];
    $row['total'] = $row['total_price'];
    return $row;
}

switch ($method) {
    case 'GET':
        if ($id) {
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
            $bill['items'] = array_map('mapBillItemRow', $stmt2->fetchAll());
            respond($bill);
        } else {
            $search = $_GET['search'] ?? '';
            $from   = $_GET['from'] ?? '';
            $to     = $_GET['to'] ?? '';

            $sql = "SELECT * FROM bills WHERE 1=1";
            $params = [];

            if ($search) {
                $sql .= " AND (bill_no ILIKE ? OR customer_name ILIKE ?)";
                $params[] = "%$search%";
                $params[] = "%$search%";
            }
            if ($from) { $sql .= " AND created_at::date >= ?::date"; $params[] = $from; }
            if ($to)   { $sql .= " AND created_at::date <= ?::date"; $params[] = $to;   }

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

        $itemsJson = json_encode($items);
        $stmt = $db->prepare("SELECT create_bill_with_items(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?::jsonb) AS result");
        try {
            $stmt->execute([
                $billNo,
                $body['customer_name'] ?? '',
                $body['customer_phone'] ?? '',
                $subtotal, $discount, $tax, $total,
                $paidAmount, max(0, $change),
                $body['payment_method'] ?? 'cash',
                $status,
                $body['notes'] ?? '',
                $itemsJson,
            ]);
            $result = json_decode($stmt->fetchColumn(), true);
            respond($result, 201);
        } catch (Exception $e) {
            respond(['error' => 'Failed: ' . $e->getMessage()], 500);
        }
        break;

    case 'DELETE':
        if (!$id) respond(['error' => 'ID required'], 400);
        try {
            $stmt = $db->prepare("SELECT delete_bill_restore_stock(?)");
            $stmt->execute([$id]);
            respond(['message' => 'Bill deleted and stock restored']);
        } catch (Exception $e) {
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
