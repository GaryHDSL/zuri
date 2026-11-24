<?php
require __DIR__ . '/auth/bootstrap.php';
if (!empty($_SESSION['zuri_user_id'])) { header('Location: account.php'); exit; }
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    zuri_verify_csrf();
    $name = trim((string)($_POST['full_name'] ?? ''));
    $email = strtolower(trim((string)($_POST['email'] ?? '')));
    $phone = trim((string)($_POST['phone'] ?? ''));
    $password = (string)($_POST['password'] ?? '');
    if ($name === '' || strlen($name) > 120 || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 190) {
        $error = 'Enter your name and a valid email address.';
    } elseif (strlen($password) < 10) {
        $error = 'Use a password with at least 10 characters.';
    } else {
        try {
            $stmt = $pdo->prepare('INSERT INTO zuri_users (full_name,email,phone,password_hash,role) VALUES (?,?,?,?,\'customer\')');
            $stmt->execute([$name, $email, $phone, password_hash($password, PASSWORD_DEFAULT)]);
            session_regenerate_id(true);
            $_SESSION['zuri_user_id'] = (int)$pdo->lastInsertId();
            $_SESSION['zuri_user_name'] = $name;
            header('Location: account.php');
            exit;
        } catch (PDOException $e) {
            if ($e->getCode() === '23000') $error = 'An account with that email already exists. Please sign in.';
            else { error_log('Zuri registration error: ' . $e->getMessage()); $error = 'Registration could not be completed. Please try again.'; }
        }
    }
}
?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Create Account | Zuri Logistics</title><link rel="stylesheet" href="css/bootstrap.min.css"><style>body{background:#f3f6f9;font-family:Arial,sans-serif;color:#061d34}.auth-wrap{max-width:510px;margin:6vh auto;padding:18px}.auth-card{background:#fff;border-radius:18px;padding:34px;box-shadow:0 18px 55px #061d3412}.brand{font-weight:900;color:#061d34;font-size:24px}.brand span{color:#b78200}.form-control{padding:13px}.btn-zuri{background:#ffbd19;color:#061d34;font-weight:800;padding:13px;border:0}.muted{color:#64778a}</style></head><body><main class="auth-wrap"><div class="auth-card"><a class="brand text-decoration-none" href="index.html">ZURI <span>LOGISTICS</span></a><h1 class="h3 fw-bold mt-4">Create your account</h1><p class="muted">Register to access your Zuri customer account.</p><?php if($error): ?><div class="alert alert-danger"><?=zuri_escape($error)?></div><?php endif; ?><form method="post" autocomplete="on"><input type="hidden" name="csrf_token" value="<?=zuri_escape(zuri_csrf_token())?>"><label class="form-label mt-2" for="full_name">Full name</label><input class="form-control" id="full_name" name="full_name" maxlength="120" required autocomplete="name"><label class="form-label mt-3" for="email">Email address</label><input class="form-control" id="email" type="email" name="email" maxlength="190" required autocomplete="email"><label class="form-label mt-3" for="phone">Phone number (optional)</label><input class="form-control" id="phone" name="phone" maxlength="40" autocomplete="tel"><label class="form-label mt-3" for="password">Password</label><input class="form-control" id="password" type="password" name="password" minlength="10" required autocomplete="new-password"><small class="muted">Use at least 10 characters.</small><button class="btn btn-zuri w-100 mt-4" type="submit">Create account</button></form><p class="mt-4 mb-0 text-center">Already registered? <a href="login.php">Sign in</a></p><p class="mt-3 mb-0 text-center"><a class="muted" href="index.html">Return to Zuri website</a></p></div></main></body></html>
