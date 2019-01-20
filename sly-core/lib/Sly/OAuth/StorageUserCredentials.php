<?php

/**
 * Created by PhpStorm.
 * User: sakram
 * Date: 3/7/17
 * Time: 10:00 AM
 */
class Sly_OAuth_StorageUserCredentials implements \OAuth2\Storage\UserCredentialsInterface
{
    /**
     * @var Sly_OAuth_UserInterface
     */
    protected $_user;

    /**
     * Sly_OAuth_StorageUserCredentials constructor.
     */
    public function __construct( Sly_OAuth_UserInterface $user = null )
    {
        $this->_user = $user;
    }

    public function checkUserCredentials($username, $password)
    {
        if ( !$this->_user ) {
            return false;
        }

        return strtolower($this->_user->getOAuthUserName()) == strtolower($username) && $this->_user->isOAuthPasswordMatched( $password );
    }

    public function getUserDetails($username)
    {
        if ( !$this->_user ) {
            return array();
        }

        return array(
            'user_id' => $this->_user->getOAuthId(),
            'scope'   => null,
        );
    }


}