<?php
require __DIR__ . '/auth/bootstrap.php';
if (!empty($_SESSION['zuri_user_id'])) { header('Location: account.php'); exit; }
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    zuri_verify_csrf();
    $email = strtolower(trim((string)($_POST['email'] ?? '')));
    $password = (string)($_POST['password'] ?? '');
    $stmt = $pdo->prepare('SELECT id, full_name, password_hash, is_active FROM zuri_users WHERE email = ? LIMIT 1');
    $stmt->execute([$email]);
    $account = $stmt->fetch();
    if ($account && (int)$account['is_active'] === 1 && password_verify($password, $account['password_hash'])) {
        session_regenerate_id(true);
        $_SESSION['zuri_user_id'] = (int)$account['id'];
        $_SESSION['zuri_user_name'] = $account['full_name'];
        header('Location: account.php');
        exit;
    }
    $error = 'Email or password is incorrect, or the account is inactive.';
}
?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Sign In | Zuri Logistics</title><link rel="stylesheet" href="css/bootstrap.min.css"><style>body{background:#f3f6f9;font-family:Arial,sans-serif;color:#061d34}.auth-wrap{max-width:510px;margin:8vh auto;padding:18px}.auth-card{background:#fff;border-radius:18px;padding:34px;box-shadow:0 18px 55px #061d3412}.brand{font-weight:900;color:#061d34;font-size:24px}.brand span{color:#b78200}.form-control{padding:13px}.btn-zuri{background:#ffbd19;color:#061d34;font-weight:800;padding:13px;border:0}.muted{color:#64778a}</style></head><body><main class="auth-wrap"><div class="auth-card"><a class="brand text-decoration-none" href="index.html">ZURI <span>LOGISTICS</span></a><h1 class="h3 fw-bold mt-4">Welcome back</h1><p class="muted">Sign in to your Zuri customer account.</p><?php if($error): ?><div class="alert alert-danger"><?=zuri_escape($error)?></div><?php endif; ?><form method="post" autocomplete="on"><input type="hidden" name="csrf_token" value="<?=zuri_escape(zuri_csrf_token())?>"><label class="form-label mt-2" for="email">Email address</label><input class="form-control" id="email" type="email" name="email" required autocomplete="username"><label class="form-label mt-3" for="password">Password</label><input class="form-control" id="password" type="password" name="password" required autocomplete="current-password"><button class="btn btn-zuri w-100 mt-4" type="submit">Sign in</button></form><p class="mt-4 mb-0 text-center">New to Zuri? <a href="register.php">Create an account</a></p><p class="mt-3 mb-0 text-center"><a class="muted" href="index.html">Return to Zuri website</a></p></div></main></body></html>
