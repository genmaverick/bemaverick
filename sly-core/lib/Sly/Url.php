<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Registry.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/FileFinder.php' );

/**
 * Class for creating urls
 *
 * @category Sly
 * @package Sly_Url
 */
class Sly_Url
{
    /**
     * @static
     * @var Sly_Url
     * @access protected
     */
    protected static $_instance = null;

    /**
     * @var SimpleXMLObject
     * @access protected
     */
    protected $_xml = null;
    

    /**
     * @static
     * @var string
     */
    protected $_defaultProtocol;

    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct( $urlsXmlFile = null )
    {
        if ( ! $urlsXmlFile ) {
            $systemConfig = Zend_Registry::get( 'systemConfig' );
            $urlsXmlFile = $systemConfig->getXmlUrlsFile();
        }
        
        $this->_xml = simplexml_load_file( $urlsXmlFile );
    }

    /**
     * Retrieves the url instance.
     *
     * @return Sly_Url
     */
    public static function getInstance()
    {
        if ( ! self::$_instance ) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }
    
    /**
     * Get the url
     *
     * @param string $page
     * @param array $params
     * @param boolean $relativeUrl Defaults to true
     * @param string $overwriteHost Default to false
     * @param boolean $sortParams Defaults to true
     * @return string
     */
    public function getUrl( $page,
                            $params = array(),
                            $relativeUrl = true,
                            $overwriteHost = false,
                            $sortParams = true,
                            $isSecure = false,
                            $htdocsCacheDir = null )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        if ( $this->_xml->$page ) {

            $paramConfigs = array();

            // make sure all required params are present and set any paramConfig
            // for later use
            if ( $this->_xml->$page->params ) {
                foreach( $this->_xml->$page->params->param as $paramXml ) {

                    $param = (string)$paramXml;

                    if ( $paramXml['required'] == 'true' &&
                         ! isset( $params[$param] ) ) {
                        error_log( "Sly_Url::getUrl: required parameter is not present in $page: $param" );
                    }

                    // default urlencode the value
                    $paramConfigs[$param]['urlencode'] = true;

                    if ( isset( $paramXml['urlencode'] ) &&
                         $paramXml['urlencode'] == 'false' ) {
                        $paramConfigs[$param]['urlencode'] = false;
                    }

                    // default smash the value
                    $paramConfigs[$param]['smash'] = false;

                    if ( isset( $paramXml['smash'] ) &&
                         $paramXml['smash'] == 'true' ) {
                        $paramConfigs[$param]['smash'] = true;
                    }

                    // default lowercase the value
                    $paramConfigs[$param]['lowercase'] = false;

                    if ( isset( $paramXml['lowercase'] ) &&
                         (strcasecmp($paramXml['lowercase'], 'true') == 0) ) {
                        $paramConfigs[$param]['lowercase'] = true;
                    }                    

                }
            }

            $url = (string) $this->_xml->$page->url;

            // we have special needs for img and flash static files, because
            // we want them on the CDN ultimately and anytime a file gets updated
            // we want a new CDN name, so we'll take the timestamp and copy the file
            // into the htdocs directory if it isn't there.

            if ( ! $htdocsCacheDir ) {
                $htdocsCacheDir = $systemConfig->getHtdocsCacheDir();
            }

            if ( $page == 'imageStatic' ) {
                $imageDirs = $systemConfig->getImagesDir();

                if ( ! is_array($imageDirs) ) {
                    $imageDirs = array( $imageDirs );
                }
                
                $fileInfo = Sly_FileFinder::findFileStat($params['imageName'], $imageDirs);
                
                $originalFile = $fileInfo['path'];
                $modifiedTime = $fileInfo['mtime'];

                $pathInfo = pathinfo( $params['imageName'] );

                if ( $pathInfo['dirname'] == '.' ) {
                    $imageName = $pathInfo['filename'] . '_' . $modifiedTime . '.' . $pathInfo['extension'];
                }
                else {
                    $imageName = $pathInfo['dirname'] . '/' . $pathInfo['filename'] . '_' . $modifiedTime . '.' . $pathInfo['extension'];
                }
                
                $newFile = "$htdocsCacheDir/img/$imageName";

                if ( ! file_exists( $newFile ) ) {
                    @mkdir( "$htdocsCacheDir/img/{$pathInfo['dirname']}", 0777, true );
                    @chmod( "$htdocsCacheDir/img/{$pathInfo['dirname']}", 0777 );
                    @copy( $originalFile, $newFile );
                }

                $params['imageName'] = $imageName;
            }
            else if ( $page == 'flashStatic' ) {
                $flashDir = $systemConfig->getFlashDir();
                $originalFile = "$flashDir/" . $params['swfName'];
                $modifiedTime = filemtime( $originalFile );
                $pathInfo = pathinfo( $originalFile );
                $swfName = $pathInfo['filename'] . '_' . $modifiedTime . '.' . $pathInfo['extension'];
                $newFile = "$htdocsCacheDir/flash/$swfName";

                if ( ! file_exists( $newFile ) ) {
                    @mkdir( "$htdocsCacheDir/flash", 0777, true );
                    @chmod( "$htdocsCacheDir/flash", 0777 );
                    @copy( $originalFile, $newFile );
                }

                $params['swfName'] = $swfName;
            }
            else if ( $page == 'videoStatic' ) {
                $videoDir = $systemConfig->getVideoDir();
                $originalFile = "$videoDir/" . $params['videoName'];
                $modifiedTime = filemtime( $originalFile );
                $pathInfo = pathinfo( $originalFile );
                $videoName = $pathInfo['filename'] . '_' . $modifiedTime . '.' . $pathInfo['extension'];
                $newFile = "$htdocsCacheDir/video/$videoName";

                if ( ! file_exists( $newFile ) ) {
                    @mkdir( "$htdocsCacheDir/video", 0777, true );
                    @chmod( "$htdocsCacheDir/video", 0777 );
                    @copy( $originalFile, $newFile );
                }

                $params['videoName'] = $videoName;
            }
            else if ( $page == 'audioStatic' ) {
                $audioDir = $systemConfig->getAudioDir();
                $originalFile = "$audioDir/" . $params['audioName'];
                $modifiedTime = filemtime( $originalFile );
                $pathInfo = pathinfo( $originalFile );
                $audioName = $pathInfo['filename'] . '_' . $modifiedTime . '.' . $pathInfo['extension'];
                $newFile = "$htdocsCacheDir/audio/$audioName";

                if ( ! file_exists( $newFile ) ) {
                    @mkdir( "$htdocsCacheDir/audio", 0777, true );
                    @chmod( "$htdocsCacheDir/audio", 0777 );
                    @copy( $originalFile, $newFile );
                }

                $params['audioName'] = $audioName;
            }
            else if ( $page == 'xmlStatic' ) {
                $xmlDir = $systemConfig->getXmlDir();
                $originalFile = "$xmlDir/" . $params['xmlName'];
                $modifiedTime = filemtime( $originalFile );
                $pathInfo = pathinfo( $originalFile );
                $xmlName = $pathInfo['filename'] . '_' . $modifiedTime . '.' . $pathInfo['extension'];
                $newFile = "$htdocsCacheDir/xml/$xmlName";

                if ( ! file_exists( $newFile ) ) {
                    @mkdir( "$htdocsCacheDir/xml", 0777, true );
                    @chmod( "$htdocsCacheDir/xml", 0777 );
                    @copy( $originalFile, $newFile );
                }

                $params['xmlName'] = $xmlName;
            }
            else if ( $page == 'fontStatic' ) {

                $fontDirs = $systemConfig->getFontDirs();

                $fileInfo = Sly_FileFinder::findFileStat($params['fontName'], $fontDirs);

                $originalFile = $fileInfo['path'];
                $modifiedTime = $fileInfo['mtime'];
                $pathInfo = pathinfo( $originalFile );

                $fontName = $pathInfo['filename'] . '_' . $modifiedTime . '.' . $pathInfo['extension'];
                $newFile = "$htdocsCacheDir/fonts/$fontName";

                if ( ! file_exists( $newFile ) ) {
                    @mkdir( "$htdocsCacheDir/fonts", 0777, true );
                    @chmod( "$htdocsCacheDir/fonts", 0777 );
                    @copy( $originalFile, $newFile );
                }

                $params['fontName'] = $fontName;
            }

            // replace any param variables into the url
            foreach( $params as $key => $value ) {

                // need to see if this key is found in the url to get
                // replaced, if so, then remove it from the params array
                // so later we can create the get params properly
                if ( strpos( $url, ":$key" ) !== false ) {

                    if ( $paramConfigs[$key]['lowercase'] ) {
                        $value = strtolower( $value );
                    }
                    
                    if ( $paramConfigs[$key]['smash'] ) {
                        $value = $this->smashValue( $value );
                    }
                    else if ( $paramConfigs[$key]['urlencode'] ) {
                        $value = urlencode( $value );
                    }

                    $url = str_replace( ":$key", $value, $url );
                    unset( $params[$key] );
                }
            }

        }
        else {

            // we did not find this page in the config, so use it as the url
            $url = $page;
        }

