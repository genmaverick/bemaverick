<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_UserParent extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_UserParent
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'user_parent';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'user_id' );

    /**
     * @var boolean
     * @access protected
     */
    protected $_rowCacheEnabled = true;

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array(
        'getEmailNotificationsEnabled' => 'email_notifications',
        'getIdVerificationStatus' => 'id_verification_status',
        'getIdVerificationTimestamp' => 'id_verification_ts',

        'setEmailNotificationsEnabled' => 'email_notifications',
        'setIdVerificationStatus' => 'id_verification_status',
        'setIdVerificationTimestamp' => 'id_verification_ts',
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_UserParent
     */
    public function getInstance()
    {
        if (null === self::$_instance) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }

    /**
     * Constructor to set tags
     */
    public function __construct()
    {
        $this->_tags = array( $this->_database.'.'.$this->_table );
    }

    /**
     * Create a parent
     *
     * @param integer $userId
     * @return void
     */
    public function createParent( $userId )
    {
        $data = array(
            'user_id' => $userId,
        );

        $this->insert( $data );
    }

}

?>
