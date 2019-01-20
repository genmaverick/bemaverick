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
            'tag|t-s' => '[Optional] The cache tag to clear',
            'key|k-s' => '[Optional] The cache key to clear',
            'all|a' => '[Optional] Clear the entire cache',
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

$cacheTags = Sly_CacheTags::getInstance( $cache );

if ( $options->tag ) {
    $tag = $options->tag;

    print "clear_cache: clearing 1 tag: $tag\n";
    $cacheTags->clearCacheIdsByTags( array( $tag ) );
}

if ( $options->key ) {
    $key = $options->key;

    print "clear_cache: clearing 1 key: $key\n";
    $cache->remove( $key );
}

if ( $options->all ) {
    print "clear_cache: clearing entire cache\n";
    $cache->clean();
}

?>
