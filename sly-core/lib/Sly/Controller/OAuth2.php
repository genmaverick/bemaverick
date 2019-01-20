<?php

/**
 * Created by PhpStorm.
 * User: sakram
 * Date: 3/1/17
 * Time: 11:26 AM
 */

if ( defined( 'OAUTH_ROOT_DIR' ) && file_exists( OAUTH_ROOT_DIR . '/autoload.php' ) ) {
    require_once( OAUTH_ROOT_DIR . '/autoload.php' );
}

require_once( SLY_ROOT_DIR . '/lib/Sly/Controller/Base.php' );

require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/UserInterface.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/ClientInterface.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/AccessTokenManager.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/GrantTypeClientCredentials.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/GrantTypeUserCredentials.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/GrantTypeRefreshToken.php' );

require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/Pdo.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/StorageClientCredentials.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/StorageUserCredentials.php' );

class Sly_Controller_OAuth2 extends Sly_Controller_Base
{
    /**
     * Source of client information from the server-side storage.
     *
     * @var Sly_OAuth_ClientInterface
     */
    protected $_client;

    /**
     * Oauth Access Token Signing Secret
     *
     * @var string
     */
    protected $_accessTokenSigningSecret;

    /**
     * An interface to retrieve the logged-in user's info
     *
     * @var Sly_OAuth_UserInterface
     */
    protected $_user;

    /**
     * Authorization code storage and validation will
     * be connected to this storage.
     *
     * @var Sly_OAuth_Pdo
     */
    protected $_authorizationStorage;

    /**
     * @var \OAuth2\Server
     */
    protected $_server;

    /**
     * Whether or not to issue refresh token for password grant types
     *
     * @var boolean
     */
    protected $_isGrantTypePasswordRefreshTokenIssuable = false;

    public function init()
    {
        $errors = $this->view->errors; /* @var Sly_Errors $errors */

        if ( !$this->_client ) {
            $errors->setError( 'invalid_client', 'proper client credentials are required' );
            $this->view->format = 'json';
            return $this->renderPage( 'errors', 0, 400 );
        }

        if ( !$this->_accessTokenSigningSecret ) {
            $errors->setError( 'invalid_signing_secret', 'invalid signing secret in the system' );
            $this->view->format = 'json';
            return $this->renderPage( 'errors', 0, 400 );
        }

        // Token Generator/Validator Manager
        $accessTokenManager = new Sly_OAuth_AccessTokenManager( $this->_authorizationStorage );
        $accessTokenManager->setClient( $this->_client );
        $accessTokenManager->setAccessTokenSigningSecret( $this->_accessTokenSigningSecret );

        // Authorization Code Generator/Validator Manager
        $authorizationCodeManager = new \OAuth2\ResponseType\AuthorizationCode( $this->_authorizationStorage );

        // Client Credentials in Storage
        $storageClientCredentials = new Sly_OAuth_StorageClientCredentials( $this->_client, $this->_user );

        // User Credentials in Storage
        $storageUserCredentials = new Sly_OAuth_StorageUserCredentials( $this->_user );

        // Specify the storage actors.
        $storage = array(
            'client_credentials' => $storageClientCredentials,
            'client'             => $storageClientCredentials,
            'user_credentials'   => $storageUserCredentials,
            'authorization_code' => $this->_authorizationStorage,
            'refresh_token'      => $this->_authorizationStorage,
        );

        // Create the OAuth Server
        $this->_server = new OAuth2\Server($storage,
            $config = array(
                'enforce_state' => false,
            ),
            $grantTypes = array(
                // Adds the "Client Credentials" grant type (it is the simplest of the grant types)
                new Sly_OAuth_GrantTypeClientCredentials( $this->_client, $this->_user ),
                // Adds the "Authorization Code" grant type (this is where the oauth magic happens)
                new OAuth2\GrantType\AuthorizationCode( $this->_authorizationStorage ),
                // Adds the "Refresh Token" grant type
                new Sly_OAuth_GrantTypeRefreshToken( $this->_authorizationStorage,
                    array( 'always_issue_new_refresh_token' => true)
                ),
                // Adds the "Password" grant type
                new Sly_OAuth_GrantTypeUserCredentials( $storageUserCredentials,
                    array( 'include_refresh_token' => $this->_isGrantTypePasswordRefreshTokenIssuable )
                ),
            ),
            $responseTypes = array(
                'token' => $accessTokenManager,
                'code'  => $authorizationCodeManager,
            ),
            $tokenTypeInterface = null,
            $scopeUtil = null,
            $clientAssertionType = $storageClientCredentials
        );

        parent::init();
    }

