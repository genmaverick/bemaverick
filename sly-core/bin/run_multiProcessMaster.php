<?php
/**
 * Sly Trunk
 *
 * Script to run a MultiProcessMaster thread.  This thread will be run once on
 * each host to start a new MultiProcessMaster.  This script should be used as a
 * template for project specific scripts.
 *
 * @category Sly
 * @package Sly
 */

require_once( '../config/setup_environment.php' ); 
require_once( SLY_ROOT_DIR . '/lib/Sly/MultiProcessMaster.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
            'log' => '[Optional] Set for logging output to log file',
            'command|c=s' => '[Required] Command to run',
            'start|s=i' => '[Required] Start element',
            'end|e=i' => '[Required] End element'
            'settings=s' => '[Required] Serialized string of settings'
        )
    );

    $options->parse();
}
catch( Zend_Console_Getopt_Exception $e ) {
    print $e->getUsageMessage();
    exit;
}

$logger = new Sly_Log( $options );
$logger->start();

$settings = unserialize( $options->settings );

$master = new Sly_MultiProcessMaster( $logger, $settings );

$err = $processMaster->RunProcess( $options->command, $options->start, $options->end );

$logger->end();

exit( $err );

?>