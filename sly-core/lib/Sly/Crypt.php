<?php

class Sly_Crypt
{
    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = array();

    /**
     * @var string
     * @access protected
     */
    protected $_cipher;

    /**
     * @var string
     * @access protected
     */
    protected $_keyHash;

    /**
     * @var integer
     * @access protected
     */
    private $_ivNumBytes;

    /**
     * @param string $key
     * @param string $cipher
     * @param string $hashAlgorithm
     */
    public function __construct( $key, $cipher = 'aes-256-ctr', $hashAlgorithm = 'sha256' )
    {
        $this->_cipher = $cipher;
        $this->_keyHash = openssl_digest( $key, $hashAlgorithm, true );
        $this->_ivNumBytes = openssl_cipher_iv_length( $cipher );
    }

    /**
     * Retrieves the crypt instance.
     *
     * @param string $key
     * @param string $cipher
     * @param string $hashAlgorithm
     * @return Sly_Crypt
     */
    public static function getInstance( $key, $cipher = 'aes-256-ctr', $hashAlgorithm = 'sha256' )
    {
        $type = $key . $cipher . $hashAlgorithm;
        
        if ( ! isset( self::$_instance[$type] ) ) {
            self::$_instance[$type] = new self( $key, $cipher, $hashAlgorithm );
        }

        return self::$_instance[$type];
    }

    /**
     * Encrypt ths string by storing the initialization vector and the string together
     *
     * @param string $text
     * @return string
     */
    public function encrypt( $text )
    {
        $iv = openssl_random_pseudo_bytes( $this->_ivNumBytes );

        $encryptedText = openssl_encrypt( $text, $this->_cipher, $this->_keyHash, OPENSSL_RAW_DATA, $iv );

        // we need to store the iv variable with the encrypted text, so we know how to decrypt it
        return base64_encode( $iv . $encryptedText );
    }

    /**
     * Decrypt the string which should have the initialization vector and the encrypted value
     *
     * @param string $encryptedValue
     * @return string
     */
    public function decrypt( $encryptedValue )
    {
        $raw = base64_decode( $encryptedValue );

        // get the iv and encrypted text so we can decrypt properly
        $iv = substr( $raw, 0, $this->_ivNumBytes );
        $encryptedText = substr( $raw, $this->_ivNumBytes );

        return openssl_decrypt( $encryptedText, $this->_cipher, $this->_keyHash, OPENSSL_RAW_DATA, $iv );
    }

}

?>
