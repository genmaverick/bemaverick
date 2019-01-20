<?php

require_once( '../../config/setup_environment.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/S3.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/Transcoder.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
            'username=s'  => '[Required] The username of the kid',
            'challenge=s' => '',
            'filename=s'  => '',
            'file=s'      => '',
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

    $amazonConfig = $site->getAmazonConfig();

    // get the variables
    $user = $site->getUserByUsername( $options->username );
    $challengeId = $options->challenge;
    $filename = $options->filename;

    // get the video response and upload it to S3
    $fileContents = file_get_contents( $options->file );
    $bucketName = $systemConfig->getSetting( 'AWS_S3_VIDEO_INPUT_BUCKET_NAME' );
    Sly_Service_Amazon_S3::putFileContents( $fileContents, $filename, $bucketName, $amazonConfig );

    // create the video
    $video = $site->createVideo( $filename );

    // add the response
    $challenge = $site->getChallenge( $challengeId );
    $challenge->addResponse( BeMaverick_Response::RESPONSE_TYPE_VIDEO, $user, $video );

    // start transcoding
    $pipelineId = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_PIPELINE_ID' );
    $presetId = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_RESPONSE_PRESET_ID' );
    BeMaverick_AWSTranscoder::startJob( $filename, $pipelineId, $presetId, $amazonConfig );

    $logger->end();
}
catch( Exception $e ) {
    $logger->err( $e->getMessage() );
    print $e->getMessage();
    exit( 1 );
}

exit( 0 );

?>
