<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_Tag extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Tag
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'tag';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'tag_id' );

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
        'getType'    => 'type',
        'getName'    => 'name',

        'setType'    => 'type',
        'setName'    => 'name',
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Tag
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
     * Create a new tag
     *
     * @param string $type
     * @param string $name
     * @return integer
     */
    public function createTag( $type, $name )
    {
        $data = array(
            'type' => $type,
            'name' => $name,
            'created_ts' => date( 'Y-m-d H:i:s' ),
        );

        return $this->insert( $data, $this->_tags, true );
    }

    /**
     * Get a tag id by name
     *
     * @param string $name
     * @return integer
     */
    public function getTagIdByName( $name )
    {
        $select = array( 'tag_id' );

        $where = array();

        $where[] = "name = '" . $this->quote( $name ) . "'";

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchOne( $sql, $this->_tags );
    }

    /**
     * Get a list of tags
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getTagIds( $filterBy, $sortBy, $count, $offset )
    {
        $select = array( 'tag_id' );

        $where = array();

        if ( @$filterBy['type'] ) {
            $where[] = "type = '" . $this->quote( $filterBy['type'] ) . "'";
        }

        if ( @$filterBy['query'] ) {
            $where[] = "name like '" . $this->quote( $filterBy['query'] ) . "%'";
        }

        $orderBy = array( 'name asc' );

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, null, $count, $offset );

        return $this->fetchColumns( $sql, $this->_tags );
    }

}

?>
