<?php

require_once( '../../config/setup_environment.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/S3.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/Transcoder.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
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

    $filename = $options->filename;

    $config = $site->getAmazonConfig();

    $pipelineId = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_PIPELINE_ID' );
    $presetId = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_RESPONSE_PRESET_ID' );

    BeMaverick_AWSTranscoder::startJob( $filename, $pipelineId, $presetId, $config );

    $logger->end();
}
catch( Exception $e ) {
    $logger->err( $e->getMessage() );
    print $e->getMessage();
    exit( 1 );
}

exit( 0 );

?>
