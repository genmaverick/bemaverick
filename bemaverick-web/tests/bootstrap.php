<?php
require_once ( __DIR__ . "/../api/config/setup_environment.php" );

// update the include path to have the libraries we need
ini_set(
    'include_path', ZEND_ROOT_DIR . '/lib:' .
    SLY_ROOT_DIR . '/lib:' .
    ini_get( 'include_path' )
);