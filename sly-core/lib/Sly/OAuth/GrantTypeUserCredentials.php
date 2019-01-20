<?php
/**
 * Created by PhpStorm.
 * User: sakram
 * Date: 4/13/17
 */

class Sly_OAuth_GrantTypeUserCredentials extends \OAuth2\GrantType\UserCredentials
{
    /**
     * Whether or not to include refresh token in the access token
     * @var boolean
     */
    protected $_includeRefreshToken = true;

    /**
     * Sly_OAuth_GrantTypeUserCredentials constructor.
     *
     * @param OAuth2\Storage\UserCredentialsInterface $storage REQUIRED Storage class for retrieving user credentials information
     * @param array $config
     */
    public function __construct(OAuth2\Storage\UserCredentialsInterface $storage, $config = array())
    {
        parent::__construct( $storage );

        if ( isset( $config['include_refresh_token'] ) ) {
            $this->_includeRefreshToken =  $config['include_refresh_token'];
        }
    }

    /**
     * Creates access token for the user
     *
     * @param \OAuth2\ResponseType\AccessTokenInterface $accessToken
     * @param string $client_id
     * @param string $user_id
     * @param string $scope
     * @return mixed
     */
    public function createAccessToken(\OAuth2\ResponseType\AccessTokenInterface $accessToken, $client_id, $user_id, $scope)
    {
        return $accessToken->createAccessToken($client_id, $user_id, $scope, $this->_includeRefreshToken);
    }

}