<?php

require_once( 'Zend/Controller/Action.php' );
require_once( 'Zend/Http/Client.php' );
require_once( 'Sly/Config/Page.php' );
require_once( 'Sly/Input.php' );
require_once( 'Sly/Date.php' );

class Sly_Controller_Base extends Zend_Controller_Action
{
    /**
     * Process all the inputs from a GET or POST request
     *
     * @param array      $requiredParams
     * @param array      $optionalParams
     * @param Sly_Errors $errors
     * @param hash       $options
     * @param hash       $inputData
     * @param hash       $customInputParamValues
     * @return Sly_Input
     */
    public function processInput( $requiredParams,
                                  $optionalParams,
                                  $errors = null,
                                  $options = null,
                                  $inputData = null,
                                  $customInputParamValues = null )
    {
        // set the input data to the request params
        if ( ! $inputData ) {
            $inputData = $this->getRequest()->getParams();
        }

        // create the input
        $input = new $this->_inputClassName( $requiredParams,
                                             $optionalParams,
                                             $options,
                                             $inputData,
                                             $customInputParamValues );

        // validate each param and set errors if needed
        if ( $errors ) {
            $input->validate( $errors );
        }

        // set the input to the view
        $this->view->input = $input;

        return $input;
    }
    
    public function sendExpiresHeader( $ttl = 600 )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        // if we send an expires param, don't squid cache it
        if ( isset( $_REQUEST['expire'] ) ) {
            $ttl = 0;
        }

