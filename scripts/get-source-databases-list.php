<?php
    // TODO: use autoloader instead
    require_once './scripts/phpLib/dot-env.php';

    (new DBMigration\DotEnv(getcwd() . '/.env'))->load();

    
    $user = getenv('DB_SOURCE_USER');
    $password = getenv('DB_SOURCE_PASSWORD');
    $protocol = getenv('DB_SOURCE_PROTOCOL');
    $host = getenv('DB_SOURCE_HOST');
    
    $connection = new PDO($protocol . ':host=' . $host, $user, $password);

    $databaseList = $connection->query('SHOW DATABASES');

    $databaseNameList = '';
    while(( $dbName = $databaseList->fetchColumn(0) ) !== false) {
        $databaseNameList = sprintf("%s %s", $databaseNameList, $dbName);
    }

    printf(trim($databaseNameList) . "\n");
