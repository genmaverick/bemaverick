<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/config/autoload_oauth_dependencies.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Controller/OAuth2.php' );

class OauthController extends Sly_Controller_OAuth2
{

    /**
     * Whether or not to issue refresh token for password grant types
     *
     * @var boolean
     */
    protected $_isGrantTypePasswordRefreshTokenIssuable = true;

    public function init() {

        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $systemConfig = $this->view->systemConfig;  /* @var BeMaverick_Config_System $systemConfig; */

        // Access token signing secret comes from configuration
        $this->_accessTokenSigningSecret = $systemConfig->getAccessTokenSigningSecret();

        // Grab the OAuth Client
        if ( isset( $_REQUEST[ 'client_id' ] ) ) {
            $this->_client = $site->getApp( $_REQUEST[ 'client_id' ] );
        }

        // Grab the Authorization Database, which is just the MySQL Db for ncm-web.
        $this->_authorizationStorage = $site->getOAuthStorage();

        // Grab the user if applicable
        $this->_user = $this->establishUser();

        parent::init();
    }

    /**
     * Obtains the user applicable for the OAuth business.
     *
     * @return Sly_OAuth_UserInterface|null
     */
    private function establishUser()
    {
        $site = $this->view->site; /* @var BeMaverick_Site $site */

        // If we're exercising grant type password, the user obtained from backend, will be off the username field.
        // Then, supplied username/password here will be matched against the backend.
        if ( isset( $_REQUEST['grant_type'] ) && isset( $_REQUEST['username'] ) && $_REQUEST['grant_type'] == 'password' ) {
            $user = $site->getUserForOAuth( $_REQUEST['username'] );
            
            // Try email address as a backup
            if (!$user) {
                $user = $site->getUserByEmailAddress( $_REQUEST['username'], null );
            }

            if ( $user ) {
                return $user;
            } else {
                error_log( 'OAuth Grant Type Password Error. User not found for username: ' . $_REQUEST['username'] );
            }
        }

        return null;
    }

}

?>
