<?php

/**
 * Sly_Strings
 */
require_once( SLY_ROOT_DIR . '/lib/Sly/Strings.php' );

/**
 * Class for management of an error
 *
 * @category Sly
 * @package Sly_Errors
 */
class Sly_Error
{
    /**
     * @var string
     * @access protected
     */
    protected $_key = NULL;

    /**
     * @var string
     * @access protected
     */
    protected $_message = NULL;
    
    /**
     * @var string
     * @access protected
     */
    protected $_messageStringId = NULL;

    /**
     * @var params
     * @access protected
     */
    protected $_descriptionStringId = NULL;

    /**
     * @var params
     * @access protected
     */
    protected $_params = array();

    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct( $key, $messageStringId, $descriptionStringId, $params = array() )
    {
        $this->_key = $key;
        $this->_messageStringId = $messageStringId;
        $this->_descriptionStringId = $descriptionStringId;
        $this->_params = $params;
    }

    /**
     * Get the key of the error
     *
     * @return string The key used to associate the error
     */
    public function getKey()
    {
        return $this->_key;
    }

    /**
     * Get the message string id
     *
     * @return string The message string id
     */
    public function getMessageStringId()
    {
        return $this->_messageStringId;
    }

    /**
     * Get the descrription string id
     *
     * @return string The descrription string id
     */
    public function getDescriptionStringId()
    {
        return $this->_descriptionStringId;
    }
    
    /**
     * Get the message of the error
     *
     * @return string The actual message to display to the user
     */
    public function getMessage()
    {
        if ( $this->_message ) {
            return $this->_message;
        }

        $strings = Sly_Strings::getInstance();
        $string = $strings->getText( $this->_messageStringId );
        return vsprintf( $string, $this->_params );
    }

    /**
     * Set the message of the error
     *
     * @return void
     */
    public function setMessage( $message )
    {
        $this->_message = $message;
    }
    
    /**
     * Get the description of the error
     *
     * @return string The actual description to display to the user
     */
    public function getDescription()
    {
        $strings = Sly_Strings::getInstance();
        $string = $strings->getText( $this->_descriptionStringId );
        return vsprintf( $string, $this->_params );
    }

}
    
?>
