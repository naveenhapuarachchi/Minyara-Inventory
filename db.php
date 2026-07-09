<?php

// Database connection configuration
function getDB() {
    $host = '127.0.0.1';
    $db   = 'minyara_inventory';
    $user = 'root';
    $pass = ''; // Default XAMPP password is empty
    $charset = 'utf8mb4';

    $dsn = "mysql:host=$host;dbname=$db;charset=$charset";
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

// Helper function to send JSON responses
function respond($data, $status = 200) {
    header('Content-Type: application/json');
    http_response_code($status);
    echo json_encode($data);
    exit;
}

// Helper function to get POST/PUT JSON body
function getBody() {
    $input = file_get_contents('php://input');
    return json_decode($input, true) ?: [];
}
