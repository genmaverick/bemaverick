<?php
/**
 * Sly
 *
 * @category   Sly
 * @package    Sly
 */

require_once( SLY_ROOT_DIR . '/lib/Sly/Thread.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Thread/Worker.php' );

/**
 * Class for managing running offline processes
 *
 * This class is designed to run on a single host machine or manage multiple
 * multi process controllers on different host machines.  It will use 
 * Sly_Thread_Worker threads to perform the actual command.  The
 * threads will be broken up by the start end and settings.
 * NOTE: Currently only single processor is implemented.
 *
 * @category Sly
 * @package Sly
 * @subpackage Sly_Thread
 */
class Sly_MultiProcessMaster
{
    /**
     * @var Sly_Log
     * @access protected
     */
    protected $_logger;

    /**
     * @var hash
     * @access protected
     */
    protected $_settings;
    
    /**
     * Class constructor
     *
     * @param Sly_Log $logger
     * @param hash $settings The settings hash can contain any of the following:
     *                       ['maxThreads'] => max number of threads per host
     *                       ['hosts'] => array of available hosts
     *                       ['minElements'] => number of elements to run in a
     *                                          single thread before splitting
     *                       ['maxElements'] => maximum number of elements to 
     *                                          run at a time in a single thread
     *                       ['hostCommand'] => script to launch master on new
     *                                          host
     *                       ['threadCommand'] => script to launch worker on
     *                                            same host
     *                       ['maxCommandElements'] => maximum number of 
     *                                                 elements to include on
     *                                                 the command line
     *                       ['tempDir'] => directory for command files
     *                       ['monitorPeriod'] => number of milliseconds to wait 
     *                                            between checks on threads
     *                       ['restartLimit'] => max number of tries for a 
     *                                           single thread.
     *                       ['errorEmail'] => Sly_Email object
     * @return void
     */
    public function __construct( $logger, $settings = array () )
    {
        $this->_logger = $logger;
        
        $settings = $this->setDefaultSettings( $settings );
        
        $this->_settings = $settings;
    }
    
    /**
     * Set the default settings if they are not set
     *
     * @param hash $settings The settings hash will contain the following:
     *                       [setting] => value
     *                       ex. ['maxThreads'] => 5
     * @return hash The returned hash will contain the adjusted settings
     */
    protected function setDefaultSettings( $settings )
    {
        // threads
        if ( ! isset( $settings['maxThreads'] ) ) {
            $settings['maxThreads'] = 5;
        }
        
        // min elements
        if ( ! isset( $settings['minElements'] ) ) {
            $settings['minElements'] = 100;
        }
        
        // max elements
        if ( ! isset( $settings['maxElements'] ) ) {
            $settings['maxElements'] = 100;
        }
        
        // min can not exceed max
        if ( $settings['minElements'] > $settings['maxElements'] ) {
            $settings['minElements'] = $settings['maxElements'];
        }
        
        // host command
        if ( ! isset( $settings['hostCommand'] ) ) {
            // TODO make this more generic
            $settings['hostCommand'] = 'cd /home/clinto/dev/nfl/trunk/bin; php run_multiProcessMaster.php --log';
        }
        
        // thread command
        if ( ! isset( $settings['threadCommand'] ) ) {
            // TODO make this more generic
            $settings['threadCommand'] = 'cd /home/clinto/dev/nfl/trunk/bin; php run_multiProcessWorker.php --log';
        }

        // max command elements
        if ( ! isset( $settings['maxCommandElements'] ) ) {
            $settings['maxCommandElements'] = 50;
        }
        
        // temp directory
        if ( ! isset( $settings['tempDir'] ) ) {
            $settings['tempDir'] = '/tmp';
        }
        
        // restart limit
        if ( ! isset( $settings['restartLimit'] ) ) {
            $settings['restartLimit'] = 3;
        }
 
        // monitor period
        if ( ! isset( $settings['monitorPeriod'] ) ) {
            $settings['monitorPeriod'] = 500000; // 0.5 sec
        }
                        
        // default for hosts is not set
        // default for errorEmail is not set
        
        return $settings;
    }
        
