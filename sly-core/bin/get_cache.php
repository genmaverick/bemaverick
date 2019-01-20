<?php
$home = getenv('SITE_HOME');
if (empty($home)) {
    echo "Must set SITE_HOME environment variable.\n";
    exit(1);
}

require_once( $home . '/config/setup_environment.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/CacheTags.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
            'key|k=s' => '[Required] The key inside the cache',
        )
    );

    $options->parse();
}
catch( Zend_Console_Getopt_Exception $e ) {
    print $e->getUsageMessage();
    exit;
}

$cache = Zend_Registry::get( 'cache' );
print 'Cache class: ' . get_class( $cache ) . "\n";
var_dump( $cache->inspectKey( $options->key ) );

?>
