<?php
/**
 * @category   Sly
 * @package    Sly_Log
 * @subpackage Sly_Log_Writer
 */

require_once 'Zend/Log/Writer/Abstract.php';

/**
 * @category   Sly
 * @package    Sly_Log
 * @subpackage Sly_Log_Writer
 */
class Sly_Log_Writer_Db extends Zend_Log_Writer_Abstract
{
    /**
     * Da class for table
     * @var Sly_Da
     */
    private $_da;
    
    /**
     * Level to write logs
     * @var integer
     */
    private $_dbLogLevel;

    /**
     * Class constructor
     *
     * @param Sly_Da $da
     * @param integer $dbLogLevel
     */
    public function __construct( $da, $dbLogLevel )
    {
        $this->_da = $da;
        $this->_dbLogLevel = $dbLogLevel;
    }

    /**
     * Formatting is not possible on this writer
     */
    public function setFormatter($formatter)
    {
        throw new Zend_Log_Exception( get_class() . ' does not support formatting' );
    }

    /**
     * Remove reference to database adapter
     *
     * @return void
     */
    public function shutdown()
    {
        $this->_da = null;
    }

    /**
     * Write a message to the log.
     *
     * @param  array  $event  event data
     * @return void
     */
    protected function _write( $event )
    {
        if ( $this->_da === null ) {
            throw new Zend_Log_Exception( 'Database adapter instance has been removed by shutdown' );
        }
        
        if ( $event['priority'] <= $this->_dbLogLevel ) {
            try {
                $this->_da->writeEvent( $event );
            }
            catch( Exception $e ) {
                error_log( "Exception writing event: " . $e->getMessage() );
            }
        }
    }

}
