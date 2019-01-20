<?php
require_once( ZEND_ROOT_DIR . '/lib/Zend/Http/Client.php' );

/**
 * Class for the instagram service
 *
 * @category Sly
 * @package Sly_Service
 */
class Sly_Service_Instagram
{
    /**
     * Get instagram embed data
     *
     * @param string $instagramId
     * @param mixed $cache
     * @param boolean $omitScript
     * @return array
     */
    public static function getEmbedData( $instagramId, $cache, $omitScript = false )
    {
        $omitScriptParam = $omitScript ? '&omitscript=1' : '';
        $url = "https://www.instagram.com/publicapi/oembed/?url=http://instagr.am/p/$instagramId/$omitScriptParam";
        $omitScriptCacheParam = $omitScript ? '1' : '0';
        $cacheKey = "sly_instagram_embed_data_{$instagramId}_$omitScriptCacheParam";

        $jsonData = $cache->load( $cacheKey, $isHit );

        if ( ! $isHit ) {

            try {
                $ttl = 86400; // 1 day
                $client = new Zend_Http_Client( $url );
                $response = $client->request( 'GET' );
                $jsonData = json_decode( $response->getBody(), true );
            }
            catch( Zend_Exception $e ) {

                $ttl = 60; /* cache negative response for 60 seconds. */
            }

            $cache->save( $jsonData, $cacheKey, $ttl );
        }

        return $jsonData;
    }

    /**
     * Get instagram public user data
     *
     * @param string $instagramId
     * @param mixed $cache
     * @return array
     */
    public static function getPublicUserData( $instagramId, $cache )
    {

        $url = "https://www.instagram.com/$instagramId/?__a=1";
        $cacheKey = "sly_instagram_user_data_{$instagramId}";

        $jsonData = $cache->load( $cacheKey, $isHit );

        if ( ! $isHit ) {

            try {
                $ttl = 86400; // 1 day
                $client = new Zend_Http_Client( $url );
                $response = $client->request( 'GET' );
                $jsonData = json_decode( $response->getBody(), true );
            }
            catch( Zend_Exception $e ) {

                $ttl = 60; /* cache negative response for 60 seconds. */
            }

            $cache->save( $jsonData, $cacheKey, $ttl );
        }

        return $jsonData;
    }

    /**
     * Get instagram profile image url
     *
     * @param string $instagramId
     * @param mixed $cache
     * @return string
     */
    public static function getUserProfileImageUrl( $instagramId, $cache )
    {
        $jsonData = Sly_Service_Instagram::getPublicUserData( $instagramId, $cache );

        if ( $jsonData
             && isset( $jsonData['graphql'] )
             && isset( $jsonData['graphql']['user'] )
             && isset( $jsonData['graphql']['user']['profile_pic_url_hd'] )
         ) {
            return $jsonData['graphql']['user']['profile_pic_url_hd'];
        }

        return '';
    }

    /**
     * Get instagram embed html
     *
     * @param string $instagramId
     * @param mixed $cache
     * @param boolean $omitScript
     * @return string
     */
    public static function getEmbedHtml( $instagramId, $cache, $omitScript = false )
    {
        $jsonData = Sly_Service_Instagram::getEmbedData( $instagramId, $cache, $omitScript );

        if ( $jsonData && isset( $jsonData['html'] ) ) {
            return $jsonData['html'];
        }

        return '';
    }
}

?>
