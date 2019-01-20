<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/App.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/ClientInterface.php' );

class BeMaverick_App implements Sly_OAuth_ClientInterface
{
    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = array();

    /**
     * @access protected
     */
    protected $_site;

    /**
     * @var integer
     * @access protected
     */
    protected $_appKey;

    /**
     * @var BeMaverick_Da_App
     * @access protected
     */
    protected $_daApp;

    /**
     * Class constructor
     *
     * @param  integer
     * @return void
     */
    public function __construct( $site, $appKey )
    {
        $this->_site = $site;
        $this->_appKey = $appKey;
        $this->_daApp = BeMaverick_Da_App::getInstance();
    }

    /**
     * Retrieves the app instance.
     *
     * @param integer $appKey
     * @return BeMaverick_App
     */
    public static function getInstance( $site, $appKey )
    {
        if ( ! $appKey ) {
            return false;
        }

        if ( ! isset( self::$_instance[$appKey] ) ) {
            $daApp = BeMaverick_Da_App::getInstance();

            // make sure app exists
            if ( $daApp->isKeysExist( array( $appKey ) ) ) {
                self::$_instance[$appKey] = new self( $site, $appKey );
            }
            else {
                self::$_instance[$appKey] = false;
            }
        }

        return self::$_instance[$appKey];
    }

    /**
     * Get the toString function
     *
     * @return string
     */
    public function __toString()
    {
        return $this->getId();
    }

    /**
     * Get the id
     *
     * @return string
     */
    public function getId()
    {
        return $this->_appKey;
    }

    /**
     * Get the key
     *
     * @return string
     */
    public function getKey()
    {
        return $this->_appKey;
    }

    /**
     * Get the App Name
     *
     * @return string
     */
    public function getName()
    {
        return $this->_daApp->getName( $this->getId() );
    }

    /**
     * Get the App's Logo URL
     *
     * @return string|null
     */
    public function getLogoUrl()
    {
        return $this->_daApp->getLogoUrl( $this->getId() );
    }

    /**
     * Gets the OAuth redirect URL
     *
     * @return string|null
     */
    public function getRedirectUrl()
    {
        return $this->_daApp->getRedirectUrl( $this->getId() );
    }

    /**
     * Gets the grant types the client's allowed to work with
     *
     * @return string
     */
    public function getGrantTypes() {
        return $this->_daApp->getGrantTypes( $this->getId() );
    }

    /**
     * Get the app secret
     *
     * @return string
     */
    public function getSecret()
    {
        return $this->_daApp->getSecret( $this->getId() );
    }

    /**
     * Get the platform
     *
     * @return string
     */
    public function getPlatform()
    {
        return $this->_daApp->getPlatform( $this->getId() );
    }

    /**
     * Gets access scope
     *
     * @return null
     */
    public function getScope()
    {
        return null;
    }

    /**
     * Check if the app has access
     *
     * @return boolean
     */
    public function hasAccess( $accessType )
    {
        if ( $accessType == 'read' ) {
            return $this->hasReadAccess();
        }
        else if ( $accessType == 'write' ) {
            return $this->hasWriteAccess();
        }
        
        return false;
    }

    /**
     * Check if the app has read access
     *
     * @return boolean
     */
    public function hasReadAccess()
    {
        return $this->_daApp->getReadAccess( $this->getId() ) == 1 ? true : false;
    }

    /**
     * Check if the app has write access
     *
     * @return boolean
     */
    public function hasWriteAccess()
    {
        return $this->_daApp->getWriteAccess( $this->getId() ) == 1 ? true : false;
    }

    /**
     * Get the auth token ttl
     *
     * @return string
     */
    public function getAuthTokenTTL()
    {
        return $this->_daApp->getAuthTokenTTL( $this->getId() );
    }    

    /**
     * Get the current app version
     *
     * @return string
     */
    public function getCurrentAppVersion()
    {
        return $this->_daApp->getCurrentAppVersion( $this->getId() );
    }

    /**
     * Get the min app version
     *
     * @return string
     */
    public function getMinAppVersion()
    {
        return $this->_daApp->getMinAppVersion( $this->getId() );
    }

}

?>
