<?php
// define the system variables
include( 'defines.php' );

// update the include path to have the libraries we need
ini_set( 'include_path', ZEND_ROOT_DIR . '/lib:' .
                         SLY_ROOT_DIR . '/lib:' .
                         ini_get( 'include_path' ) );

// require all libs
require_once( ZEND_ROOT_DIR   . '/lib/Zend/Registry.php' );
require_once( SLY_ROOT_DIR    . '/lib/Sly/DbAdapter.php' );
require_once( SLY_ROOT_DIR    . '/lib/Sly/Da.php' );
require_once( SLY_ROOT_DIR    . '/lib/Sly/Strings.php' );
require_once( SLY_ROOT_DIR    . '/lib/Sly/Cache/Memcached.php' );
require_once( SLY_ROOT_DIR    . '/lib/Sly/CacheTags.php' );
require_once( __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR  . '/lib/__SLY_CLASS_PREFIX__/Site.php' );
require_once( __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR  . '/lib/__SLY_CLASS_PREFIX__/Validator.php' );
require_once( __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR  . '/lib/__SLY_CLASS_PREFIX__/Config/System.php' );

// create the system config
$systemConfig = new __SLY_CLASS_PREFIX___Config_System();

// systemConfig was created from the <site> setup environment script
Zend_Registry::set( 'systemConfig', $systemConfig );

// set the strings file
Sly_Strings::setStringsFile( $systemConfig->getStringsXmlFile() );

// set the cache
$cache = new Sly_Cache_Memcached( $systemConfig->getCacheBackendOptions() );

// set the cacheTags
$cacheTags = Sly_CacheTags::getInstance( $cache );

// set the cache and cache tags to the da object
Sly_Da::setCache( $cache );
Sly_Da::setCacheTags( $cacheTags );

// setup the normal site database config
$dbAdapter = Sly_DbAdapter::getInstance( $systemConfig->getDatabaseConfig() );
Sly_Da::setAdapter( $dbAdapter );

// set up some objects
$site = __SLY_CLASS_PREFIX___Site::getInstance();
$validator = __SLY_CLASS_PREFIX___Validator::getInstance();

Zend_Registry::set( 'dbAdapter', $dbAdapter );
Zend_Registry::set( 'cache', $cache );
Zend_Registry::set( 'site', $site );
Zend_Registry::set( 'validator', $validator );

?>
