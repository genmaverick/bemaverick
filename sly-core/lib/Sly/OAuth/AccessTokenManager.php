<?php

if ( defined( 'OAUTH_ROOT_DIR' ) && file_exists( OAUTH_ROOT_DIR . '/autoload.php' ) ) {
    require_once( OAUTH_ROOT_DIR . '/autoload.php' );
}

use \Firebase\JWT\JWT;

/**
 * Created by PhpStorm.
 * User: sakram
 * Date: 3/3/17
 * Time: 3:25 PM
 */
class Sly_OAuth_AccessTokenManager implements \OAuth2\ResponseType\AccessTokenInterface
{

    /**
     * The default token time-to-live, 1 day, if none found.
     */
    const DEFAULT_TOKEN_TTL = 86400;

    /**
     * @var string
     */
    protected $_accessTokenSigningSecret;

    /**
     * @var Sly_OAuth_Pdo
     */
    protected $_refreshStorage;


    /**
     * @var array
     */
    protected $_config;

    /**
     * @var integer
     */
    protected $_tokenTTL;

    /**
     * Sly_OAuth_AccessTokenManager constructor.
     *
     * @param \OAuth2\Storage\RefreshTokenInterface|null $refreshStorage
     * @param array $config
     */
    public function __construct( Sly_OAuth_Pdo $refreshStorage = null, array $config = array() )
    {
        $this->_refreshStorage = $refreshStorage;

        $this->_config = array_merge(array(
            'token_type'             => 'bearer',
            'refresh_token_lifetime' => 1209600, // 14 days.
        ), $config);

        $this->_tokenTTL = self::DEFAULT_TOKEN_TTL;
    }

    /**
     * @deprecated
     *
     * Was being used to set the token's TTL based on client configuration.
     * @see setTokenTTL to do just that.
     *
     * @param Sly_OAuth_ClientInterface $client
     */
    public function setClient( Sly_OAuth_ClientInterface $client ) {
        $clientTokenTTL = (int) $client->getAuthTokenTTL();
        if ( $clientTokenTTL != 0 ) {
            $this->_tokenTTL = $clientTokenTTL;
        }
     }

    /**
     * @param integer $ttl the token's TTL in seconds
     */
    public function setTokenTTL( $ttl ) {
        $ttl = (int) $ttl;
        if ( $ttl > 0) {
            $this->_tokenTTL = $ttl;
        }
    }

    /**
     * Sets the secret with which acess token will be signed.
     *
     * @param string $secret
     */
    public function setAccessTokenSigningSecret( $secret ) {
        $this->_accessTokenSigningSecret = $secret;
    }

    /**
     * Creates the OAuth Token Response
     *
     * @param \OAuth2\ResponseType\client $clientId
     * @param \OAuth2\ResponseType\user|null $userId
     * @param null $scope
     * @param bool $includeRefreshToken
     *
     * @throws \LogicException
     * @return array
     */
    public function createAccessToken($clientId, $userId = null, $scope = null, $includeRefreshToken = true)
    {
        if ( !$this->_accessTokenSigningSecret ) {
            throw new LogicException( 'Signing secret not set. Please call setAccessTokenSigningSecret first.' );
        }

        $token = array(
            "access_token" => $this->generateAccessToken( $clientId, $userId ),
            "expires_in" => $this->_tokenTTL,
            "token_type" => $this->_config[ 'token_type' ],
            "scope" => $scope,
            "user_id" => $userId,            
        );

        /*
         * Issue a refresh token also, if we support them
         *
         * Refresh Tokens are considered supported if an instance of OAuth2\Storage\RefreshTokenInterface
         * is supplied in the constructor
         */
        if ($includeRefreshToken && $this->_refreshStorage) {

            $expires = 0;
            if ($this->_config[ 'refresh_token_lifetime' ] > 0) {
                $expires = time() + $this->_config[ 'refresh_token_lifetime' ];
            }

            $userRefreshToken = $this->_refreshStorage->getLatestUserRefreshToken( $userId, $clientId, $expires );

            if ( is_null( $userRefreshToken ) ) {
                $userRefreshToken = $this->generateRefreshToken();
                $this->_refreshStorage->setRefreshToken($userRefreshToken, $clientId, $userId, $expires, $scope);
            }

            $token[ "refresh_token" ] = $userRefreshToken;
        }

        return $token;
    }

