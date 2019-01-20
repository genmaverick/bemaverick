<?php
require_once( '../scripts/config/setup_environment.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
            'environment|e=s'     => '[Required] The environment to install on',
            'source_file=s'       => '[Required] The source file',
            'host|h=s'            => '[Optional] The host to push to',
        )
    );

    $options->parse();
}
catch( Zend_Console_Getopt_Exception $e ) {
    print $e->getUsageMessage();
    exit( 1 );
}

if ( ! $options->source_file ) {
    print "usage: php push_file.php --source_file blah\n\n";
    print "List of codes\n";
    print "----------------\n";
    print "zend\nsly\ncommon";
    exit( 1 );
}

$ENVIRONMENT_TO_USER = array(
    'production' => 'bemaverick',
    'stage' => 'bemaverick',
);

$ENVIRONMENT_TO_HOSTS = array(
    'production' => array(
        'www01.usw1c.prd.bemaverick.com',
        'www02.usw1c.prd.bemaverick.com',
    ),
    'stage' => array(
        'www01.usw1c.stg.bemaverick.com',
    ),
);

$sourceFile = $options->source_file;
$environment = $options->environment ? $options->environment : 'production';

$sourceRealPath = realpath( $sourceFile );

$destinationFile = preg_replace( "/^.*\/dev\/bemaverick-web/", 'files/bemaverick', $sourceRealPath );

// get the user for this environment
$user = $ENVIRONMENT_TO_USER["$environment"];

// get the hosts
$hosts = $ENVIRONMENT_TO_HOSTS["$environment"];
if ( $options->host ) {
   $hosts = array( $options->host );
}

// we need the first host to get the file to compare
$firstHost = $hosts[0];

// get the current file and put in tmp directory
$basename = basename( $destinationFile );
system( "scp -p $user@$firstHost:$destinationFile /tmp/$basename.$firstHost" );

// do the diff
$diff = `diff /tmp/$basename.$firstHost $sourceFile`;

if ( ! $diff ) {
    print "no diff, not pushing\n";
    //exit( 0 );
}

print "$diff\n";
print "Do you want to push file (y|n)? ";

$fh = fopen( 'php://stdin', 'r' );
$input = fgets( $fh );

if ( trim( $input ) != 'y' ) {
    print "not pushing\n";
    exit( 0 );
}

foreach( $hosts as $host ) {

    print "scp -p $sourceFile $user@$host:$destinationFile\n";
    system( "scp -p $sourceFile $user@$host:$destinationFile" );
}

unlink( "/tmp/$basename.$firstHost" );

exit( 0 );
