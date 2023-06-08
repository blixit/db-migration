<?php
    // TODO: use autoloader instead
    require_once './scripts/phpLib/dot-env.php';

    (new DBMigration\DotEnv(getcwd() . '/.env'))->load();

    $protocol = getenv('DB_DEST_PROTOCOL');
    $host = getenv('DB_DEST_HOST');
    $port = getenv('DB_DEST_PORT');
    $user = getenv('DB_DEST_USER');
    $password = getenv('DB_DEST_PASSWORD');

    $connection = new PDO($protocol . ':host=' . $host . ';port=' . $port, $user, $password);

    if (!isset($argv[1]) || strlen($argv[1]) === 0) {
        printf("A database name must be specified\n");
        exit(1);
    }
    
    $databaseName = $argv[1];

    printf("Creating database '%s'... \n", $databaseName);

    $connection->query( 'DROP DATABASE ' . $databaseName );
    $connection->query( 'CREATE DATABASE ' . $databaseName );

    printf("Done !\n");
