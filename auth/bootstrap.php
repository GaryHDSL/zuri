<?php
declare(strict_types=1);

/*
 * Configure these environment variables in the hosting control panel:
 * ZURI_DB_HOST, ZURI_DB_NAME, ZURI_DB_USER, ZURI_DB_PASS.
 * Never commit database credentials to this repository.
 */
$host = getenv('ZURI_DB_HOST') ?: '';
$name = getenv('ZURI_DB_NAME') ?: '';
$user = getenv('ZURI_DB_USER') ?: '';
$pass = getenv('ZURI_DB_PASS') ?: '';

if ($host === '' || $name === '' || $user === '') {
    http_response_code(503);
    exit('Zuri accounts are not configured yet. Please contact the website administrator.');
}

$isHttps = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off');
session_set_cookie_params([
    'lifetime' => 0,
    'path' => '/',
    'secure' => $isHttps,
    'httponly' => true,
    'samesite' => 'Lax',
]);
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}

try {
    $pdo = new PDO(
        "mysql:host={$host};dbname={$name};charset=utf8mb4",
        $user,
        $pass,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]
    );
} catch (PDOException $e) {
    error_log('Zuri account database connection failed: ' . $e->getMessage());
    http_response_code(503);
    exit('Accounts are temporarily unavailable. Please try again later.');
}

function zuri_csrf_token(): string {
    if (empty($_SESSION['zuri_csrf'])) {
        $_SESSION['zuri_csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['zuri_csrf'];
}

function zuri_verify_csrf(): void {
    $token = $_POST['csrf_token'] ?? '';
    if (!is_string($token) || !hash_equals($_SESSION['zuri_csrf'] ?? '', $token)) {
        http_response_code(400);
        exit('Your session expired. Please go back and try again.');
    }
}

function zuri_escape(string $value): string {
    return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function zuri_require_login(): void {
    if (empty($_SESSION['zuri_user_id'])) {
        header('Location: login.php');
        exit;
    }
}
