<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_UserPreferences extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_UserPreferences
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'user_preferences';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'id' );

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array(
    );

    protected $_allowedTypes = array(
        'notifications_general',
        'notifications_follow',
        'notifications_post'
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_UserSavedContents
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
    }

    /**
     * Get a list of user preferences
     *
     * @param integer $userId
     * @return array
     */
    public function getUserPreferences( $userId )
    {
        $select = array(
            'id', 
            'user_id',
            'preference_type',
            'value_bool'
         );

        $where = array();
        $where[] = "user_id = $userId";

        $sql = $this->createSqlStatement( $select, $where );

        $tags = array(
            $this->_database.'.'.$this->_table.".user_id=$userId"
        );

        return $this->fetchRows( $sql, $tags );
    }

    /**
     * Update user preferences
     *
     * @param integer $userId
     * @param string $preferences
     * @return void
     */
    public function updateUserPreferences( $userId, $preferences )
    {
        // $this->deleteUserPreferences( $userId );
        foreach ( $preferences as $preferenceType => $value ) {
            $valueBool = ($value==true || $value==1 || $value=='true') ?? false;
            $this->deleteUserPreference( $userId, $preferenceType );
            $this->addUserPreference( $userId, $preferenceType, $valueBool );
        }
    }

    /**
     * Add a new user preferences
     *
     * @param integer $userId
     * @param string $preferenceType
     * @param string $valueBool
     * @param string $valueString
     * @return void
     */
    public function addUserPreference( $userId, $preferenceType, $valueBool=null, $valueString=null )
    {
        $data = array(
            'user_id' => $userId,
            'preference_type' => $preferenceType,
            'value_bool' => $valueBool,
            'value_string' => $valueString,
        );

        $tags = array(
            $this->_database.'.'.$this->_table.".user_id=$userId"
        );

        $this->insert( $data, $tags, true );
    }

    /**
     * Delete the user preferences
     *
     * @param integer $userId
     * @return void
     */
    public function deleteUserPreferences( $userId )
    {
        $tags = array(
            $this->_database.'.'.$this->_table.".user_id=$userId"
        );

        $this->delete( "user_id = $userId", $tags );
    }

    /**
     * Delete the user preferences
     *
     * @param integer $userId
     * @param string $preferenceType
     * @return void
     */
    public function deleteUserPreference( $userId, $preferenceType )
    {
        $tags = array(
            $this->_database.'.'.$this->_table.".user_id=$userId"
        );

        $this->delete( "user_id = $userId && preference_type = '$preferenceType'", $tags );
    }

    /**
     * Delete the user
     *
     * @param integer $userId
     * @return void
     */
    public function deleteUser( $userId )
    {
        $tags = array(
            $this->_database.'.'.$this->_table.".user_id=$userId"
        );

        $this->delete( "user_id = $userId", $tags );
    }

}

?>
