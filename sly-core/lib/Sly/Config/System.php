<?php
require_once( ZEND_ROOT_DIR . '/lib/Zend/Controller/Front.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Filter/StripTags.php' );

class Sly_Config_System
{

    protected $_site = 'site';

    public function setSite( $site )
    {
        $this->_site = $site;
    }

    public function getSite()
    {
        return $this->_site;
    }

    /**
     * Get the site source (which code base it is accessing)
     *
     * @return string
     */
    public function getSiteSource()
    {
        if ( defined( 'SYSTEM_SITE_SOURCE' ) ) {
            return SYSTEM_SITE_SOURCE;
        }
        
        return 'website';
    }

    public function getEnvironment()
    {
        return SYSTEM_ENVIRONMENT;
    }

    public function getRootDir()
    {
        return SYSTEM_ROOT_DIR;
    }
    
    public function getConfigDir()
    {
        return SYSTEM_ROOT_DIR . '/config';
    }

    public function getFontDir()
    {
        return SYSTEM_ROOT_DIR . '/fonts';
    }
    
    public function getLogDir()
    {
        return SYSTEM_ROOT_DIR . '/logs';
    }

    public function getImagesDir()
    {
        return SYSTEM_ROOT_DIR . '/img';
    }

    public function getFlashDir()
    {
        return SYSTEM_ROOT_DIR . '/flash';
    }

    public function getVideoDir()
    {
        return SYSTEM_ROOT_DIR . '/video';
    }

    public function getAudioDir()
    {
        return SYSTEM_ROOT_DIR . '/audio';
    }

    public function getAssetsDir()
    {
        return SYSTEM_ROOT_DIR . '/assets';
    }

    public function getXmlDir()
    {
        return SYSTEM_ROOT_DIR . '/xml';
    }
    
    public function getHtdocsDir()
    {
        return SYSTEM_ROOT_DIR . '/htdocs';
    }
    
    public function getHtdocsCacheDir()
    {
        return SYSTEM_ROOT_DIR . '/htdocs/cache';
    }

    public function getDownloadDir()
    {
        return SYSTEM_ROOT_DIR . '/download';
    }

    public function getFontDirs()
    {
        return array( SYSTEM_ROOT_DIR . '/fonts');
    }

    public function getCdnHosts()
    {
        if ( ! SYSTEM_CDN_HOSTS ) {
            return false;
        }
        
        return explode( ',', SYSTEM_CDN_HOSTS );
    }    
    
    public function getXmlUrlsFile()
    {
        return SYSTEM_ROOT_DIR . '/config/urls.xml';
    }
 
    public function getStringsXmlFile()
    {
        return SYSTEM_ROOT_DIR . '/config/strings.xml';
    }

    public function getCSSNamespace()
    {
        return false;
    }
    
    public function isHttpCaching()
    {
        if ( defined( 'SYSTEM_HTTP_CACHING' ) ) {
            return SYSTEM_HTTP_CACHING;
        }
        
        return false;
    }
    
    public function isJsCaching()
    {
        if ( defined( 'SYSTEM_JS_CACHING' ) ) {
            return SYSTEM_JS_CACHING;
        }

        return true;
    }

    public function isMinifyCssJsEnabled()
    {
        if ( defined( 'SYSTEM_MINIFY_CSS_JS_ENABLED' ) ) {
            return SYSTEM_MINIFY_CSS_JS_ENABLED;
        }

        return false;
    }
    
    public function isLessEnabled()
    {
        if ( defined( 'SYSTEM_LESS_ENABLED' ) ) {
            return SYSTEM_LESS_ENABLED;
        }

        return false;
    }
    
    public function getWapHttpHost()
    {
        return SYSTEM_WAP_HTTP_HOST;
    }
    
    public function getErrorEmailAddress()
    {
        return SYSTEM_ERROR_EMAIL_ADDRESS;
    }

    public function getFromUserEmailAddress()
    {
        return SYSTEM_FROM_USER_EMAIL_ADDRESS;
    }

    public function getFromUserEmailName()
    {
        return SYSTEM_FROM_USER_EMAIL_NAME;
    }

    public function getDbLogFile()
    {
        return SYSTEM_DB_LOG_FILE;
    }
    
    public function getDbLogClass()
    {
        return SYSTEM_DB_LOG_CLASS;
    }
    
    public function getDbLogLevel()
    {
        return SYSTEM_DB_LOG_LEVEL;
    }

    public function getFacebookAppKey()
    {
        return FACEBOOK_APP_KEY;
    }

