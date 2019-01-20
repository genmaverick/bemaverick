<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Http/Client.php' );

/**
 * Class for the google service
 *
 * @category Sly
 * @package Sly_Service
 */
class Sly_Service_Google
{

    public static function getTokenInfo( $idToken )
    {
        $tokenInfoUrl = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=$idToken";

        $client = new Zend_Http_Client( $tokenInfoUrl );

        try {
            $response = $client->request( 'GET' );
        }
        catch( Zend_Exception $e ) {
            error_log( "Sly_Service_Google caught exception: $tokenInfoUrl : " . $e->getMessage() );
        }

        if ( $response && $response->getStatus() == 200 ) {
            $body = $response->getBody();
            return json_decode( $body );
        }

        error_log( "Sly_Service_Google response not 200: ". print_r( $response, true ) );
        
        return null;
    }

}

?>
