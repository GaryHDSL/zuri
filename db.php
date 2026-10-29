<?php

$host = "ql306.infinityfree.com";
$user = "if0_43274647";
$pass = "Odsv8CfedT0k";
$db   = "if0_43274647_zuri";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Database connection failed.");
}

$conn->set_charset("utf8mb4");