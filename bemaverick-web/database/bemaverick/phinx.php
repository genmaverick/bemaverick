<?php

require_once( __DIR__ . '/../config/setup_environment.php');

$dbName = 'bemaverick';
$dbConfig = Zend_Registry::get( 'databaseConfig' );
$dbSettings = $dbConfig->getDatabaseSettings( $dbName );
$connection = new \PDO( 'mysql:dbname='.$dbSettings['dbname'].';host='.$dbSettings['host'],
    $dbSettings['username'],
    $dbSettings['password']);

return array(
    'paths' => array(
        'migrations' => __DIR__ . '/migrations',
        'seeds' => __DIR__ . '/seeds',
    ),
    'environments' =>
        array(
            'default_database' => $dbName,
            $dbName => array(
                'name' => $dbName,
                'connection' => $connection,
            )
        )
);

?>
