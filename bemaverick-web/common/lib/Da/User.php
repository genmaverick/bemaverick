<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Util.php' );

class BeMaverick_Da_User extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_User
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'user';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'user_id' );

    /**
     * @var array
     * @access protected
     */
    protected $_dataTypes = array(
        'updates_ts'   => 'timestamp',
        'phone_number' => 'varchar',
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
        'getUserType'            => 'user_type',
        'getUsername'            => 'username',
        'getPassword'            => 'password',
        'getEmailAddress'        => 'email_address',
        'getParentEmailAddress'  => 'parent_email_address',
        'getFirstName'           => 'first_name',
        'getLastName'            => 'last_name',
        'getBio'                 => 'bio',
        'getHashtags'            => 'hashtags',
        'getBirthdate'           => 'birthdate',
        'getPhoneNumber'         => 'phone_number',
        'getVerified'            => 'verified',
        'getEmailVerified'       => 'email_verified',
        'getVPCStatus'           => 'vpc_status',
        'getStatus'              => 'status',
        'getRevokedReason'       => 'revoked_reason',
        'getUUID'                => 'uuid',
        'getRegisteredTimestamp' => 'registered_ts',
        'getProfileImageId'            => 'profile_image_id',
        'getProfileCoverImageType'     => 'profile_cover_image_type',
        'getProfileCoverImageId'       => 'profile_cover_image_id',
        'getProfileCoverPresetImageId' => 'profile_cover_preset_image_id',
        'getProfileCoverTint'          => 'profile_cover_tint',

        'setUserType'            => 'user_type',
        'setUsername'            => 'username',
        'setPassword'            => 'password',
        'setEmailAddress'        => 'email_address',
        'setParentEmailAddress'  => 'parent_email_address',
        'setFirstName'           => 'first_name',
        'setLastName'            => 'last_name',
        'setBio'                 => 'bio',
        'setHashtags'            => 'hashtags',
        'setBirthdate'           => 'birthdate',
        'setPhoneNumber'         => 'phone_number',
        'setVerified'            => 'verified',
        'setEmailVerified'       => 'email_verified',
        'setVPCStatus'           => 'vpc_status',
        'setStatus'              => 'status',
        'setRevokedReason'       => 'revoked_reason',
        'setUUID'                => 'uuid',
        'setRegisteredTimestamp' => 'registered_ts',
        'setProfileImageId'            => 'profile_image_id',
        'setProfileCoverImageType'     => 'profile_cover_image_type',
        'setProfileCoverImageId'       => 'profile_cover_image_id',
        'setProfileCoverPresetImageId' => 'profile_cover_preset_image_id',
        'setProfileCoverTint'          => 'profile_cover_tint',

    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_User
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
     * Create a user
     *
     * @param string $userType
     * @param string $username
     * @param string $password
     * @param string $emailAddress
     * @param string $parentEmailAddress
     * @param string $birthdate
     * @return integer
     */
    public function createUser( $userType, $username, $password, $emailAddress, $parentEmailAddress, $birthdate, $profileCoverImageType=null, $profileCoverImageId=null, $profileCoverPresetImageId=null )
    {
        $data = array(
            'user_type' => $userType,
            'username' => $username,
            'password' => $password,
            'email_address' => $emailAddress,
            'parent_email_address' => $parentEmailAddress,
            'birthdate' => $birthdate,
            'profile_cover_image_type' => $profileCoverImageType,
            'profile_cover_image_id' => $profileCoverImageId,
            'profile_cover_preset_image_id' => $profileCoverPresetImageId,
            'registered_ts' => date( 'Y-m-d H:i:s' ),
            'uuid'     => BeMaverick_Util::generateUUID('user'),
        );

        return $this->insert( $data );
    }

    /**
     * Check if the username is taken
     *
     * @param string $username
     * @return boolean
     */
    public function isUsernameTaken( $username )
    {
        $data = array(
            'username' => $username,
        );

        return $this->isRowExist( $data );
    }

    /**
     * Check if the email address is taken
     *
     * @param string $emailAddress
     * @return boolean
     */
    public function isEmailAddressTaken( $emailAddress )
    {
        $data = array(
            'email_address' => $emailAddress,
        );

        return $this->isRowExist( $data );
    }


    /**
     * Get the user id by username
     *
     * @param string $username
     * @param string $status
     * @return integer
     */
    public function getUserIdByUsername( $username, $status )
    {
        $where = array();
        $where[] = "username = '" . $this->quote( $username ) . "'";

        if ( $status ) {
            $where[] = "status = 'active'";
        }

        $sql = $this->createSqlStatement( array( 'user_id' ), $where );

        return $this->fetchOne( $sql );
    }

    /**
     * Get the user id by email address
     *
     * @param string $emailAddress
     * @param string $status
     * @return integer
     */
    public function getUserIdByEmailAddress( $emailAddress, $status )
    {
        $where = array();
        $where[] = "email_address = '" . $this->quote( $emailAddress ) . "'";

        if ( $status ) {
            $where[] = "status = 'active'";
        }

        $sql = $this->createSqlStatement( array( 'user_id' ), $where );

        return $this->fetchOne( $sql );
    }

    /**
     * Get the user id by phone number
     *
     * @param string $phoneNumber
     * @param string $status
     * @return integer
     */
    public function getUserIdByPhoneNumber( $phoneNumber, $status )
    {
        $where = array();
        $where[] = "phone_number = '" . $this->quote( $phoneNumber ) . "'";

        if ( $status ) {
            $where[] = "status = 'active'";
        }

        $sql = $this->createSqlStatement( array( 'user_id' ), $where );

        return $this->fetchOne( $sql );
    }

    /**
     * Get a list of user ids
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return array
     */
    public function getUserIds( $filterBy, $sortBy, $count, $offset )
    {
        $select = array( 'user.user_id' );

        $leftJoin = array();
        $where = array();

        $this->_updateWhereClause( $filterBy, $where, $leftJoin );

        $orderBy = array( 'user.user_id asc' );
        
        if ( $sortBy ) {
            
            $sort = $sortBy['sort'];
            $sortOrder = $sortBy['sortOrder'];
            
            if ( $sort == 'id' ) {
                $orderBy = array( "user.user_id $sortOrder" );
            } else if ( $sort == 'registeredTimestamp' ) {
                $orderBy = array( "user.registered_ts $sortOrder" );
            } else if ( $sort == 'birthdate' ) {
                $orderBy = array( "user.birthdate $sortOrder" );
            } else if ( $sort == 'mentorName' ) {
                $orderBy = array( "user_mentor.first_name $sortOrder", "user_mentor.last_name $sortOrder" );

                $leftJoin[] = 'left join user_mentor on user_mentor.user_id = user.user_id';
            } else if ( $sort == 'engagedUsers' ) {

                // This satisfies the following requirement from MVP-212:
                // # of badges given
                // # of responses created by the user and
                $orderBy = array( "(BG.response_badge_count + RG.response_count * 5) $sortOrder",  'user_id desc' );
                $date = Sly_Date::subDays( date( 'Y-m-d' ), 14 );

                $leftJoin[] = "left join ( select user_id, count(*) as response_badge_count from response_badge where response_badge.created_ts > '$date' group by user_id ) as BG on BG.user_id = user.user_id";
                $leftJoin[] = "left join ( select user_id, count(*) as response_count from response where response.created_ts > '$date' group by user_id ) as RG on RG.user_id = user.user_id";

                // If we want the third option in MVP-212, the below query will work, but is pretty slow. We might
                // want to consider creating these badge counts on the user pre-calculated rather than doing
                // things on the fly in SQL.

                /*
                 select user.*, BG.badges_given, RG.responses_given, BR.badges_received
                    from user
                    join ( select user_id, count(*) as badges_given from response_badge group by user_id ) as BG
                      on BG.user_id = user.user_id
                    join ( select user_id, count(*) as responses_given from response group by user_id ) as RG
                      on RG.user_id = user.user_id
                    join ( select user_id, SUM(RBR.response_badges_received) as badges_received from response
                        join (select response_id, count(*) as response_badges_received from response_badge group by response_id) RBR
                          on RBR.response_id = response.response_id
                         GROUP BY user_id ) BR
                      on BR.user_id = user.user_id
                    ORDER BY BG.badges_given desc, RG.responses_given desc, BR.badges_received desc;
                 */
            } else if ( $sort == 'numResponses' ) {

                // This satisfies the following requirement from MVP-212:
                // # of badges given
                // # of responses created by the user and
                $orderBy = array( "RG.responses_given $sortOrder", 'user_id desc' );

                $timestamp = @$sortBy['responseStartCreatedTimestamp'] ? $sortBy['responseStartCreatedTimestamp'] : '2018-01-01';

                $leftJoin[] = "left join ( select user_id, count(*) as responses_given from response where response.created_ts >= '$timestamp' group by user_id ) as RG on RG.user_id = user.user_id";
            }
        }

        $leftJoin = array_unique( $leftJoin );
        
        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, $leftJoin, $count, $offset );

        return $this->fetchColumns( $sql );
    }

    /**
     * Get the response
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getUserId( $filterBy )
    {
        $select = array( 'distinct(user.user_id)' );

        $where = array();
        $leftJoin = array();

        $this->_updateWhereClause( $filterBy, $where, $leftJoin );

        $sql = $this->createSqlStatement( $select, $where, null, null, $leftJoin );

        return $this->fetchCount( $sql );
    }

    /**
     * Get the count of users
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getUserCount( $filterBy )
    {
        $select = array( 'count(distinct(user.user_id))' );

        $leftJoin = array();
        $where = array();

        $this->_updateWhereClause( $filterBy, $where, $leftJoin );

        $sql = $this->createSqlStatement( $select, $where, null, null, $leftJoin );

        return $this->fetchCount( $sql );
    }

    /**
     * Delete the user
     *
     * @param integer $userId
     * @return void
     */
    public function deleteUser( $userId )
    {
        $this->deleteRow( array( $userId ) );
    }

    /**
     * Update the where clause from the filterBy
     *
     * @param hash $filterBy
     * @param array $where
     * @param array $leftJoin
     * @return void
     */
    private function _updateWhereClause( $filterBy, &$where, &$leftJoin )
    {

        if ( @$filterBy['userType'] ) {
            $where[] = "user.user_type = '" . $this->quote( $filterBy['userType'] ) . "'";
        }

        if ( @$filterBy['notUserType'] ) {
            $where[] = "user.user_type != '" . $this->quote( $filterBy['notUserType'] ) . "'";
        }

        if ( @$filterBy['userStatus'] ) {
            $where[] = "user.status = '" . $this->quote( $filterBy['userStatus'] ) . "'";
        }

        if ( @$filterBy['uuid'] ) {
            $where[] = "user.uuid = '" . $this->quote( $filterBy['uuid'] ) . "'";
        }

        if ( @$filterBy['username'] ) {
            $where[] = "user.username = '" . $this->quote( $filterBy['username'] ) . "'";
        }

        if ( @$filterBy['notUserId'] ) {
            $where[] = "user.user_id != " . $filterBy['notUserId'];
        }

        if ( @$filterBy['parentEmailAddress'] ) {
            $leftJoin[] = 'left join user_kid on user_kid.user_id = user.user_id';

            $where[] = "user_kid.parent_email_address = '" . $this->quote( $filterBy['parentEmailAddress'] ) . "'";
        }

        if ( @$filterBy['emailAddresses'] ) {
            $where[] = "user.email_Address in ('" . join( "','", $filterBy['emailAddresses'] ) . "')";
        }

        if ( @$filterBy['phoneNumbers'] ) {
            $where[] = "user.phone_number in ('" . join( "','", $filterBy['phoneNumbers'] ) . "')";
        }

        if ( @$filterBy['loginProvider'] ) {
            $leftJoin[] = "left join user_login_providers on user_login_providers.user_id = user.user_id and 
                                                             user_login_providers.login_provider = '" . $this->quote( $filterBy['loginProvider'] ) . "'";

            $where[] = "user_login_providers.login_provider_user_id in ('" . join( "','", $filterBy['loginProviderUserIds'] ) . "')";
        }

        if ( @$filterBy['startAge'] ) {
            $startBirthdate = date( 'Y' ) - $filterBy['startAge'] . '-' . date( 'm-d' );

            $where[] = "user.birthdate <= '" . $startBirthdate . "'";
        }

        if ( @$filterBy['endAge'] ) {
            $endBirthdate = date( 'Y' ) - $filterBy['endAge'] . '-' . date( 'm-d' );

            $where[] = "user.birthdate >= '" . $endBirthdate . "'";
        }

        if ( @$filterBy['startRegisteredDate'] ) {
            $where[] = "user.registered_ts >= '" . $filterBy['startRegisteredDate'] . "'";
        }

        if ( @$filterBy['endRegisteredDate'] ) {
            $where[] = "user.registered_ts <= '" . $filterBy['endRegisteredDate'] . "'";
        }

        if ( @$filterBy['query'] ) {
            $query = $this->quote( $filterBy['query'] );

            $leftJoin[] = 'left join user_kid on user_kid.user_id = user.user_id';

            $orWhere = array();
            $orWhere[] = "user_kid.parent_email_address like '%$query%'";
            $orWhere[] = "user.username like '%$query%'";
            $orWhere[] = "user.email_address like '%$query%'";
            $orWhere[] = "user.first_name like '%$query%'";
            $orWhere[] = "user.last_name like '%$query%'";

            $where[] = '(' . join( ' or ', $orWhere ) . ')';
        }

        $leftJoin = array_unique( $leftJoin );
    }

    /**
     * Get a list of users by autocomplete query
     *
     * @param string $query
     * @return Array
     */
    public function getAutocomplete( $query )
    {
        $query = strtolower( addslashes( $query ) );

        $sql = "
            SELECT 
                user_id, 
                username, 
                first_name, 
                last_name, 
                email_address, 
                user_type,
                verified,
                profile_image_id
            FROM user
            WHERE
                LOWER(
                    CONCAT(
                        COALESCE(username,''),'|',
                        COALESCE(first_name,''),'|',
                        COALESCE(last_name,''),'|',
                        COALESCE(email_address,''))) 
                    LIKE '%" .$query. "%'
            AND status = 'active'
            AND user_type IN ('kid', 'mentor')
            order by username asc
            LIMIT 0, 25;";

        // error_log('Da/User.php::getAutocomplete().$query => ' . $query);

        return $this->fetchRows($sql);
    }

    /**
     * Get a list of following user ids
     *
     * @param integer $userId
     * @param string $status
     * @return integer[]
     */
    public function getFollowingUserIds( $userId, $status = 'active' )
    {
        $select = array( 'u2.user_id' );

        $leftJoin = array();
        $leftJoin[] = 'u1
                       left join user_following_users ufu on u1.user_id = ufu.user_id
                       left join user u2 on ufu.following_user_id = u2.user_id';

        $where = array();
        $where[] = "u1.user_id = $userId";
        $where[] = 'u2.status = "'.$status.'"';

        $orderBy = array();

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, $leftJoin );
        return $this->fetchColumns( $sql );
    }

    /**
     * Get a count of following user count
     *
     * @param integer $userId
     * @param string $status
     * @return integer
     */
    public function getFollowingUserCount( $userId, $status = 'active' )
    {
        $select = array( 'count(u2.user_id)' );

        $leftJoin = array();
        $leftJoin[] = 'u1
                       left join user_following_users ufu on u1.user_id = ufu.user_id
                       left join user u2 on ufu.following_user_id = u2.user_id';

        $where = array();
        $where[] = "u1.user_id = $userId";
        $where[] = 'u2.status = "'.$status.'"';

        $orderBy = array();

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, $leftJoin );
        return $this->fetchCount( $sql );
    }

    /**
     * Get a list of followers
     *
     * The follower is the user_id column, because that is the user that follows the
     * following_user_id column
     *
     * @param integer $userId
     * @param string $status
     * @return integer[]
     */
    public function getFollowerUserIds( $userId, $status = 'active' )
    {
        $select = array( 'u2.user_id' );

        $leftJoin = array();
        $leftJoin[] = 'u1
                       left join user_following_users ufu on u1.user_id = ufu.following_user_id
                       left join user u2 on ufu.user_id = u2.user_id';

        $where = array();
        $where[] = "u1.user_id = $userId";
        $where[] = 'u2.status = "'.$status.'"';

        $orderBy = array();

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, $leftJoin );
        return $this->fetchColumns( $sql );
    }

    /**
     * Get a count of followers
     *
     * @param integer $userId
     * @param string $status
     * @return integer
     */
    public function getFollowersUserCount( $userId, $status = 'active' )
    {
        $select = array( 'count(u2.user_id)' );

        $leftJoin = array();
        $leftJoin[] = 'u1
                       left join user_following_users ufu on u1.user_id = ufu.following_user_id
                       left join user u2 on ufu.user_id = u2.user_id';

        $where = array();
        $where[] = "u1.user_id = $userId";
        $where[] = 'u2.status = "'.$status.'"';

        $orderBy = array();

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, $leftJoin );
        return $this->fetchCount( $sql );
    }
}

?>
