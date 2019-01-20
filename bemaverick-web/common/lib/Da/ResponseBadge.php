<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_ResponseBadge extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_ResponseBadge
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'response_badge';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'response_id', 'badge_id', 'user_id' );

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array();
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_ResponseBadge
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
     * @param integer $responseId
     * @param integer $badgeId
     * @param integer $userId
     * @return void
     */
    public function addResponseBadge( $responseId, $badgeId, $userId )
    {
        $data = array(
            'response_id' => $responseId,
            'badge_id' => $badgeId,
            'user_id' => $userId,
            'created_ts' => date( 'Y-m-d H:i:s' ),
        );

        $this->insert( $data, $this->_tags, true );
    }

    /**
     * Delete a new badge for a user
     *
     * @param integer $responseId
     * @param integer $badgeId
     * @param integer $userId
     * @return void
     */
    public function deleteResponseBadge( $responseId, $badgeId, $userId )
    {
        $this->deleteRow( array( $responseId, $badgeId, $userId ), $this->_tags );
    }

    /**
     * Get a count of all the badges for this response
     *
     * @param integer $responseId
     * @return void
     */
    public function getResponseBadgeCounts( $responseId )
    {
        $select = array( 'badge_id', 'count(*) as count' );

        $where = array();
        $where[] = "status = 'active'";
        $where[] = "response_id = $responseId";

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
     * Get a count of all the badges this user has received from their responses
     *
     * @param integer $userId
     * @return void
     */
    public function getUserReceivedBadgesCount( $userId )
    {
        $select = array( 'badge_id', 'count(*) as count' );

        $leftJoin = array();
        $leftJoin[] = 'left join response on response.response_id = response_badge.response_id';

        $where = array();
        $where[] = "response_badge.status = 'active'";
        $where[] = "response.user_id = $userId";

        $tags = $this->_tags;
        $tags[] = 'bemaverick.response';

        $groupBy = array( 'badge_id' );

        $sql = $this->createSqlStatement( $select, $where, null, $groupBy, $leftJoin );

        return $this->fetchAssoc( $sql, $tags );
    }

    /**
     * Get a list of badge ids the user has given to a response
     *
     * @param integer $userId
     * @param integer $responseId
     * @return void
     */
    public function getUserGivenResponseBadgeIds( $userId, $responseId )
    {
        $select = array( 'badge_id' );

        $where = array();
        $where[] = "status = 'active'";
        $where[] = "user_id = $userId";
        $where[] = "response_id = $responseId";

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Get a list of users ids that have badged this repsonse
     *
     * @param integer $userId
     * @param integer|null $badgeId
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function getResponseIds( $userId, $badgeId, $count, $offset )
    {
        $select = array( 'distinct(response_badge.response_id), response_badge.updated_ts' );

        $where = array();
        $where[] = "response_badge.status = 'active'";
        $where[] = "response_badge.user_id = $userId";

        if ( $badgeId ) {
            $where[] = "response_badge.badge_id = $badgeId";
        }


        $orderBy = array( 'response_badge.updated_ts desc' );

        $leftJoin = array();
        $leftJoin[] = "left join response on response.response_id = response_badge.response_id and response.status = 'active'";

        // Filter for active badges only
        $this->_filterActiveBadges($leftJoin, $where);

        $tags = $this->_tags;
        $tags[] = 'bemaverick.response_badge_user';


        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, $leftJoin, $count, $offset );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Get a list of users ids that have badged this repsonse
     *
     * @param integer $responseId
     * @param integer|null $badgeId
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function getUserIds( $responseId, $badgeId, $count, $offset )
    {
        $select = array( 'user_id, max(created_ts) as max_created_ts' );

        $leftJoin = array();

        $where = array();
        $where[] = "response_badge.status = 'active'";
        $where[] = "response_badge.response_id = $responseId";

        if ( $badgeId ) {
            $where[] = "badge_id = $badgeId";
        }
        
        // Filter for active badges only
        $this->_filterActiveBadges($leftJoin, $where);

        $orderBy = array( 'max_created_ts desc' );

        $groupBy = array( 'user_id' );

        $sql = $this->createSqlStatement( $select, $where, $orderBy, $groupBy, $leftJoin, $count, $offset );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Get the count of users ids that have badged this repsonse
     *
     * @param integer $responseId
     * @param integer|null $badgeId
     * @return void
     */
    public function getUserCount( $responseId, $badgeId )
    {
        $select = array( 'count(distinct(user_id))' );

        $where = array();
        $where[] = "status = 'active'";
        $where[] = "response_id = $responseId";

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
     * Delete the response
     *
     * @param integer $responseId
     * @return void
     */
    public function deleteResponse( $responseId )
    {
        $data = array(
            'status' => 'deleted',
        );

        $where = array( "response_id = $responseId" );


        $this->update( $data, $where, null, $this->_tags );
    }

    /**
     * Modifies the query for Active badge filter
     */
    public function _filterActiveBadges(&$leftJoin, &$where) {

        // Filter for active badges only
        if( is_array($leftJoin) ) {
            $leftJoin[] ='left join badge on response_badge.badge_id = badge.badge_id';
        }
        if( is_array($where) ) {
            $where[] = "badge.status = 'active'";
        }
    }

}

?>
