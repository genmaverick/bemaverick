<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Http/Client.php' );

class Sly_GeoData
{

    /**
     * Get the city and state of a zip code
     *
     * @return hash
     */
    public function getCityAndState( $zipCode )
    {
        try {

            $client = new Zend_Http_Client( 'http://where.yahooapis.com/geocode' );
            $client->setParameterGet( 'location', $zipCode );
            //$client->setParameterGet( 'format', 'json' );
            $client->setParameterGet( 'flags', 'J' );

            $response = $client->request( 'GET' );

            $contents = json_decode( $response->getBody() );
        }
        catch( Exception $e ) {
            error_log( "unable to get zip code data: " . $e->getMessage() );
            return false;
        }

    
        $data = array(
            //'city'  => $contents['ResultSet']['Result'][0]['city'],
            //'state' => $contents['ResultSet']['Result'][0]['state'],
            'city'  => (string) $contents->ResultSet->Results[0]->city,
            'state' => (string) $contents->ResultSet->Results[0]->state,
        );
    
        return $data;
    }

    /**
     * Get the latitude and longitude of a zip code
     *
     * @return hash
     */
    public static function getLatLong( $zipCode )
    {
        try {

            $client = new Zend_Http_Client( 'http://where.yahooapis.com/geocode' );
            $client->setParameterGet( 'location', $zipCode );
            //$client->setParameterGet( 'format', 'json' );
            $client->setParameterGet( 'flags', 'J' );

            $response = $client->request( 'GET' );

            $contents = json_decode( $response->getBody() );
        }
        catch( Exception $e ) {
            error_log( "unable to get zip code data: " . $e->getMessage() );
            return false;
        }
    
        $data = array(
            $contents->ResultSet->Results[0]->latitude,
            $contents->ResultSet->Results[0]->longitude,
        );

//        $data = array(
//            $contents['ResultSet']['Result'][0]['latitude'],
//            $contents['ResultSet']['Result'][0]['longitude'],
//        );
    
        return $data;
    }

    /**
     * Get the distance between two lat/longs
     *
     * @return integer
     */
    public static function calculateDistance( $lat1, $lon1, $lat2, $lon2, $unit)
    { 

        $theta = $lon1 - $lon2; 
        $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) +  cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta)); 
        $dist = acos($dist); 
        $dist = rad2deg($dist); 
        $miles = $dist * 60 * 1.1515;
        $unit = strtoupper($unit);

        if ($unit == "K") {
            return ($miles * 1.609344); 
        } 
        else if ($unit == "N") {
            return ($miles * 0.8684);
        }
        else {
            return $miles;
        }
    }

    /**
     * Get the geolocation from ip address
     *
     * @return hash
     */
    public static function getGeolocationFromIPAddress( $ipAddress )
    {
        try {

            $client = new Zend_Http_Client( "http://ipinfo.io/$ipAddress/geo" );

            $response = $client->request( 'GET' );

            $contents = json_decode( $response->getBody(), true );
        }
        catch( Exception $e ) {
            error_log( "unable to get zip code data: " . $e->getMessage() );
            return null;
        }

        return $contents;    
    }

}
