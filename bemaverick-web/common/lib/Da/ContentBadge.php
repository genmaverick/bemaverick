<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_ContentBadge extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_ContentBadge
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'content_badge';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'content_id', 'badge_id', 'user_id' );

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array();
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_ContentBadge
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
     * Add a new badge for a user
     *
     * @param integer $contentId
     * @param integer $badgeId
     * @param integer $userId
     * @return void
     */
    public function addContentBadge( $contentId, $badgeId, $userId )
    {
        $data = array(
            'content_id' => $contentId,
            'badge_id' => $badgeId,
            'user_id' => $userId,
            'created_ts' => date( 'Y-m-d H:i:s' ),
        );

        $this->insert( $data, $this->_tags, true );
    }

    /**
     * Delete a new badge for a user
     *
     * @param integer $contentId
     * @param integer $badgeId
     * @param integer $userId
     * @return void
     */
    public function deleteContentBadge( $contentId, $badgeId, $userId )
    {
        $this->deleteRow( array( $contentId, $badgeId, $userId ), $this->_tags );
    }

    /**
     * Get a count of all the badges for this content
     *
     * @param integer $contentId
     * @return void
     */
    public function getContentBadgeCounts( $contentId )
    {
        $select = array( 'badge_id', 'count(*) as count' );

        $where = array();
        $where[] = "status = 'active'";
        $where[] = "content_id = $contentId";

        $groupBy = array( 'badge_id' );

        $sql = $this->createSqlStatement( $select, $where, null, $groupBy );

        return $this->fetchAssoc( $sql, $this->_tags );
    }

    /**
     * Get a count of all the badges this user has given out
     *
     * @param integer $userId
     * @return void
     */
    public function getUserGivenBadgesCount( $userId )
    {
        $select = array( 'badge_id', 'count(*) as count' );

        $where = array();
        $where[] = "status = 'active'";
        $where[] = "user_id = $userId";

        $groupBy = array( 'badge_id' );

        $sql = $this->createSqlStatement( $select, $where, null, $groupBy );

        return $this->fetchAssoc( $sql, $this->_tags );
    }

    /**
     * Get a count of all the badges this user has received from their content
     *
     * @param integer $userId
     * @return void
     */
    public function getUserReceivedBadgesCount( $userId )
    {
        $select = array( 'badge_id', 'count(*) as count' );

        $leftJoin = array();
        $leftJoin[] = 'left join content on content.content_id = content_badge.content_id';

        $where = array();
        $where[] = "content_badge.status = 'active'";
        $where[] = "content.user_id = $userId";

        $tags = $this->_tags;
        $tags[] = 'bemaverick.content';

        $groupBy = array( 'badge_id' );

        $sql = $this->createSqlStatement( $select, $where, null, $groupBy, $leftJoin );

        return $this->fetchAssoc( $sql, $tags );
    }

    /**
     * Get a list of badge ids the user has given to a content
     *
     * @param integer $userId
     * @param integer $contentId
     * @return Integer[]
     */
    public function getUserGivenContentBadgeIds( $userId, $contentId )
    {
        $select = array( 'badge_id' );

        $where = array();
        $where[] = "status = 'active'";
        $where[] = "user_id = $userId";
        $where[] = "content_id = $contentId";

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Get a list of users ids that have badged this content
     *
     * @param integer $contentId
     * @param integer|null $badgeId
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function getUserIds( $contentId, $badgeId, $count, $offset )
    {
        $select = array( 'user_id, max(created_ts) as max_created_ts' );

        $where = array();
        $where[] = "status = 'active'";
        $where[] = "content_id = $contentId";

        if ( $badgeId ) {
            $where[] = "badge_id = $badgeId";
        }

        $orderBy = array( 'max_created_ts desc' );

        $groupBy = array( 'user_id' );

        $sql = $this->createSqlStatement( $select, $where, $orderBy, $groupBy, null, $count, $offset );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Get the count of users ids that have badged this content
     *
     * @param integer $contentId
     * @param integer|null $badgeId
     * @return void
     */
    public function getUserCount( $contentId, $badgeId )
    {
        $select = array( 'count(distinct(user_id))' );

        $where = array();
        $where[] = "status = 'active'";
        $where[] = "content_id = $contentId";

        if ( $badgeId ) {
            $where[] = "badge_id = $badgeId";
        }

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchCount( $sql, $this->_tags );
    }

    /**
     * Deactivate all badges by the user
     *
     * @param integer $userId
     * @return void
     */
    public function deactivateUser( $userId )
    {
        $data = array(
            'status' => 'deleted',
        );

        $where = array( "user_id = $userId" );


        $this->update( $data, $where, null, $this->_tags );
    }

    /**
     * Reactivate all badges by the user
     *
     * @param integer $userId
     * @return void
     */
    public function reactivateUser( $userId )
    {
        $data = array(
            'status' => 'active',
        );

        $where = array( "user_id = $userId" );


        $this->update( $data, $where, null, $this->_tags );
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
