<?php
$content = file_get_contents('index.html');
$parts = explode('<!DOCTYPE html>', $content);
foreach($parts as $part) {
    if (trim($part) === '') continue;
    $html = '<!DOCTYPE html>' . $part;
    if (preg_match('/<title>(.*?)<\/title>/', $html, $matches)) {
        $title = $matches[1];
        $filename = '';
        if (strpos($title, 'Dashboard') !== false) $filename = 'index.html';
        elseif (strpos($title, 'Analytics') !== false) $filename = 'analytics.html';
        elseif (strpos($title, 'POS Billing') !== false) $filename = 'billing.html';
        elseif (strpos($title, 'Bills History') !== false) $filename = 'bills.html';
        elseif (strpos($title, 'Categories') !== false) $filename = 'categories.html';
        elseif (strpos($title, 'Products') !== false) $filename = 'inventory.html';
        elseif (strpos($title, 'Settings') !== false) $filename = 'settings.html';
        
        if ($filename) {
            // Replace ?v=4 with ?v=5 in the repaired file
            $html = str_replace('?v=4', '?v=5', $html);
            file_put_contents($filename, $html);
            echo "Recovered $filename\n";
        }
    }
}
echo "Done.";
