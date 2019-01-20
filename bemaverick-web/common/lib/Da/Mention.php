<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_Mention extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Mentionx
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'model_mention';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'model_id', 'user_id', 'id' );

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array(
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Mention
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
     * Add a new mention
     *
     * @param integer $modelType
     * @param integer $modelId
     * @param integer $userId
     * @return void
     */
    public function addMention( $modelType, $modelId, $userId )
    {
        $data = array(
            'model_type' => $modelType,
            'model_id' => $modelId,
            'user_id' => $userId,
        );

        $this->insert( $data, $this->_tags );
    }

    /**
     * Get a list of mention ids
     *
     * @param string $modelType
     * @param integer $modelId
     * @return integer[]
     */
    public function getMentionIds( $modelType, $modelId )
    {
        $select = array( 'id' );

        $where = array();
        $where[] = "model_type = '$modelType'";
        $where[] = "model_id = $modelId";

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Get the user_id
     *
     * @param string $mentionId
     * @return integer
     */
    public function getMentionedUserId( $mentionId )
    {
        $select = array( 'user_id' );

        $where = array();
        $where[] = "id = $mentionId";

        $sql = $this->createSqlStatement( $select, $where );

        $userId = $this->fetchColumns( $sql, $this->_tags );

        return $userId[0];
    }

    /**
     * Delete all mentions for $modelId
     *
     * @param integer $modelId
     * @return void
     */
    public function deleteMentions( $modelId )
    {
        $this->delete( "model_id = $modelId", $this->_tags );
    }

}

?>
