<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Controller/Action.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Config/Page.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Webservice.php');

class Sly_Controller_WebservicesBase extends Zend_Controller_Action
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

        // set the defaults
        $input->format = $input->format ? $input->format : 'xml';
        $this->view->format = $input->format;
        
        // set the input to the view
        $this->view->input = $input;

        return $input;
    }


    /**
     * Sends the headers for expiring given the ttl
     *
     * @param integer $ttl The max age for the request to cache
     * @return void
     */
    public function sendExpiresHeader( $ttl = 300 )
    {
        $response = $this->getResponse();

        $response->setHeader( Sly_Webservice::HTTP_HEADER_EXPIRES, '', true );
        $response->setHeader( Sly_Webservice::HTTP_HEADER_PRAGMA, '', true );
        $response->setHeader( Sly_Webservice::HTTP_HEADER_CACHE_CONTROL, 'public', true );
        $response->setHeader( Sly_Webservice::HTTP_HEADER_CACHE_CONTROL, "max-age=$ttl" );
    }

     
    /**
     * Renders the page and puts the html result into the response body
     *
     * @param string $page The page to render. ex: leagueHome
     * @param integer $responseCode HTTP response code to return
     * @return void
     */
    public function renderPage( $page, $responseCode = Sly_Webservice::HTTP_RC_OK )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        $pageConfig = new Sly_Config_Page( $page );

        if ( ! $pageConfig ) {
            $this->view->requestedPage = $page;
            $pageConfig = new Sly_Config_Page( 'notfound' );
        }

        $template = $pageConfig->getTemplate();

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

        // render layout script and append to Response's body
        $layoutContent = $this->view->render( $template );

        $response = $this->getResponse();

        if ($responseCode != Sly_Webservice::HTTP_RC_OK) {
            $response->setHttpResponseCode( $responseCode );
        }

        $response->appendBody($layoutContent, null);
    }


}




?>