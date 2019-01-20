<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_UserSavedChallenges extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_UserSavedChallenges
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'user_favorite_challenges';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'user_id', 'challenge_id' );

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

    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_UserSavedChallenges
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
     * Get a list of saved challenge ids
     *
     * @param integer $userId
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getChallengeIds( $userId, $count = 0, $offset = 0, $orderBy = null )
    {
        $select = array( 'challenge_id' );

        $where = array("user_id = $userId");
        $orderBy = (!empty($orderBy)) ? $orderBy : array("updated_ts desc");

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, null, $count, $offset );

        // error_log('getChallengeIds.$sql => '.$sql);

        return $this->fetchColumns( $sql );
    }

    /**
     * Add a new user challenge
     *
     * @param integer $userId
     * @param integer $challengeId
     * @return void
     */
    public function addUserSavedChallenge( $userId, $challengeId )
    {
        $data = array(
            'user_id' => $userId,
            'challenge_id' => $challengeId,
        );

        $this->insert( $data, $this->_tags, true );
    }

    /**
     * Delete the user challenge
     *
     * @param integer $userId
     * @param integer $challengeId
     * @return void
     */
    public function deleteUserSavedChallenge( $userId, $challengeId )
    {
        $this->deleteRow( array( $userId, $challengeId ), $this->_tags );
    }

    /**
     * Delete the user
     *
     * @param integer $userId
     * @return void
     */
    public function deleteUser( $userId )
    {
        $this->delete( "user_id = $userId", $this->_tags );
    }

}

?>
