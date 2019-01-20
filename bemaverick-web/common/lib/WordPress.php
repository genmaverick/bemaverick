<?php

/**
 * Class utility for the wordpress api
 *
 */
class BeMaverick_WordPress
{

    const CATEGORY_PARENTAL_RESOURCES = 2;
    const CATEGORY_STATIC_PAGES = 3;
    const DEFAULT_TTL = 86400;

    /**
     * Get the recent articles
     *
     * @param BeMaverick_Site $site
     * @param integer $numPosts
     * @param integer $categories
     * @param mixed $cache
     * @param integer $ttl
     * @return hash[]
     */
    public static function getPosts( $site, $numPosts = 3, $categories = self::CATEGORY_PARENTAL_RESOURCES, $cache = null, $ttl = self::DEFAULT_TTL )
    {
        $systemConfig = $site->getSystemConfig();

        $wordPressApiUrl = $systemConfig->getSetting( 'WORDPRESS_API_URL' );
        $wordPressApiUrl .= "/posts";

        $params = array(
            'page' => 1,
            'per_page' => $numPosts,
            'categories' => $categories
        );

        return self::_makeApiRequest( $wordPressApiUrl, $params, $cache, $ttl );
    }

    /**
     * Get a specific post
     *
     * @param BeMaverick_Site $site
     * @param integer $contentId
     * @param string $contentType
     * @param mixed $cache
     * @param integer $ttl
     * @return hash
     */
    public static function getPost( $site, $contentId, $cache = null, $contentType, $ttl = self::DEFAULT_TTL )
    {
        $systemConfig = $site->getSystemConfig();

        $wordPressApiUrl = $systemConfig->getSetting( 'WORDPRESS_API_URL' );
        $wordPressApiUrl = $wordPressApiUrl.'/'.$contentType.'/'.$contentId;

        return self::_makeApiRequest( $wordPressApiUrl, array(), $cache, $ttl );
    }

    /**
     * Get a piece of media
     *
     * @param BeMaverick_Site $site
     * @param integer $mediaId
     * @param mixed $cache
     * @param integer $ttl
     * @return hash
     */
    public static function getMedia( $site, $mediaId, $cache = null, $ttl = self::DEFAULT_TTL )
    {
        $systemConfig = $site->getSystemConfig();

        $wordPressApiUrl = $systemConfig->getSetting( 'WORDPRESS_API_URL' );
        $wordPressApiUrl .= "/media/$mediaId";

        return self::_makeApiRequest( $wordPressApiUrl, array(), $cache, $ttl );
    }

    /**
     * Get a user
     *
     * @param BeMaverick_Site $site
     * @param integer $userId
     * @param mixed $cache
     * @param integer $ttl
     * @return hash
     */
    public static function getUser( $site, $userId, $cache = null, $ttl = self::DEFAULT_TTL )
    {
        $systemConfig = $site->getSystemConfig();

        $wordPressApiUrl = $systemConfig->getSetting( 'WORDPRESS_API_URL' );
        $wordPressApiUrl .= "/users/$userId";

        return self::_makeApiRequest( $wordPressApiUrl, array(), $cache, $ttl );
    }


    /**
     * Make the specific api call to wordpress
     *
     * @param string $url
     * @param array $params
     * @param mixed $cache
     * @param integer $ttl
     * @param string $method
     * @return hash
     */
    protected static function _makeApiRequest( $url, $params = array(), $cache = null, $ttl = self::DEFAULT_TTL, $method = 'GET' )
    {
        if ( $cache ) {
            $paramString = $params ? ':'.http_build_query( $params, '', '_' ) : '';
            $cacheKey = 'bemaverick_wordpress_'.$url.$paramString;
            $jsonData = $cache->load( $cacheKey, $isHit );
            if ( $isHit ) {
                return $jsonData;
            }
        }

        $client = new Zend_Http_Client( $url );

        if ( $params ) {
            if ( $method == 'GET' ) {
                foreach ( $params as $key => $value ) {
                    $client->setParameterGet( $key, $value );
                }
            } else if ( $method == 'POST' ) {
                foreach ( $params as $key => $value ) {
                    $client->setParameterPost( $key, $value );
                }
            }
        }

        try {
            $response = $client->request( $method );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_WordPress::_makeApiRequest exception found: " . $e->getMessage() );
            return null;
        }

        if ( ! $response || $response->getStatus() != 200 ) {
            error_log( "BeMaverick_WordPress::_makeApiRequest response invalid: " . print_r( $response, true ) );
            return null;
        }

        $responseBody = $response->getBody();
        $jsonData = json_decode( $responseBody, true );

        if ( $cache ) {
            $cache->save( $jsonData, $cacheKey, $ttl );
        }

        return $jsonData;
    }

}

?>
