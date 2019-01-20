<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class ShareController extends BeMaverick_Controller_Base
{
    const SHARE_OBJECT_TYPE_CHALLENGE = 'challenge';
    const SHARE_OBJECT_TYPE_RESPONSE = 'response';
    const SHARE_OBJECT_TYPE_USER = 'user';

    /**
     * Handle inbound share links from Branch.io
     *
     * @return void
     */
    public function inboundAction()
    {
        // get the view variables
        $errors = $this->view->errors;
        $site = $this->view->site;         /* @var BeMaverick_Site $site */

        // declare variables
        $redirectUrl = null;
        $replaceHeader = true;
        $redirectStatusCode = 302;

        // load request parameters
        $params = $this->_getAllParams();
        $objectType = $this->_getParam('objectType', null);
        $objectId = $this->_getParam('objectId', null);

        // test for required variables
        if (!$objectType || !$objectId) {
            $errors->setError('', 'SHARE_LINK_INVALID');
            return $this->renderPage( 'errors' );
        }

        // determine redirect URL
        switch ( $objectType ) {
            case self::SHARE_OBJECT_TYPE_CHALLENGE :
                $challenge = $site->getChallenge( $objectId );
                $redirectUrl = $challenge ? $challenge->getUrl() : null;
                break;
            case self::SHARE_OBJECT_TYPE_RESPONSE :
                $response = $site->getResponse( $objectId );
                $redirectUrl = $response ? $response->getUrl() : null;
                break;
            case self::SHARE_OBJECT_TYPE_USER :
                $user = $site->getUser( $objectId );
                $redirectUrl = $user ? $user->getUrl() : null;
                break;
            default:
                break;
        }

        if (!$redirectUrl) {
            $errors->setError('', 'SHARE_LINK_NOT_FOUND');
        }

        $redirectUrl .= "?share=true";

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // redirect the user
        return $this->_redirect( $redirectUrl );

    }


}
