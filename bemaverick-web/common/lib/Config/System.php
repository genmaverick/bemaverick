<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Controller/Front.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Filter/StripTags.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Config/System.php' );

class BeMaverick_Config_System extends Sly_Config_System
{
    /**
     * @var object
     * @access protected
     */
    protected $_factory;

    /**
     * @var hash
     * @access protected
     */
    protected $_settings = array();

    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct( $factory, $settings )
    {
        $this->_factory = $factory;
        $this->_settings = $settings;
    }

    /**
     * Get the factory
     *
     * @return object
     */
    public function getFactory()
    {
        return $this->_factory;
    }

    /**
     * Get if a setting is set
     *
     * @param string $settingName
     * @return boolean
     */
    public function isSettingSet( $settingName )
    {
        return isset( $this->_settings[$settingName] );
    }

    /**
     * Get a setting
     *
     * @param string $settingName
     * @return mixed
     */
    public function getSetting( $settingName )
    {
        if ( isset( $this->_settings[$settingName] ) ) {
            return $this->_settings[$settingName];
        }
        
        return null;
    }
        
    /**
     * Set a setting
     *
     * This will override any previous value for that setting
     *
     * @param string $settingName
     * @param mixed $value
     * @return void
     */
    public function setSetting( $settingName, $value )
    {
        $this->_settings[$settingName] = $value;
    }


    public function getSiteSource()
    {
        if ( $this->isSettingSet( 'SYSTEM_SITE_SOURCE' ) ) {
            return $this->getSetting( 'SYSTEM_SITE_SOURCE' );
        }
        
        return 'api';
    }

    public function getPackageBuildVersion()
    {
        return @file_get_contents( $this->getSetting( 'SYSTEM_PACKAGE_BUILD_VERSION_FILE' ) );
    }

    public function getCookieSalt()
    {
        return $this->getSetting( 'SYSTEM_COOKIE_SALT' );
    }

    public function getCookieDomain()
    {
        return $this->getSetting( 'SYSTEM_COOKIE_DOMAIN' );
    }

    public function getSiteLanguage()
    {
        return 'en';
    }

    public function getTranslationFile()
    {
        return $this->getSetting( 'SYSTEM_TRANSLATION_FILE' );
    }

    public function getCSSDirs()
    {
        return $this->getSetting( 'SYSTEM_CSS_DIRS' );
    }

    public function getImagesDir()
    {
        return $this->getSetting( 'SYSTEM_IMAGE_DIRS' );
    }

    public function getJSDirs()
    {
        return $this->getSetting( 'SYSTEM_JS_DIRS' );
    }

    public function getModuleDirs()
    {
        return $this->getSetting( 'SYSTEM_MODULE_DIRS' );
    }

    public function getPageDirs()
    {
        return $this->getSetting( 'SYSTEM_PAGE_DIRS' );
    }

    public function getFontDirs()
    {
        return $this->getSetting( 'SYSTEM_FONT_DIRS' );
    }

    public function getViewHelpers()
    {
        return $this->getSetting( 'SYSTEM_HELPERS' );
    }

    /*********************************************************************
     * The following functions override all of the functions in 
     * Sly_Config_System that use defined constants (other than paths)
     *********************************************************************/


    public function getEnvironment()
    {
        return $this->getSetting( 'SYSTEM_ENVIRONMENT' );
    }

    public function getRootDir()
    {
        return $this->getSetting( 'SYSTEM_ROOT_DIR' );
    }
    
    public function getConfigDir()
    {
        return $this->getSetting( 'SYSTEM_ROOT_DIR' ) . '/config';
    }

    public function getLogDir()
    {
        return BEMAVERICK_ROOT_DIR . '/logs';
    }

    public function getFontDir()
    {
        return $this->getSetting( 'SYSTEM_ROOT_DIR' ) . '/fonts';
    }

    public function getHtdocsDir()
    {
        return $this->getSetting( 'SYSTEM_ROOT_DIR' ) . '/htdocs';
    }

    public function getHtdocsCacheDir()
    {
        return $this->getSetting( 'SYSTEM_ROOT_DIR' ) . '/htdocs/cache';
    }

    public function getStringsXmlFile()
    {
        return $this->getSetting( 'SYSTEM_ROOT_DIR' ) . '/config/strings.xml';
    }
    
    public function getXmlUrlsFile()
    {
        return $this->getSetting( 'SYSTEM_ROOT_DIR' ) . '/config/urls.xml';
    }
 
