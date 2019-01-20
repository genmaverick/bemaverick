<?php

require_once( '../../config/setup_environment.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/S3.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
            'file=s'      => '[Required] The video file to upload',
            'filename=s'  => '[Required] The video filename to put into the bucket',
            'log'         => '[Optional] Set for logging output to log file',
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

    $site = Zend_Registry::get( 'site' );
    $systemConfig = Zend_Registry::get( 'systemConfig' );

    $config = $site->getAmazonConfig();

    $filename = $options->filename;

    $fileContents = file_get_contents( $options->file );

    $bucketName = $systemConfig->getSetting( 'AWS_S3_VIDEO_INPUT_BUCKET_NAME' );

    Sly_Service_Amazon_S3::putFileContents( $fileContents, $filename, $bucketName, $config );

    $logger->end();
}
catch( Exception $e ) {
    $logger->err( $e->getMessage() );
    print $e->getMessage();
    exit( 1 );
}

exit( 0 );

?>