        if ( $systemConfig->isHttpCaching() ) {
            $response = $this->getResponse();

            if ( $ttl == 0 ) {
                $response->setHeader( 'Cache-Control', 'no-cache', true );
            }
            else {
                $now = time();
                
                $expires = Sly_Date::formatDate( $now+$ttl, 'D, d M Y H:i:s', 'UTC' ) . ' GMT';
                $lastModified = Sly_Date::formatDate( $now, 'D, d M Y H:i:s', 'UTC' ) . ' GMT';
                
                $response->setHeader( 'Expires', $expires, true );
                $response->setHeader( 'Cache-Control', "max-age=$ttl", true );
                $response->setHeader( 'Last-Modified', $lastModified, true );
            }
        }
    }
 
    public function renderPage( $page, $ttl = 0, $responseCode = 200 )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        $pageConfig = new Sly_Config_Page( $page );
        
        if ( ! $pageConfig ) {
            $this->view->requestedPage = $page;
            $pageConfig = new Sly_Config_Page( 'notfound' );
        }

        //$template = ( $this->view->ajax ) ? $pageConfig->getTemplateAjax() : $pageConfig->getTemplate();
        $template = $pageConfig->getTemplate();

        // update the page title if needed
        if ( $this->view->pageTitle ) {
            $pageConfig->setTitle( $this->view->pageTitle );
        }
        
        // assign this config to the view
        $this->view->pageConfig = $pageConfig;

        // also add to registry
        Zend_Registry::set( 'pageConfig', $pageConfig );
        
        // add the module dirs to the view script paths
        $moduleDirs = $systemConfig->getModuleDirs();
        $this->view->addScriptPath( $moduleDirs );

        // add helper paths
        $viewHelpers = $systemConfig->getViewHelpers();
        foreach( $viewHelpers as $viewHelper ) {
            $this->view->addHelperPath( $viewHelper['path'], $viewHelper['classPrefix'] );
        }

        // render layout script and append to response's body
        $layoutContent = $this->view->render( $template );

        $response = $this->getResponse();
        //$response->setHeader( 'X-UA-Compatible', 'IE=edge;chrome=1', true );

        // set the content type and the chart set.  setting the char set in the response
        // header is a best practice suggested by page speed
        // text/html default. but application/json if ajax.
        //$response->setHeader( 'Content-Type', $this->view->ajax ? 'application/json; charset=UTF-8' : 'text/html; charset=UTF-8' );

        // set the cache-control to private so proxies won't cache the response
        /*
        if ( ! $ttl ) {
            $response->setHeader( 'Cache-Control', 'private, no-store, no-cache' );
            $response->setHeader( 'Pragma', 'no-cache' );
            $response->setHeader( 'Expires', 'Sat, 01 Jan 2000 00:00:00 GMT' );
        }
        else {
            $response->setHeader( 'Pragma', '', true );
            $response->setHeader( 'Cache-Control', 'public', true );
            $response->setHeader( 'Cache-Control', "max-age=$ttl" );
        }
        */

        if ( $responseCode != 200 ) {
            $response->setHttpResponseCode( $responseCode );
        }

        $response->appendBody($layoutContent, null);
    }

    /**
     * Render proxy api request
     *
     * @param string $requestUrl
     * @return void
     */
    public function renderProxyApiRequest( $requestUrl )
    {
        $systemConfig = $this->view->systemConfig;

        $client = new Zend_Http_Client( $requestUrl );

        // we only need auth in devel environment
        if ( $systemConfig->getEnvironment() == 'devel' ) {
            $client->setAuth( 'drc', 'cowboys22' );
        }

        $apiResponse = $client->request( 'GET' );
        
        $contentType = $apiResponse->getHeader( 'Content-Type' );
        $cacheControls = $apiResponse->getHeader( 'Cache-Control' );
        $status = $apiResponse->getStatus();

        // update this response from the api call
        $response = $this->getResponse();
        $response->setHeader( 'Content-Type', $contentType );
        $response->setHttpResponseCode( $status );
        
        if ( ! is_array( $cacheControls ) ) {
            $cacheControls = array( $cacheControls );
        }

        foreach( $cacheControls as $cacheControl ) {
            $response->setHeader( 'Cache-Control', $cacheControl );
        }
        
        $response->appendBody( $apiResponse->getBody(), null );
    }

    /**
     * Redirect the page and make sure to set proper ttl
     *
     * @return void
     */
    public function redirectPage( $url, $ttl = 0 )
    {
        // set the cache-control to private so proxies won't cache the response
        $response = $this->getResponse();

        if ( ! $ttl ) {
            $response->setHeader( 'Cache-Control', 'private, no-store, no-cache' );
            $response->setHeader( 'Pragma', 'no-cache' );
            $response->setHeader( 'Expires', 'Sat, 01 Jan 2000 00:00:00 GMT' );
        }
        else {
            $response->setHeader( 'Pragma', '', true );
            $response->setHeader( 'Cache-Control', 'public', true );
            $response->setHeader( 'Cache-Control', "max-age=$ttl" );
        }

        return $this->_redirect( $url );
    }    

    function sendDebugInfo()
    {
        if ( ! Zend_Registry::isRegistered( 'debugLogger' ) ) { 
            return; 
        }
    
        $logger = Zend_Registry::get('debugLogger');
    
        // get the database config
        $databaseConfig = Zend_Registry::get( 'databaseConfig' );
        
        $dbAdapters = array();

        $databaseNames = $databaseConfig->getDatabaseNames();
        
        foreach( $databaseNames as $databaseName ) {
            $dbAdapters[$databaseName] = $databaseConfig->getDbAdapter( $databaseName, null );
        }

        $totalQueryCount = 0;
        $totalQueryTime = 0;
        foreach( $dbAdapters as $databaseName => $dbAdapter ) {
            $totalQueryCount += $dbAdapter->_queryCount;
            $totalQueryTime += $dbAdapter->_queryTime;
        }
        
        $logger->info( "Total query count: $totalQueryCount" );
        $logger->info( "Total query time: $totalQueryTime" );
        
        foreach( $dbAdapters as $databaseName => $dbAdapter ) {
            $logger->info( "Query count for $databaseName: " . $dbAdapter->_queryCount );
            $logger->info( "Query time for $databaseName: " . $dbAdapter->_queryCount );
        }

        foreach( $dbAdapters as $databaseName => $dbAdapter ) {
            $logger->info( "Queries for $databaseName: " );
            $logger->info( $dbAdapter->_queries );
        }

        foreach( $dbAdapters as $databaseName => $dbAdapter ) {
            if ( count( $dbAdapter->_queryStack ) > 0 ) {
                $logger->info( "Query stack for $databaseName: " . $dbAdapter->_queryStack );
            }
        }
        
        // print the memcache info        
        $cache = Zend_Registry::get( 'cache' );
        $logger->info( "Memcache Request count: " . count( $cache->_requests ) );
        $logger->info( "Total request size: " . $cache->_requestSize );
        $logger->info( $cache->_requests );
              
        // debug memcache further
        if ( count( $cache->_requestStack ) > 0 ) {
            $logger->info( $cache->_requestStack );
        }
        
        // memcache dup check
        $keyCount = array();
        $dupKeys = array();
        foreach( $cache->_requests as $request ) {
            if ( isset( $keyCount[$request] ) ) {
                $keyCount[$request]++;
                $dupKeys[$request] = $keyCount[$request];
            }
            else {
                $keyCount[$request] = 1;
            }
        }
        $logger->info( "Duplicated memcache keys" );
        $logger->info( $dupKeys );
        
        // breakup keys by top two layers (db and table)
        $other = 0;
        $counts = array();
        foreach( $cache->_requests as $request ) {
            $res = preg_match('/^([a-zA-Z_]+)\.([a-zA-Z_]+)\./', $request, $matches);
            if (!$res) {
                $other++;
            } 
            else {
                if (isset($counts[$matches[1]][$matches[2]])) {
                    $counts[$matches[1]][$matches[2]]++;
                }
                else {
                    $counts[$matches[1]][$matches[2]] = 1;
                }
            }
        }
        $logger->info( "Other requests (by Database and table): $other" );
        $logger->info( $counts );

        // add sql => md5 key if present
        $cacheTags = Sly_Da::getCacheTags();
        if ( $cacheTags && $cacheTags->_debugLegend ) {
            $logger->info( "SQL => md5 key" );
            $logger->info( $cacheTags->_debugLegend );
        }
    }
}

?>
