<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Thread.php' );

/**
 * Class to start and manage a single thread of a multiProcess workflow
 *
 * This class will be managed by a MultiProcessMaster class.  There will be TWO
 * objects for each thread.  This one will monitor and communicate with the 
 * thread from the master object.  A Sly_MultiProcessWorker object will be 
 * running in the thread itself.
 *
 * @description This class will launch new threads
 * @category Sly
 * @package Sly
 * @subpackage Sly_Thread
 */
class Sly_Thread_Worker extends Sly_Thread 
{
    /**
     * Get the status of the thread
     *
     * This function is called from the master process to check if a worker is 
     * ready for a new task.  This is really just a wrapper to check the stdout.
     *
     * @return string Returned status can be:
     *                'ready' - ready for a new task
     *                'done'  - completed previous task and ready for new task
     *                '' - not ready
     */
    public function getStatus()
    {
        return rtrim( $this->getStdout() );
    }
    
    /**
     * Ends the process loop and closes the thread
     *
     * This function is called from the master process to terminate the worker
     * process.  It will first send a command to exit the processing loop and 
     * then close the thread when the process completes.
     *
     * @return integer The termination status of the thread
     */
    public function endClose()
    {
        $this->writeStdin( "end\n" );
        
        while( $this->isActive() ) {
            // delay 1/4 second
            usleep( 250000 );
        }
        
        return $this->close();
    }
    
    /**
     * Run a command
     *
     * This function is called from the master process to run a command from the
     * process loop.
     *
     * @param string $command
     * @param integer $start
     * @param integer $end
     * @param array $elements
     * @param string $fileName Name of file to get elements from
     * @return void
     */
    public function runCommand( $command, $start, $end, $elements = null, $fileName = null )
    {
        if ( $start !== null && $end !== null ) {
            $this->writeStdin( "run $command --start $start --end $end\n" );
        }
        else if ( $elements !== null ) {
            $strElements = implode( ',', $elements );
            $this->writeStdin( "run $command --elements $strElements\n" );
        }
        else {
            $this->writeStdin( "run $command --fileName $fileName\n" );
        }
    }

}

?>