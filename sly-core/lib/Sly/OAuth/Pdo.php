<?php

/**
 * Created by PhpStorm.
 * User: sakram
 * Date: 3/7/17
 * Time: 11:30 AM
 */
class Sly_OAuth_Pdo extends \OAuth2\Storage\Pdo
{
    public function __construct($connection, array $config = array())
    {
        parent::__construct($connection, $config);
        $this->config['user_clients_authorized_table'] = 'oauth_user_authorized_clients';
    }

    /**
     * Retrieves row see if the user has authorized a client
     *
     * @param $user_id
     * @param $client_id
     * @return mixed
     */
    public function getUserAuthorizedClient( $user_id, $client_id )
    {
        $stmt = $this->db->prepare(sprintf('SELECT * from %s where user_id = :user_id and client_id = :client_id', $this->config['user_clients_authorized_table']));

        $stmt->execute(compact('user_id', 'client_id'));

        return $stmt->fetch(\PDO::FETCH_ASSOC);
    }

    /**
     * Checks to see if the user has authorized a client before
     *
     * @param $user_id
     * @param $client_id
     * @return bool
     */
    public function hasUserAuthorizedClient( $user_id, $client_id )
    {
        return $this->getUserAuthorizedClient( $user_id, $client_id ) ? true : false;
    }

    /**
     * Sets user preference in having authorized a client
     *
     * @param $user_id
     * @param $client_id
     * @param null $scope
     * @return bool
     */
    public function setUserAuthorizedClient( $user_id, $client_id, $scope = null)
    {
        // if it exists, update it.
        if ( $this->getUserAuthorizedClient( $user_id, $client_id ) ) {
            $stmt = $this->db->prepare($sql = sprintf('UPDATE %s SET scope=:scope where user_id=:user_id and client_id=:client_id', $this->config['user_clients_authorized_table']));
        } else {
            $stmt = $this->db->prepare(sprintf('INSERT INTO %s (user_id, client_id, scope) VALUES (:user_id, :client_id, :scope)', $this->config['user_clients_authorized_table']));
        }

        return $stmt->execute(compact('user_id', 'client_id', 'scope'));
    }

    /**
     * Revokes user's preference in having authorized a client
     *
     * @param $user_id
     * @param $client_id
     * @return bool
     */
    public function revokeUserAuthorizedClient( $user_id, $client_id )
    {
        $revoked = false;
        
        if ( $this->hasUserAuthorizedClient( $user_id, $client_id ) ) {
            $stmt = $this->db->prepare(sprintf('DELETE from %s where user_id = :user_id and client_id = :client_id', $this->config['user_clients_authorized_table']));
            $revoked = $stmt->execute(compact('user_id', 'client_id'));

            // Also delete any refresh tokens
            $this->deleteUserRefreshTokens( $user_id, $client_id );
        }

        return $revoked;
    }


    /**
     * @param $user_id string
     * @param $client_id string
     */
    public function deleteUserRefreshTokens( $user_id, $client_id )
    {
        // Also delete any refresh tokens
        $stmt = $this->db->prepare(sprintf('DELETE from %s where user_id = :user_id and client_id = :client_id', $this->config['refresh_token_table']));
        $stmt->execute(compact('user_id', 'client_id'));
    }


    /**
     * @param $user_id string
     * @param $client_id string
     * @param $expires unix timestamp
     * @return string|null
     */
    public function getLatestUserRefreshToken( $user_id, $client_id, $expires )
    {
        $stmt = $this->db->prepare(sprintf('SELECT refresh_token, expires FROM %s WHERE user_id = :user_id AND client_id = :client_id ORDER BY expires DESC LIMIT 1', $this->config['refresh_token_table']));
        $stmt->execute(compact('user_id', 'client_id'));
        $result = $stmt->fetch(\PDO::FETCH_ASSOC);

        if ( !$result ) {
            return null;
        }

        $refreshToken = $result['refresh_token'];
        $refreshTokenExpires = strtotime( $result['expires'] );

        // Latest refresh token has expired, nothing in the DB is good.
        // Clear out the user's refresh tokens, however many that may be.
        if ($refreshTokenExpires > 0 && $refreshTokenExpires < time()) {
            $this->deleteUserRefreshTokens( $user_id, $client_id );
            return null;
        } else {
            $this->updateUserRefreshTokenExpiration($refreshToken, $expires);
            return $refreshToken;
        }
    }

    /**
     * @param $refresh_token string
     * @param $expires unix timestamp
     * @return bool
     */
    public function updateUserRefreshTokenExpiration( $refresh_token, $expires )
    {
        // convert expires to datestring
        $expires = date('Y-m-d H:i:s', $expires);
        $stmt = $this->db->prepare(sprintf('UPDATE %s SET expires = :expires WHERE refresh_token = :refresh_token', $this->config['refresh_token_table']));
        return $stmt->execute(compact('refresh_token', 'expires'));
    }


}