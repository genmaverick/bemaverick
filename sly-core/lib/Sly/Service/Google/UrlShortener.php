<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Http/Client.php' );

class Sly_Service_Google_UrlShortener
{
    /**
     * Returns a google shortened url from a long url
     *
     * @param string $longUrl
     * @param string $apiKey
     * @return string
     */
    public static function getShortUrl( $longUrl, $apiKey )
    {
        $client = new Zend_Http_Client( 'https://www.googleapis.com/urlshortener/v1/url' );
        $client->setHeaders( Zend_Http_Client::CONTENT_TYPE, 'application/json' );
        $client->setParameterGet( 'fields', 'id' );
        $client->setParameterGet( 'key', $apiKey );

        $payload = json_encode(
            array(
                'longUrl' => $longUrl,
            )
        );

        $client->setRawData( $payload );

        try {
            $response = $client->request( 'POST' );
        }
        catch( Exception $e ) {
            error_log( "Sly_Service_Google_UrlShortener::getShortUrl exception caught: " . $e->getMessage() );
            return $longUrl;
        }

        $body = json_decode( $response->getBody(), true );

        if ( @$body['error'] ) {
            error_log( "Sly_Service_Google_UrlShortener::getShortUrl error found: " . $response->getBody() . ", $longUrl" );
            return $longUrl;
        }

        return $body['id'];
    }

}

?>
