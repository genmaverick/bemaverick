<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_Stream extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Stream
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'stream';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'stream_id' );

    /**
     * @var hash
     * @access protected
     */
    protected $_dataTypes = array(
        'updated_ts' => 'timestamp',
    );

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
        'getLabel'          => 'label',
        'getDefinition'     => 'definition',
        'getSortOrder'      => 'sort_order',
        'getStatus'         => 'status',
        'getModelType'      => 'model_type',
        'getStreamType'     => 'stream_type',
        'setLabel'          => 'label',
        'setDefinition'     => 'definition',
        'setSortOrder'      => 'sort_order',
        'setStatus'         => 'status',
        'setModelType'      => 'model_type',
        'setStreamType'     => 'stream_type',
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Stream
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
     * Create a new stream
     *
     * @param string $label
     * @param string $definition
     * @param integer $sortOrder
     * @return integer
     */
    public function createStream( $label, $definition, $sortOrder, $modelType, $streamType, $status )
    {
        $data = array(
            'label' => $label,
            'definition' => json_encode( $definition ),
            'sort_order' => $sortOrder,
            'model_type' => $modelType,
            'stream_type' => $streamType,
            'status' => $status ?? 'active',
        );

        return $this->insert( $data, $this->_tags );
    }

    /**
     * Get a list of stream ids
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getStreamIds( $filterBy, $sortBy, $count, $offset )
    {
        $select = array( 'stream_id' );

        $where = array();
        // $where[] = "status = 'active'";
        if (!isset($filterBy['status'])) {
            $filterBy['status'] = 'active';
        }
        foreach($filterBy as $key => $value) {
            if (!is_null($value) && $value != '')   
                if (is_array($value))
                    $where[] = "$key IN ('". implode("','", $value) . "')";
                elseif ($key == 'query') 
                    $where[] = "label LIKE '%$value%'";
                else
                    $where[] = "$key = '$value'";
        }

        $orderBy = array( 'sort_order asc' );

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, null, $count, $offset );

        // die('$sql => '.$sql);

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Get the count of streams
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getStreamCount( $filterBy )
    {
        $select = array( 'count(distinct(stream_id))' );

        $where = array();
        if (!isset($filterBy['status'])) {
            $filterBy['status'] = 'active';
        }
        foreach($filterBy as $key => $value) {
            if (!is_null($value) && $value != '')   
                if (is_array($value))
                    $where[] = "$key IN ('". implode("','", $value) . "')";
                elseif ($key == 'query') 
                    $where[] = "label LIKE '%$value%'";
                else
                    $where[] = "$key = '$value'";
        }

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchCount( $sql, $this->_tags );
    }

    /**
     * Delete a stream
     *
     * @param integer $streamId
     * @return void
     */
    public function deleteStream( $streamId )
    {
        $this->deleteRow( array( $streamId ), $this->_tags );
    }

}

?>