    /**
     * token action
     *
     * Case A - Get token based on client credentials:
     * Verb: POST
     * grant_type=client_credentials
     * client_id=test_key
     * client_secret=test_secret
     *
     * Case B - Get token based on authorization code:
     * Verb: POST
     * grant_type=
     */
    public function tokenAction()
    {
        $errors = $this->view->errors; /* @var Sly_Errors $errors */

        // Can't proceed without a valid client or signing secret in the DB.
        // Response of invalid client or secret is handled in init().
        if ( !$this->_client || !$this->_accessTokenSigningSecret ) {
            return;
        }

        // Gets the token
        $response = $this->_server->handleTokenRequest(OAuth2\Request::createFromGlobals());

        /* @var \OAuth2\Response $response */
        if ( is_a( $response, '\OAuth2\Response' ) && $response->getStatusCode() >= 400 ) {
            foreach ( $response->getParameters() as $parameterKey => $parameterValue ) {
                if ( $parameterKey == 'error_description' ) {
                    $errors->setError( $parameterKey, $parameterValue );
                }
            }
            $this->view->format = 'json';
            return $this->renderPage( 'errors', 0, $response->getStatusCode() );
        }

        $response->send();
    }

    /**
     * authorization action
     */
    public function authorizeAction()
    {
        $errors = $this->view->errors; /* @var Sly_Errors $errors */

        if ( $errors->hasErrors() ) {
            $this->view->format = 'json';
            return $this->renderPage( 'errors', 0, 400 );
        }

        // Can't proceed without a valid Client
        // Response of invalid client is handled in init().
        if ( !$this->_client || !$this->_accessTokenSigningSecret ) {
            return;
        }

        // Can't proceed without a valid user
        if ( !$this->_user ) {
            $errors->setError( 'invalid_user', 'user required.' );
            $this->view->format = 'json';
            return $this->renderPage( 'errors', 0, 400 );
        }

        $userId = $this->_user->getId();
        $clientId = $this->_client->getId();

        // Fill the basic client info
        $response = new OAuth2\Response();
        $response->setParameters( array(
            'client_name' => $this->_client->getName(),
            'client_icon_image' => $this->_client->getLogoUrl(),
            'client_redirect_url' => $this->_client->getRedirectUrl(),
        ) );

        // We posting
        if ( $_SERVER['REQUEST_METHOD'] == 'POST' ) {
            $response->setParameter('authorization_code', $this->getAuthorizationCode($userId, $clientId) );
        } else {
            // Include an authorization code if the user has authorized in the past.
            if ( $this->_authorizationStorage->hasUserAuthorizedClient( $userId, $clientId )) {
                $response->setParameter('authorization_code', $this->getAuthorizationCode($userId, $clientId) );
            }
        }

        $response->send();
    }

    /**
     * token validation action
     */
    public function validateAction()
    {
        $errors = $this->view->errors; /* @var Sly_Errors $errors */

        // Can't proceed without a valid client or signing secret
        // Response of invalid client is handled in init().
        if ( !$this->_client || !$this->_accessTokenSigningSecret ) {
            return;
        }

        // Token Generator/Validator Manager
        $accessTokenManager = new Sly_OAuth_AccessTokenManager( $this->_authorizationStorage );
        $accessTokenManager->setClient( $this->_client );
        $accessTokenManager->setAccessTokenSigningSecret( $this->_accessTokenSigningSecret );

        $token = isset( $_GET['token'] ) ?  $_GET['token'] : '';

        $validationResult = $accessTokenManager->validateToken( $token );

        $response = new OAuth2\Response();
        foreach ( $validationResult as $key => $value ) {
            $response->setParameter( $key, $value );
        }
        if ( !$validationResult['valid'] ) {
            $errors->setError( 'invalid_token', 'Invalid Token' );
            $this->view->format = 'json';
            return $this->renderPage( 'errors', 0, 400 );
        }
        $response->send();
    }


    /**
     * Revokes user authorization of a client
     */
    public function revokeAction()
    {
        $errors = $this->view->errors; /* @var Sly_Errors $errors */

        // Can't proceed without a valid Client.
        // Response of invalid client is handled in init().
        if ( !$this->_client ) {
            return;
        }

        // Can't proceed without a valid user
        if ( !$this->_user ) {
            $errors->setError( 'invalid_user', 'user required.' );
            $this->view->format = 'json';
            return $this->renderPage( 'errors', 0, 400 );
        }

        $userId = $this->_user->getId();
        $clientId = $this->_client->getId();
        $revoked = $this->_authorizationStorage->revokeUserAuthorizedClient( $userId, $clientId );

        // Fill the basic status
        $response = new OAuth2\Response();
        $response->setParameter( 'revoked', $revoked );
        $response->setParameter( 'user_id', $userId );
        $response->setParameter( 'client_id', $clientId );

        $response->send();
    }

    /**
     * Gets the authorization code
     *
     * @return string
     */
    private function getAuthorizationCode( string $userId, string $clientId )
    {
        // Keep track of the authorization preference.
        $this->_authorizationStorage->setUserAuthorizedClient( $userId, $clientId );

        $_POST['response_type'] = 'code';
        $request = OAuth2\Request::createFromGlobals();
        $fakeResponse = new OAuth2\Response();

        $this->_server->handleAuthorizeRequest( $request, $fakeResponse, true, $this->_user->getId() );

        if ( $fakeResponse->isClientError() || $fakeResponse->isServerError() ) {
            $fakeResponse->send();
            exit(1);
        }

        // pull out the authorization code from the fake response.
        $code = substr($fakeResponse->getHttpHeader('Location'), strpos($fakeResponse->getHttpHeader('Location'), 'code=')+5, 40);

        return $code;
    }

}