<?php
/**
 * Asp_View_Helper
 *
 * @category   BeMaverick
 * @package    BeMaverick_View_Helper
 */
class BeMaverick_View_Helper_FormatPageTracking
{
    /**
     * Get all the page tracker info
     *
     * @return array
     */

    /**
     * Returns this helper
     *
     * @return BeMaverick_View_Helper_FormatPageTracking
     */
    public function formatPageTracking()
    {
        return $this;
    }

    /**
     * Get page tracking info
     *
     * @param Sly_Config_Page $pageConfig
     * @return array
     */
    public function getTrackingInfo( $pageConfig = null )
    {
        if ( $this->view->noPageTracking ) {
            return array();
        }

        $loginUser = $this->view->loginUser;

        return array(
            'userId' => $loginUser ? $loginUser->getId() : null,
            'identify' => $this->getIdentifyDetails( $loginUser ),
            'page' => $this->getPageDetails( $pageConfig ),
        );
    }

    /**
     * Get identify details
     *
     * @param BeMaverick_User $user
     * @return array
     */
    public function getIdentifyDetails( $user )
    {
        if ( ! $user ) {
            return array();
        }
        $identify = array();
        $identify['emailAddress'] = $user->getEmailAddress();
        $identify['firstName'] = $user->getFirstName();
        $identify['lastName'] = $user->getLastName();
        $identify['parentEmailAddress'] = $user->getParentEmailAddress();
        $identify['isTeen'] = $user->isTeen();
        $identify['username'] = $user->getUsername();
        $idenitfy['hasBio'] =  method_exists( ( $user ), 'getBio' ) && $user->getBio() ? true : false;
        $idenitfy['hasAvatar'] = $user->getProfileImage() ? true : false;

        return $identify;
    }

    /**
     * Get page details
     *
     * @param Sly_Config_Page $pageConfig
     * @return array
     */
    public function getPageDetails( $pageConfig )
    {
        if ( ! $pageConfig ) {
            return array();
        }
        $page = array();
        $url = $this->getUrl();
        $parsedUrl = parse_url( $url );
        $pageType = $pageConfig->getType();
        $pagePath = isset( $parsedUrl['path'] ) ? $parsedUrl['path'] : '/';

        if ( $pageType == 'users' ) { // for user pages
            $pagePath = '/users';
            $user = $this->view->user;
            if ( $user ) {
                $page['id'] = $user->getId();
                $page['contentType'] = 'User';
            }
        } else if ( $pageType == 'challenges' ) { // for challenge pages
            $pagePath = '/challenges';
            $challenge = $this->view->challenge;
            if ( $challenge ) {
                $page['id'] = $challenge->getId();
                $page['contentType'] = 'Challenge';
                $page['challengeTitle'] = $challenge->getTitle();
            }
        } else if ( $pageType == 'responses' ) { // for response pages
            $pagePath = '/responses';
            $response = $this->view->response;
            if ( $response ) {
                $page['id'] = $response->getId();
                $page['contentType'] = 'Response';
                $responseChallenge = $response->getChallenge();
                if ( $responseChallenge ) {
                    $page['challengeId'] = $responseChallenge->getId();
                    $page['challengeTitle'] = $responseChallenge->getTitle();
                }
            }
        }

        $page['url'] = $url;
        $page['path'] = $pagePath;
        return $page;
    }

    /**
     * Format a string
     *
     * @param string $string
     * @return string
     */
    public function replaceNames( $string )
    {
        return str_replace( '-', ' ', strtolower( preg_replace( '/(.*?[a-z]{1})([A-Z]{1}.*?)/', '${1} ${2}', $string ) ) );
    }

    /**
     *  Remove params from a query
     *
     * @param string $url
     * @param string $paramName
     * @return string
     */
    public function removeQueryParam($url, $paramName)
    {
        list( $urlpart, $qspart ) = array_pad( explode( '?', $url ), 2, '' );
        if ( !$qspart ) {
            return $url;
        }
        parse_str( $qspart, $qsvars );
        unset( $qsvars[$paramName] );
        $newqs = http_build_query( $qsvars );
        if ( $newqs ) {
            return $urlpart . '?' . $newqs;
        } else {
            return $urlpart;
        }
    }

    /**
     *  Get the current request url
     *
     * @return string
     */
    public function getUrl()
    {
        $systemConfig = $this->view->systemConfig;
        $currentUrl = $systemConfig->getCurrentUrl( true );
        $server = $systemConfig->getHttpHost( false );

        $url = $this->removeQueryParam( 'https://'.$server.$currentUrl, 'rnd' );
        $url = $this->removeQueryParam( $url, 'mobile' );
        $url = $this->removeQueryParam( $url, 'slide' );
        $url = $this->removeQueryParam( $url, 'pbv' );
        $url = $this->removeQueryParam( $url, 'history' );
        $url = $this->removeQueryParam( $url, 'ajax' );
        $url = $this->removeQueryParam( $url, 'password' );
        $url = $this->removeQueryParam( $url, 'passwordConfirm' );
        $url = $this->removeQueryParam( $url, 'emailAddress' );
        $url = $this->removeQueryParam( $url, 'elemId' );
        $url = $this->removeQueryParam( $url, 'requestName' );

        return $url;
    }


    /**
     * Set the view to this object
     *
     * @param Zend_View_Interface $view
     * @return void
     */
    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }
}
