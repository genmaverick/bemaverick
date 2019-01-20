<?php
/**
 * Sly Trunk
 *
 * Script to run a MultiProcessWorker thread.  This script should be used as a 
 * template for project specific scripts.
 *
 * @category Sly
 * @package Sly
 */

require_once( '../config/setup_environment.php' ); 
require_once( SLY_ROOT_DIR . '/lib/Sly/MultiProcessWorker.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
            'log' => '[Optional] Set for logging output to log file',
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

$settings['timeout'] = 90;
$settings['monitorPeriod'] = 1;

$worker = new Sly_MultiProcessWorker( $logger, $settings );

$err = $worker->runLoop();

$logger->end();

exit( $err );
?>