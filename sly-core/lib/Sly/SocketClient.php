<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/SocketMessage.php' );

/**
 * Class for running a socket based message client.
 *
 * Designed for use with Sly_SocketServer
 *
 * @description This class runs a socket based message client
 * @category Sly
 * @package Sly_SocketClient
 */

class Sly_SocketClient {

    /**
     * The logger
     *
     * @var array
     */
    protected $_logger = null;

    /**
     * The settings
     *
     * @var array
     */
    protected $_settings = null;

    /**
     * The main socket
     *
     * @var array
     */
    protected $_sock = null;

    /**
     * Queue for messages
     *
     * @var array
     */
    protected $_receivedQueue = array();

    public function __construct( $logger )
    {
        $this->_logger = $logger;
    }

    public function connect( $settings ) {
        $this->_settings = array_merge( $this->getDefaultSettings(), $settings );
         
        /* Allow the script to hang around waiting for connections. */
        set_time_limit(0);
        
        /* Turn on implicit output flushing so we see what we're getting
         * as it comes in. */
        ob_implicit_flush();
        
        if (($this->_sock = socket_create(AF_INET, SOCK_STREAM, SOL_TCP)) === false) {
            $this->_logger->err( "socket_create() failed: reason: " . socket_strerror(socket_last_error()) );
            return false;
        }
        
        if (socket_connect($this->_sock, $settings['address'], $settings['port']) === false) {
            $this->_logger->err( "socket_connect() failed: reason: " . socket_strerror(socket_last_error($this->_sock)) );
            return false;
        }
        
        socket_set_nonblock( $this->_sock );
                            
        // get initial handshake
        if ( ( $msg = $this->getData() ) === false) {
            return false;
        }
        
        $this->_logger->info( "Established socket connection." );
        return $msg;
    }

    protected function read( $waitForInput ) {
        $sock = $this->_sock;
        $bufferSize = $this->_settings['bufferSize'];
        $buffer = '';
        $nullVar = null;
        
        $read = array( $sock );
        
        if ( $waitForInput ) {
            // wait for availble input
            while( true ) {
                $ready = socket_select( $read, $nullVar, $nullVar, $nullVar );
                if ( in_array( $sock, $read ) ) {
                    break;
                }
            }
        }
        
        // now get the input
        while( true ) {
            $input = socket_read($sock, $bufferSize);

            if ( $input === false ) {
                $errCode = socket_last_error( $sock );
                // This seems to just mean there is no more data in buffer
                if ( $errCode == 11 && $buffer != '' ) {
                    break;
                }
                
                $this->_logger->warn( "[$key]socket_read() failed: [$errCode] reason: '" . socket_strerror($errCode) );
                
                return false;
            }
            // according to docs we get empty string if no more to read,
            // but it seems to trigger the error above instead
            if ( $input == "" ) {
                return false;
            }
            $buffer .= $input;
        }
            
        if ( $this->isDebug() ) {
            $this->_logger->debug( "[$sock]Read: '$buffer'" );
        }
                    
        return $buffer;
    }
    
    protected function write( $msg ) {
        $sock = $this->_sock;
        $bufferSize = $this->_settings['bufferSize'];
        $offset = 0;
        $msgLen = strlen( $msg );
        
        while ( $offset < $msgLen ) {
            $chunk = substr( $msg, $offset, $bufferSize );
            $sent = socket_write( $sock, $chunk, strlen($chunk) );
            
            if ( $this->isDebug() ) {
                $this->_logger->debug( "[$sock]Sent: $chunk" );
            }
            
            if ( $sent === false ) {
                return false;
            }
            
            $offset += $sent;
        }
        
        return $offset;
    }

    public function readMessage( $waitForInput )
    {
        // check if any messages are in the queue
        if ( count( $this->_receivedQueue ) > 0 ) {
            return array_shift( $this->_receivedQueue );
        }
        
        if ( ($input = $this->read( $waitForInput )) === false ) {
            return false;
        }
        
        //$input = trim($input);
        
        $messages = array();
        
        // There may have been multiple messages on the socket
        while( strlen( $input ) > 0 ) {
            // Get the length of the message part
            $pos = strpos( $input, '***' );
            if ( $pos === false ) {
                $this->_logger->warn( "Input is poorly formed" );
                return false;
            }
            $messageLength = (int)substr( $input, 0, $pos );
            
            $rawMessage = substr( $input, $pos + 3, $messageLength );
            
            if ( strlen( $rawMessage ) != $messageLength ) {
                $this->_logger->warn( "Incomplete message" );
                return false;
            }
            
            if ( ( $data = unserialize( $rawMessage ) ) === false ) {
                $this->_logger->warn( "Input is not an object" );
                return false;
            }
        
            $messages[] = new Sly_SocketMessage( $data );
            
            $input = substr( $input, $pos + 3 + $messageLength );
        }
        
        $message = array_shift( $messages );
        
        if ( count( $messages ) > 0 ) {
            $this->_receivedQueue = $messages;
        }
        return $message;   
    }
    
    protected function writeMessage( $message )
    {
        $data = (string) $message;
        $sent = $this->write( strlen( $data ).'***'.$data );
                
        if ( $sent === false ) {
            return false;
        }
        
        return true;
    }
    
    public function sendMessageReceived()
    {
        $message = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_RECEIVED, '' );
        return $this->writeMessage( $message );
    }
    
    public function sendData( $output )
    {
        $message = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_DATA, $ouput );
        return $this->writeMessage( $message );
    }

    public function getData()
    {
        $message = $this->readMessage( true );
        
        if ( $message === false ) {
            return false;
        }
        
        return $message->getBody();
    }
    
    public function sendEcho( $data )
    {
        $message = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_ECHO, $data );
        return $this->writeMessage( $message );
    }
    
    public function sendBroadcast( $data )
    {
        $broadcastMessage = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_DATA, $data );
        $message = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_BROADCAST, $broadcastMessage );
        return $this->writeMessage( $message );
    }
                    
    public function quit()
    {
        $message = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_QUIT, '' );
        $this->writeMessage( $message );
        
        // Give the server a chance to clear the buffer before closing the socket
        sleep(1);
        socket_close( $this->_sock );
    }
    
    public function listenChannel( $channel, $startId = false )
    {
        $message = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_CHANNEL_LISTEN, '' );
        $message->setChannel( $channel );
        $message->setStartId( $startId );
        $this->writeMessage( $message );
    }
    
    public function stopChannel( $channel )
    {
        $message = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_CHANNEL_STOP, '' );
        $message->setChannel( $channel );
        $this->writeMessage( $message );
    }
  
    public function sendChannel( $channel, $data )
    {
        $updateMessage = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_DATA, $data );
        $updateMessage->setChannel( $channel );
        $message = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_CHANNEL_SEND, $updateMessage );
        $message->setChannel( $channel );
        $this->writeMessage( $message );
    }
    
    public function closeChannel( $channel )
    {
        $message = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_CHANNEL_CLOSE, '' );
        $message->setChannel( $channel );
        $this->writeMessage( $message );
    }
        
    public function getDefaultSettings()
    {
        $settings = array( 'bufferSize' => 2048,
                           'maxErrors' => 3,
                           'debug' => false,
                         );
                         
        return $settings;
    }
    
    public function isDebug()
    {
        return $this->_settings['debug'];
    }

}

?>
