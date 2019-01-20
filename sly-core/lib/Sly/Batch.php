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
class Sly_Batch
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
     * @var GearmanClient
     * @access protected
     */
    protected $_client;
        
    /**
     * @var array
     * @access protected
     */
    protected $_tasks;
        
    /**
     * @var integer
     * @access protected
     */
    protected $_errors;
    
    /**
     * Class constructor
     *
     * @param Sly_Log $logger
     * @param hash $settings The settings hash can contain any of the following:
     *                       ['maxElements'] => maximum number of elements to 
     *                                          run at a time in a single chunk
     *                       ['monitorPeriod'] => number of milliseconds to wait 
     *                                            between checks on jobs
     *                       ['restartLimit'] => max number of tries for a 
     *                                           single job. [not used]
     *                       ['taskServers'] => array of hash of task Servers
     *                                          server hash contains
     *                                          'host' => IP
     *                                          'port' => port (default to 4730)
     *                       ['outputFile'] => file to dump task output into
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
        // max elements
        if ( ! isset( $settings['maxElements'] ) ) {
            $settings['maxElements'] = 300;
        }
        
        // restart limit
        if ( ! isset( $settings['restartLimit'] ) ) {
            $settings['restartLimit'] = 3;
        }
 
        // monitor period
        if ( ! isset( $settings['monitorPeriod'] ) ) {
            $settings['monitorPeriod'] = 500000; // 0.5 sec
        }
                        
        // taskServers defaults to not set
                        
        // errorEmail defaults to not set
        
        // ouputFile defaults to not set
        
        return $settings;
    }
        
    /**
     * Get the client.  Initialize if needed.
     *
     * @return GearmanClient
     */
    public function getClient()
    {
        if ( $this->_client ) {
            return $this->_client;
        }
        
        $this->_client = new GearmanClient();
        //$this->_client->setTimeout( 1000 ); // one sec
        
        if ( isset ( $this->_settings['taskServers'] ) ) {
            
            foreach( $this->_settings['taskServers'] as $server ) {
                $host = $server['host'];
                if ( isset( $server['port'] ) ) {
                    $port = $server['port'];
                }
                else {
                    $port = 4730;
                }
                
                $this->_client->addServer( $host, $port );

            }
            
        }
        else {
            // use default client settings
            $this->_client->addServer();             
        }

        // test server response
        // shawnr - 2017-01-09 - echo is no longer available in gearman version we have
        //if ( ! $this->_client->echo( 'test' ) ) {
        //    $this->_logger->err( 'No response from gearman server(s)' );
        //    $this->_client = false;
        //    return false;
        //}
        
        // reset timeout
        $this->_client->setTimeout( -1 ); // infite
        
        // register completed callback
        $this->_client->setCompleteCallback( array( 'Sly_Batch', 'taskCompleteCallback' ) );
        
        // register fail callback
        $this->_client->setFailCallback( array( 'Sly_Batch', 'taskFailCallback' ) );
        
        // register data callback
        $this->_client->setDataCallback( array( 'Sly_Batch', 'taskDataCallback' ) );
        
        return $this->_client;
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
            
        // get task client
        $client = $this->getClient();
        
        if ( $client === false ) {
            return -1;
        }
        
        $workload['command'] = $command;
        
        $jobId = rand(1,100000000);
        
        $this->_tasks = array();
        $this->_errors = false;
                    
        // parse data from file seperately to avoid memory issues
        if ( $filename ) {
            
            $chunkSize = $this->_settings['maxElements'];
            
            $fileRef = fopen( $filename, 'r' );
            
            if ( ! $fileRef ) {
                $this->_logger->err( "Cannot open file: $filename" );
                return -1;
            }
            
            while( ! feof( $fileRef ) ) {
                $count = 0;
                $elements = array();
                
                // get rows
                while ( ! feof( $fileRef ) && $count++ <= $chunkSize ) {
                    $element = fgets( $fileRef );
                    $element = rtrim( $element );
                    $elements[] = $element;
                }
                
                $workload['elements'] = $elements;
                $description = $this->getTaskDescription( $jobId, $workload, false );
                $this->_tasks[$jobId]['description'] = $description;            
                $this->_logger->info( "Adding task: $description" );
                $client->addTask( "runScript", serialize( $workload ), $this, $jobId++ );
            }
            
            fclose( $fileRef );
        }
        else {
            
            // split the elements into chunks
            $chunks = array();
            
            if ( $start !== null && $end !== null ) {
                    
                // get the target elements for each thread
                $chunkSize = $this->_settings['maxElements'];
                
                $chunkStart = $start;
                
                while( $chunkStart <= $end ) {
                    $chunkEnd = $chunkStart + $chunkSize - 1;
                    $chunkEnd = ( $chunkEnd <= $end ) ? $chunkEnd : $end;
                    
                    $chunks[] = range( $chunkStart, $chunkEnd );
                    
                    $chunkStart = $chunkEnd + 1;
                }
           
            }
            else {
                
                $chunkSize = $this->_settings['maxElements'];
                
                $chunkStart = 0;
                
                while( $chunkStart < count( $elementList ) ) {
                    $chunks[] = array_slice( $elementList, $chunkStart, $chunkSize );
                    
                    $chunkStart += $chunkSize;
                }
                                
            }

            $showAllElements = ( count( $chunks ) * $chunkSize < 1000 );
            
            foreach( $chunks as $chunk ) {
                $workload['elements'] = $chunk;
                $description = $this->getTaskDescription( $jobId, $workload, $showAllElements );
                $this->_tasks[$jobId]['description'] = $description;            
                $this->_logger->info( "Adding task: $description" );
                $client->addTask( "runScript", serialize( $workload ), $this, $jobId++ );
            }
        }
        
        $this->_logger->info( "Running tasks" );
        
        if ( ! $client->runTasks() ) {
            $this->_logger->err( "Timeout handing off tasks.  Either server failure or no workers." );
            return -1;
        }
        
        // monitor jobs until complete
        while( count( $this->_tasks ) > 0 ) {
            sleep( $this->_settings['monitorPeriod'] );
        }
        
        // report success / failure
        return ( $this->_errors ) ? -1 : 0;
    }

    /**
     * Get a description of the task for logging
     *
     * @param integer $jobId
     * @param hash $workload
     * @return string
     */
    public function getTaskDescription( $jobId, $workload, $showAllElements )
    {
        $command = $workload['command'];
        
        if ( $showAllElements ) {
            $elements = join( ',', $workload['elements'] );
        }
        else {
            $elements = join( ',', array_slice( $workload['elements'], 0, 5 ) );
            
            if ( count( $elements > 5 ) ) {
                $elements .= '...' . end( $workload['elements'] );
            }
        }
        
        return "Task Id: $jobId Command: $command Elements: $elements";
    }
    
    /**
     * Callback function for completed task
     *
     * @param GearmanTask $task
     * @param Sly_Batch
     * @return void
     */
    public static function taskCompleteCallback( $task, $batch )
    {
        $batch->taskComplete( $task );
    }
        
    /**
     * Complete a task
     *
     * @param GearmanTask $task
     * @return void
     */
    protected function taskComplete( $task )
    {
        $jobId = $task->unique();
        
        $data = $this->_tasks[$jobId]['data'];
        
        if ( $data['output'] ) {
            $output = implode( "\n", $data['output'] );
            $output .= "\n";
        }
        else {
            $output = '';
        }
        
        if ( isset( $this->_settings['outputFile'] ) && $output != '' ) {
            file_put_contents( $this->_settings['outputFile'], $output, FILE_APPEND );
            $this->_logger->info( "Completed Task $jobId Host: {$data['host']} File: {$data['file']}" );
        }
        else {
            $this->_logger->info( "Completed Task $jobId Host: {$data['host']} File: {$data['file']} Output: \n$output" );
        }
        
        unset( $this->_tasks[$jobId] ); 
    }       
        
    /**
     * Callback function for task failure
     *
     * @param GearmanTask $task
     * @param Sly_Batch
     * @return void
     */
    public static function taskFailCallback( $task, $batch )
    {
        $batch->taskFail( $task );
    }
        
    /**
     * Task Fail
     *
     * @param GearmanTask $task
     * @return void
     */
    protected function taskFail( $task )
    {
        $jobId = $task->unique();
        
        $data = $this->_tasks[$jobId]['data'];
        
        $output = implode( "\n", $data['output'] );
        
        $this->_logger->err( "Task Failed ID: $jobId Host: {$data['host']} File: {$data['file']} Output: $output" );
        
        // TODO reattempt
        
        unset( $this->_tasks[$jobId] ); 
    } 
            
    /**
     * Callback function for task failure
     *
     * @param GearmanTask $task
     * @param Sly_Batch
     * @return void
     */
    public static function taskDataCallback( $task, $batch )
    {
        $batch->taskData( $task );
    }
        
    /**
     * Task Fail
     *
     * @param GearmanTask $task
     * @return void
     */
    protected function taskData( $task )
    {
        $jobId = $task->unique();
        
        $data =  unserialize( $task->data() );
        $this->_tasks[$jobId]['data'] = $data;
        
        if ( $data['status'] == 'starting' ) {
            $this->_logger->info( "Starting ID: $jobId on {$data['host']} with file: {$data['file']}" );
        }
    } 
}

?>
