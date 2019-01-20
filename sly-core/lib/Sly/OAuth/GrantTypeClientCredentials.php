<?php

/**
 * Created by PhpStorm.
 * User: sakram
 * Date: 3/6/17
 * Time: 3:19 PM
 */
class Sly_OAuth_GrantTypeClientCredentials implements \OAuth2\GrantType\GrantTypeInterface
{

    /**
     * @var Sly_OAuth_ClientInterface
     */
    protected  $_client;


    /**
     * @var Sly_OAuth_UserInterface
     */
    protected $_user;

    /**
     * Sly_OAuth_GrantTypeClientCredentials constructor.
     *
     * @param Sly_OAuth_ClientInterface $client
     * @param Sly_OAuth_UserInterface $user
     * 
     * @throws LogicException
     */
    public function __construct( Sly_OAuth_ClientInterface $client, Sly_OAuth_UserInterface $user = null)
    {
        if ( !$client ) {
            throw new LogicException( 'Client cannot be null' );
        }

        $this->_client = $client;
        $this->_user = $user;
    }


    public function getQuerystringIdentifier()
    {
        return 'client_credentials';
    }

    public function validateRequest(\OAuth2\RequestInterface $request, \OAuth2\ResponseInterface $response)
    {
        $client_id = $request->request( 'client_id' );
        if ( !$client_id ) $client_id = $request->query( 'client_id' ); // try looking for one more time.

        $client_secret = $request->request( 'client_secret' );
        if ( !$client_secret ) $client_secret = $request->query( 'client_secret' );

        if ( $this->_client->getId() !== $client_id && $this->_client->getSecret() !== $client_secret ) {
            $response->setError( 400, 'invalid_client', 'The client credentials are invalid' );
            return false;
        }

        return true;
    }

    public function getClientId()
    {
        return $this->_client->getId();
    }

    public function getUserId()
    {
        return $this->_user ? $this->_user->getId() : null;
    }

    public function getScope()
    {
        return $this->_client->getScope();
    }

    public function createAccessToken(\OAuth2\ResponseType\AccessTokenInterface $accessToken, $client_id, $user_id, $scope)
    {
        /**
         * Client Credentials Grant does NOT include a refresh token
         *
         * @see http://tools.ietf.org/html/rfc6749#section-4.4.3
         */
        $includeRefreshToken = false;

        return $accessToken->createAccessToken($client_id, $user_id, $scope, $includeRefreshToken);
    }


}