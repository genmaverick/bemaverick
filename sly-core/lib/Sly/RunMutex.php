<?php

class Sly_RunMutex
{
    var $_lockName = '';
    var $_fileHandle = null;

    public function __construct( $lockName )
    {
        $this->_lockName = preg_replace( '/[^a-z0-9_]/', '', $lockName );
    }

    public function getFileHandle()
    {
        if ( ! $this->_fileHandle ) {
            $this->_fileHandle = fopen( '/tmp/sly_lock_'. $this->_lockName, 'c' );
        }
        
        return $this->_fileHandle;
    }

    public function lock( $throwException = true )
    {
        $success = flock( $this->getFileHandle(), LOCK_EX | LOCK_NB );
        
        if ( ! $success && $throwException ) {
            throw new Exception( 'could not get lock: ' . $this->_lockName );
        }
        
        return $success;
    }

    public function unlock()
    {
        $fileHandle = $this->getFileHandle();
        
        $success = flock( $fileHandle, LOCK_UN );
        fclose( $fileHandle );

        // delete the file
        unlink( '/tmp/sly_lock_' . $this->_lockName );
                
        return $success;
    }

}

?>