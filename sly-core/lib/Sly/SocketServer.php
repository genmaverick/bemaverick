<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/SocketMessage.php' );

/**
 * Class for running a socket based message server.
 *
 * Designed for use with Sly_SocketClient
 *
 * @description This class runs a socket based message server
 * @category Sly
 * @package Sly_SocketServer
 */

class Sly_SocketServer {

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
     * The clients
     *
     * @var array
     */
    protected $_clients = array();
    
    /**
     * Counter for client ids
     *
     * @var array
     */
    protected $_nextClientId = 0;
    
    /**
     * Counter for client ids
     *
     * @var array
     */
    protected $_nextMessageId = 0;
            
    /**
     * The main socket
     *
     * @var array
     */
    protected $_sock = null;
    
    /**
     * The channels
     *
     * @var array
     */
    protected $_channels = array();


    public function __construct( $logger )
    {
        $this->_logger = $logger;
    }

    public function initialize( $settings ) {
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
        
        if (socket_bind($this->_sock, $settings['address'], $settings['port']) === false) {
            $this->_logger->err( "socket_bind() failed: reason: " . socket_strerror(socket_last_error($this->_sock)) );
            return false;
        }
        
        if (socket_listen($this->_sock, 5) === false) {
            $this->_logger->err( "socket_listen() failed: reason: " . socket_strerror(socket_last_error($this->_sock)) );
            return false;
        }
        
        $this->_logger->info( "Established socket connection." );
        return true;
    }
    
    public function run() {
        
        $sock = $this->_sock;
        $logger = $this->_logger;
        
        if ( $sock == null ) {
            $logger->err( "Attempting to run on uninitialized connection." );
            return false;
        }
        
        $nullVar = null;
        
        do {
        
            $read = array();
            $read[] = $sock;
            
            foreach( $this->_clients as $client ) {
                if ( isset( $client['sock'] ) && $client['sock'] != null ) {
                    $read[] = $client['sock'];
                }
            }
            
            $ready = socket_select( $read, $nullVar, $nullVar, $nullVar );
            
            // New connections come on the main socket connection
            if ( in_array( $sock, $read ) ) {
                
                if ( count( $this->_clients ) >= $this->_settings['maxConnections'] ) {
                    $logger->warn( "Max connections reached" );
                }
                else {
                    // accept the connection and save in _clients

                    $newSock = socket_accept($sock);
                    
                    if ( $newSock === false ) {
                        echo "socket_accept() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
                        break;
                    }
                    
                    $clientId = $this->_nextClientId++;
                    
                    // TODO get client settings from client
                    $client = array( 'id' => $clientId,
                                     'sock' => $newSock,
                                     'errCount' => 0,
                                     'isAdmin' => true,
                                   );
                    
                    $this->_clients[$clientId] = $client;
                    
                    socket_set_nonblock( $newSock );

                    // TODO security
                    
                    // Send welcome.
                    $msg = "\nWelcome to Clinto's Test Server. \n" .
                        "We really need some bloody security here.\n";
                    $this->sendData($client, $msg);
                    
                    $logger->info( "Established new connection: $clientId" );
  
                }
                
                if ( --$ready <= 0 ) {
                    continue;
                }
            }
            
            foreach( $this->_clients as $clientId => $client ) {
                if ( $client['sock'] != null ) {
                    
                    if ( in_array( $client['sock'], $read ) ) {
                            
                        if ( false === ( $messages = $this->readMessages($client, false ) ) ) {
                            if ( ++$client['errCount'] > $this->_settings['maxErrors'] ) { 
                                $logger->err( "[$clientId] Exceeded max error count.  Closing." );
                                $this->closeClient( $client );
                            }
                            continue;
                        }
                        
                        foreach ( $messages as $message ) {
                            $messageType = $message->getMessageType();
                            
                            switch ( $messageType ) {
                                case Sly_SocketMessage::MESSAGE_TYPE_ECHO:
                                    $input = $message->getBody();
                                    $talkback = "Sever Response: You said '$input'.\n";
                                    $this->sendData( $client, $talkback );
                                    break;
                                case Sly_SocketMessage::MESSAGE_TYPE_QUIT:
                                    $logger->info( "[$clientId]Received quit.  Closing connection." );
                                    $this->closeClient( $client );
                                    break 2;
                                case Sly_SocketMessage::MESSAGE_TYPE_SHUTDOWN:
                                    if ( $client['isAdmin'] ) {
                                        $logger->info( "[$clientId]Received shutdown. Closing server." );
                                        break 4;
                                    }
                                    break;
                                case Sly_SocketMessage::MESSAGE_TYPE_BROADCAST:
                                    $this->broadcast( $message->getBody() );
                                    break;
                                case Sly_SocketMessage::MESSAGE_TYPE_DATA:
                                    // don't do anything with data to server
                                    if ( $this->isDebug() ) {
                                        $body = $message->getBody();
                                        $logger->debug( "[$clientId]Received Data.  Body: $body" );
                                    }
                                    break;
                                case Sly_SocketMessage::MESSAGE_TYPE_CHANNEL_LISTEN:
                                    $startId = $message->getStartId();
                                    $this->addToChannel( $client, $message->getChannel(), $startId );
                                    break;
                                case Sly_SocketMessage::MESSAGE_TYPE_CHANNEL_STOP:
                                    $this->removeFromChannel( $client, $message->getChannel() );
                                    break;
                                case Sly_SocketMessage::MESSAGE_TYPE_CHANNEL_SEND:
                                    $this->sendChannel( $message->getChannel(), $message->getBody() );
                                    break;       
                                case Sly_SocketMessage::MESSAGE_TYPE_CHANNEL_CLOSE:
                                    $this->closeChannel( $message->getChannel() );
                                    break;                                                                                                        
                                default:
                                    $logger->warn( "[$clientId]Unsupported message type: $messageType" );
                                    break;
                            }
                        }

                    }
                }
            }
        } while ( true );
        
        
        return true;
    }

