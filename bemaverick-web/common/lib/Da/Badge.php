<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_Badge extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Badge
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'badge';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'badge_id' );

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
        'getName' => 'name',
        'setName' => 'name',
        'getStatus' => 'status',
        'setStatus' => 'status',
        'getColor' => 'color',
        'setColor' => 'color',
        'getSortOrder' => 'sort_order',
        'setSortOrder' => 'sort_order',
        'getPrimaryImageUrl' => 'primary_image_url',
        'setPrimaryImageUrl' => 'primary_image_url',
        'getSecondaryImageUrl' => 'secondary_image_url',
        'setSecondaryImageUrl' => 'secondary_image_url',
        'getDescription' => 'description',
        'setDescription' => 'description',
        'getOffsetX' => 'offset_x',
        'setOffsetX' => 'offset_x',
        'getOffsetY' => 'offset_y',
        'setOffsetY' => 'offset_y',
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Badge
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
     * Get a list of badge ids
     *
     * @return integer[]
     */
    public function getBadgeIds( $status = null )
    {
        $indexKey = 'getBadgeIds.' . $status;

        if ( isset( $this->_indexes[$indexKey] ) ) {
            return $this->_indexes[$indexKey];
        }

        $select = array( 'badge_id' );

        $where = array();
        if(!is_null($status) && $status != 'any') {
            $where[] = "status = '$status'";
        }

        $orderBy = array( 'sort_order asc' );

        $sql = $this->createSqlStatement( $select, $where, $orderBy );

        $this->_indexes[$indexKey] = $this->fetchColumns( $sql, $this->_tags );

        return $this->_indexes[$indexKey];
    }
}

?>
