<?php

require_once( '../../config/setup_environment.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/S3.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
            'username=s'  => '[Required] The username of the kid',
            'parent_email_address=s' => '[Required] The parent email address',
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

    $username = $options->username;
    $password = 'test';
    $parentEmailAddress = $options->parent_email_address;
    $birthdate = '2005-04-13';
    $emailAddress = null;

    $user = $site->createKid( $username, $password, $birthdate, $emailAddress, $parentEmailAddress );

    $logger->end();
}
catch( Exception $e ) {
    $logger->err( $e->getMessage() );
    print $e->getMessage();
    exit( 1 );
}

exit( 0 );

?>
