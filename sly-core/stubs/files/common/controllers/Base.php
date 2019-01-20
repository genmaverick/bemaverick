<?php

require_once( SLY_ROOT_DIR     . '/lib/Sly/Config/Page.php' );
require_once( SLY_ROOT_DIR     . '/lib/Sly/Controller/Base.php' );
require_once( __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR . '/lib/__SLY_CLASS_PREFIX__/Input.php' );

/**
 * The base class for the controller which all other controllers extend
 *
 */
class __SLY_CLASS_PREFIX___Controller_Base extends Sly_Controller_Base
{
    protected $_inputClassName = '__SLY_CLASS_PREFIX___Input';

    const HTTP_RC_OK                    = 200;
    const HTTP_RC_BAD_REQUEST           = 400;
    const HTTP_RC_NOT_FOUND             = 404;
    const HTTP_RC_INTERNAL_SERVER_ERROR = 500;

    /**
     * Renders the page and puts the html result into the response body
     *
     * @param string $page The page to render. ex: leagueHome
     * @return void
     */
    public function renderPage( $page, $ttl = 0, $responseCode = self::HTTP_RC_OK )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        $pageConfig = new Sly_Config_Page( $page );

        if ( ! $pageConfig ) {
            $this->view->requestedPage = $page;
            $pageConfig = new Sly_Config_Page( 'notfound' );
        }

        $template = ( $this->view->ajax ) ? $pageConfig->getTemplateAjax() : $pageConfig->getTemplate();
            
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

        if ( $responseCode != self::HTTP_RC_OK ) {
            $response->setHttpResponseCode( $responseCode );
        }

        $response->appendBody($layoutContent, null);
    }

    /**
     * Check to see if the page is viewable by the user
     *
     * @return boolean
     */
    protected function isPageViewable( $viewerTypeAllowed = 'loggedIn' )
    {
        $result = true;
        
        // logged in
        if ( $viewerTypeAllowed == 'loggedIn' ) {

            if ( ! $this->view->loginUser ) {
                return $this->_redirect( '/' );
            }
        }

        // set the error if return false
        if ( ! $result ) {
            $this->view->errors->setError( 'page', 'NO_PERMISSION_TO_VIEW_PAGE' );
        }

        return $result;
    }

}

?>