    public function createChannel( $channelId )
    {
        $channel = array( 'clients' => array(),
                          'messages' => array(),
                        );
                        
        $this->_channels[$channelId] = $channel;
    }
    
    public function closeClient( $client )
    {
        $this->removeFromChannel( $client, 'all' );
        socket_close( $client['sock'] );
        unset( $this->_clients[$client['id']] );
    }
        
    public function addToChannel( $client, $channelId, $startId )
    {
        if ( !isset( $this->_channels[$channelId] ) ) {
            $this->createChannel( $channelId );
        }
        
        $this->_channels[$channelId]['clients'][$client['id']] = $client; 
        
        if ( $startId !== false ) {
            $this->sendChannelMessages( $client, $channelId, $startId );
        }                      
    }
    
    public function sendChannelMessages( $client, $channelId, $startId )
    {
        // debug
        var_dump( $this->_channels );
        
        foreach( $this->_channels[$channelId]['messages'] as $messageId => $message ) {
            if ( $messageId >= $startId ) {
                $this->writeMessage( $client, $message );
            }
        }
    }
    
    public function removeFromChannel( $client, $channelId )
    {
        if ( $channelId != 'all' ) {
            unset( $this->_channels[$channelId]['clients'][$client['id']] );
        }
        else {
            foreach ( $this->_channels as $channelId => $channel ) {
                unset( $this->_channels[$channelId]['clients'][$client['id']] );
            }
        }
    }
        
    public function sendChannel( $channelId, $message )
    {
        if ( $this->_settings['debug'] ) {
            $this->_logger->debug( "sendChannel: $channelId message: '$message'" );
        }
        
        if ( !isset( $this->_channels[$channelId] ) ) {
            $this->createChannel( $channelId );
        }
        
        // if message is the serialized representation of a message turn it back
        // into a message object so we can add the id
        if ( !is_object( $message ) ) {
            $message = new Sly_SocketMessage( unserialize($message) );
        }
        
        $messageId = $this->_nextMessageId++;
        $message->setId( $messageId );
        $message->setChannel( $channelId );
        
        // don't save the closes
        if ( $message->getMessageType() != Sly_SocketMessage::MESSAGE_TYPE_CHANNEL_CLOSE ) {
            // save to the channel's messages
            $this->_channels[$channelId]['messages'][$messageId] = $message;
            
            // backup to file
            $this->backupMessage( $message, $channelId );
        }
        
        // make sure the channel is set in the message
        foreach( $this->_channels[$channelId]['clients'] as $client ) {
            $this->writeMessage( $client, $message );
        }
    }

