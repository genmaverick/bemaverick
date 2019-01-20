<?php

// database connection settings

$databaseSettings = array(

    'bemaverick' => array(
        'host'     => '35.203.132.77',
        'username' => 'bemaverick',
        'password' => 'lph5Bmwqr1I18uLA',
        'dbname'   => 'bemaverick',
    ),
);

$prodDatabaseSettings = array(

    'bemaverick' => array(
        'host'     => '35.203.167.152',
        'username' => 'bemaverick',
        'password' => 'HoY7eurpwjL.TRqQkn8R2Y2G',
        'dbname'   => 'bemaverick',
    ),
);

return (isset($_GET['debug']) && $_GET['debug'] == 'localprod' && false) ? $prodDatabaseSettings : $databaseSettings;


?>
