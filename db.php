<?php

// Supabase PostgreSQL connection (for local PHP / XAMPP development)
function getDB() {
    $host = getenv('DB_HOST') ?: 'db.uiizyekyixavhmverrvq.supabase.co';
    $port = getenv('DB_PORT') ?: '5432';
    $db   = getenv('DB_NAME') ?: 'postgres';
    $user = getenv('DB_USER') ?: 'postgres';
    $pass = getenv('DB_PASSWORD') ?: '';
    $charset = 'utf8';

    $dsn = "pgsql:host=$host;port=$port;dbname=$db;sslmode=require";
    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];

    try {
        return new PDO($dsn, $user, $pass, $options);
    } catch (\PDOException $e) {
        respond(['error' => 'Database connection failed: ' . $e->getMessage()], 500);
        exit;
    }
}

function pgLastInsertId($db, $table = 'products') {
    $seq = $table . '_id_seq';
    return $db->query("SELECT currval('$seq')")->fetchColumn();
}

function respond($data, $status = 200) {
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
    http_response_code($status);
    echo json_encode($data);
    exit;
}

function getBody() {
    $input = file_get_contents('php://input');
    return json_decode($input, true) ?: [];
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    respond(['ok' => true]);
}
