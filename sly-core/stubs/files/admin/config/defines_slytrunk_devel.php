<?php

$USER = preg_match('/^\/home\/([^\/]+)\//', getcwd(), $matches) ? $matches[1] : false;

// define the zend and sly root dir
define( 'ZEND_ROOT_DIR',                     "/home/$USER/dev/zend/trunk" );
define( 'TWITTER_ROOT_DIR',                  "/home/$USER/dev/twitter/trunk" );
define( 'FACEBOOK_ROOT_DIR',                 "/home/$USER/dev/facebook/trunk" );
define( 'SLY_ROOT_DIR',                      "/home/$USER/dev/sly/trunk" );
define( '__SLY_REPOSITORY_UPPERCASE_NAME___ROOT_DIR',             "/home/$USER/dev/__SLY_REPOSITORY_NAME__/trunk" );
define( '__SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR',      "/home/$USER/dev/__SLY_REPOSITORY_NAME__/trunk/common" );
define( '__SLY_REPOSITORY_UPPERCASE_NAME___ADMIN_ROOT_DIR',       "/home/$USER/dev/__SLY_REPOSITORY_NAME__/trunk/admin" );
define( '__SLY_REPOSITORY_UPPERCASE_NAME___WEBSERVICES_ROOT_DIR', "/home/$USER/dev/__SLY_REPOSITORY_NAME__/trunk/webservices" );

// define other dirs for this site
define( 'SYSTEM_ROOT_DIR',                   "/home/$USER/dev/__SLY_REPOSITORY_NAME__/trunk/admin" );

// define random settings
define( 'SYSTEM_ENVIRONMENT',           'devel' );
define( 'SYSTEM_DEBUG_MODE',            false );
define( 'SYSTEM_HTTP_HOST',             "$USER.admin.__SLY_REPOSITORY_NAME__.slytrunk.com" );
define( 'SYSTEM_ERROR_EMAIL_ADDRESS',   "$USER@slytrunk.com" );

// frontend configs
define( 'SYSTEM_LESS_ENABLED', true );
define( 'SYSTEM_TWITTER_BOOTSTRAP_VERSION', '2.3.0' );

// memcache configs
define( 'SYSTEM_MEMCACHE_HOSTS', 'localhost' );

// site database connection settings
define( 'SYSTEM_DATABASE_HOST', 'localhost' );
define( 'SYSTEM_DATABASE_USERNAME', 'apache' );
define( 'SYSTEM_DATABASE_PASSWORD', 'mysql' );
define( 'SYSTEM_DATABASE_DBNAME', '__SLY_DATABASE_NAME__' );

?>
