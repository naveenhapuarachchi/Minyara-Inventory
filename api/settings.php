<?php
require_once __DIR__ . '/../db.php';

$method = $_SERVER['REQUEST_METHOD'];
$file = __DIR__ . '/../database/settings.json';

// Default settings
$defaults = [
    'shop_name' => 'MINYARA',
    'shop_tagline' => 'A MOMENTS OF TECHNOLOGY',
    'shop_address' => 'Printing & Stationery',
    'shop_phone' => '',
    'shop_email' => 'minyara.team.lk@gmail.com',
    'currency' => 'Rs.'
];

if ($method === 'GET') {
    if (file_exists($file)) {
        $data = json_decode(file_get_contents($file), true);
        if ($data) {
            $defaults = array_merge($defaults, $data);
        }
    }
    respond($defaults);
} else if ($method === 'POST') {
    $body = getBody();
    $data = array_merge($defaults, $body);
    if (!is_dir(dirname($file))) mkdir(dirname($file), 0755, true);
    file_put_contents($file, json_encode($data, JSON_PRETTY_PRINT));
    respond(['message' => 'Settings saved successfully']);
} else {
    respond(['error' => 'Method not allowed'], 405);
}
