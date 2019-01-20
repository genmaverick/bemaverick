<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Thread.php' );

/**
 * Class to start and manage a single thread of a multiProcess workflow
 *
 * This class will run a single process of a multiProcess function.  This 
 * process will be kicked off and run from a Sly_MultiProcessMaster object.  The
 * master object will use Sly_Thread_Worker objects to communicate to the 
 * threads.
 *
 * @description This class will launch new threads
 * @category Sly
 * @package Sly
 * @subpackage Sly_Thread
 */
class Sly_MultiProcessWorker 
{
    /**
     * @var hash
     * @access protected
     */
    protected $_logger;
    
    /**
     * @var hash
     * @access protected
     */
    protected $_settings;
    
    /**
     * @var stream
     * @access protected
     */
    protected $_inputStream;
    
    /**
     * @var stream
     * @access protected
     */
    protected $_outputStream;
    
    /**
     * Class Constructor
     *
     * @param Sly_Logger $logger
     * @param hash $settings The settings hash will contain the following:
     *                       ['timeout'] => max time to wait for new commands
     *                       ['monitorPeriod'] => number of seconds to wait 
     *                                            between checks for commands
     * @return null
     */
    public function __construct( $logger, $settings = array() ) 
    {
        $this->_logger = $logger;
        
        $this->_settings = $this->setDefaultSettings( $settings );
        
        // set the input stream to not block (for timeout)
        $this->_inputStream = fopen( "php://stdin", "r" );
        stream_set_blocking( $this->_inputStream, 0 );
        
        $this->_outputStream = fopen( "php://stdout", "w" );
    }
        
    /**
     * Run the main process loop
     *
     * The thread script should create a worker object and then run this 
     * function.  The function will continue to loop running commands until it
     * recieves an 'end' command.  Commands to the loop should be sent through 
     * the master functions from the MultiProcessMaster.
     *
     * @return integer Returns 0 if terminated from a command and -1 if
     *                 the loop terminated from a timeout.
     */
    public function runLoop()
    {
        $this->_logger->info( "Starting runLoop" );
        
        $lastTime = time();
        
        $this->setStatus( 'ready' );
        
        // run the main loop
        while( time() < $lastTime + $this->_settings['timeout'] ) {
            $command = $this->getCommand();
            
            $words = explode( " ", $command );
            
            switch( $words[0] ) {
                case 'end':
                    $this->_logger->info( "Exiting runLoop" );
                    
                    // return from function
                    return 0;
                case 'run':
                    $runCommand = substr( $command, 4 );
                    
                    $this->_logger->info( "Running command: $runCommand" );
                    
                    exec( $runCommand );
                    
                    $this->setStatus( 'done' );
                    
                    // reset the timeout timer
                    $lastTime = time();
                    break;
            }
            
            // wait monitorPeriod
            sleep( $this->_settings['monitorPeriod'] );
            
        }
        
        // should only reach here on a timeout
        $this->_logger->info( "RunLoop timed out" );
        return -1;    
        
    }
    
    
    /**
     * Set the default settings if they are not set
     *
     * @param hash $settings The settings hash will contain the following:
     *                       [setting] => value
     *                       ex. ['timeout'] => 90
     * @return hash The returned hash will contain the adjusted settings
     */
    protected function setDefaultSettings( $settings )
    {    
        // timeout
        if ( ! isset( $settings['timeout'] ) ) {
            $settings['timeout'] = 90;
        }
        
        // monitorPeriod
        if ( ! isset( $settings['monitorPeriod'] ) ) {
            $settings['monitorPeriod'] = 1;
        }
        
        return $settings;
    }
    
    /**
     * Set the status
     *
     * This function is run from the worker thread.  At this point it just
     * prints the status to stdout.
     *
     * @param string $status
     * @return void
     */
    public function setStatus( $status )
    {
        // add a cariage return
        $status .= "\n";
        
        fwrite( $this->_outputStream, $status );
    }
    
    /**
     * Get a command string
     *
     * This function is run from the worker thread.  At this point it just gets
     * a string from stdin
     *
     * @return string
     */
    public function getCommand()
    {
        return rtrim( fgets( $this->_inputStream ) );
    }
}

?>