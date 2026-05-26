<?php
try {
    $pdo = new PDO("pgsql:host=aws-1-ap-northeast-2.pooler.supabase.com;port=5432;dbname=postgres", "user", "pass");
    echo "connected";
} catch (Exception $e) {
    echo $e->getMessage();
}
