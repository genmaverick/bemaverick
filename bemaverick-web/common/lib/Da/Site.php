<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_Site extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Site
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'site';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'site_id' );

    /**
     * @var boolean
     * @access protected
     */
    protected $_rowCacheEnabled = true;

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array(

    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Site
     */
    public function getInstance()
    {
        if (null === self::$_instance) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }

    /**
     * Constructor to set tags
     */
    public function __construct()
    {
        $this->_tags = array( $this->_database.'.'.$this->_table );
    }

}

?>
