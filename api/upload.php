<?php
require_once __DIR__ . '/../db.php';

// Ensure the directory exists
$targetDir = __DIR__ . '/../assets/products/';
if (!file_exists($targetDir)) {
    mkdir($targetDir, 0777, true);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!isset($_FILES['image'])) {
        respond(['error' => 'No image uploaded'], 400);
    }

    $file = $_FILES['image'];
    $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    $allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

    if (!in_array($ext, $allowed)) {
        respond(['error' => 'Invalid file type. Only JPG, PNG, GIF, and WebP are allowed.'], 400);
    }

    if ($file['size'] > 2 * 1024 * 1024) {
        respond(['error' => 'File size too large. Max 2MB allowed.'], 400);
    }

    $filename = uniqid('prod_') . '.' . $ext;
    $targetFile = $targetDir . $filename;

    if (move_uploaded_file($file['tmp_name'], $targetFile)) {
        respond([
            'message' => 'Upload successful',
            'path' => 'assets/products/' . $filename
        ], 200);
    } else {
        respond(['error' => 'Failed to move uploaded file. Check directory permissions.'], 500);
    }
} else {
    respond(['error' => 'Method not allowed'], 405);
}
