<?php
require_once( BEMAVERICK_ROOT_DIR . '/vendor/bshaffer/oauth2-server-php/src/OAuth2/Autoloader.php' );
OAuth2\Autoloader::register();

require_once( BEMAVERICK_ROOT_DIR . '/vendor/firebase/php-jwt/src/JWT.php' );
require_once( BEMAVERICK_ROOT_DIR . '/vendor/firebase/php-jwt/src/BeforeValidException.php' );
require_once( BEMAVERICK_ROOT_DIR . '/vendor/firebase/php-jwt/src/ExpiredException.php' );
require_once( BEMAVERICK_ROOT_DIR . '/vendor/firebase/php-jwt/src/SignatureInvalidException.php' );

require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/UserInterface.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/ClientInterface.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/AccessTokenManager.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/GrantTypeClientCredentials.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/GrantTypeUserCredentials.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/GrantTypeRefreshToken.php' );

require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/Pdo.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/StorageClientCredentials.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/StorageUserCredentials.php' );
?>
