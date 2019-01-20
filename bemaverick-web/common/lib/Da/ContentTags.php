<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_ContentTags extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_ContentTags
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'content_tags';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'content_id', 'tag_id' );

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array(

    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_ContentTags
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
     * @param integer $contentId
     * @return integer[]
     */
    public function getContentTagIds( $contentId )
    {
        $select = array( 'tag_id' );

        $where = array();
        $where[] = "content_id = $contentId";

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Add a new tag
     *
     * @param integer $contentId
     * @param integer $tagId
     * @return void
     */
    public function addContentTag( $contentId, $tagId )
    {
        $data = array(
            'content_id' => $contentId,
            'tag_id' => $tagId,
        );

        $this->insert( $data, $this->_tags );
    }

    /**
     * Delete the content
     *
     * @param integer $contentId
     * @return void
     */
    public function deleteContent( $contentId )
    {
        $this->delete( "content_id = $contentId", $this->_tags );
    }

}

?>
