<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Mobile/Push/Apns.php' );

class Sly_Mobile_Push_Apns
{

    /**
     * Send a notification to a user
     *
     * @return void
     */
    public function sendNotification( $deviceToken, $alertText, $customData = null, $badgeCount = 1, $logger = null )
    {
        if ( ! $deviceToken ) {
            return;
        }
        
        if ( Zend_Registry::isRegistered( 'logger' ) ) {
            Zend_Registry::get( 'logger' )->info( "sending alert '$alertText' to device: $deviceToken" );
        }
        else {
            error_log( "sending alert '$alertText' to device: $deviceToken" );
        }
            
        $message = new Zend_Mobile_Push_Message_Apns();
        $message->setToken( $deviceToken );
        $message->setAlert( $alertText );
        $message->setBadge( $badgeCount );
        $message->setSound( 'default' );
        $message->setId( time() );

        if ( $customData ) {
            foreach( $customData as $key => $value ) {
                $message->addCustomData( $key, $value );
            }
        }
     
        $apns = new Zend_Mobile_Push_Apns();
        $apns->setCertificate( SYSTEM_APPLE_PUSH_SERVICE_CERTIFICATE_FILE );
        $apns->setCertificatePassphrase( SYSTEM_APPLE_PUSH_SERVICE_CERTIFICATE_PASSPHRASE );
     
        try {
            $apns->connect( SYSTEM_APPLE_PUSH_SERVICE_SERVER_URI_INDEX );
        }
        catch (Zend_Mobile_Push_Exception_ServerUnavailable $e) {
            // you can either attempt to reconnect here or try again later
            return;
        }
        catch (Zend_Mobile_Push_Exception $e) {
            error_log( 'Sly_Mobile_Push_Apns::sendNotification Error:' . $e->getMessage() );
            return;
        }
     
        try {
            $apns->send( $message );
        }
        catch (Zend_Mobile_Push_Exception_InvalidToken $e) {
            // you would likely want to remove the token from being sent to again
            error_log( 'Sly_Mobile_Push_Apns::sendNotification Error:' . $e->getMessage() );
        }
        catch (Zend_Mobile_Push_Exception $e) {
            // all other exceptions only require action to be sent
            error_log( 'Sly_Mobile_Push_Apns::sendNotification Error:' . $e->getMessage() );
        }
    
        $apns->close();
    }

}

?>