    public function closeChannel( $channelId )
    {
        if ( !isset( $this->_channels[$channelId] ) ) {
            return false;
        }
        
        // send a closed message to all listeners
        $message = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_CHANNEL_CLOSED, '' );
        $message->setChannel( $channelId );            
        $this->sendChannel( $channelId, $message );
        
        // now unset it
        unset( $this->_channels[$channelId] );
    }
    
    protected function read( $client, $waitForInput ) {
        $sock = $client['sock'];
        $bufferSize = $this->_settings['bufferSize'];
        $buffer = '';
                
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
                    socket_clear_error( $sock );
                    break;
                }
                
                $this->_logger->warn( "[{$client['id']}]socket_read() failed: [$errCode] reason: '" . socket_strerror($errCode) );
                
                return false;
            }
            // according to docs we get empty string if no more to read,
            // but it seems to trigger the error above instead
            if ( $input == "" ) {
                $errCode = socket_last_error( $sock );
                $this->_logger->warn( "[{$client['id']}]socket_read() empty string: [$errCode] reason: '" . socket_strerror($errCode) );
                return false;
            }
            $buffer .= $input;
        }
            
        if ( $this->isDebug() ) {
            var_dump( $buffer );
            var_dump( $input );
            $this->_logger->debug( "[{$client['id']}]Read: '$buffer'" );
        }
                    
        return $buffer;
    }
    
    protected function write( $client, $msg ) {
        $sock = $client['sock'];
        $bufferSize = $this->_settings['bufferSize'];
        $offset = 0;
        $msgLen = strlen( $msg );
        
        while ( $offset < $msgLen ) {
            $chunk = substr( $msg, $offset, $bufferSize );
            $sent = socket_write( $sock, $chunk, strlen($chunk) );
            
            if ( $this->isDebug() ) {
                $this->_logger->debug( "[{$client['id']}]Sent: $chunk" );
            }
            
            if ( $sent === false ) {
                return false;
            }
            
            $offset += $sent;
        }
        
        return $offset;
    }
                                        
    public function close()
    {
        socket_close( $this->_sock );
        $this->_sock = null;
    }
    
    public function broadcast( $message )
    {
        foreach( $this->_clients as $clientId => $client ) {
            if ( !isset( $client['sock'] ) || $client['sock'] == null ) {
                continue;
            }
            
            $this->writeMessage( $client, $message );
        }
    }

    public function readMessages( $client, $waitForInput )
    {
        if ( ($input = $this->read( $client, $waitForInput )) === false ) {
            return false;
        }
        
        $messages = array();
        
        // There may have been multiple messages on the socket
        while( strlen( $input ) > 0 ) {
            // Get the lenth of the message part
            $pos = strpos( $input, '***' );
            if ( $pos === false ) {
                $this->_logger->warn( "[{$client['id']}]Input is poorly formed" );
                return false;
            }
            $messageLength = (int)substr( $input, 0, $pos );
            
            $rawMessage = substr( $input, $pos + 3, $messageLength );
            
            if ( strlen( $rawMessage ) != $messageLength ) {
                $this->_logger->warn( "[{$client['id']}]Incomplete message" );
                return false;
            }
            
            if ( ( $data = unserialize( $rawMessage ) ) === false ) {
                $this->_logger->warn( "[{$client['id']}]Input is not an object" );
                return false;
            }
        
            $messages[] = new Sly_SocketMessage( $data );

            
            $input = substr( $input, $pos + 3 + $messageLength );
        }
        
        return $messages;   
    }
    
    public function writeMessage( $client, $message )
    {
        $data = (string) $message;
        $sent = $this->write( $client, strlen( $data ).'***'.$data );
                
        if ( $sent === false ) {
            return false;
        }
        
        return true;
    }
    
    public function sendData( $client, $output )
    {
        $message = Sly_SocketMessage::create( Sly_SocketMessage::MESSAGE_TYPE_DATA, $output );
        return $this->writeMessage( $client, $message );
    }
    
    public function getDefaultSettings()
    {
        $settings = array( 'bufferSize' => 2048,
                           'maxConnections' => 10,
                           'maxErrors' => 0,
                           'debug' => false,
                           'fileBackup' => false,
                         );
                         
        return $settings;
    }
    
    public function backupMessage( $message, $channelId )
    {
        // TODO
    }
    
    public function isDebug()
    {
        return $this->_settings['debug'];
    }
}

?>
