<?php

use OAuth2\Storage\RefreshTokenInterface;
use OAuth2\ResponseType\AccessTokenInterface;
use OAuth2\GrantType\GrantTypeInterface;
use OAuth2\RequestInterface;
use OAuth2\ResponseInterface;

class Sly_OAuth_GrantTypeRefreshToken implements GrantTypeInterface
{
    private $refreshToken;

    protected $storage;
    protected $config;

    /**
     * @param OAuth2\Storage\RefreshTokenInterface $storage REQUIRED Storage class for retrieving refresh token information
     * @param array                                $config  OPTIONAL Configuration options for the server
     *                                                      <code>
     *                                                      $config = array(
     *                                                      'always_issue_new_refresh_token' => true, // whether to issue a new refresh token upon successful token request
     *                                                      'unset_refresh_token_after_use' => true // whether to unset the refresh token after after using
     *                                                      );
     *                                                      </code>
     */
    public function __construct(RefreshTokenInterface $storage, $config = array())
    {
        $this->config = array_merge(array(
            'always_issue_new_refresh_token' => false,
            'unset_refresh_token_after_use' => true
        ), $config);

        // to preserve B.C. with v1.6
        // @see https://github.com/bshaffer/oauth2-server-php/pull/580
        // @todo - remove in v2.0
        if (isset($config['always_issue_new_refresh_token']) && !isset($config['unset_refresh_token_after_use'])) {
            $this->config['unset_refresh_token_after_use'] = $config['always_issue_new_refresh_token'];
        }

        $this->storage = $storage;
    }

    public function getQuerystringIdentifier()
    {
        return 'refresh_token';
    }

    public function validateRequest(RequestInterface $request, ResponseInterface $response)
    {
        if (!$request->request("refresh_token")) {
            $response->setError(400, 'invalid_request', 'Missing parameter: "refresh_token" is required');

            return null;
        }

        if (!$refreshToken = $this->storage->getRefreshToken($request->request("refresh_token"))) {
            $response->setError(400, 'invalid_grant', 'Invalid refresh token');

            return null;
        }

        if ($refreshToken['expires'] > 0 && $refreshToken["expires"] < time()) {
            $response->setError(400, 'invalid_grant', 'Refresh token has expired');

            return null;
        }

        // store the refresh token locally so we can delete it when a new refresh token is generated
        $this->refreshToken = $refreshToken;

        return true;
    }

    public function getClientId()
    {
        return $this->refreshToken['client_id'];
    }

    public function getUserId()
    {
        return isset($this->refreshToken['user_id']) ? $this->refreshToken['user_id'] : null;
    }

    public function getScope()
    {
        return isset($this->refreshToken['scope']) ? $this->refreshToken['scope'] : null;
    }

    public function createAccessToken(AccessTokenInterface $accessToken, $client_id, $user_id, $scope)
    {
        $issueNewRefreshToken = $this->config['always_issue_new_refresh_token'];
        $token = $accessToken->createAccessToken($client_id, $user_id, $scope, $issueNewRefreshToken);
        return $token;
    }
}