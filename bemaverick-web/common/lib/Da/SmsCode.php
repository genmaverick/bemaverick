<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_SmsCode extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_SmsCode
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'sms_code';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'phone_number' );

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array(
        'getCode'    => 'code',

        'setCode'    => 'code',
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_SmsCode
     */
    public function getInstance()
    {
        if (null === self::$_instance) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }

    /**
     * Delete the phone number
     *
     * @param string $phoneNumber
     * @return void
     */
    public function deletePhoneNumber( $phoneNumber )
    {
        $this->deleteRow( array( $phoneNumber ) );
    }

}

?>