    /**
     * Run process according to settings
     *
     * Runs the process for all objects using the settings.  Return if
     * processing was successfull.  The function must recieve a start and end, a
     * list of elements, or a filename to get a list of elements from.
     *
     * @param string $command
     * @param integer $start
     * @param integer $end
     * @param array $elementList
     * @param string $filename Name of file to get list from
     * @return integer Returns 0 if successfull
     *                 -1 if unrecovered errors
     *                 -2 for invalid parameters
     */
    public function runProcess( $command, $start, $end, $elementList = null, $filename = null )
    {
        // check parameters
        if ( ($start === null || $end === null) &&
             $elementList === null && $filename === null ) {
            $this->_logger->err( "Insufficient element parameters" );
            return -2;
        }
        
        if ( $start > $end ) {
            $this->_logger->err( "Start cannot be greater than end" );
            return -2;
        }
        
        if ( isset( $this->_settings['hosts'] ) ) {
            return runProcessHosts( $command, $start, $end, $elementList, $filename );
        }
        
        // split the elements into chunks
        $chunks = array();
        
        if ( $start !== null && $end !== null ) {
                
            // get the target elements for each thread
            $threadElements = ceil( ( $end - $start + 1 ) / $this->_settings['maxThreads'] );
            $threadElements = ( $threadElements < $this->_settings['minElements'] ) ? $this->_settings['minElements'] : $threadElements;
            $threadElements = ( $threadElements > $this->_settings['maxElements'] ) ? $this->_settings['maxElements'] : $threadElements;
            
            $chunkStart = $start;
            
            while( $chunkStart <= $end ) {
                $chunkEnd = $chunkStart + $threadElements - 1;
                $chunkEnd = ( $chunkEnd <= $end ) ? $chunkEnd : $end;
                
                $chunk['start'] = $chunkStart;
                $chunk['end'] = $chunkEnd;
                $chunk['elements'] = null;
                $chunk['filename'] = null;
                
                $chunks[] = $chunk;
                
                $chunkStart = $chunkEnd + 1;
            }
       
        }
        else {
            
            // get array of elements 
            if ( $elementList === null ) {
                $elementList = explode( ',', file_get_contents( $filename ) );
            }
            
            $threadElements = ceil( count( $elementList ) / $this->_settings['maxThreads'] );

            $threadElements = $threadElements < $this->_settings['minElements'] ?
                              $this->_settings['minElements'] :
                              $threadElements;

            $threadElements = $threadElements > $this->_settings['maxElements'] ?
                              $this->_settings['maxElements'] :
                              $threadElements;
            
            $chunkStart = 0;
            
            while( $chunkStart <= count( $elementList ) ) {
                $chunk['start'] = null;
                $chunk['end'] = null;
                
                if ( $threadElements <= $this->_settings['maxCommandElements'] ) {
                    $chunk['elements'] = array_slice( $elementList, $chunkStart, $threadElements );
                    $chunk['filename'] = null;
                }
                else {
                    $filename = tempnam( $this->_settings['tempDir'], 'SLY_MPE' );
                    file_put_contents( $filename, implode( ',', array_slice( $elementList, $chunkStart, $threadElements ) ) );
                    
                    $chunk['elements'] = null;
                    $chunk['fileName'] = $filename;
                }
                
                $chunks[] = $chunk;
                
                $chunkStart += $threadElements;
            }                
                            
        }
        
        // debug
        //print_r( $chunks );
        //exit( -1 );
        
        // get the number of threads
        $threadCount = ( count( $chunks ) > $this->_settings['maxThreads'] ) ?
                       $this->_settings['maxThreads'] :
                       count( $chunks );
        
        // debug
        $chunkCount = count( $chunks );
        $this->_logger->info( "chunk Count: $chunkCount, threadCount: $threadCount" );
        
        $threads = array();
        
        // launch the threads
        for( $i = 1; $i <= $threadCount; $i++ ) {
            $threadInfo['thread'] = new Sly_Thread_Worker( $this->_settings['threadCommand'] );
            
            $threads[] = $threadInfo;
        }
        
        $errorCount = 0;
        $complete = false;
        $success = true;
        
        // monitor the threads until they all complete
        while ( count( $threads ) > 0 ) {
        
            foreach( $threads as $key => $thread ) {
                
                $error = $thread['thread']->getStderr();
                if ( $error != '' ) {
                    $this->_logger->err( "Error: $error" );
                }      
                
                if ( $thread['thread']->isActive() ) {
                    $status = $thread['thread']->getStatus();
                    
                    // debug
                    //$this->_logger->info( "Status: $status" );
                    
                    switch( $status ) {
                        case 'done':
                            // delete temp file if any
                            if ( $thread['chunk']['filename'] !== null ) {
                                unlink( $thread['chunk']['filename'] );
                            }
                        case 'ready':
                            // get next chunk or close thread
                            if ( count( $chunks ) == 0 ) {
                                $thread['thread']->endClose();
                                unset( $threads[$key] );
                                continue;
                            }
                            
                            $chunk = array_shift( $chunks );
                            
                            $thread['thread']->runCommand( $command,
                                                           $chunk['start'],
                                                           $chunk['end'],
                                                           $chunk['elements'],
                                                           $chunk['filename'] );

                            $threads[$key]['chunk'] = $chunk;
                            
                            $this->_logger->info( "Sending command: $command " .
                                                  "start: {$chunk['start']} " .
                                                  "end: {$chunk['end']} " .
                                                  "elements: {$chunk['elements']}" .
                                                  "filename: {$chunk['filename']}" );
                            
                            break;
                    }
                    
                }
                else {
                    
                    // thread fatally terminated.
                    $terminationStatus = $thread['thread']->close();
                    
                    if ( $errorCount++ > $this->_settings['restartLimit'] ) {
                        $this->_logger->alert( "Exceeded restart limit.  Not restarting." );
                        
                        // send email
                        if ( isset( $this->_settings['errorEmail'] ) ) {
                            $this->_settings['errorEmail']->sendErrorEmail( "Critical Error running command: $command",
                                            array( "Exceeded restart count with command: $command.",
                                                   "Not Restarting!" ) );
                        }

                        // delete temp file if any
                        if ( $thread['chunk']['filename'] !== null ) {
                            unlink( $thread['chunk']['filename'] );
                        }     
                                           
                        unset( $threads[$key] );
                        $success = false;                        
                    }
                    else {
                        $this->_logger->err( "There was an error. Restarting." );
                        
                        $threads[$key]['thread'] = new Sly_Thread_Worker( $this->_settings['threadCommand'] );
                        
                        // push the chunk back onto the queue
                        if ( isset( $threads[$key]['chunk'] ) ) {
                            array_unshift( $chunks, $threads[$key]['chunk'] );
                            unset( $threads[$key]['chunk'] );
                        }

                    }

                }

            }
            
            usleep( $this->_settings['monitorPeriod'] );
        
        }        
        
        return ( $success ) ? 0 : -1;
        
    }
    
