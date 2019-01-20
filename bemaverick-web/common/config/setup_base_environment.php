<?php
date_default_timezone_set( 'America/Los_Angeles' );

// This code expects $factory to be already defined in the current context.

// require all needed libraries
require_once( ZEND_ROOT_DIR    . '/lib/Zend/Registry.php' );
require_once( SLY_ROOT_DIR     . '/lib/Sly/Da.php' );
require_once( SLY_ROOT_DIR     . '/lib/Sly/CacheTags.php' );
require_once( SLY_ROOT_DIR     . '/lib/Sly/Strings.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Config/Database.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

$systemConfig = $factory->getSystemConfig();

// set the cache
$cacheType = $systemConfig->getSetting( 'SYSTEM_CACHE_TYPE' );
if ( $cacheType == 'mock' ) {

    require_once( SLY_ROOT_DIR     . '/lib/Sly/Cache/Mock.php' );
    $cache = new Sly_Cache_Mock();

} else {

    require_once( SLY_ROOT_DIR     . '/lib/Sly/Cache/Redis.php' );
    $cache = new Sly_Cache_Redis( $systemConfig->getCacheBackendOptions() );
}

$cacheTags = Sly_CacheTags::getInstance( $cache );

// set the cache and cache tags to the da object
Sly_Da::setCache( $cache );
Sly_Da::setCacheTags( $cacheTags );

// set the strings file
Sly_Strings::setStringsFile( $systemConfig->getStringsXmlFile() );

// pull in the database settings and initialize the database config
$databaseSettings = include( BEMAVERICK_COMMON_ROOT_DIR . '/config/databases.php' );
$databaseConfig = new BeMaverick_Config_Database( $databaseSettings );

// set the adapters for everything
BeMaverick_Da::setAdapter( $databaseConfig->getDbAdapter( 'bemaverick', $factory ) );

// set up some objects
$site = $factory->getSite( $systemConfig->getSetting( 'SYSTEM_SITE_ID' ) );
$validator = $factory->getValidator();

// set registry variables
Zend_Registry::set( 'databaseConfig', $databaseConfig );
Zend_Registry::set( 'systemConfig',   $systemConfig );
Zend_Registry::set( 'cache',          $cache );
Zend_Registry::set( 'factory',        $factory );
Zend_Registry::set( 'site',           $site );
Zend_Registry::set( 'validator',      $validator );

?>
