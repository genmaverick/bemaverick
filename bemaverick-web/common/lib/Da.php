<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Da.php' );

/**
 * Base class for access to the database tables.
 *
 */
class BeMaverick_Da extends Sly_Da
{

    /**
     * The db adapter object
     *
     * @var Sly_DbAdapter
     */
    protected static $_dbAdapter;

    /**
     * The read db adapter object
     *
     * @var Sly_DbAdapter
     */
    protected static $_readDbAdapter;    
   
    /**
     * @var string
     * @access protected
     */
    protected $_database = 'bemaverick';

    /**
     * Get the dbAdapter
     */
    public function getDbAdapter()
    {
        return self::$_dbAdapter;
    }

    /**
     * Sets the db adapter for all objects
     *
     * @param  Sly_DbAdapter $db
     * @return void
     */
    public static function setAdapter( $dbAdapter )
    {
        self::$_dbAdapter = $dbAdapter;

        // if the read db adapter isn't set, then set it to this
        if ( ! self::$_readDbAdapter ) {
            self::setReadDbAdapter( $dbAdapter );
        }
    }
    
    /**
     * Get the read dbAdapter
     */
    public function getReadDbAdapter()
    {
        return self::$_readDbAdapter;
    }
        
    /**
     * Sets the read db adapter for all objects
     *
     * @param  Sly_DbAdapter $db
     * @return void
     */
    public static function setReadDbAdapter( $readDbAdapter )
    {
        self::$_readDbAdapter = $readDbAdapter;
    }
}

?>
