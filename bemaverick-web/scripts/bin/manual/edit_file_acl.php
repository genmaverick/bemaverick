<?php

require_once( '../../config/setup_environment.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/S3.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
            'filename=s'  => '[Required] The filename in the bucket',
            'bucket=s'    => '[Required] The bucket of the file',
            'acl=s'       => '[Required[ The acl of the file',
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
    $bucketName = $options->bucket;
    $acl = $options->acl;

    Sly_Service_Amazon_S3::editFileACL( $filename, $bucketName, $acl, $config );

    $logger->end();
}
catch( Exception $e ) {
    $logger->err( $e->getMessage() );
    print $e->getMessage();
    exit( 1 );
}

exit( 0 );

?>
