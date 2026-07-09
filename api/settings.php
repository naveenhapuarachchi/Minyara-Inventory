<?php
require_once __DIR__ . '/../db.php';

$method = $_SERVER['REQUEST_METHOD'];

$defaults = [
    'shop_name' => 'MINYARA Printing',
    'shop_tagline' => 'A MOMENTS OF TECHNOLOGY',
    'shop_address' => '143/7, Church rd, Welivita, Kaduwela',
    'shop_phone' => '0786763999',
    'shop_email' => 'minyara.team.lk@gmail.com',
    'currency' => 'Rs.',
    'bill_prefix' => 'MIN-',
    'invoice_footer' => ''
];

$db = getDB();

if ($method === 'GET') {
    $stmt = $db->query("SELECT settings FROM app_settings WHERE id = 1");
    $row = $stmt->fetch();
    if ($row && $row['settings']) {
        $data = json_decode($row['settings'], true);
        if ($data) $defaults = array_merge($defaults, $data);
    }
    respond($defaults);
} else if ($method === 'POST') {
    $body = getBody();
    $stmt = $db->query("SELECT settings FROM app_settings WHERE id = 1");
    $row = $stmt->fetch();
    $current = $defaults;
    if ($row && $row['settings']) {
        $decoded = json_decode($row['settings'], true);
        if ($decoded) $current = array_merge($current, $decoded);
    }
    $data = array_merge($current, $body);
    $json = json_encode($data);
    $db->prepare("
        INSERT INTO app_settings (id, settings, updated_at)
        VALUES (1, ?::jsonb, NOW())
        ON CONFLICT (id) DO UPDATE SET settings = EXCLUDED.settings, updated_at = NOW()
    ")->execute([$json]);
    respond(['message' => 'Settings saved successfully']);
} else {
    respond(['error' => 'Method not allowed'], 405);
}
