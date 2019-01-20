<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_Challenge extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Challenge
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'challenge';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'challenge_id' );

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
        'getMentorId'         => 'mentor_id',
        'getUserId'           => 'user_id',
        'getImageId'          => 'image_id',
        'getVideoId'          => 'video_id',
        'getMainImageId'      => 'main_image_id',
        'getCardImageId'      => 'card_image_id',
        'getUUID'             => 'uuid',
        'getTitle'            => 'title',
        'getDescription'      => 'description',
        'getHashtags'         => 'hashtags',
        'getImageText'        => 'image_text',
        'getLinkUrl'          => 'link_url',
        'getStartTime'        => 'start_time',
        'getEndTime'          => 'end_time',
        'getWinnerResponseId' => 'winner_response_id',
        'getStatus'           => 'status',
        'getHideFromStreams'  => 'hide_from_streams',
        'getModerationStatus' => 'moderation_status',
        'getChallengeType'    => 'challenge_type',
        'getUpdatedTimestamp' => 'updated_ts',
        'getCreatedTimestamp' => 'created_ts',
        'setMentorId'         => 'mentor_id',
        'setUserId'           => 'user_id',
        'setVideoId'          => 'video_id',
        'setImageId'          => 'image_id',
        'setMainImageId'      => 'main_image_id',
        'setCardImageId'      => 'card_image_id',
        'setUUID'             => 'uuid',
        'setTitle'            => 'title',
        'setDescription'      => 'description',
        'setHashtags'         => 'hashtags',
        'setImageText'        => 'image_text',
        'setLinkUrl'          => 'link_url',
        'setStartTime'        => 'start_time',
        'setEndTime'          => 'end_time',
        'setWinnerResponseId' => 'winner_response_id',
        'setStatus'           => 'status',
        'setHideFromStreams'  => 'hide_from_streams',
        'setModerationStatus' => 'moderation_status',
        'setChallengeType'    => 'challenge_type',
        'setUpdatedTimestamp' => 'updated_ts',
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Challenge
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
     * Create a new challenge
     *
     * @param integer $userId
     * @param string $title
     * @param string $challengeDescription
     * @return integer
     */
    public function createChallenge( $userId, $title, $challengeDescription, $challengeType = null, $videoId = null, $imageId = null )
    {
        $data = array(
            'user_id'           => $userId,
            'title'             => $title,
            'description'       => $challengeDescription,
            'challenge_type'    => $challengeType,
            'video_id'          => $videoId,
            'image_id'          => $imageId,
            'created_ts'        => date( 'Y-m-d H:i:s' ),
            'uuid'              => BeMaverick_Util::generateUUID(),
        );

        return $this->insert( $data, $this->_tags );
    }

    /**
     * Get a list of challenge ids
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getChallengeIds( $filterBy, $sortBy, $count, $offset )
    {
        $select = array( 'challenge.challenge_id' );

        $leftJoin = array();
        $where = array();
        $groupBy = array();

        // die('$filterBy => '.print_r($filterBy,true));

        if ( @$filterBy['challengeStatus'] ) {

            $now = date( 'Y-m-d H:i:s' );

            // challengeStatus has 3 special statuses that combine the status and start/end times
            if ( $filterBy['challengeStatus'] == 'active' ) {

                $where[] = "challenge.status = 'published'";
                $where[] = "challenge.start_time <= '$now'";
                $where[] = "challenge.end_time >= '$now'";

            } else if ( $filterBy['challengeStatus'] == 'closed' ) {
                $where[] = "challenge.status = 'published'";

                $where[] = "challenge.end_time < '$now'";

            } else if ( $filterBy['challengeStatus'] == 'upcoming' ) {
                $where[] = "challenge.status = 'published'";

                $where[] = "challenge.start_time > '$now'";
            } else {
                $where[] = "challenge.status = '" . $this->quote( $filterBy['challengeStatus'] ) . "'";
            }
        }

        if ( @$filterBy['minimumHours'] ) {
            $seconds = round($filterBy['minimumHours'] * 60 * 60, 0);
            $startTime = date( 'Y-m-d H:i:s', strtotime("-".$seconds." seconds") );
            $where[] = "challenge.created_ts < '$startTime'";
        }

        if ( isset($filterBy['hasResponse']) ) {
            $inOperator = ($filterBy['hasResponse'] == 'true') ? 'in' : 'not in';
            $where[] = "challenge_id $inOperator (select distinct challenge_id from response where status='active' and challenge_id > 0)";
        }

        if ( isset($filterBy['responseUserId']) ) {
            $responseUserId = $filterBy['responseUserId'];
            $where[] = "challenge_id in (select distinct challenge_id from response where status='active' and challenge_id > 0 and user_id = $responseUserId)";
        }


        if ( isset($filterBy['mentionedUserId']) ) {
            $mentionedUserId = $filterBy['mentionedUserId'];
            $leftJoin[] = "inner join model_mention on model_mention.model_type='challenge' and model_mention.model_id = challenge.challenge_id and model_mention.user_id=".$mentionedUserId;
        }

        if ( isset($filterBy['hasLinkUrl']) ) {
            $where[] = "link_url is not null";
        }

        if ( @$filterBy['userId'] ) {
            $where[] = "challenge.user_id = " . $filterBy['userId'];
        }

        if ( @$filterBy['status'] ) {
            $where[] = "challenge.status = '" . $this->quote( $filterBy['status'] ) . "'";
        }

        if ( @$filterBy && array_key_exists( 'hideFromStreams', $filterBy ) ) {
            if ( $filterBy['hideFromStreams'] ) {
                $where[] = 'challenge.hide_from_streams = 1';
            } else {
                $where[] = 'challenge.hide_from_streams != 1';
            }
        }

        if ( isset($filterBy['challengeStream']) ) {
            $leftJoin[] = "left join featured_models on featured_models.model_id = challenge.challenge_id and
                                                        featured_models.model_type = 'challenge' and
                                                        featured_models.featured_type = 'challenge-stream'";

            if ($filterBy['challengeStream'] == false) {
                $where[] = "featured_models.model_id is null";
            } elseif($filterBy['challengeStream'] == true) {
                $where[] = "featured_models.model_id is not null";
            }
        } 

        // die('$where => '.print_r($where,true));

        if ( @$filterBy['query'] ) {
            
            $query = $filterBy['query'];

            $clause = "( challenge.user_id in ( select DISTINCT user_id from bemaverick.user where user.username like '%" . $this->quote( $query ) . "%')"
            ." OR challenge.title like '%" . $this->quote( $filterBy['query'] ) . "%' )";
            
            if (is_numeric($query)) {
                $clause .= " OR challenge.challenge_id = $query";
            }

            $where[] = $clause;
            
        }

        $orderBy = array( 'challenge.created_ts desc' );

        if ( @$sortBy['sort'] ) {
            $sort = $sortBy['sort'];
            $sortOrder = $sortBy['sortOrder'] ?? 'desc';

            if ( $sort == 'id' ) {
                $orderBy = array( "challenge.challenge_id $sortOrder" );
            } else if ( $sort == 'created' ) {
                $orderBy = array( "challenge.created_ts $sortOrder" );
            } else if ( $sort == 'title' ) {
                $orderBy = array( "challenge.title $sortOrder" );
            } else if ( $sort == 'startTime' ) {
                $orderBy = array( "challenge.start_time $sortOrder" );
            } else if ( $sort == 'endTime' ) {
                $orderBy = array( "challenge.end_time $sortOrder" );
            } else if ( $sort == 'userUsername' ) {

                $leftJoin[] = 'left join user on user.user_id = challenge.user_id';
                $orderBy = array( "user.username $sortOrder" );

            } else if ( $sort == 'numBadges' ) {

                $orderBy = array( "IFNULL(rb.num_badges,0) $sortOrder" );

                $leftJoin[] = 'left join (
                    select challenge_id, count(*) as num_badges
                    from response_badge 
                    join response
                        on response.response_id = response_badge.response_id
                    group by challenge_id
                    ) as rb on rb.challenge_id = challenge.challenge_id';
            } else if ( $sort == 'featuredAndStartTimestamp' ) {

                $featuredType = $sortBy['featuredType'] ?? 'maverick-stream';

                $joinDirection = "right";
                if ($featuredType == "challenge-stream") {
                    $joinDirection = "left";
                }

                $leftJoin[] = "$joinDirection join featured_models on featured_models.model_id = challenge.challenge_id and
                                                            featured_models.model_type = 'challenge' and
                                                            featured_models.featured_type = '$featuredType'";

                $orderBy = array( "IFNULL(featured_models.sort_order,1000000) asc", "challenge.start_time desc" );

                if ( $featuredType == "challenge-stream" ) {
                    $where[] = 'challenge.hide_from_streams != 1'; // do not show hidden challenges in recent challenges tab
                }
            
            } else if ( $sort == 'oneStreamChallenges' ) {
                $featuredType = $sortBy['featuredType'] ?? 'challenge-stream';

                $leftJoin[] = "inner join featured_models on featured_models.model_id = challenge.challenge_id and
                                                            featured_models.model_type = 'challenge' and
                                                            featured_models.featured_type = '$featuredType'";

                $orderBy = array( "featured_models.sort_order asc" );

            } else if ( $sort == 'trending_v1' ) {
                /** Return the most recently active challenges */

                $trendingDays = $_GET['trending_days'] ?? 3; // number of days to calculate trending window
                $trendingStart = $_GET['trending_start'] ?? 0; // number of days ago to start calculation (0 = from now)
                $responsesWeight = $_GET['responses_weight'] ?? 5; // weight the value of number of responses per challenge
                $badgesWeight = $_GET['badges_weight'] ?? 1; // weight the value of number of badges per responses to a challenge

                $leftJoin[] = "left join response r on challenge.challenge_id = r.challenge_id
                                and r.status = 'active'
                                and r.created_ts > DATE_SUB(NOW(), INTERVAL $trendingDays DAY)
                                and r.created_ts < DATE_SUB(NOW(), INTERVAL $trendingStart DAY)";
                $leftJoin[] = "left join response_badge rb on r.response_id = rb.response_id
                                and rb.created_ts > DATE_SUB(NOW(), INTERVAL $trendingDays DAY)
                                and rb.created_ts < DATE_SUB(NOW(), INTERVAL $trendingStart DAY)";
                
                $where[] = "challenge.status = 'published'";
                $where[] = "r.response_id is not null";
                $where[] = 'challenge.hide_from_streams != 1'; // do not show hidden challenges in trending tab

                $groupBy[] = "challenge.challenge_id";

                // Calculate the trending score
                $orderBy = array();
                $orderBy[] = "( 
                    ( count(rb.response_id) * $badgesWeight ) 
                    + 
                    ( count(distinct r.response_id) * $responsesWeight ) 
                ) desc";  
            } else if ( $sort == 'trending_v2' || $sort == 'trending' ) {

                $leftJoin[] = "left join response r on r.challenge_id = challenge.challenge_id";
                
                $where[] = "challenge.status = 'published'";
                $where[] = "r.response_id is not null";
                $where[] = 'challenge.hide_from_streams != 1';

                $groupBy[] = "challenge.challenge_id";

                // Calculate the trending score
                $orderBy = array();
                $decay_base_power = $_GET['decay_base'] ?? 7; // a higher grade prefers more recent content
                $decay_base = pow(10, $decay_base_power); // 10000000; // Used to calculate the geometric decay of popularity over time
                $decay_days = $_GET['decay_days'] ?? 210; // Cutoff in days for historical response popularity value
                $video_multiplier = $_GET['video_multiplier'] ?? 1.7; // Increases score by multipler for video challenges versus image challenges

                $orderBy[] = "round(
                    (
                        sum(round(power(".$decay_base.", (greatest((".$decay_days." - datediff(NOW(), r.created_ts)),1) / ".$decay_days.")) / ".($decay_base/10).", 2))
                        + round(count(r.response_id) ) / 10
                    )
                    *
                    if(challenge.challenge_type = 'video', ".$video_multiplier.", 1)
                ) desc";  

                /** raw SQL formula */
                /*
                select
                challenge.challenge_id
                from challenge
                left join response r on r.challenge_id = challenge.challenge_id
                where challenge.status = 'published'
                and r.response_id is not null
                and challenge.hide_from_streams != 1
                group by challenge.challenge_id
                order by round(
                    (
                        sum(round(power(10000000, (greatest((120 - datediff(NOW(), r.created_ts)),1) / 120)) / 1000000, 2))
                        + round(count(r.response_id) ) / 10
                    )
                    *
                    if(challenge.challenge_type = 'video', 1.7, 1)
                ) desc
                */
            } else if ( $sort == 'mentioned' ) {
                $orderBy = array( "model_mention.updated_ts desc" );
            }


        }


        $sql = $this->createSqlStatement( $select, $where, $orderBy, $groupBy, $leftJoin, $count, $offset );
        // die(__FILE__.':'.__LINE__.'.$sql => '. $sql);

        // error_log( print_r("getChallengeIds::SQL".json_encode( $sql ), true) );

        $challengeIds = $this->fetchColumns( $sql );
        return $challengeIds;
    }

    /**
     * Get the count of challenges
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getChallengeCount( $filterBy )
    {
        $select = array( 'count(distinct(challenge_id))' );

        $where = array();

        if ( @$filterBy['challengeStatus'] ) {

            $now = date( 'Y-m-d H:i:s' );

            // challengeStatus has 3 special statuses that combine the status and start/end times
            if ( $filterBy['challengeStatus'] == 'active' ) {

                $where[] = "status = 'published'";
                $where[] = "start_time <= '$now'";
                $where[] = "end_time >= '$now'";

            } else if ( $filterBy['challengeStatus'] == 'closed' ) {
                $where[] = "status = 'published'";

                $where[] = "end_time < '$now'";

            } else if ( $filterBy['challengeStatus'] == 'upcoming' ) {
                $where[] = "status = 'published'";

                $where[] = "start_time > '$now'";
            } else {
                $where[] = "status = '" . $this->quote( $filterBy['challengeStatus'] ) . "'";
            }
        }

        if ( @$filterBy['mentorId'] ) {
            $where[] = "mentor_id = " . $filterBy['mentorId'];
        }

        if ( @$filterBy['userId'] ) {
            $where[] = "user_id = " . $filterBy['userId'];
        }

        if ( @$filterBy['query'] ) {
            $where[] = "title like '%" . $this->quote( $filterBy['query'] ) . "%'";
        }

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchCount( $sql );
    }

    /**
     * Deactivate all challenges by the user
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

        $challengeIds = $this->getChallengeIds( $filterBy, null, null, 0 );
        foreach ( $challengeIds as $challengeId ) {
            $this->setStatus( $challengeId, 'deleted' );
        }
    }

    /**
     * Reactivate all challenges by the user
     *
     * @param integer $userId
     * @return void
     */
    public function reactivateUser( $userId )
    {
        // we can't use an update sql statement because we are using rowCacheEnabled = true
        // which means the individual row caches won't get updated in redis.  instead we have
        // to find all the challenges for this user and update each one
        $filterBy = array(
            'userId' => $userId,
        );

        $challengeIds = $this->getChallengeIds( $filterBy, null, null, 0 );
        foreach ( $challengeIds as $challengeId ) {
            $this->setStatus( $challengeId, 'published' );
        }
    }

    /**
     * Delete the challenge
     *
     * @param integer $challengeId
     * @return void
     */
    public function deleteChallenge( $challengeId )
    {
        $this->deleteRow( array( $challengeId ), $this->_tags );
    }

}

?>
