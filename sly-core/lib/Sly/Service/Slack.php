<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Http/Client.php' );

/**
 * Class for the slack service
 *
 * @category Sly
 * @package Sly_Service
 */
class Sly_Service_Slack
{

    /**
     * Send the message to slack channel
     *
     * @param string $message
     * @return void
     */
    public static function sendChannelMessage( $token, $channel, $message )
    {
        $tokens = array();
        if ( is_array($token) ) {
            $tokens = $token;
        } else {
            $tokens[] = $token;
        }

        $channels = array();
        if ( is_array($channel) ) {
            $channels = $channel;
        } else {
            $channels[] = $channel;
        }

        //$message = urlencode( $message );
        $client = new Zend_Http_Client( 'https://slack.com/api/chat.postMessage' );
        $client->setParameterGet( 'text', $message );
        $client->setParameterGet( 'pretty', '1' );
        try {

            $numTimes = min( count($tokens), count($channels) );
            for ($idx = 0; $idx < $numTimes; $idx++ ) {
                $client->setParameterGet( 'token', $tokens[$idx] );
                $client->setParameterGet( 'channel', $channels[$idx] );
                $response = $client->request( 'GET' );
            }

        }
        catch( Zend_Exception $e ) {
            error_log( "Sly_Service_Slack::sendChannelMessage : " . $e->getMessage() );
            return;
        }
        // we don't care about the output
        return;
    }
}

?>