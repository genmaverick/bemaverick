<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/DbAdapter.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/DbAdapter/Multi.php' );

/**
 * Database configuration class of the entire system
 *
 */
class BeMaverick_Config_Database
{
    /**
     * @var array
     * @access protected
     */
    protected $_databaseSettings;

    /**
     * Array of dbAdapters
     * @var Array
     * @access protected
     */
    protected $_dbAdapters = array();
    
    /**
     * Constructor
     */
    public function __construct( $databaseSettings )
    {
        $this->_databaseSettings = $databaseSettings;
    }
    
    /**
     * Get a dbAdapter for a database name
     *
     * @param string $databaseName
     * @return Sly_DbAdapter
     */
    public function getDbAdapter( $databaseName, $factory )
    {
        if ( isset( $this->_dbAdapters[$databaseName] ) ) {
            return $this->_dbAdapters[$databaseName];
        }
        
        if ( ! isset( $this->_databaseSettings[$databaseName] ) ) {
            throw new Exception( "Database: $databaseName not in settings!" );
        }

        $settings = $this->_databaseSettings[$databaseName];

        if ( isset( $settings['multi'] ) && $settings['multi'] ) {
            if ( !isset( $settings['hostObjectClassName'] ) ) {
                throw new Exception( "Database: $databaseName hostObjectClassName must be set with multi" );
            }
            
            // Some special handling is required to construct a class from its
            // name (call_user_func will NOT work with __construct)
            $reflectionClass = new ReflectionClass( $settings['hostObjectClassName'] );

            $hostObject = $reflectionClass->newInstanceArgs( array($factory) );
            
            $dbAdapter = Sly_DbAdapter_Multi::getInstance( $settings, $hostObject );
        }
        else {
            $dbAdapter = Sly_DbAdapter::getInstance( $settings );
        }
        
        $this->_dbAdapters[$databaseName] = $dbAdapter;
        return $this->_dbAdapters[$databaseName];
    }

    /**
     * Get all the dbadapters
     *
     * @return array
     */
    public function getDatabaseNames()
    {
        return array_keys( $this->_databaseSettings );
    }

    /**
     * @param $dbName string the database settings name
     * @return array @nullable
     */
    public function getDatabaseSettings( $dbName ) {
        if ( array_key_exists( $dbName, $this->_databaseSettings ) ) {
            return $this->_databaseSettings[$dbName];
        }
        return null;
    }

}

?>