    public function getFacebookAppId()
    {
        return FACEBOOK_APP_ID;
    }
    
    public function getFacebookAppSecret()
    {
        return FACEBOOK_APP_SECRET;
    }

    public function getFacebookAppAdmins()
    {
        return FACEBOOK_APP_ADMINS;
    }
    
    public function getDatabaseConfig()
    {
        $config = array(
            'host'     => SYSTEM_DATABASE_HOST,
            'username' => SYSTEM_DATABASE_USERNAME,
            'password' => SYSTEM_DATABASE_PASSWORD,
            'dbname'   => SYSTEM_DATABASE_DBNAME,
        );

        return $config;
    }

    public function getCacheBackendOptions()
    {

        $hosts = split( ',', SYSTEM_MEMCACHE_HOSTS );

        $options = array(
            'servers' => array(),
        );

        foreach( $hosts as $host ) {
            $options['servers'][] = array( 'host' => $host,
                                           'port' => 11211,
                                           'persistent' => true );
        }

        return $options;
    }
    
    public function isProduction()
    {
        if ( $this->getEnvironment() == 'production' ) {
            return true;
        }

        return false;
    }

    public function isSiteDown()
    {
        if ( file_exists( SYSTEM_ROOT_DIR . '/var/sitedown.txt' ) ) {
            return true;
        }

        // cannot check connection here
        //if ( Zend_Registry::isRegistered( 'dbAdapter' ) &&
        //     ! Zend_Registry::get( 'dbAdapter' )->isConnected() ) {
        //    return true;
        //}
        
        return false;
    }
    
    public function isDebug()
    {
        if ( isset( $_REQUEST['debug'] ) || (defined( 'SYSTEM_DEBUG_MODE' ) && SYSTEM_DEBUG_MODE) ) {
            return true;
        }

        return false;
    }    

    public function getCurrentUrl( $relative = true, $removeParams = array() )
    {
        $front = Zend_Controller_Front::getInstance();
        $request = $front->getRequest();
        $filter = new Zend_Filter_StripTags();

        $requestUri = $filter->filter( $request->getRequestUri() );
        
        if ( $removeParams ) {
            $parsedUrl = parse_url( $requestUri );

            if ( isset($parsedUrl['query']) ) {
                parse_str( $parsedUrl['query'], $queryParams );
                foreach( $removeParams as $param ) {
                    unset( $queryParams[$param] );
                }
                $requestUri = $parsedUrl['path'] . '?' . http_build_query( $queryParams );
            }
        }

        if ( $relative ) {
            return $requestUri;
        }

        // get the server protocol
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' || $_SERVER['SERVER_PORT'] == 443) ? 
                    'https' :
                    'http';
        
        return $protocol . '://' . $this->getHttpHost() . $requestUri;
    }
    
    public function getHttpHost( $useRequest = true )
    {
        $front = Zend_Controller_Front::getInstance();

        $request = $front->getRequest();

        if ( $useRequest && $request ) {
            $httpHost = $request->getServer( 'HTTP_HOST' );
        }
        else {
            $httpHost = SYSTEM_HTTP_HOST;
        }

        return $httpHost;
    }
    
    public function getHttpReferer()
    {
        $front = Zend_Controller_Front::getInstance();

        $request = $front->getRequest();

        return $request->getServer( 'HTTP_REFERER' );
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
             @$_SERVER['HTTP_X_HTTPS'] == 'on' ||
            @$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https'  ) {
            $isRequestSecure = true;
        }
        
        return $isRequestSecure;
    }
    
    public function getRemoteIp()
    {
        $front = Zend_Controller_Front::getInstance();
        $request = $front->getRequest();
        return $request->getServer( 'REMOTE_ADDR' );
    }

    public function getShortServerName()
    {
        //return trim( `hostname -i` );
        return php_uname( 'n' );
    }

    public function getRequestUri() 
    { 
        $front = Zend_Controller_Front::getInstance(); 
        $filter = new Zend_Filter_StripTags(); 

        return $filter->filter( $front->getRequest()->getPathInfo() ); 
    }
   
    /*
        Data dictionary used for translating strings.
    */
    public function getTranslationFile()
    {
        return(NULL);
    }

    public function getCurrentTimestamp()
    {
        if ( defined( 'SYSTEM_CURRENT_TIMESTAMP' ) ) {
            return SYSTEM_CURRENT_TIMESTAMP;
        }

        return date( 'Y-m-d H:i:s' );
    }
}

?>
