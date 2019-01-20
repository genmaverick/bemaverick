<?php

require_once( SLY_ROOT_DIR     . '/lib/Sly/Config/Page.php' );
require_once( SLY_ROOT_DIR     . '/lib/Sly/Controller/Base.php' );
require_once( SLY_ROOT_DIR     . '/lib/Sly/Util.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Input.php' );

/**
 * The base class for the controller which all other controllers extend
 *
 */
class BeMaverick_Controller_Base extends Sly_Controller_Base
{
    protected $_inputClassName = 'BeMaverick_Input';

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

        // render layout script and append to Response's body
        $layoutContent = $this->view->render( $template );

        // set the cache-control to private so proxies won't cache the response
        $response = $this->getResponse();

        $response->setHeader( 'X-UA-Compatible', 'IE=edge;chrome=1', true );
        // $response->setHeader( 'Access-Control-Allow-Origin', '*' );

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

        if ( $this->view->ajax ) {
            $response->setHeader( 'Content-Type', 'application/json' );
        }

        if ( $responseCode != self::HTTP_RC_OK ) {
            $response->setHttpResponseCode( $responseCode );
        }

        $response->appendBody($layoutContent, null);

        $this->sendDebugInfo();
    }

    /**
     * Check to see if the page is viewable by the user
     *
     * @param string $viewerTypeAllowed
     * @return boolean
     */
    protected function isPageViewable( $viewerTypeAllowed = 'loggedIn', $loginPage = 'authLogin' )
    {
        $redirectUrl = false;

        // logged in
        if ( $viewerTypeAllowed == 'loggedIn' ) {

            if ( $this->view->loginUser ) {
                return true;
            }

            $systemConfig = Zend_Registry::get( 'systemConfig' );

            $currentUrl = $systemConfig->getCurrentUrl( false );

            $params = array(
                'redirect' => $currentUrl,
            );

            $redirectUrl = $this->view->site->getUrl( $loginPage, $params );
        }

        // check if we need to redirect the user
        if ( $redirectUrl ) {

            // ajax doesn't handle redirects, so we have to set the variable in  the view and return false
            if ( $this->view->ajax ) {
                $this->view->redirectUrl = $redirectUrl;
                $this->view->errors->setError( 'page', 'NO_PERMISSION_TO_VIEW_PAGE' );
                return false;
            }

            return $this->_redirect( $redirectUrl );
        }

        $this->view->errors->setError( 'page', 'NO_PERMISSION_TO_VIEW_PAGE' );

        return false;
    }

    /**
     * Create a challenge video from the uploaded file
     *
     * @param BeMaverick_Site $site
     * @param integer $id
     * @param string $videoType   Either 'challenge' or 'response' or 'content'
     * @param string $inputName
     * @return BeMaverick_Video
     */
    protected function _createVideoFromUploadedFile( $site, $id, $videoType, $inputName = 'video' )
    {
        $video = null;

        if ( isset( $_FILES[$inputName] )
            && is_uploaded_file( $_FILES[$inputName]['tmp_name'] )
            && file_exists( $_FILES[$inputName]['tmp_name'] )
        ) {

            $videoFileContents = file_get_contents( $_FILES[$inputName]['tmp_name'] );

            $extension = pathinfo( $_FILES[$inputName]['name'], PATHINFO_EXTENSION );

            $filename = $videoType . '-' . $id . '-' . md5( $videoFileContents ) . '.' . $extension;

            $thumbnailUrl = $site->generateAmazonVideoThumbnail( $filename );

            $video = $site->createVideo( $filename );

            $site->uploadVideoToAmazon( $videoFileContents, $filename );

            $site->startAmazonTranscoderJob( $video, $videoType, false );
        }

        return $video;
    }
}


?>
