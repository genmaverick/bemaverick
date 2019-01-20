<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Util.php' );

class BeMaverick_Da_Content extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Content
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'content';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'content_id' );

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
        'getContentType'      => 'content_type',
        'getUUID'             => 'uuid',
        'getUserId'           => 'user_id',
        'getVideoId'          => 'video_id',
        'getImageId'          => 'image_id',
        'getCoverImageId'     => 'cover_image_id',
        'getTitle'            => 'title',
        'getDescription'      => 'description',
        'getStatus'           => 'status',
        'getCreatedTimestamp' => 'created_ts',
        'getUpdatedTimestamp' => 'updated_ts',

        'setContentType'      => 'content_type',
        'setUUID'             => 'uuid',
        'setUserId'           => 'user_id',
        'setVideoId'          => 'video_id',
        'setImageId'          => 'image_id',
        'setCoverImageId'     => 'cover_image_id',
        'setTitle'            => 'title',
        'setDescription'      => 'description',
        'setStatus'           => 'status',
        'setCreatedTimestamp' => 'created_ts',
        'setUpdatedTimestamp' => 'updated_ts',
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Content
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
     * Create a new content
     *
     * @param string $contentType
     * @param integer $userId
     * @param integer $videoId
     * @param integer $imageId
     * @param string $title
     * @param string $description
     * @return integer
     */
    public function createContent( $contentType, $userId, $videoId, $imageId, $title, $description)
    {
        $data = array(
            'content_type' => $contentType,
            'user_id' => $userId,
            'video_id' => $videoId,
            'image_id' => $imageId,
            'title' => $title,
            'description' => $description,
            'created_ts' => date( 'Y-m-d H:i:s' ),
            'uuid'     => BeMaverick_Util::generateUUID('content'),
            'created_ts' => date( 'Y-m-d H:i:s' ),
        );

        return $this->insert( $data, $this->_tags );
    }

    /**
     * Get a list of content ids
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getContentIds( $filterBy, $sortBy, $count, $offset )
    {
        $select = array( 'distinct(content.content_id)' );

        $where = array();
        $leftJoin = array();
        $tags = $this->_tags;
        $this->_updateWhereClause( $filterBy, $where, $leftJoin, $tags );

        $groupBy = array( 'content.content_id' );
        $orderBy = array( 'content.created_ts desc' );



        if ( @$sortBy['sort'] ) {
            $sort = $sortBy['sort'];
            $sortOrder = $sortBy['sortOrder'];

            if ( $sort == 'id' ) {
                $orderBy = array( "content.content_id $sortOrder" );
            } else if ( $sort == 'title' ) {
                $orderBy = array( "content.title $sortOrder" );
            } else if ( $sort == 'createdTimestamp' ) {
                $orderBy = array( "content.created_ts $sortOrder" );
            }
        }

        $sql = $this->createSqlStatement( $select, $where, $orderBy, $groupBy, $leftJoin, $count, $offset );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Get the count of contents
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getContentCount( $filterBy )
    {
        $select = array( 'count(distinct(content.content_id))' );

        $where = array();
        $leftJoin = array();
        $tags = $this->_tags;
        $this->_updateWhereClause( $filterBy, $where, $leftJoin, $tags );

        $sql = $this->createSqlStatement( $select, $where, null, null, $leftJoin );

        return $this->fetchCount( $sql, $this->_tags );
    }

    /**
     * Delete the content
     *
     * @param integer $contentId
     * @return void
     */
    public function deleteContent( $contentId )
    {
        $this->deleteRow( array( $contentId ), $this->_tags );
    }

    /**
     * Deactivate all contents by the user
     *
     * @param integer $userId
     * @return void
     */
    public function deactivateUser( $userId )
    {
        // we can't use an update sql statement because we are using rowCacheEnabled = true
        // which means the individual row caches won't get updated in redis.  instead we have
        // to find all the content for this user and update each one
        $filterBy = array(
            'userId' => $userId,
        );

        $contentIds = $this->getContentIds( $filterBy, null, null, 0 );
        foreach ( $contentIds as $contentId ) {
            $this->setStatus( $contentId, 'deleted' );
        }
    }

    /**
     * Reactivate all contents by the user
     *
     * @param integer $userId
     * @return void
     */
    public function reactivateUser( $userId )
    {
        // we can't use an update sql statement because we are using rowCacheEnabled = true
        // which means the individual row caches won't get updated in redis.  instead we have
        // to find all the content for this user and update each one
        $filterBy = array(
            'userId' => $userId,
        );

        $contentIds = $this->getContentIds( $filterBy, null, null, 0 );
        foreach ( $contentIds as $contentId ) {
            $this->setStatus( $contentId, 'active' );
        }
    }

    /**
     * Update the where clause from the filterBy
     *
     * @param hash $filterBy
     * @param array $where
     * @param array $leftJoin
     * @param array $tags
     * @return void
     */
    private function _updateWhereClause( $filterBy, &$where, &$leftJoin, &$tags )
    {
        if ( @$filterBy['contentStatus'] ) {
            $where[] = "content.status = '" . $this->quote( $filterBy['contentStatus'] ) . "'";
        }

        if ( @$filterBy['contentType'] ) {
            $where[] = "content.content_type = '" . $this->quote( $filterBy['contentType'] ) . "'";
        }

        if ( @$filterBy['userId'] ) {
            $where[] = "content.user_id = " . $filterBy['userId'];
        }

        if ( @$filterBy['query'] ) {
            $where[] = "content.title like '%" . $this->quote( $filterBy['query'] ) . "%'";
        }

        if ( @$filterBy['badgedUserId'] ) {
            $leftJoin[] = 'left join content_badge on content_badge.content_id = content.content_id';

            $where[] = "content_badge.user_id = " . $filterBy['badgedUserId'];

            $tags[] = 'bemaverick.content_badge';
        }

        if ( @$filterBy['badgeId'] ) {
            $leftJoin[] = 'left join content_badge on content_badge.content_id = content.content_id';

            $where[] = "content_badge.badge_id = " . $filterBy['badgeId'];

            $tags[] = 'bemaverick.content_badge';
        }

        $leftJoin = array_unique( $leftJoin );
        $tags = array_unique( $tags );
    }

}

?>
