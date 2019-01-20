<?php

/**
 * Created by PhpStorm.
 * User: sakram
 */
interface Sly_OAuth_UserInterface
{
    /**
     * Gets the user's unique id
     *
     * @return mixed
     */
    public function getOAuthId();

    /**
     * Gets the user's name.
     *
     * @return string
     */
    public function getOAuthName();

    /**
     * Gets the username, used for OAuth for password grant-type.
     * Email can be used here if that's what the user and password combo is.
     *
     * @return mixed
     */
    public function getOAuthUserName();

    /**
     * Checks to see if the supplied password matches to that of the user
     *
     * @param $password string
     * @return mixed
     */
    public function isOAuthPasswordMatched( $password );

}