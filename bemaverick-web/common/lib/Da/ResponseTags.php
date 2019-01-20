<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_ResponseTags extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_ResponseTags
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'response_tags';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'response_id', 'tag_id' );

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array(
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_ResponseTags
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
     * Get a list of tags ids
     *
     * @param integer $responseId
     * @return integer[]
     */
    public function getResponseTagIds( $responseId )
    {
        $select = array( 'tag_id' );

        $where = array();
        $where[] = "response_id = $responseId";

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Add a new tag
     *
     * @param integer $responseId
     * @param integer $tagId
     * @return void
     */
    public function addResponseTag( $responseId, $tagId )
    {
        $data = array(
            'response_id' => $responseId,
            'tag_id' => $tagId,
        );

        $this->insert( $data, $this->_tags );
    }

    /**
     * Delete the response
     *
     * @param integer $responseId
     * @return void
     */
    public function deleteResponse( $responseId )
    {
        $this->delete( "response_id = $responseId", $this->_tags );
    }

}

?>
