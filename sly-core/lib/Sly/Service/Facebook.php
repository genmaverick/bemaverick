<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Http/Client.php' );

/**
 * Class for the facebook service
 *
 * @category Sly
 * @package Sly_Service
 */
class Sly_Service_Facebook
{

    /**
     * Clear the share cache url for facebook
     *
     * @return void
     */
    public static function clearShareUrlCache( $url )
    {
        $client = new Zend_Http_Client( 'https://graph.facebook.com' );
        $client->setParameterPost( 'id', $url );
        $client->setParameterPost( 'scrape', 'true' );

        try {
            $response = $client->request( 'POST' );
        }
        catch( Zend_Exception $e ) {
            error_log( "Sly_Service_Facebook::clearShareUrlCache failed with exception: " . $e->getMessage() );
            return false;
        }

        return true;
    }

    /**
     * Get instagram embed code
     *
     * @return string
     */
    public static function getEmbedData( $facebookUrl, $cache, $omitscript = false, $width = "auto" )
    {

        $endPoint = strpos( $facebookUrl, 'video' ) === false ? "https://www.facebook.com/plugins/post/oembed.json/?" : "https://www.facebook.com/plugins/video/oembed.json/?";
        $cacheKey = 'sly_facebook_embed_code_'.$facebookUrl.'_'.$width.'_'.$omitscript;

        $args = array(
            'url' => $facebookUrl,
        );
        if ( $width != 'auto' ) {
            $args['maxwidth'] = $width;
        }

        if ( $omitscript ) {
            $args['omitscript'] = 1;
        }

        $jsonData = $cache->load( $cacheKey, $isHit );

        if ( ! $isHit ) {

            try {
                $ttl = 86400; // 1 day

                $client = new Zend_Http_Client( $endPoint );
                if ( count($args) ) {
                    $client->setParameterGet( $args );
                }
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


    public static function getEmbedHtml( $facebookUrl, $cache, $omitScript = false, $width = "auto" ) {

        $jsonData = Sly_Service_Facebook::getEmbedData( $facebookUrl, $cache, $omitScript, $width );
        $html = '';
        if ( $jsonData && isset( $jsonData['html'] ) ) {
            $html = $jsonData['html'];
        }
        return $html;

    }


    public static function getFacebookUserData( $accessToken, $fields = null )
    {
        $graphUrl = "https://graph.facebook.com/me?access_token=$accessToken";

        if ( $fields ) {
            $graphUrl .= '&fields='. join( ',', $fields );
        }

        $client = new Zend_Http_Client( $graphUrl );

        try {
            $response = $client->request( 'GET' );
        }
        catch( Zend_Exception $e ) {
            error_log( "AuthUser caught exception: $graphUrl : " . $e->getMessage() );
        }

        if ( $response && $response->getStatus() == 200 ) {
            return json_decode( $response->getBody() );
        }

        return null;
    }

}

?>
