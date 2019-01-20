<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_FeaturedModels extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_FeaturedModels
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'featured_models';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'featured_type', 'model_id', 'model_type' );

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array(
        'setSortOrder' => 'sort_order',
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_FeaturedModels
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
     * Create a new featured model
     *
     * @param string $featuredType
     * @param integer $modelId
     * @param string $modelType
     * @param integer $sortOrder
     * @return integer
     */
    public function addFeaturedModel( $featuredType, $modelId, $modelType, $sortOrder )
    {
        $data = array(
            'featured_type' => $featuredType,
            'model_id' => $modelId,
            'model_type' => $modelType,
            'sort_order' => $sortOrder,
            'created_ts' => date( 'Y-m-d H:i:s' ),
        );

        return $this->insert( $data, $this->_tags );
    }

    /**
     * Get a list of model ids
     *
     * @param string $featuredType
     * @param string $modelType
     * @param boolean $activeOnly
     * @return integer[]
     */
    public function getFeaturedModelIds( $featuredType, $modelType, $activeOnly = true )
    {
        $select = array( 'featured_models.model_id' );

        $where = array();

        $where[] = "featured_models.featured_type = '$featuredType'";
        $where[] = "featured_models.model_type = '$modelType'";
        $now = date( 'Y-m-d H:i:s' );

        if ( $modelType == BeMaverick_Site::MODEL_TYPE_RESPONSE ) {
            $leftJoin[] = "join response on response.response_id = featured_models.model_id and response.status = 'active'";
        } else if ( $modelType == BeMaverick_Site::MODEL_TYPE_CHALLENGE ) {
            $leftJoin[] = $activeOnly
                ? "join challenge on challenge.challenge_id = featured_models.model_id and challenge.status = 'published' and challenge.start_time <= '$now' and challenge.end_time >= '$now'"
                : "join challenge on challenge.challenge_id = featured_models.model_id";
        } else if ( $modelType == BeMaverick_Site::MODEL_TYPE_USER ) {
            $leftJoin[] = "join user on user.user_id = featured_models.model_id and user.status = 'active'";
        }

        $orderBy = array( 'sort_order asc' );

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, $leftJoin );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Delete featured model
     *
     * @param string $featuredType
     * @param string $modelId
     * @param string $modelType
     * @return void
     */
    public function deleteFeaturedModel( $featuredType, $modelId, $modelType )
    {
        return $this->deleteRow( array( $featuredType, $modelId, $modelType ), $this->_tags );
    }

}

?>