    public function getCdnHosts()
    {
        if ( ! $this->isSettingSet( 'SYSTEM_CDN_HOSTS' ) ) {
            return false;
        }
        
        return $this->getSetting( 'SYSTEM_CDN_HOSTS' );
    }    

    public function getCSSNamespace()
    {
        return false;
    }

    public function isHttpCaching()
    {
        if ( $this->isSettingSet( 'SYSTEM_HTTP_CACHING' ) ) {
            return $this->getSetting( 'SYSTEM_HTTP_CACHING' );
        }
        
        return false;
    }
    
    public function isJsCaching()
    {
        if ( $this->isSettingSet( 'SYSTEM_JS_CACHING' ) ) {
            return $this->getSetting( 'SYSTEM_JS_CACHING' );
        }

        return true;
    }

    public function isMinifyCssJsEnabled()
    {
        if ( $this->isSettingSet( 'SYSTEM_MINIFY_CSS_JS_ENABLED' ) ) {
            return $this->getSetting( 'SYSTEM_MINIFY_CSS_JS_ENABLED' );
        }

        return false;
    }
    
    public function isLessEnabled()
    {
        if ( $this->isSettingSet( 'SYSTEM_LESS_ENABLED' ) ) {
            return $this->getSetting( 'SYSTEM_LESS_ENABLED' );
        }

        return false;
    }
    
    public function isDebug()
    {
        if ( isset( $_REQUEST['debug'] ) || SYSTEM_DEBUG_MODE ) {
            return true;
        }

        return false;
    }

    public function getHttpHost( $useRequest = true )
    {
        $front = Zend_Controller_Front::getInstance();

        $request = $front->getRequest();

        if ( $useRequest && $request ) {
            $httpHost = $request->getServer( 'HTTP_HOST' );
        }
        else {
            $httpHost = $this->getSetting( 'SYSTEM_HTTP_HOST' );
        }

        return $httpHost;
    }

    public function getCacheBackendOptions()
    {
        return $this->getSetting( 'SYSTEM_REDIS_HOSTS' );
    }

    /**
     * Get an array of the batch host servers
     *
     * @return array
     */
    public function getBatchHosts()
    {
        $hosts = $this->getSetting( 'SYSTEM_BATCH_HOSTS' );

        $options = array();

        foreach( $hosts as $host ) {
            $options[] = array( 'host' => $host,
                                'port' => 4730 );
        }

        return $options;
    }

    public function getCurrentUrl( $relative = true )
    {
        $front = Zend_Controller_Front::getInstance();
        $request = $front->getRequest();
        $filter = new Zend_Filter_StripTags();

        $requestUri = $filter->filter( $request->getRequestUri() );

        if ( $relative ) {
            return $requestUri;
        }

        // get the server protocol
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' || $_SERVER['SERVER_PORT'] == 443) ? 
                    'https' :
                    'http';
        
        return $protocol . '://' . $this->getHttpHost() . $requestUri;
    }    

    public function getHttpUserAgent()
    {
        $front = Zend_Controller_Front::getInstance();

        $request = $front->getRequest();

        return $request->getServer( 'HTTP_USER_AGENT' );
    }

    public function isRequestSecure()
    {
        static $isRequestSecure = null;
        
        if ( $isRequestSecure !== null ) {
            return $isRequestSecure;
        }
        
        $isRequestSecure = false;

        if ( @$_SERVER['HTTPS'] == 'on' ||
             @$_SERVER['HTTP_X_HTTPS'] == 'on' ) {
            $isRequestSecure = true;
        }
        
        return $isRequestSecure;
    }

    public function isProduction()
    {
        if ( $this->getEnvironment() == 'production' ) {
            return true;
        }

        return false;
    }

    public function getShortServerName()
    {
        //return trim( `hostname -i` );
        return php_uname( 'n' );
    }
    
    public function getImageHost()
    {
        return $this->getSetting( 'SYSTEM_IMAGE_HOST' );
    }

    public function getImageSalt()
    {
        return $this->getSetting( 'SYSTEM_IMAGE_SALT' );
    }
    
    public function getImageCompressionQuality()
    {
        return $this->getSetting( 'SYSTEM_IMAGE_COMPRESSION_QUALITY' );
    }

    public function getImageMaxSize()
    {
        return '2000x2000';
    }
    
    public function getAssetsDir()
    {
        return $this->getSetting( 'SYSTEM_ASSETS_DIR' );
    }

    public function getAccessTokenSigningSecret()
    {
        return $this->getSetting( 'OAUTH_ACCESS_TOKEN_SIGNING_SECRET' );
    }

}

?>
