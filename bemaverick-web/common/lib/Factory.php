<?php

require_once( SLY_ROOT_DIR            . '/lib/Sly/Url.php' );

require_once( BEMAVERICK_ROOT_DIR        . '/vendor/autoload.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Config/System.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Challenge.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Response.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Site.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/User.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Validator.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Video.php' );

require_once( BEMAVERICK_API_ROOT_DIR . '/lib/ResponseData.php' );

/**
 * Factory to get all other objects for the site
 *
 */
class BeMaverick_Factory
{

    /**
     * The system config for this game
     *
     * @var mixed
     * @access protected
     */
    protected $_systemConfig;

    /**
     * The site code
     *
     * @var string
     * @access protected
     */
    protected $_siteCode;

    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct( $siteCode, $subSite = 'website' )
    {
        $allSettings = include( BEMAVERICK_COMMON_ROOT_DIR . '/config/settings.php' );

        $settings = $allSettings['common'];
        $settings = array_merge( $settings, $allSettings[$siteCode] );

        if ( isset( $allSettings["${siteCode}_${subSite}"] ) ) {
            $settings = array_merge( $settings, $allSettings["${siteCode}_${subSite}"] );
        }
        
        $this->_systemConfig = new BeMaverick_Config_System( $this, $settings );
        $this->_siteCode = $siteCode;

        return $this->_systemConfig;
    }    

    /**
     * Get the system config
     *
     * @return Sly_Config_System
     */
    public function getSystemConfig()
    {
        return $this->_systemConfig;
    }

    /**
     * Get the site code
     *
     * @return string
     */
    public function getSiteCode()
    {
        return $this->_siteCode;
    }    

    /**
     * Get a dbAdapter
     *
     * @param string $databaseName
     * @return Sly_DbAdapter
     */
    public function getDbAdapter( $databaseName )
    {
        $databaseConfig = Zend_Registry::get( 'databaseConfig' );
        
        return $databaseConfig->getDbAdapter( $databaseName, $this );
    }
    
    /**
     * Get the site class
     *
     * @param integer $siteId
     * @return BeMaverick_Site
     */
    public function getSite( $siteId = null )
    {
        if ( ! $siteId ) {
            $siteId = $this->getSystemConfig()->getSetting( 'SYSTEM_SITE_ID' );
        }
        
        return BeMaverick_Site::getInstance( $this, $siteId );
    }

    /**
     * Get the validator class
     *
     * @return BeMaverick_Validator
     */
    public function getValidator()
    {
        return BeMaverick_Validator::getInstance( $this );
    }

    /**
     * Get the response class
     *
     * @return BeMaverick_Api_ResponseData
     */
    public function getResponseData()
    {
        return new BeMaverick_Api_ResponseData;
    }

}

?>
