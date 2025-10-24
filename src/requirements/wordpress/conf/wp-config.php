<?php
define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'wp_user' );
define( 'DB_PASSWORD', 'wp_pass' );
define( 'DB_HOST', 'mariadb:3306' );

define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );

define( 'AUTH_KEY',         'putyouruniquephrasehere' );
define( 'SECURE_AUTH_KEY',  'putyouruniquephrasehere' );
define( 'LOGGED_IN_KEY',    'putyouruniquephrasehere' );
define( 'NONCE_KEY',        'putyouruniquephrasehere' );
define( 'AUTH_SALT',        'putyouruniquephrasehere' );
define( 'SECURE_AUTH_SALT', 'putyouruniquephrasehere' );
define( 'LOGGED_IN_SALT',   'putyouruniquephrasehere' );
define( 'NONCE_SALT',       'putyouruniquephrasehere' );

$table_prefix = 'wp_';
define( 'WP_DEBUG', false );

if ( !defined('ABSPATH') )
	define('ABSPATH', __DIR__ . '/');
require_once ABSPATH . 'wp-settings.php';
