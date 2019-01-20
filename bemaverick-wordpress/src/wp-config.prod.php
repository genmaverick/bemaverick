<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //

/** The name of the database for WordPress */
define( 'DB_NAME', 'database_name_here' );

/** MySQL database username */
define( 'DB_USER', 'username_here' );

/** MySQL database password */
define( 'DB_PASSWORD', 'password_here' );

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/** Amazon Config */
define( 'AS3CF_AWS_ACCESS_KEY_ID',     'AKIAJCP6YMG3AEIE7WYA' );
define( 'AS3CF_AWS_SECRET_ACCESS_KEY', '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' );

/** Wordpress Address */
define('WP_HOME','https://wordpress.genmaverick.com');
define('WP_SITEURL','https://wordpress.genmaverick.com');
define('WP_CONTENT_URL','https://wordpress.genmaverick.com/wp-content');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '93c3e0cc3e3e4e2cf59d1dcb670f787707f63b22');
define('SECURE_AUTH_KEY',  'beb9212e0b584c080f7974d9d3f9440731cec7b0');
define('LOGGED_IN_KEY',    '494fc2dcf42bd8ad376495b0497e10aae74a561c');
define('NONCE_KEY',        'f0d15bea693bf8d0a6f44bf88d8a4443e4f690b9');
define('AUTH_SALT',        '5c2e421a6eb889fa04e3970058a442787fe17fad');
define('SECURE_AUTH_SALT', 'b73890bbcb8d5dd09059ec39451860872459f6eb');
define('LOGGED_IN_SALT',   '1d6d3e012d895dc52d16a34d1e572a198a194929');
define('NONCE_SALT',       'f8cf9b555e8d70348d16b9fecc6533456248bacd');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', false);

// If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact
// see also http://codex.wordpress.org/Administration_Over_SSL#Using_a_Reverse_Proxy
// if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
	$_SERVER['HTTPS'] = 'on';
// }

define( 'FORCE_SSL_LOGIN', false );
define( 'FORCE_SSL_ADMIN', false );

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
