<?php
    require_once 'dbconfig.php';

    // reference: https://phpdelusions.net/pdo_examples/connect_to_mysql


    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];

    try {
        $dsn = "mysql:host=$host;dbname=$db;charset=$charset;port=$port";
        $connection = new PDO($dsn, $username, $password, $options);
        // echo "Connected to server! <br>";
    } catch(PDOException $e){
        throw new PDOException($e->getMessage(), (int)$e->getCode());
    }
