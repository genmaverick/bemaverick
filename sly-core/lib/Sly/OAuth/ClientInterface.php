<?php

/**
 * Created by PhpStorm.
 * User: sakram
 * Date: 3/4/17
 * Time: 3:06 PM
 */
interface Sly_OAuth_ClientInterface
{
    /**
     * Get the id
     *
     * @return string
     */
    public function getId();

    /**
     * Get the key
     *
     * @return string
     */
    public function getKey();

    /**
     * Get the name
     *
     * @return string
     */
    public function getName();

    /**
     * Get the app secret
     *
     * @return string
     */
    public function getSecret();

    /**
     * Get the access scope space separated.
     * Should be space-separated scopes
     *
     * @return string
     */
    public function getScope();

    /**
     * Get the auth token ttl
     *
     * @return string
     */
    public function getAuthTokenTTL();

    /**
     * Get the platform
     *
     * @return string
     */
    public function getPlatform();

    /**
     * Check if the app has access
     *
     * @var string $accessType read or write
     * @return boolean
     */
    public function hasAccess( $accessType );

    /**
     * Gets the client's image url logo
     *
     * @return string
     */
    public function getLogoUrl();

    /**
     * Gets the OAuth redirect Url
     *
     * @return string
     */
    public function getRedirectUrl();

    /**
     * Gets the grant types the client's allowed to work with
     *
     * @return string
     */
    public function getGrantTypes();

}