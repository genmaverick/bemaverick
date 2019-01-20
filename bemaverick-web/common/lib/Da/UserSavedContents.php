<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_UserSavedContents extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_UserSavedContents
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'user_saved_contents';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'user_id', 'content_id' );

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
        $this->_tags = array( $this->_database.'.'.$this->_table );
    }

    /**
     * Get a list of saved contents ids
     *
     * @param integer $userId
     * @return integer[]
     */
    public function getContentIds( $userId )
    {
        $select = array( 'content_id' );

        $where = array();
        $where[] = "user_id = $userId";

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchColumns( $sql );
    }

    /**
     * Add a new user content
     *
     * @param integer $userId
     * @param integer $contentId
     * @return void
     */
    public function addUserSavedContent( $userId, $contentId )
    {
        $data = array(
            'user_id' => $userId,
            'content_id' => $contentId,
        );

        $this->insert( $data, $this->_tags, true );
    }

    /**
     * Delete the user content
     *
     * @param integer $userId
     * @param integer $contentId
     * @return void
     */
    public function deleteUserSavedContent( $userId, $contentId )
    {
        $this->deleteRow( array( $userId, $contentId ), $this->_tags );
    }

    /**
     * Delete the user
     *
     * @param integer $userId
     * @return void
     */
    public function deleteUser( $userId )
    {
        $this->delete( "user_id = $userId" );
    }

}

?>
