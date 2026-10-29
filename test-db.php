<?php

require_once "db.php";

if ($conn->connect_error) {
    die("Database connection failed: " . $conn->connect_error);
}

echo "SUCCESS: Zuri MySQL database connected.";