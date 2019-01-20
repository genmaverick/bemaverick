<?php

/**
 * Created by PhpStorm.
 * User: sakram
 * Date: 3/6/17
 * Time: 3:26 PM
 */
class Sly_OAuth_StorageClientCredentials
    implements
    \OAuth2\Storage\ClientCredentialsInterface,
    \OAuth2\ClientAssertionType\ClientAssertionTypeInterface
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
     * Sly_OAuth_ClientAssertionType constructor.
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

    public function checkClientCredentials($client_id, $client_secret = null)
    {
        return $this->_client->getKey() == $client_id && $this->_client->getSecret() == $client_secret;
    }

    public function isPublicClient($client_id)
    {
        $this->_client->getSecret() ? false : true;
    }

    public function getClientDetails($client_id)
    {
        $clientDetails = array(
            'redirect_uri' => $this->_client->getRedirectUrl(),
            'client_id' => $this->_client->getId(),
            'scope' => $this->getClientScope( $client_id ),
            'grant_types' => $this->_client->getGrantTypes(),
        );

        if ( $this->_user ) {
            $clientDetails[ 'user_id' ] = $this->_user->getId();
        }
        return $clientDetails;
    }

    public function getClientScope($client_id)
    {
        return $this->_client->getScope();
    }

    public function checkRestrictedGrantType($client_id, $grant_type)
    {
        $grantTypes = $this->_client->getGrantTypes();

        // empty, means, free for all
        if ( !$grantTypes ) {
            return true;
        }

        return strpos( $grantTypes, $grant_type ) > -1;
    }

    //
    public function validateRequest(\OAuth2\RequestInterface $request, \OAuth2\ResponseInterface $response)
    {
        $client_id = $request->request( 'client_id' );
        if ( !$client_id ) $client_id = $request->query( 'client_id' ); // try looking for one more time.

        $client_secret = $request->request('client_secret');
        if ( !$client_secret ) $client_secret = $request->query('client_secret');

        // TODO: Allow public clients?
        if ( !$this->checkClientCredentials( $client_id, $client_secret ) ) {
            $response->setError(400, 'invalid_client', 'The client credentials are invalid');
            return false;
        }

        return true;
    }

    public function getClientId()
    {
        return $this->_client->getId();
    }


}