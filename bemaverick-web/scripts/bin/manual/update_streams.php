<?php

require_once( '../../config/setup_environment.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
            'file=s'  => '[Required] The config file to load for the streams',
            'log'     => '[Optional] Set for logging output to log file',
        )
    );

    $options->parse();
}
catch( Zend_Console_Getopt_Exception $e ) {
    print $e->getUsageMessage();
    exit( 1 );
}

$logger = new Sly_Log( $options );

try {

    $logger->start();

    if ( ! $options->file ) {
        $logger->crit( "You must specify --file <file>" );
        exit( 1 );
    }

    $site = Zend_Registry::get( 'site' );               /* @var BeMaverick_Site $site */

    $daStream = BeMaverick_Da_Stream::getInstance();

    $jsonConfig = file_get_contents( $options->file );

    $streamsDefinition = json_decode( $jsonConfig, true );

    // first delete all the streams and we want to have the auto-increment start over as well
    $daStream->truncate();

    // add all the streams in the order we got them in the json file
    $sortOrder = 1;
    foreach ( $streamsDefinition as $streamDefinition ) {

        $label = $streamDefinition['label'];

        $site->createStream( $label, $streamDefinition, $sortOrder );
    }

    $logger->end();
}
catch( Exception $e ) {
    $logger->err( $e->getMessage() );
    print $e->getMessage();
    exit( 1 );
}

exit( 0 );

?>