        // add any leftover params to the getString
        $getString = array();

        // sort the params, so they are always in the same order for SEO purposes
        if ( $sortParams ) { 
            ksort( $params );
        }

        foreach( $params as $key => $value ) {

            if ( is_array( $value ) ) {
                foreach( $value as $subValue ) {
                    $getString[] = "$key=" . urlencode( $subValue );
                }
            }
            else {
                $getString[] = "$key=". urlencode( $value );
            }
        }

        if ( $getString ) {
            $url .= '?' . join( '&', $getString );
        }

        $protocol = $this->getDefaultProtocol();

        if ( $isSecure ) {
            $protocol = 'https';
        }

        if ( $overwriteHost ) {

            $protocol = $isSecure ? 'https' : 'http';

            $url = "$protocol://$overwriteHost$url";
        }
        else {
            // set url to not be relative 
            if ( ! $relativeUrl ) {
                $url = "$protocol://" . $systemConfig->getHttpHost() . $url;
            }

            // add the cdn if needed
            else if ( @$this->_xml->$page->url['cdn'] == 'true' ) {
                $cdnHost = $this->getCdnHost( $url );
                if ( $cdnHost ) {

                    $isCdnSecure = @$this->_xml->$page->url['isSecure'] == 'true';

                    if ( $isCdnSecure ) {
                        $url = "https://" . $cdnHost . $url;
                    }
                    else if ( @$this->_xml->$page->url['protocol'] == 'true' ) {
                        $url = "$protocol://" . $cdnHost . $url;
                    }
                    else {
                        $url = "//" . $cdnHost . $url;
                    }
                }
            }

        }
        return $url;
    }

    /**
     * Smash the value
     *
     * @return string
     */
    public function smashValue( $value )
    {
        $value = trim( $value );
        $value = str_replace( ' ', '-', $value );
        $value = preg_replace( '/[^a-zA-Z0-9\-_]/', '', $value );
        $value = preg_replace( '/\-+/', '-', $value );

        return $value;
    }

    /**
     * Get the CDN Host to use for this relative url
     *
     * @return string
     */
    public function getCdnHost( $relativeUrl, $checkRequestSecure = true )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );
        
        // Shah & Shawn -  10/30/2015 - Not needed at this point.
        //
        // check if request is secure, if so, then don't use the
        // cdn at all
        //        
        // if ( $checkRequestSecure && $systemConfig->isRequestSecure() ) {
        //     return false;
        // }
        
        $cdnHosts = $systemConfig->getCdnHosts();
        
        if ( ! $cdnHosts ) {
            return false;
        }
           
        // if there is only 1 cdn host, then just return it
        if ( count( $cdnHosts ) == 1 ) {
            return $cdnHosts[0];
        }

        // the cdn url is a list, so hash it to the number of
        // cdn urls we have and return the correct one. We want it
        // to always return the same one, so the CDN doesn't go
        // back to origin for each CDN url.        
        $index = abs(crc32( $relativeUrl )) % count( $cdnHosts );

        return $cdnHosts[$index]; 
    }

    /**
     * Inquire the request
     * 
     * @return string - http or https
     */
    public function getDefaultProtocol() {

        if ( isset( $this->_defaultProtocol ) ) {
            return $this->_defaultProtocol;
        }

        if ( @$_SERVER['HTTPS'] == 'on'
            || @$_SERVER['SERVER_PORT'] == 443
            || @$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https' ) {
            $this->_defaultProtocol = "https";
        }
        else {
            $this->_defaultProtocol = 'http';
        }

        return $this->_defaultProtocol;
    }

    /**
     * Ensures the Open-Graph url is prefixed with a protocol.
     * 
     * @param  string $url 
     * @return string
     */
    public function getOgTagUrl( $url ) {
        if ( strrpos( $url, '//' ) === 0 ) { // starts with protocol-relative
            return $this->getDefaultProtocol() . ':' . $url;
        } 
        else if ( strrpos( $url, 'http' ) !== 0  ) { // not prefixed with protocol
            return $this->getDefaultProtocol() . '://' . $url;
        } 
        else {
            return $url;
        }
    }

}
    
?>
