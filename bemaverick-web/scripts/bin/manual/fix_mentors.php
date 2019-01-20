<?php

require_once( '../../config/setup_environment.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log.php' );

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

    $daUser = BeMaverick_da_Mentor::getInstance();

    $rows = $daUser->fetchRows( "select * from mentor" );

    foreach ( $rows as $row ) {

        $mentorId = $row['mentor_id'];
        $firstName = $row['first_name'];
        $lastName = $row['last_name'];
        $shortDescription = $row['short_description'];
        $profileImageId = $row['profile_image_id'];

        $profileImage = $site->getImage( $profileImageId );

        $username = strtolower( $firstName . '_' . $lastName );

        $mentor = $site->createMentor( $username, 'test123', $firstName, $lastName );
        $mentor->setShortDescription( $shortDescription );
        $mentor->setProfileImage( $profileImage );

        $userId = $mentor->getId();

        $daUser->query( "update challenge set user_id = $userId where mentor_id = $mentorId" );
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
