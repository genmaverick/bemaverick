<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_App extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_App
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'app';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'app_key' );

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
        'getSecret'            => 'secret',
        'getName'              => 'name',
        'getPlatform'          => 'platform',
        'getReadAccess'        => 'read_access',
        'getWriteAccess'       => 'write_access',
        'getAuthTokenTTL'      => 'auth_token_ttl',
        'getCurrentAppVersion' => 'current_app_version',
        'getMinAppVersion'     => 'min_app_version',
        'getLogoUrl'           => 'logo_url',
        'getRedirectUrl'       => 'redirect_url',
        'getGrantTypes'        => 'grant_types',

        'setSecret'            => 'secret',
        'setName'              => 'name',
        'setPlatform'          => 'platform',
        'setReadAccess'        => 'read_access',
        'setWriteAccess'       => 'write_access',
        'setAuthTokenTTL'      => 'auth_token_ttl',
        'setCurrentAppVersion' => 'current_app_version',
        'setMinAppVersion'     => 'min_app_version',
        'setLogoUrl'           => 'logo_url',
        'setRedirectUrl'       => 'redirect_url',
        'setGrantTypes'        => 'grant_types',
    );

    /**
     * Constructor to set tags
     */
    public function __construct()
    {
        $this->_tags = array( $this->_database.'.'.$this->_table );
    }    

    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_App
     */
    public function getInstance()
    {
        if (null === self::$_instance) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }

}

?>
