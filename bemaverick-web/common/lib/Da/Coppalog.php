<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_Coppalog extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Coppalog
     * @access protected
     */
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'coppalog';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'id' );

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
        'getKidUserId'          => 'kid_user_id',
        'getConfirmationId'     => 'confirmation_id',
        'getResponseAction'     => 'response_action',
        'getResponseDetail'     => 'response_detail',
        'getResponseIssues'     => 'response_issues',

        'setKidUserId'          => 'kid_user_id',
        'setConfirmationId'     => 'confirmation_id',
        'setResponseAction'     => 'response_action',
        'setResponseDetail'     => 'response_detail',
        'setResponseIssues'     => 'response_issues',
    );

    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Coppalog
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
     * Create a record of the transaction
     *
     * @param string $kidUserId
     * @param string $firstName
     * @param string $lastName
     * @param string $address
     * @param string $zip
     * @param string $lastFourSSN
     * @param string $response
     * @return integer
     */
    public function createlog( $kidUserId, $firstName, $lastName, $address, $zip, $lastFourSSN, $response )
    {
        $confirmation_id = -1;
        $response_action = '';
        $response_detail = '';
        $response_issues = '';

        if ( $response ) {
            if ( $response['meta'] ) {
                $confirmation_id = $response['meta']['confirmation'];
            }

            if ( $response['result'] ) {
                $response_action = $response['result']['action'];
                $response_detail = $response['result']['detail'];
                $response_issues = $response['result']['issues'];
            }
        }

        if ( $response && $response['result'] ) {
            $confirmation_id = $response['meta']['confirmation'];
        }


        $data = array(
            'kid_user_id' => $kidUserId,
            'first_name' => $firstName,
            'last_name' => $lastName,
            'address' => $address,
            'zip' => $zip,
            'last_four_ssn' => $lastFourSSN,
            'confirmation_id' => $confirmation_id,
            'response_action' => $response_action,
            'response_detail' => $response_detail,
            'response_issues' => join( ', ', $response_issues ),
            'created_ts' => date( 'Y-m-d H:i:s' )
        );

        error_log( print_r( $data, true ) );

        return $this->insert( $data, $this->_tags, true );
    }

}

?>