    /**
     * Constructs the redirect URI
     *
     * @param $params
     * @param null $user_id
     * @return array
     */
    public function getAuthorizeResponse($params, $user_id = null)
    {
        // build the URL to redirect to
        $result = array('query' => array());

        $params += array('scope' => null, 'state' => null);

        /*
         * a refresh token MUST NOT be included in the fragment
         *
         * @see http://tools.ietf.org/html/rfc6749#section-4.2.2
         */
        $includeRefreshToken = false;
        $result["fragment"] = $this->createAccessToken($params['client_id'], $user_id, $params['scope'], $includeRefreshToken);

        if (isset($params['state'])) {
            $result["fragment"]["state"] = $params['state'];
        }

        return array($params['redirect_uri'], $result);
    }

    /**
     * Generates the JWT
     *
     * @param string $clientId The client Id
     * @param string|null $userId The userId
     * @return string
     *
     * @throws \LogicException
     */
    protected function generateAccessToken( $clientId, $userId = null )
    {
        if ( !$clientId ) {
            throw new LogicException( 'client_id or client cannot be null. Please call setClient first.' );
        }

        if ( !$this->_accessTokenSigningSecret ) {
            throw new LogicException( 'Access token signing secret cannot be null. Please call setAccessTokenSigningSecret first.' );
        }

        $payload = array(
            "iss"           => $clientId,
            "exp"           => time() + $this->_tokenTTL,
        );

        if ( $userId ) {
            $payload[ 'sub' ] = $userId;
        }

        $jwt = JWT::encode( $payload, $this->_accessTokenSigningSecret, $alg = 'HS256' );

        return $jwt;
    }

    /**
     * Returns an array of the token validation exercise.
     *
     * @param string $jwt
     * @return array
     *
     * @throws LogicException Got secret to work with
     */
    public function validateToken( $jwt ) {

        if ( !$this->_accessTokenSigningSecret ) {
            throw new LogicException( 'Signing secret cannot be null. Please call setAccessTokenSigningSecret first.' );
        }

        $result = array(
            'valid' => false,
        );

        try {
            $data = $this->decodeToken( $jwt );
            $result[ 'valid' ] = true;
            $result[ 'data'  ] = $data;
        }
        catch ( Exception $ex ) {
            $result[ 'valid'  ] = false;
            $result[ 'reason' ] = $ex->getMessage();
        }

        return $result;
    }

    /**
     * Decodes JWT into object
     *
     * @param string $jwt
     * @return array
     *
     * @throws LogicException               Got no JWT or secret to work with
     * @throws UnexpectedValueException     Provided JWT was invalid
     * @throws SignatureInvalidException    Provided JWT was invalid because the signature verification failed
     * @throws BeforeValidException         Provided JWT is trying to be used before it's eligible as defined by 'nbf'
     * @throws BeforeValidException         Provided JWT is trying to be used before it's been created as defined by 'iat'
     * @throws ExpiredException             Provided JWT has since expired, as defined by the 'exp' claim
     */
    public function decodeToken( $jwt ) {

        if ( !$jwt ) {
            throw new LogicException( 'jwt cannot be null' );
        }

        if ( !$this->_accessTokenSigningSecret ) {
            throw new LogicException( 'Signing secret cannot be null. Please call setAccessTokenSigningSecret first.' );
        }

        $decoded = JWT::decode( $jwt, $this->_accessTokenSigningSecret, array('HS256'));
        return $decoded;
    }

    /**
     * Generates an unique refresh token
     *
     * Implementing classes may want to override this function to implement
     * other refresh token generation schemes.
     *
     * @return
     * An unique refresh.
     */
    protected function generateRefreshToken()
    {
        if (function_exists('openssl_random_pseudo_bytes')) {
            $randomData = openssl_random_pseudo_bytes(20);
            if ($randomData !== false && strlen($randomData) === 20) {
                return bin2hex($randomData);
            }
        }
        if (function_exists('mcrypt_create_iv')) {
            $randomData = mcrypt_create_iv(20, MCRYPT_DEV_URANDOM);
            if ($randomData !== false && strlen($randomData) === 20) {
                return bin2hex($randomData);
            }
        }
        if (@file_exists('/dev/urandom')) { // Get 100 bytes of random data
            $randomData = file_get_contents('/dev/urandom', false, null, 0, 20);
            if ($randomData !== false && strlen($randomData) === 20) {
                return bin2hex($randomData);
            }
        }
        // Last resort which you probably should just get rid of:
        $randomData = mt_rand() . mt_rand() . mt_rand() . mt_rand() . microtime(true) . uniqid(mt_rand(), true);

        return substr(hash('sha512', $randomData), 0, 40);
    }

}
