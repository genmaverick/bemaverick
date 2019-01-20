<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Http/Client.php' );

/**
 * Class for the twotter service
 *
 * @category Sly
 * @package Sly_Service
 */
class Sly_Service_Twitter
{

    /**
     * Get instagram embed code
     *
     * @param string $twitterId
     * @param mixed $cache
     * @param boolean $omitScript
     * @return string
     */
    public static function getEmbedHtml( $twitterId, $cache, $omitScript = true )
    {

        $scriptParam = $omitScript ? '&omit_script=1' : '';

        $url = "https://api.twitter.com/1/statuses/oembed.json?id=$twitterId$scriptParam";
        $cacheKey = "sly_twitter_embed_code_$twitterId";
        $html = $cache->load( $cacheKey, $isHit );

        if ( ! $isHit ) {
            try {
                $ttl = 86400; // 1 day

                $client = new Zend_Http_Client( $url );
                $response = $client->request( 'GET' );
                $jsonData = json_decode( $response->getBody(), true );
                if ( $jsonData && isset( $jsonData['html'] ) ) {
                    $html = $jsonData['html'];
                } else {
                    $html = '';
                    $ttl = 60;
                }
            }
            catch( Zend_Exception $e ) {

                $ttl = 60; /* cache negative response for 60 seconds. */
            }

            $cache->save( $html, $cacheKey, $ttl );
        }

        return $html;
    }
}

?>
