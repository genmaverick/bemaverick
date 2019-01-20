<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Mobile/Push/Gcm.php' );

class Sly_Mobile_Push_Gcm
{

    /**
     * Send a notification to a user
     *
     * @return void
     */
    public function sendNotification( $deviceToken, $data = null, $logger = null )
    {
        if ( ! $deviceToken ) {
            return;
        }

        if ( Zend_Registry::isRegistered( 'logger' ) ) {
            Zend_Registry::get( 'logger' )->info( "sending alert '{$data['text']}' to device: $deviceToken" );
        }
        else {
            error_log( "sending alert '{$data['text']}' to device: $deviceToken" );
        }
                
        $message = new Zend_Mobile_Push_Message_Gcm();
        $message->setToken( $deviceToken );

        foreach( $data as $key => $value ) {
            $message->addData( $key, $value );
        }
     
        $gcm = new Zend_Mobile_Push_Gcm();
        $gcm->setApiKey( SYSTEM_GCM_PUSH_SERVICE_API_KEY );
     
        $response = null;
        
        try {
            $response = $gcm->send( $message );
        }
        catch (Zend_Mobile_Push_Exception_InvalidToken $e) {
            // you would likely want to remove the token from being sent to again
            error_log( 'Sly_Mobile_Push_Gcm::sendNotification Error:' . $e->getMessage() );
        }
        catch (Zend_Mobile_Push_Exception $e) {
            // all other exceptions only require action to be sent
            error_log( 'Sly_Mobile_Push_Gcm::sendNotification Error:' . $e->getMessage() );
        }
    
        return $response;
    }

}

?>
