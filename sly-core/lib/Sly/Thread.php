<?php

/**
 * Class to start and manage new threads
 *
 * @description This class will launch new threads
 * @category Sly
 * @package Sly
 * @subpackage Sly_Thread
 */
class Sly_Thread 
{
    /**
     * @var integer
     * @access protected
     */
    protected $_processId ; 
    
    /**
     * Input, output, and error pipes for process
     *
     * @var integer
     * @access protected
     */
    protected $_pipes; 
    
    /**
     * @var string
     * @access protected
     */
    protected $_buffer; 
    
    /**
     * Class Constructor
     *
     * @param string $command
     * @param string $path
     * @return null
     */
    public function __construct( $command, $path = null ) 
    {
        $descriptor = array( 0 => array( "pipe", "r" ), 1 => array( "pipe", "w" ), 2 => array( "pipe", "w" ) );
        $this->_processId = proc_open( $command, $descriptor, $this->_pipes, $path );
        stream_set_blocking( $this->_pipes[1], 0 );
        stream_set_blocking( $this->_pipes[2], 0 );
    }
    
    /**
     * Get the id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->_processId;
    }
    
    /**
     * Check if process is still active
     *
     * @return boolean $isActive
     */
    public function isActive() 
    {       
        //first check if stream is even available
        if ( ! $metaData = @stream_get_meta_data( $this->_pipes[1] ) ) {
            return false;
        }
        
        $this->_buffer = $this->getStdout();
        $metaData = stream_get_meta_data( $this->_pipes[1] );
        return ! $metaData["eof"];      
    }
    
    /**
     * Close the process
     *
     * NOTE the termination status seems to be unreliable and should not be used
     * by the calling process to determine the success of the thread.
     *
     * @return integer $terminationStatus
     */
    public function close() 
    {
        $terminationStatus = proc_close( $this->_processId );
        $this->_processId = NULL;
        return $terminationStatus;
    }
    
    /**
     * Write to stdin
     *
     * @param string $data
     * @return null
     */
    public function writeStdin( $data ) 
    {
        fwrite( $this->_pipes[0], $data );
    }
    
    /**
     * Get from stdout
     *
     * @return string
     */
    public function getStdout() 
    {
        $buffer = $this->_buffer;
        $this->_buffer = "";
        while( $data = fgets( $this->_pipes[1], 1024 ) ) {
            $buffer .= $data;
        }
        return $buffer;
    }
    
    /**
     * Get from stderr
     *
     * @reurn string
     */
    public function getStderr() 
    {
        $buffer = "";
        while( $r = fgets( $this->_pipes[2], 1024 ) ) {
            $buffer .= $r;
        }
        return $buffer;
    }
}

?>