    /**
     * Run the process on multiple hosts
     *
     * This function is not called directly.  Use runProcess.
     *
     * @param string $command
     * @param integer $start
     * @param integer $end
     * @return integer Returns 0 if successfull and -1 if unrecovered errors
     */
    protected function runProcessHosts( $command, $start, $end )
    {
            $hostCommand = $this->_settings['hostCommand'];
            
            // divide task among processors
            $countHosts = count( $this->_settings['hosts'] );
            $hostElements = ceil ( ( $end - $start + 1 ) / $countHosts );
            
            $hostElements = ( $hostElements < $this->_settings['minElements'] ) ? $this->_settings['minElements'] : $hostElements;
            
            foreach( $this->_settings['hosts'] as $host ) {
                if ( $start > $end ) {
                    break;
                }
                
                $hostEnd = $start + $hostElements - 1;
                $hostEnd = ( $hostEnd > $end ) ? $end : $hostEnd;
                
                $settings = serialize( $this->_settings );
                
                $commands[] = "ssh $host; " . 
                              "$hostCommand --command $command --start $start --end $hostEnd --settings $settings";
                
                $start = $hostEnd + 1;
            } 
            
            return $this->runCommands( $commands );
    }
    
    /**
     * Run an array of commands each in their own thread
     *
     * Will monitor the commands and attempt to resolve any issues.  Will return
     * true if all commands complete successfully.  This command will ignore
     * the maxThreads setting and run one thread for each command.
     * 
     * @param array $commands
     * @return integer Returns 0 if successfull and -1 if unrecovered errors
     */
    public function runCommands( $commands )
    {
        $success = true;
        
        $threads = array();
        
        // launch a thread for all the commands
        foreach( $commands as $command ) {
            $threadInfo['command'] = $command;
            $threadInfo['errorCount'] = 0;
            $threadInfo['thread'] = new Sly_Thread( $command );
            
            $this->_logger->info( "Launched thread for command: $command" );
            
            $threads[] = $threadInfo;
        }
        
        // monitor the threads until they all complete
        while ( count( $threads ) > 0 ) {
        
            foreach( $threads as $key => $thread ) {
                
                // if not active
                if ( ! $thread['thread']->isActive() ) {
                    $command = $thread['command'];
                    $terminationStatus = $thread['thread']->close();
                    
                    if ( $terminationStatus == 0 ) {
                        $this->_logger->info( "Successfully Finished command: $command" );
                        unset( $threads[$key] );
                    } 
                    else {
                        // debug
                        $this->_logger->err( "Command: $command returned: $terminationStatus");
                        
                        $threads[$key]['errorCount']++;
                        if ( $threads[$key]['errorCount'] < $this->_settings['restartLimit'] ) {
                            $this->_logger->err( "There was an error with command: $command.  Restarting." );
                            
                            $threads[$key]['thread'] = new Sly_Thread( $command );
                        } 
                        else {
                            $this->_logger->alert( "Exceeded restart count with command: $command. Not Restarting!" );
                            
                            // send email
                            if ( isset( $this->_settings['errorEmail'] ) ) {
                                $this->_settings['errorEmail']->sendErrorEmail( "Critical Error running command: $command",
                                                array( "Exceeded restart count with command: $command.",
                                                       "Not Restarting!" ) );
                            }
                            
                            unset( $threads[$key] );
                            $success = false;
                        }
                    }
                    
                    
                }
                else {
                    $error = $thread['thread']->getStderr();
                    if ( $error != '' ) {
                        $this->_logger->err( "Command: $command -- $error" );
                    }
                }
            }
            
            // wait monitor period
            usleep( $this->_settings['monitorPeriod'] );
        
        }
        
        return ( $success ) ? 0 : -1;  
                     
    }

}

?>
