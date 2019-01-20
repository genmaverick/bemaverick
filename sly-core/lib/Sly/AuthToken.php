<?php

class Sly_AuthToken
{
    /**
     * Generate the token
     *
     * @param string $appKey
     * @param integer $userId
     * @param integer $timestamp
     * @return string
     */
    public static function generate( $appKey, $userId, $timestamp, $environment )
    {
        return base64_encode( "$appKey&$userId&$timestamp&$environment" );
    }
 
    /**
     * Decode the auth token
     *
     * @param string $authToken
     * @return string
     */
    public static function decode( $authToken )
    {
        return base64_decode( $authToken );
    }

    /**
     * Generate the application auth token
     *
     * @param string $appKey
     * @param integer $timestamp
     * @return string
     */
    public static function generateAppToken( $appKey, $timestamp, $environment )
    {
        return base64_encode( "$appKey&$timestamp&$environment" );
    }
 
    /**
     * Decode the auth token
     *
     * @param string $authToken
     * @return string
     */
    public static function decodeAppToken( $authToken )
    {
        return base64_decode( $authToken );
    }
    

    
}

?>
