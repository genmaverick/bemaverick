<?php

if (PHP_MAJOR_VERSION >= 7) {
    set_error_handler(function ($errno, $errstr) {
       return strpos($errstr, 'Declaration of') === 0;
    }, E_WARNING);
}

// define the system variables
include( 'defines.php' );

// update the include path to have the libraries we need
ini_set( 'include_path', ZEND_ROOT_DIR . '/lib:' .
                         SLY_ROOT_DIR . '/lib:' .
                         ini_get( 'include_path' ) );

// files needed for setup
require_once( BEMAVERICK_COMMON_ROOT_DIR  . '/lib/Factory.php' );

// create the factory
$factory = new BeMaverick_Factory( 'website' );

// include the common setup_environment
include( BEMAVERICK_COMMON_ROOT_DIR . '/config/setup_base_environment.php' );

?>
