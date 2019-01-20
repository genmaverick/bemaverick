<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Util.php' );

class BeMaverick_Da_Response extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Response
     * @access protected
     */
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'response';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'response_id' );

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
        'getResponseType'      => 'response_type',
        'getUserId'            => 'user_id',
        'getChallengeId'       => 'challenge_id',
        'getVideoId'           => 'video_id',
        'getImageId'           => 'image_id',
        'getCoverImageId'      => 'cover_image_id',
        'getDescription'       => 'description',
        'getHashtags'          => 'hashtags',
        'getStatus'            => 'status',
        'getCreatedTimestamp'  => 'created_ts',
        'getFavorite'          => 'favorite',
        'getUUID'              => 'uuid',
        'getModerationStatus'  => 'moderation_status',
        'getPublic'            => 'public',
        'getUpdatedTimestamp'  => 'updated_ts',
        'getTitle'             => 'title',
        'getPostType'          => 'post_type',
        'getHideFromStreams'   => 'hide_from_streams',
        'getTranscriptionText' => 'transcription_text',
        'setResponseType'      => 'response_type',
        'setUserId'            => 'user_id',
        'setChallengeId'       => 'challenge_id',
        'setVideoId'           => 'video_id',
        'setImageId'           => 'image_id',
        'setCoverImageId'      => 'cover_image_id',
        'setDescription'       => 'description',
        'setHashtags'          => 'hashtags',
        'setStatus'            => 'status',
        'setCreatedTimestamp'  => 'created_ts',
        'setFavorite'          => 'favorite',
        'setUUID'              => 'uuid',
        'setModerationStatus'  => 'moderation_status',
        'setPublic'            => 'public',
        'setUpdatedTimestamp'  => 'updated_ts',
        'setTitle'             => 'title',
        'setPostType'          => 'post_type',
        'setHideFromStreams'   => 'hide_from_streams',
        'setTranscriptionText' => 'transcription_text',
    );

    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Response
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
     * Create a new response
     *
     * @param string $responseType
     * @param integer $userId
     * @param integer $challengeId
     * @param integer $videoId
     * @param integer $imageId
     * @return integer
     */
    public function createResponse( 
        $responseType, 
        $userId, 
        $challengeId, 
        $videoId, 
        $imageId, 
        $postType = null,
        $responseStatus = BeMaverick_Response::RESPONSE_STATUS_ACTIVE
    )
    {
        // Default postType value based on challengeId provided
        if (is_null($postType)) {
            $postType = $challengeId 
                ? BeMaverick_Response::POST_TYPE_RESPONSE
                : BeMaverick_Response::POST_TYPE_CONTENT;
        }

        $data = array(
            'response_type' => $responseType,
            'status' => $responseStatus,
            'user_id' => $userId,
            'challenge_id' => $challengeId,
            'post_type' => $postType,
            'video_id' => $videoId,
            'image_id' => $imageId,
            'created_ts' => date( 'Y-m-d H:i:s' ),
            'uuid' => BeMaverick_Util::generateUUID('response'),
        );

        return $this->insert( $data, $this->_tags );
    }

    /**
     * Get a list of response ids
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getResponseIds( $filterBy, $sortBy, $count, $offset )
    {
        $select = array( 'distinct(response.response_id)' );

        $where = array();
        $leftJoin = array();

        $tags = $this->_tags;

        $this->_updateWhereClause( $filterBy, $where, $leftJoin, $tags );

        $groupBy = array( 'response.response_id' );

        $orderBy = array( 'response.response_id asc' );

        if ( @$sortBy['sort'] ) {
            $sort = $sortBy['sort'];
            $sortOrder = $sortBy['sortOrder'];

            if ( $sort == 'id' ) {
                $orderBy = array( "response.response_id $sortOrder" );
            } else if ( $sort == 'createdTimestamp' ) {
                $orderBy = array( "response.created_ts $sortOrder" );
            } else if ( $sort == 'favorite' ) {
                $orderBy = array( "response.favorite $sortOrder, response.updated_ts $sortOrder" );
            } else if ( $sort == 'challengeTitle' ) {
                $orderBy = array( "challenge.title $sortOrder" );

                $leftJoin[] = 'left join challenge on challenge.challenge_id = response.challenge_id';
            } else if ( $sort == 'username' ) {
                $orderBy = array( "user.username $sortOrder" );

                $leftJoin[] = 'left join user on user.user_id = response.user_id';
            } else if ( $sort == 'numBadges' ) {
                $orderBy = array( "IFNULL(BC.badge_count, 0) $sortOrder, response.created_ts $sortOrder" );

                $leftJoin[] = 'left join (select response_id, count(*) as badge_count from response_badge group by response_id) BC
                    on BC.response_id = response.response_id';
            } else if ( $sort == 'challengeResponses' ) {
                $orderBy = array( "IFNULL(CRC.challenge_response_count, 0) $sortOrder, response.created_ts $sortOrder" );

                $leftJoin[] = 'join (select challenge_id, count(*) as challenge_response_count from response group by challenge_id) CRC
                    on CRC.challenge_id = response.challenge_id';
            } else if ( $sort == 'featured' ) {

                $select[] = "featured_models.sort_order";
                $select[] = "response.created_ts";

                $featuredType = $filterBy['featuredType'] ?? 'maverick-stream';
                $allowBackfillResponses = false;
                $joinDirection = $allowBackfillResponses ? 'left' : 'right';
                $leftJoin[] = "$joinDirection join featured_models on featured_models.model_id = response.response_id and featured_models.model_type = 'response' and featured_models.featured_type = '$featuredType'";
                $groupBy[] = "featured_models.sort_order";
                $groupBy[] = "response.created_ts";
                $orderBy = array( "IFNULL(featured_models.sort_order,1000000) asc", "response.created_ts desc" ); 

                $tags[] = "bemaverick.featured_type.".$featuredType;
            }
        }

        $leftJoin = array_unique( $leftJoin );

        $sql = $this->createSqlStatement( $select, $where, $orderBy, $groupBy, $leftJoin, $count, $offset );

        // error_log('da/Response.php():getResponseIds()');
        // error_log('$sql => '.$sql);
        // error_log('$tags => '.print_r($tags,true));

        $ids = $this->fetchColumns( $sql, $tags );

        // error_log('$ids => '.print_r($ids,true));

        return $ids;
    }

    /**
     * Get the response
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getResponseId( $filterBy )
    {
        $select = array( 'distinct(response.response_id)' );

        $where = array();
        $leftJoin = array();

        $tags = $this->_tags;

        $this->_updateWhereClause( $filterBy, $where, $leftJoin, $tags );

        $sql = $this->createSqlStatement( $select, $where, null, null, $leftJoin );

        return $this->fetchCount( $sql, $tags );
    }

    /**
     * Get the count of responses
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getResponseCount( $filterBy )
    {
        $select = array( 'count(distinct(response.response_id))' );

        $where = array();
        $leftJoin = array();

        $tags = $this->_tags;

        $this->_updateWhereClause( $filterBy, $where, $leftJoin, $tags );

        $sql = $this->createSqlStatement( $select, $where, null, null, $leftJoin );

        return $this->fetchCount( $sql, $tags );
    }


    /**
     * Get a list of challenges and responses from users followed by a given user
     *
     * @param int $userId
     * @param int $count
     * @param int $offset
     * @return array
     */
    public function getMyFeed( $userId, $count = 100, $offset = 0, $fetchCount = false ) {

        $fields = 'my_feed.*';
        if ($fetchCount) {
            $fields = 'count(*)';
        }

        // Select all Responses and Challenges from users followed by a given userId
        $sql = "
            select $fields from (
                select
                    'response' as content_type,
                    response.response_id as content_id,
                    response.user_id,
                    response.status,
                    response.created_ts,
                    challenge.user_id as challenge_user_id,
                    challenge.challenge_id as challenge_id
                from response
                    left join challenge on response.challenge_id = challenge.challenge_id
                where response.status = 'active'
                union
                select
                    'challenge' as content_type,
                    challenge_id as content_id,
                    user_id,
                    status,
                    created_ts,
                    null as challenge_user_id,
                    null as challenge_id
                from challenge
                where challenge.status = 'published'
            ) my_feed
            where 
              user_id in(select distinct(following_user_id) from user_following_users where user_id = {$userId})
              or (challenge_user_id = {$userId} and content_type = 'response')
              or (content_type = 'response' and challenge_id in (select distinct challenge_id from response where user_id = {$userId}))
            order by my_feed.created_ts desc
            limit {$offset}, {$count}
        ";

        if ( $fetchCount ) {
            $data = $this->fetchCount( $sql );
        } else {
            // return the complete data set
            $data = $this->fetchRows( $sql );
        }


        return $data;
    }

    /**
     * Get a count of all challenges and responses from users followed by a given user
     *
     * @param int $userId
     * @param int $count
     * @return integer
     */
    public function getMyFeedCount( $userId ) {
        $sqlMaxCount = 18446744073709551615;
        $phpIntMax = PHP_INT_MAX;
        $offset = 0;
        $fetchCount = true;
        return $this->getMyFeed( $userId, $phpIntMax, $offset, $fetchCount );
    }


    /**
     * Get a list of response ids from engaged users
     *
     * @param string $date
     * @return integer[]
     */
    public function getEngagedUsersResponseIds( $date )
    {
        // TODO: rewrite using createSqlStatement()
        $sql = "select response.response_id
from response
  join (select user_id, count(*) as response_badge_count
        from response_badge
        where response_badge.created_ts > '$date'
        group by user_id) as RBC
    on RBC.user_id = response.user_id
  join (select user_id, count(*) as response_count
        from response
        where response.created_ts > '$date'
        group by user_id) as RC
    on RC.user_id = response.user_id
  join (select max(response_id) as max_response_id, user_id
        from response
        group by user_id) as MR
    on MR.user_id = response.user_id
       AND MR.max_response_id = response.response_id
where response.created_ts > '$date'
  AND response.status IN ('active')
  AND response.hide_from_streams = 0
order by (RBC.response_badge_count + RC.response_count * 5) DESC;";

        return $this->fetchColumns( $sql );
    }

    /**
     * Get a list of unique user ids with a response for a challenge
     *
     * @param integer $challengeId
     * @param integer $count
     * @return integer[]
     */
    public function getUniqueUserIds( $challengeId, $count )
    {
        $select = array( 'distinct(response.user_id)', 'response.created_ts' );

        $where = array();
        $where[] = "response.challenge_id = " . $challengeId;

        $orderBy = array( 'response.created_ts desc' );

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, null, $count );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Deactivate all responses by the user
     *
     * @param integer $userId
     * @return void
     */
    public function deactivateUser( $userId )
    {
        // we can't use an update sql statement because we are using rowCacheEnabled = true
        // which means the individual row caches won't get updated in redis.  instead we have
        // to find all the responses for this user and update each one
        $filterBy = array(
            'userId' => $userId,
        );

        $responseIds = $this->getResponseIds( $filterBy, null, null, 0 );
        foreach ( $responseIds as $responseId ) {
            $this->setStatus( $responseId, 'deleted' );
        }
    }

    /**
     * Reactivate all responses by the user
     *
     * @param integer $userId
     * @return void
     */
    public function reactivateUser( $userId )
    {
        // we can't use an update sql statement because we are using rowCacheEnabled = true
        // which means the individual row caches won't get updated in redis.  instead we have
        // to find all the responses for this user and update each one
        $filterBy = array(
            'userId' => $userId,
        );

        $responseIds = $this->getResponseIds( $filterBy, null, null, 0  );
        foreach ( $responseIds as $responseId ) {
            $this->setStatus( $responseId, 'active' );
        }
    }

    /**
     * Delete the response
     *
     * @param integer $responseId
     * @return void
     */
    public function deleteResponse( $responseId )
    {
        $this->deleteRow( array( $responseId ), $this->_tags );
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

        $filterBy = !is_null($filterBy) ? $filterBy : array();

        if ( @$filterBy['challengeId'] ) {
            $where[] = "response.challenge_id = " . $filterBy['challengeId'];
        }

        if ( @$filterBy['userId'] ) {
            $where[] = "response.user_id = " . $filterBy['userId'];
        }

        if ( @$filterBy['uuid'] ) {
            $where[] = "response.uuid = '" . $this->quote( $filterBy['uuid'] ) . "'";
        }

        if ( @$filterBy['responseStatus'] ) {
            $where[] = "response.status = '" . $this->quote( $filterBy['responseStatus'] ) . "'";
        }

        if ( @$filterBy['responseType'] ) {
            $responseType = $filterBy['responseType'];
            if ( is_array( $responseType ) ) {
                $where[] = "response.response_type IN ('" . implode( "', '", $responseType ) . "')";
            } else {
                $where[] = "response.response_type = '" . $this->quote( $filterBy['responseType'] ) . "'";
            }
        }

        if ( @$filterBy['postType'] ) {
            $postType = $filterBy['postType'];
            if ( is_array( $postType ) ) {
                $where[] = "response.post_type IN ('" . implode( "', '", $postType ) . "')";
            } else {
                $where[] = "response.post_type = '" . $this->quote( $filterBy['postType'] ) . "'";
            }
        }

        if ( $filterBy && array_key_exists( 'hideFromStreams', $filterBy ) ) {
            if ( $filterBy['hideFromStreams'] ) {
                $where[] = 'response.hide_from_streams = 1';
            } else {
                $where[] = 'response.hide_from_streams != 1';
            }
        }

        if ( @$filterBy['challengeUserId'] ) {
            $leftJoin[] = 'left join challenge on challenge.challenge_id = response.challenge_id';

            $where[] = "challenge.user_id = " . $filterBy['challengeUserId'];

            $tags[] = 'bemaverick.challenge';
        }

        if ( @$filterBy['query'] ) {
            
            $query = $filterBy['query'];

            $clause = "( response.user_id in ( select DISTINCT user_id from bemaverick.user where user.username like '%" . $this->quote( $filterBy['query'] ) . "%')"
            ." OR response.challenge_id in ( SELECT DISTINCT challenge_id from bemaverick.challenge where challenge.title like '%" . $this->quote( $filterBy['query'] ) . "%') ) ";
            
            if (is_numeric($query)) {
                $clause .= " OR response.response_id = $query";
            }

            $where[] = $clause;
        }

        if ( @$filterBy['badgedUserId'] ) {
            $leftJoin[] = 'left join response_badge on response_badge.response_id = response.response_id';

            $where[] = "response_badge.user_id = " . $filterBy['badgedUserId'];

            $tags[] = 'bemaverick.response_badge';
        }

        if ( @$filterBy['badgeId'] ) {
            $leftJoin[] = 'left join response_badge on response_badge.response_id = response.response_id';

            $where[] = "response_badge.badge_id = " . $filterBy['badgeId'];

            $tags[] = 'bemaverick.response_badge';
        }

        if ( @$filterBy['featuredType'] ) {

            $featuredType = $filterBy['featuredType'] ?? 'maverick-stream';
            $allowBackfillResponses = false;
            $joinDirection = $allowBackfillResponses ? 'left' : 'right';
            $leftJoin[] = "$joinDirection join featured_models fm2 on fm2.model_id = response.response_id and
                                                        fm2.model_type = 'response' and
                                                        fm2.featured_type = '$featuredType'";
            
        }

        if ( array_key_exists( 'followingUserId', $filterBy ) ) {
            $followingUserId = $filterBy['followingUserId'];

            $leftJoin[] = "join response_badge
                on response.response_id = response_badge.response_id";
            $leftJoin[] = "join user_following_users
                on user_following_users.user_id = response_badge.user_id";

            $where[] = "user_following_users.following_user_id = $followingUserId";

            $tags[] = 'bemaverick.response_badge';
            $tags[] = 'bemaverick.user_following_users';
        }

        if ( array_key_exists( 'followerUserId', $filterBy ) ) {
            $followerUserId = $filterBy['followerUserId'];

            $leftJoin[] = "join user_following_users
                on user_following_users.user_id = $followerUserId";

            $where[] = "response.user_id = user_following_users.following_user_id";

            $tags[] = 'bemaverick.user_following_users';
        }

        if ( array_key_exists( 'delay', $filterBy ) ) {
            $delay = $filterBy['delay'];
            $now = time();
            $seconds = $delay * 60;
            $time = $now - ($seconds);
            $date = date( 'Y-m-d H:i:s', $time );
            $where[] = "response.created_ts <= '$date'";
        }

        // print("<pre>\$where ".print_r($where,true)."</pre>");
        $leftJoin = array_unique( $leftJoin );

        $tags = array_unique( $tags );
    }

}

?>
