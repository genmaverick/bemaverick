<?php
require_once( ZEND_ROOT_DIR . '/lib/Zend/Registry.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Log.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Log/Writer/Stream.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log/Writer/Db.php' );

class Sly_Log extends Zend_Log
{

    protected $_options;
    protected $_startTime;
    protected $_endTime;
    protected $_logFile;

    /**
     * Construct the logger based on the options
     *
     * @param array $options There are two options supported: 
     *                       logdb - log to the database
     *                       log - log to file ( or stdout if not set )
     * @param string $date The date to use for the log file directory.  Defaults
     *                     to current.
     * @return Sly_Log
     */
    public function __construct( $options = null, $date = null )
    {
        $this->_options = $options;
        $systemConfig = Zend_Registry::get( 'systemConfig' );
        
        $logWriters = array();

        // get the script name and params
        $args = $_SERVER['argv'];
        $scriptName = array_shift( $args );
        $scriptName = basename( $scriptName, '.php' );

        // add the params if there were any
        $params = null;
        if ( count( $args ) > 0 ) {
            $params = join( ' ', $args );
            $params = str_replace( '--logdb', '', $params );
            $params = str_replace( '--log', '', $params );
            $params = trim( $params );

            if ( ! $params ) {
                $params = null;
            }
        }

        if ( $options && isset( $this->_options->logdb ) ) {
            require_once( $systemConfig->getDbLogFile() );
            
            $daClass = call_user_func( array( $systemConfig->getDbLogClass(), 'getInstance' ) );
            $dbLogLevel = $systemConfig->getDbLogLevel();
            
            $logWriters[] = new Sly_Log_Writer_Db( $daClass, $dbLogLevel );
        }
        
        if ( $options && isset( $this->_options->log ) ) {
            $logDir = $systemConfig->getLogDir();
            $date = $date ? $date : date( 'Y-m-d' );

            // modify params for better filename
            $thisParams = '';
            if ( $params ) {
                $thisParams = '.' . $params;
                $thisParams = str_replace( ' ', '_', $thisParams );
                $thisParams = str_replace( '-', '', $thisParams );
                $thisParams = str_replace( ';', '', $thisParams );
                $thisParams = str_replace( '/', ':', $thisParams );
            }

            if ( strlen( $thisParams ) > 200 ) {
                $thisParams = substr( $thisParams, 0, 200 ) . "...";
            }

            $this->_logFile = "$logDir/$date/${scriptName}${thisParams}.log";

            @mkdir( "$logDir/$date", 0777, true );
            
            // force mode since mkdir can get overwritten
            @chmod( "$logDir/$date", 0777 );

            $logWriters[] = new Zend_Log_Writer_Stream( $this->_logFile );
        }
        else {
            $logWriters[] = new Zend_Log_Writer_Stream( 'php://output' );
        }

        parent::__construct( $logWriters[0] );
        
        // add any additional writers
        if ( count( $logWriters > 1 ) ) {
            for( $i = 1; $i < count( $logWriters ); $i++ ) {
                $this->addWriter( $logWriters[$i] );
            }
        }
        
        $this->setEventItem( 'script', "$scriptName.php" );
        $this->setEventItem( 'params', $params );

        Zend_Registry::set( 'logger', $this );
    }

    public function start()
    {
        $this->_startTime = time();

        //$scriptName = basename( $_SERVER['argv'][0], '.php' );

        $this->info( join( ' ', $_SERVER['argv'] ) );

        $this->info( 'start time: ' . date( 'r', $this->_startTime ) );
    }

    /**
     * Record the end and optionally the number of items processed
     *
     * @param integer $numProcessed
     * @return void
     */
    public function end( $numProcessed = null )
    {
        $this->_endTime = time();
        $totalTime = $this->_endTime - $this->_startTime;
        $this->setEventItem( 'executionTime', $totalTime );
                    
        $this->info( 'end time: ' . date( 'r', $this->_endTime ) );
        
        if ( $numProcessed !== null ) {
            $this->setEventItem( 'processed', $numProcessed );
            $this->notice( "processed $numProcessed items in $totalTime seconds" );
        }
        else {
            $this->notice( "completed in $totalTime seconds" );
        }

        // set the mod to 666 for the file, in case another user runs the same script
        // and wants to add to the log file
        if ( $this->_logFile ) {
            @chmod( $this->_logFile, 0666 );
        }

    }

}

?>
