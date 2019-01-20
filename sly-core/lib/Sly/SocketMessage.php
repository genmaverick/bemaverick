<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/DataObject.php' );

/**
 * Class for messages
 *
 * Designed for use with Sly_SocketServer and Sly_SocketClient
 *
 * @description This class defines message for socket server and client
 * @category Sly
 * @package Sly_SocketMessage
 */

class Sly_SocketMessage extends Sly_DataObject {

    /**
     * Constants for message type
     */
    const MESSAGE_TYPE_ECHO           = 'echo';
    const MESSAGE_TYPE_QUIT           = 'quit';
    const MESSAGE_TYPE_SHUTDOWN       = 'shutdown';
    const MESSAGE_TYPE_BROADCAST      = 'broadcast';
    const MESSAGE_TYPE_DATA           = 'data';
    const MESSAGE_TYPE_CHANNEL_LISTEN = 'channel_listen';
    const MESSAGE_TYPE_CHANNEL_STOP   = 'channel_stop';
    const MESSAGE_TYPE_CHANNEL_SEND   = 'channel_send';
    const MESSAGE_TYPE_CHANNEL_CLOSE  = 'channel_close';
    const MESSAGE_TYPE_CHANNEL_CLOSED = 'channel_closed';
    
    
    public static function create( $messageType, $body )
    {
        $data = array( 'messageType' => $messageType,
                       'body' => $body,
                     );
                       
        return new Sly_SocketMessage( $data );
    }        
}

?>
