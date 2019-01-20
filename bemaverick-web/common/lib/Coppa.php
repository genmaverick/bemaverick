<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Http/Client.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Coppalog.php' );

class BeMaverick_COPPA
{
    /**
     * Verify the identity of the parent through a third party verification service.
     *
     * @param BeMaverick_Site $site
     * @param string $kidUserId
     * @param string $firstName
     * @param string $lastName
     * @param string $address
     * @param string $zip
     * @param string $lastFourSSN
     * @param string $testKey
     * @return Array
     */
    public static function verifyParentIdentity( $site, $kidUserId, $firstName, $lastName, $address, $zip, $lastFourSSN, $testKey)
    {
        $systemConfig = $site->getSystemConfig();
        $environment = $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );
        $serviceUserName = $systemConfig->getSetting( 'VERATAD_USERNAME' );
        $servicePassword = $systemConfig->getSetting( 'VERATAD_PASSWORD' );
        $service = $systemConfig->getSetting( 'VERATAD_SERVICE' );
        $serviceURL = $systemConfig->getSetting( 'VERATAD_URL' );
        $client = new Zend_Http_Client( $serviceURL );
        $client->setHeaders( array( 'Content-Type' => 'application/json' ) );

        $body = array(
            'user'      => $serviceUserName,
            'pass'      => $servicePassword,
            'service'   => $service,
            'reference' => $kidUserId,
            'target'    => array(
                'fn'    => $firstName,
                'ln'    => $lastName,
                'addr'  => $address,
                'zip'   => $zip,
                'age'   => "18+",
                'ssn'   => $lastFourSSN,
            )
        );

        if ( $environment != 'production' && $environment != 'stage') {
            $body['target']['test_key'] = $testKey;
        }

        $client->setRawData( json_encode( $body ) );

        $result = array(
            'result' => array()
        );

        try {
            $response = $client->request( 'POST' );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_COPPA::IDVerification exception found: " . $e->getMessage() );
            $result['result'] = array(
                'action' => 'FAIL',
                'detail' => 'System Error'
            );

            //log the response
            $daCoppalogs = BeMaverick_Da_Coppalog::getInstance();
            $daCoppalogs->createlog( $kidUserId, $firstName, $lastName, $address, $zip, $lastFourSSN, $result );

            return $result;
        }

        if ( ! $response || $response->getStatus() != 200 ) {
            error_log( "BeMaverick_COPPA::IDVerification response invalid: " . print_r( $response, true ) );
            $result['result'] = array(
                'action' => 'FAIL',
                'detail' => 'Invalid response'
            );

            //log the response from veratad
            $daCoppalogs = BeMaverick_Da_Coppalog::getInstance();
            $daCoppalogs->createlog( $kidUserId, $firstName, $lastName, $address, $zip, $lastFourSSN, $result );

            return $result;
        } else if ( $response && $response->getStatus() == 200 ) {
            $responseResult = json_decode( $response->getBody(), true );
            $result['result'] = $responseResult['result'];

            //log the response from veratad
            $daCoppalogs = BeMaverick_Da_Coppalog::getInstance();
            $daCoppalogs->createlog( $kidUserId, $firstName, $lastName, $address, $zip, $lastFourSSN, $responseResult );
        }

        return $result;
    }
}
?>
