<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/User.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/UserLoginProviders.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/UserSavedChallenges.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/UserFollowingUsers.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/UserPreferences.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/UserSavedContents.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Challenge.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Cookie.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Image.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/UserInterface.php' );

class BeMaverick_User implements Sly_OAuth_UserInterface
{
    const USER_TYPE_KID     = 'kid';
    const USER_TYPE_PARENT  = 'parent';
    const USER_TYPE_MENTOR  = 'mentor';

    const USER_STATUS_DRAFT     = 'draft';
    const USER_STATUS_ACTIVE    = 'active';
    const USER_STATUS_INACTIVE  = 'inactive';
    const USER_STATUS_REVOKED   = 'revoked';
    const USER_STATUS_DELETED   = 'deleted';

    const USER_REVOKED_INAPPROPRIATE  = 'inappropriate';
    const USER_REVOKED_HARASSMENT     = 'harassment';
    const USER_REVOKED_NOTDEMO        = 'notdemo';
    const USER_REVOKED_PARENTAL       = 'parental';
    const USER_REVOKED_OTHER          = 'other';

    const USER_LOGIN_PROVIDER_FACEBOOK = 'facebook';
    const USER_LOGIN_PROVIDER_TWITTER  = 'twitter';

    const PROFILE_COVER_IMAGE_TYPE_PRESET  = 'preset';
    const PROFILE_COVER_IMAGE_TYPE_CUSTOM  = 'custom';

    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = array();

    /**
     * @var BeMaverick_Site $site
     * @access protected
     */
    protected $_site;

    /**
     * @var integer
     * @access protected
     */
    protected $_userId;

    /**
     * @var BeMaverick_Da_User
     * @access protected
     */
    protected $_daUser;

    /**
     * @var BeMaverick_Da_UserFollowingUsers
     * @access protected
     */
    protected $_daUserFollowingUsers;

    /**
     * @var BeMaverick_Da_UserSavedChallenges
     * @access protected
     */
    protected $_daUserSavedChallenges;

    /**
     * @var BeMaverick_Da_UserSavedContents
     * @access protected
     */
    protected $_daUserSavedContents;

    /**
     * @var BeMaverick_Da_UserPreferences
     * @access protected
     */
    protected $_daUserPreferences;

    /**
     * @var BeMaverick_Da_Challenge
     * @access protected
     */
    protected $_daChallenge;

    /**
     * Class constructor
     *
     * @param  integer
     * @return void
     */
    public function __construct( $site, $userId )
    {
        $this->_site = $site;
        $this->_userId = $userId;
        $this->_daUser = BeMaverick_Da_User::getInstance();
        $this->_daUserFollowingUsers = BeMaverick_Da_UserFollowingUsers::getInstance();
        $this->_daUserSavedChallenges = BeMaverick_Da_UserSavedChallenges::getInstance();
        $this->_daUserSavedContents = BeMaverick_Da_UserSavedContents::getInstance();
        $this->_daUserPreferences = BeMaverick_Da_UserPreferences::getInstance();
        $this->_daChallenge = BeMaverick_Da_Challenge::getInstance();
    }

    /**
     * Retrieves the user instance.
     *
     * @param BeMaverick_Site $site
     * @param integer $userId
     * @return BeMaverick_User_Mentor
     */
    public static function getInstance( $site, $userId )
    {
        if ( ! $userId ) {
            return null;
        }

        if ( ! isset( self::$_instance[$userId] ) ) {

            $daUser = BeMaverick_Da_User::getInstance();

            // make sure kid exists
            if ( ! $daUser->isKeysExist( array( $userId ) ) ) {
                self::$_instance[$userId] = null;
            } else {
                self::$_instance[$userId] = new self( $site, $userId );
            }
        }

        return self::$_instance[$userId];
    }

    /**
     * Create a user
     *
     * @param BeMaverick_Site $site
     * @param string $userType
     * @param string $username
     * @param string $password
     * @param string $emailAddress
     * @param string $parentEmailAddress
     * @param string $birthdate
     * @return integer
     */
    public static function createUser( $site, $userType, $username, $password, $emailAddress = null, $parentEmailAddress = null, $birthdate = null )
    {
        $daUser = BeMaverick_Da_User::getInstance();
        $daProfileCoverPresetImage = BeMaverick_Da_ProfileCoverPresetImage::getInstance();

        $password = $password ? md5( $password ) : null;

        // Generate dynamic profile cover from preset images
        $profileCoverImageType = self::PROFILE_COVER_IMAGE_TYPE_PRESET;
        $profileCoverImageId = null;
        $profileCoverPresetImageId = $daProfileCoverPresetImage->getRandomProfileCoverPresetImageId();

        $userId = $daUser->createUser(
            $userType,
            $username,
            $password,
            $emailAddress,
            $parentEmailAddress,
            $birthdate,
            $profileCoverImageType,
            $profileCoverImageId,
            $profileCoverPresetImageId
         );

        self::$_instance[$userId] = new self( $site, $userId );

        return self::$_instance[$userId];
    }

    /**
     * Get the user by the username
     *
     * @param BeMaverick_Site $site
     * @param string $username
     * @param string $status
     * @return BeMaverick_User
     */
    public static function getUserByUsername( $site, $username, $status = 'active' )
    {
        $daUser = BeMaverick_Da_User::getInstance();

        $userId = $daUser->getUserIdByUsername( $username, $status );

        return $site->getUser( $userId );
    }

    /**
     * Get the user by the email address
     *
     * @param BeMaverick_Site $site
     * @param string $emailAddress
     * @param string $status
     * @return BeMaverick_User
     */
    public static function getUserByEmailAddress( $site, $emailAddress, $status = 'active' )
    {
        $daUser = BeMaverick_Da_User::getInstance();

        $userId = $daUser->getUserIdByEmailAddress( $emailAddress, $status );

        return $site->getUser( $userId );
    }

    /**
     * Get the user by the phone number
     *
     * @param BeMaverick_Site $site
     * @param string $phoneNumber
     * @param string $status
     * @return BeMaverick_User
     */
    public static function getUserByPhoneNumber( $site, $phoneNumber, $status = 'active' )
    {
        $daUser = BeMaverick_Da_User::getInstance();

        $userId = $daUser->getUserIdByPhoneNumber( $phoneNumber, $status );

        return $site->getUser( $userId );
    }

    /**
     * Get the user by the login provider
     *
     * @param BeMaverick_Site $site
     * @param string $loginProvider
     * @param string $loginProviderUserId
     * @return BeMaverick_User
     */
    public static function getUserByLoginProvider( $site, $loginProvider, $loginProviderUserId )
    {
        $daUserLoginProviders = BeMaverick_Da_UserLoginProviders::getInstance();

        $userId = $daUserLoginProviders->getUserId( $loginProvider, $loginProviderUserId );

        return $site->getUser( $userId );
    }

    /**
     * Check if the username is taken
     *
     * @param string $username
     * @return boolean
     */
    public static function isUsernameTaken( $username )
    {
        $daUser = BeMaverick_Da_User::getInstance();

        return $daUser->isUsernameTaken( $username );
    }

    /**
     * Check if the email address is taken
     *
     * @param string $emailAddress
     * @return boolean
     */
    public static function isEmailAddressTaken( $emailAddress )
    {
        $daUser = BeMaverick_Da_User::getInstance();

        return $daUser->isEmailAddressTaken( $emailAddress );
    }

    /**
     * Get a list of users
     *
     * @param BeMaverick_Site $site
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return array
     */
    public static function getUsers( $site, $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $daUser = BeMaverick_Da_User::getInstance();

        $userIds = $daUser->getUserIds( $filterBy, $sortBy, $count, $offset );

        $users = array();
        foreach ( $userIds as $userId ) {
            $users[] = $site->getUser( $userId );
        }

        return $users;
    }

    /**
     * Get a user
     *
     * @param BeMaverick_Site $site
     * @param hash $filterBy
     * @return BeMaverick_User
     */
    public static function getUser( $site, $filterBy = null )
    {
        $daUser = BeMaverick_Da_User::getInstance();
        $userId = $daUser->getUserId( $filterBy );

        $user = $site->getUser( $userId );

        return $user;
    }


    /**
     * Get a count of users
     *
     * @param hash $filterBy
     * @return integer
     */
    public static function getUserCount( $filterBy = null )
    {
        $daUser = BeMaverick_Da_User::getInstance();

        return $daUser->getUserCount( $filterBy );
    }

    /**
     * Get the toString function
     *
     * @return string
     */
    public function __toString()
    {
        return $this->getId();
    }

    /**
     * Get the id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->_userId;
    }

    /**
     * Get the site
     *
     * @return BeMaverick_Site
     */
    public function getSite()
    {
        return $this->_site;
    }

    /**
     * Get the user type
     *
     * @return string
     */
    public function getUserType()
    {
        return $this->_daUser->getUserType( $this->getId() );
    }

    /**
     * Set the user type
     *
     * @param string $userType
     * @return string
     */
    public function setUserType( $userType )
    {
        $this->_daUser->setUserType( $this->getId(), $userType );
    }

    /**
     * Get the username
     *
     * @return string
     */
    public function getUsername()
    {
        return $this->_daUser->getUsername( $this->getId() );
    }

    /**
     * Set the username
     *
     * @param string $username
     * @return void
     */
    public function setUsername( $username )
    {
        $this->_daUser->setUsername( $this->getId(), $username );
    }

    /**
     * Get the password
     *
     * @return string
     */
    public function getPassword()
    {
        return $this->_daUser->getPassword( $this->getId() );
    }

    /**
     * Set the password
     *
     * @param string $password
     * @return void
     */
    public function setPassword( $password )
    {
        $this->_daUser->setPassword( $this->getId(), md5( $password ) );
    }

    /**
     * Get the email address
     *
     * @return string
     */
    public function getEmailAddress()
    {
        return $this->_daUser->getEmailAddress( $this->getId() );
    }

    /**
     * Set the email address
     *
     * @param string $emailAddress
     * @return void
     */
    public function setEmailAddress( $emailAddress )
    {
        $this->_daUser->setEmailAddress( $this->getId(), $emailAddress );
    }

    /**
     * Get the parent email address
     *
     * @return string
     */
    public function getParentEmailAddress()
    {
        return $this->_daUser->getParentEmailAddress( $this->getId() );
    }

    /**
     * Set the parent email address
     *
     * @param string $parentEmailAddress
     * @return void
     */
    public function setParentEmailAddress( $parentEmailAddress )
    {
        $this->_daUser->setParentEmailAddress( $this->getId(), $parentEmailAddress );
    }

    /**
     * Get the name
     *
     * @return string
     */
    public function getName()
    {
        return $this->getFirstName() . ' ' . $this->getLastName();
    }

    /**
     * Get the first name
     *
     * @return string
     */
    public function getFirstName()
    {
        return $this->_daUser->getFirstName( $this->getId() );
    }

    /**
     * Set the first name
     *
     * @param string $firstName
     * @return void
     */
    public function setFirstName( $firstName )
    {
        $this->_daUser->setFirstName( $this->getId(), $firstName );
    }

    /**
     * Get the last name
     *
     * @return string
     */
    public function getLastName()
    {
        return $this->_daUser->getLastName( $this->getId() );
    }

    /**
     * Set the last name
     *
     * @param string $lastName
     * @return void
     */
    public function setLastName( $lastName )
    {
        $this->_daUser->setLastName( $this->getId(), $lastName );
    }

    /**
     * Get the bio
     *
     * @return string
     */
    public function getBio()
    {
        return $this->_daUser->getBio( $this->getId() );
    }

    /**
     * Set the bio
     *
     * @param string $bio
     * @return void
     */
    public function setBio( $bio )
    {
        $this->_daUser->setBio( $this->getId(), $bio );
    }

    /**
     * Get the hashtags
     *
     * @return array
     */
    public function getHashtags()
    {
        $arrayString = $this->_daUser->getHashtags( $this->getId() );

        return json_decode($arrayString);
    }

    /**
     * Set the hashtags
     *
     * @param string $string
     * @return void
     */
    public function setHashtags( $string )
    {
        $hashtags = BeMaverick_Util::getHashtagsFromString( $string );

        $hashtags = ( count($hashtags) > 0 ) ? json_encode($hashtags) : null;

        $this->_daUser->setHashtags( $this->getId(), $hashtags );
    }

    /**
     * Get the birthdate
     *
     * @return string
     */
    public function getBirthdate()
    {
        return $this->_daUser->getBirthdate( $this->getId() );
    }

    /**
     * Set the birthdate
     *
     * @param string $birthdate
     * @return void
     */
    public function setBirthdate( $birthdate )
    {
        $this->_daUser->setBirthdate( $this->getId(), $birthdate );
    }

    /**
     * Get the age
     *
     * @return integer
     */
    public function getAge()
    {
        $birthdate = $this->getBirthdate();

        if ( ! $birthdate ) {
            return null;
        }

        $from = new DateTime( $birthdate );
        $to   = new DateTime( 'today' );

        return $from->diff( $to )->y;
    }

    /**
     * Check if this user is a teen
     *
     * @return boolean
     */
    public function isTeen()
    {
        $age = $this->getAge();
        // check for catalyst
        $userType = $this->getUserType();

        // Skip check for catalysts, parents
        if (in_array($userType, [
            BeMaverick_User::USER_TYPE_MENTOR,
            BeMaverick_User::USER_TYPE_PARENT,
        ])) {
            return true;
        }

        if ( ! $age ) {
            return false;
        }

        if ( $age >= 13 ) {
            return true;
        }

        return false;
    }

    /**
     * Get the phone number
     *
     * @return string
     */
    public function getPhoneNumber()
    {
        return $this->_daUser->getPhoneNumber( $this->getId() );
    }

    /**
     * Set the phone number
     *
     * @param string $phoneNumber
     * @return void
     */
    public function setPhoneNumber( $phoneNumber )
    {
        $this->_daUser->setPhoneNumber( $this->getId(), $phoneNumber );
    }

    /**
     * Get the VPC status
     *
     * @return int
     */
    public function getVPCStatus()
    {
        if ( $this->isTeen() ) {
            return true;
        }

        $value =  $this->_daUser->getVPCStatus( $this->getId() );
        return ( $value == 1 ) ? true : false;
    }

    /**
     * Set the VPC status
     *
     * @param int $vpcStatus
     * @return void
     */
    public function setVPCStatus( $vpcStatus )
    {
        $value = $vpcStatus ? 1 : 0;
        $this->_daUser->setVPCStatus( $this->getId(), $value );
    }

    /**
     * Check if this user is a parent
     *
     * @return boolean
     */
    public function isParent()
    {
        if ( $this->getUserType() == BeMaverick_User::USER_TYPE_PARENT ) {
            return true;
        }

        return false;
    }

    /**
     * Check if this user is a kid
     *
     * @return boolean
     */
    public function isKid()
    {
        if ( $this->getUserType() == BeMaverick_User::USER_TYPE_KID ) {
            return true;
        }

        return false;
    }

    /**
     * Check if this user is a mentor
     *
     * @return boolean
     */
    public function isMentor()
    {
        if ( $this->getUserType() == BeMaverick_User::USER_TYPE_MENTOR ) {
            return true;
        }

        return false;
    }

    /**
     * Check if this user is a parent of given kid
     *
     * @param BeMaverick_User_Kid $kid
     * @return boolean
     */
    public function isParentOfKid( $kid )
    {
        if ( ! $this->isParent() || ! $kid->isKid() ) {
            return false;
        }

        if ( $this->getEmailAddress() == $kid->getParentEmailAddress() ) {
            return true;
        }

        return false;
    }

    /**
     * Check if the account is verified
     *
     * @return boolean
     */
    public function isVerified()
    {
        $value = $this->_daUser->getVerified( $this->getId() );
        return ( $value == 1 ) ? true : false;
    }

    /**
     * Check if the account email is verified
     *
     * @return boolean
     */
    public function isEmailVerified()
    {
        $value = $this->_daUser->getEmailVerified( $this->getId() );
        return ( $value == 1 ) ? true : false;
    }

    /**
     * Set if the account is verified
     *
     * @param boolean $verified
     * @return void
     */
    public function setVerified( $verified )
    {
        $value = $verified ? 1 : 0;
        // error_log('setVerified '.$this->getId().' = '.var_export($verified,true));
        $this->_daUser->setVerified( $this->getId(), $value );
    }

    /**
     * Set if the account email is verified
     *
     * @param boolean $emailVerified
     * @return void
     */
    public function setEmailVerified( $emailVerified )
    {
        $value = $emailVerified ? 1 : 0;
        $this->_daUser->setEmailVerified( $this->getId(), $value );
    }

    /**
     * Get the status
     *
     * @return string
     */
    public function getStatus()
    {
        return $this->_daUser->getStatus( $this->getId() );
    }

    /**
     * Set the status
     *
     * @param string $status
     * @return void
     */
    public function setStatus( $status )
    {
        $this->_daUser->setStatus( $this->getId(), $status );
    }

    /**
     * Get the revoked_reason
     *
     * @return string
     */
    public function getRevokedReason()
    {
        return $this->_daUser->getRevokedReason( $this->getId() );
    }

    /**
     * Set the revoked_reason ('inappropriate', 'harassment', 'notdemo', 'parental', 'other')
     *
     * @param string $reason
     * @return void
     */
    public function setRevokedReason( $reason )
    {
        $this->_daUser->setRevokedReason( $this->getId(), $reason );
    }

    /**
     * Get the uuid
     *
     * @return string
     */
    public function getUUID()
    {
        return $this->_daUser->getUUID( $this->getId() );
    }

    /**
     * Set the uuid
     *
     * @param string $uuid
     * @return void
     */
    public function setUUID( $uuid )
    {
        $this->_daUser->setUUID( $this->getId(), $uuid );
    }

    /**
     * Get the registered timestamp
     *
     * @return string
     */
    public function getRegisteredTimestamp()
    {
        return $this->_daUser->getRegisteredTimestamp( $this->getId() );
    }

    /**
     * Set the registered timestamp
     *
     * @param string $registeredTimestamp
     * @return void
     */
    public function setRegisteredTimestamp( $registeredTimestamp )
    {
        $this->_daUser->setRegisteredTimestamp( $this->getId(), $registeredTimestamp );
    }

    /**
     * Get the profile image
     *
     * @return BeMaverick_Image
     */
    public function getProfileImage()
    {
        $imageId = $this->_daUser->getProfileImageId( $this->getId() );
        return $this->_site->getImage( $imageId );
    }

    /**
     * Set the profile image
     *
     * @param BeMaverick_Image $image
     * @return void
     */
    public function setProfileImage( $image )
    {
        if (!$image) {
            // error_log('LIB USER SET PROFILE IMAGE ID NULL');
            $this->_daUser->setProfileImageId( $this->getId(), null );
        } else {
            $imageId = $image ? $image->getId() : null;
            $this->_daUser->setProfileImageId( $this->getId(), $imageId );
        }
    }

    /**
     * Get the profile cover image type
     *
     * @return string
     */
    public function getProfileCoverImageType()
    {
        return $this->_daUser->getProfileCoverImageType( $this->getId() );
    }

    /**
     * Set the profile cover image type
     *
     * @param string $profileCoverImageType
     * @return void
     */
    public function setProfileCoverImageType( $profileCoverImageType )
    {
        $this->_daUser->setProfileCoverImageType( $this->getId(), $profileCoverImageType );
    }

    /**
     * Get the profile cover image
     *
     * @return BeMaverick_Image
     */
    public function getProfileCoverImage()
    {
        $imageId = $this->_daUser->getProfileCoverImageId( $this->getId() );
        return $this->_site->getImage( $imageId );
    }

    /**
     * Set the profile cover image
     *
     * @param BeMaverick_Image $image
     * @return void
     */
    public function setProfileCoverImage( $image )
    {
        $imageId = $image ? $image->getId() : null;
        $this->_daUser->setProfileCoverImageId( $this->getId(), $imageId );
    }

    /**
     * Get the profile cover preset image id
     *
     * @return integer
     */
    public function getProfileCoverPresetImageId()
    {
        return $this->_daUser->getProfileCoverPresetImageId( $this->getId() );
    }

    /**
     * Get the profile_cover_preset_image_id -> image_id
     *
     * @return integer
     */
    public function getProfileCoverPresetRealImageId()
    {
        $presetIdOne = $this->_daUser->getProfileCoverPresetImageId( $this->getId() );

        $daProfileCoverPresetImage = BeMaverick_Da_ProfileCoverPresetImage::getInstance();

        return $daProfileCoverPresetImage->getProfileCoverPresetRealImageId( $presetIdOne );
    }

    /**
     * Set the profile cover preset image id
     *
     * @param integer $profileCoverPresetImageId
     * @return void
     */
    public function setProfileCoverPresetImageId( $profileCoverPresetImageId )
    {
        $this->_daUser->setProfileCoverPresetImageId( $this->getId(), $profileCoverPresetImageId );
    }

    /**
     * Get the profile cover tint
     *
     * @return string
     */
    public function getProfileCoverTint()
    {
        return $this->_daUser->getProfileCoverTint( $this->getId() );
    }

    /**
     * Set the profile cover tint
     *
     * @param string $profileCoverTint
     * @return void
     */
    public function setProfileCoverTint( $profileCoverTint )
    {
        $this->_daUser->setProfileCoverTint( $this->getId(), $profileCoverTint );
    }

    /**
     * Add the social login provider
     *
     * @param string $loginProvider
     * @param string $loginProviderUserId
     * @return void
     */
    public function addSocialLoginProvider( $loginProvider, $loginProviderUserId )
    {
        $daUserLoginProviders = BeMaverick_Da_UserLoginProviders::getInstance();
        $daUserLoginProviders->setLoginProviderUserId( $this->getId(), $loginProvider, $loginProviderUserId );
    }

    /**
     * Get the social login providers
     *
     * @param string $loginProvider
     * @param string $loginProviderUserId
     * @return void
     */
    public function getLoginProviders()
    {
        $userId = $this->getId();
        $daUserLoginProviders = BeMaverick_Da_UserLoginProviders::getInstance();
        $loginProviders = $daUserLoginProviders->getLoginProviders($userId);

        return $loginProviders;
    }

    /**
     * Get the user's responses
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Response[]
     */
    public function getResponses( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        if ( $filterBy == null ) {
            $filterBy = array();
        }

        $filterBy['userId'] = $this->getId();
        $filterBy['responseStatus'] = 'active';

        $sortBy = array(
            'sort' => 'createdTimestamp',
            'sortOrder' => 'desc',
        );

        return $this->_site->getResponses( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the response count
     *
    * @return integer
     */
    public function getResponseCount()
    {
        $filterBy = array(
            'userId' => $this->getId(),
            'responseStatus' => 'active',
        );

        return $this->_site->getResponseCount( $filterBy );
    }

    /**
     * Get the count of users that has given a badge to this user
     *
     * @return hash
     */
    public function getReceivedBadgesCount()
    {
        $daResponseBadges = BeMaverick_Da_ResponseBadge::getInstance();

        return $daResponseBadges->getUserReceivedBadgesCount( $this->getId() );
    }

    /**
     * Get the count of badges that this user has given out
     *
     * @return hash
     */
    public function getGivenBadgesCount()
    {
        $daResponseBadges = BeMaverick_Da_ResponseBadge::getInstance();

        return $daResponseBadges->getUserGivenBadgesCount( $this->getId() );
    }

    /**
     * Get the list of badge ids that this user has given out for a response
     *
     * @param BeMaverick_Response $response
     * @return integer[]
     */
    public function getGivenResponseBadgeIds( $response )
    {
        $daResponseBadges = BeMaverick_Da_ResponseBadge::getInstance();

        return $daResponseBadges->getUserGivenResponseBadgeIds( $this->getId(), $response->getId() );
    }

    /**
     * Get the list of badge ids that this user has given out for a content
     *
     * @param BeMaverick_Content $content
     * @return integer[]
     */
    public function getGivenContentBadgeIds( $content )
    {
        $daContentBadges = BeMaverick_Da_ContentBadge::getInstance();

        return $daContentBadges->getUserGivenContentBadgeIds( $this->getId(), $content->getId() );
    }

    /**
     * Check if this user is following the given user
     *
     * @param BeMaverick_User $user
     * @return boolean
     */
    public function isFollowingUser( $user )
    {
        return $this->_daUserFollowingUsers->isUserFollowingUser( $this->getId(), $user->getId() );
    }

    /**
     * Get the users this user is following
     *
     * @return BeMaverick_User[]
     */
    public function getFollowingUsers()
    {
        $userIds = $this->_daUser->getFollowingUserIds( $this->getId() );

        $users = array();
        foreach ( $userIds as $userId ) {
            $user = $this->_site->getUser( $userId );

            if ( $user ) {
                $users[] = $user;
            }
        }

        return $users;
    }

    /**
     * Get the count of following users
     *
     * @return integer
     */
    public function getFollowingUserCount()
    {
        return $this->_daUser->getFollowingUserCount( $this->getId() );
    }

    /**
     * Add a following user to this user
     *
     * @param BeMaverick_User $followingUser
     * @return void
     */
    public function addFollowingUser( $followingUser )
    {
        $this->_daUserFollowingUsers->addUserFollowingUser( $this->getId(), $followingUser->getId() );
    }

    /**
     * Delete a following user to this user
     *
     * @param BeMaverick_User $followingUser
     * @return void
     */
    public function deleteFollowingUser( $followingUser )
    {
        $this->_daUserFollowingUsers->deleteUserFollowingUser( $this->getId(), $followingUser->getId() );
    }

    /**
     * Get the users this user is following
     *
     * @return BeMaverick_User[]
     */
    public function getFollowerUsers()
    {
        $userIds = $this->_daUser->getFollowerUserIds( $this->getId() );

        $users = array();
        foreach ( $userIds as $userId ) {
            $user = $this->_site->getUser( $userId );
            if ( $user ) {
                $users[] = $user;
            }
        }

        return $users;
    }

    /**
     * Get the count of followers for this user
     *
     * @return integer
     */
    public function getFollowersUserCount()
    {
        return $this->_daUser->getFollowersUserCount( $this->getId() );
    }

    /**
     * Delete a follower user to this user
     *
     * @param BeMaverick_User $followerUser
     * @return void
     */
    public function deleteFollowerUser( $followerUser )
    {
        $this->_daUserFollowingUsers->deleteUserFollowingUser( $followerUser->getId(), $this->getId() );
    }

    /**
     * Get a list of challenges created by this user
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Challenge[]
     */
    public function getChallenges( $filterBy = null, $sortBy = null, $count = null, $offset = null )
    {
        $filterBy['userId'] = $this->getId();
        // $filterBy['challengeStatus'] = 'published';
        $filterBy['challengeStatus'] = 'active';

        return $this->_site->getChallenges( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the challenge count
     *
    * @return integer
     */
    public function getChallengeCount()
    {
        $filterBy = array(
            'userId' => $this->getId(),
            'challengeStatus' => 'published',
        );

        return $this->_site->getChallengeCount( $filterBy );
    }

    /**
     * Get the user's saved challenges
     *
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Challenge[]
     */
    public function getSavedChallenges($count = null, $offset = 0, $orderBy = null)
    {
        $challengeIds = $this->_daUserSavedChallenges->getChallengeIds( $this->getId(), $count, $offset, $orderBy );

        $savedChallenges = array();

        foreach ( $challengeIds as $challengeId ) {
            $challenge = $this->_site->getChallenge($challengeId);

            $savedChallenges[] = $challenge;
        }

        return $savedChallenges;
    }

    /**
     * Get the user saved challenges count
     *
     * @return integer
     */
    public function getSavedChallengesCount()
    {
        return count($this->_daUserSavedChallenges->getChallengeIds($this->getId()));
    }

    /**
     * Add a saved challenge
     *
     * @param BeMaverick_Challenge $challenge
     * @return void
     */
    public function addSavedChallenge( $challenge )
    {
        $this->_daUserSavedChallenges->addUserSavedChallenge( $this->getId(), $challenge->getId() );
    }

    /**
     * Delete a saved challenge
     *
     * @param BeMaverick_Challenge $challenge
     * @return void
     */
    public function deleteSavedChallenge( $challenge )
    {
        $this->_daUserSavedChallenges->deleteUserSavedChallenge( $this->getId(), $challenge->getId() );
    }


    /**
     * Get the user's contents
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Content[]
     */
    public function getContents($filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        if ( $filterBy == null ) {
            $filterBy = array();
        }

        $filterBy['userId'] = $this->getId();
        $filterBy['contentStatus'] = 'active';

        return $this->_site->getContents( $filterBy, $sortBy, $count, $offset );
    }


    /**
     * Get the user's saved contents
     *
     * @return BeMaverick_Content[]
     */
    public function getSavedContents()
    {
        $contentIds = $this->_daUserSavedContents->getContentIds( $this->getId() );

        $contents = array();
        foreach ( $contentIds as $contentId ) {
            $contents[] = $this->_site->getContent( $contentId );
        }

        return $contents;
    }

    /**
     * Add a saved content
     *
     * @param BeMaverick_Content $content
     * @return void
     */
    public function addSavedContent( $content )
    {
        $this->_daUserSavedContents->addUserSavedContent( $this->getId(), $content->getId() );
    }

    /**
     * Delete a saved content
     *
     * @param BeMaverick_Content $content
     * @return void
     */
    public function deleteSavedContent( $content )
    {
        $this->_daUserSavedContents->deleteUserSavedContent( $this->getId(), $content->getId() );
    }

    /**
     * Get a list of notifications for this user
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Notification[]
     */
    public function getNotifications( $filterBy = null, $sortBy = null, $count = null, $offset = null )
    {
        $filterBy['userId'] = $this->getId();

        return $this->_site->getNotifications( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the notification count
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getNotificationCount( $filterBy = null )
    {
        $filterBy['userId'] = $this->getId();

        return $this->_site->getNotificationCount( $filterBy );
    }

    /**
     * Gets the user's unique id
     *
     * @return mixed
     */
    public function getOAuthId()
    {
        return $this->getId();
    }

    /**
     * Gets the user's name.
     *
     * @return string
     */
    public function getOAuthName()
    {
        return $this->getUsername();
    }

    /**
     * Gets the username, used for OAuth for password grant-type.
     * Email can be used here if that's what the user and password combo is.
     *
     * @return mixed
     */
    public function getOAuthUserName()
    {
        // Validate email address for 'parent' users
        $userType = $this->getUserType();
        return ($userType == 'parent')
            ? $this->getEmailAddress()
            : $this->getUsername();
    }

    /**
     * Checks to see if the supplied password matches to that of the user
     *
     * @param string $password
     * @return boolean
     */
    public function isOAuthPasswordMatched( $password )
    {
        return $this->getPassword() === md5( $password );
    }

    /**
     * Get the oauth access token for this user
     *
     * Note: This access token can/will be used on forms that a user submits; for example
     * edit settings to prevent CSRF attackes.
     *
     * @param string $appKey
     * @return string
     */
    public function getOAuthAccessToken( $appKey = 'bemaverick_web' )
    {
        require_once( BEMAVERICK_COMMON_ROOT_DIR . '/config/autoload_oauth_dependencies.php' );

        // generate the oauth access  token
        $accessTokenManger = new Sly_OAuth_AccessTokenManager();
        $accessTokenManger->setAccessTokenSigningSecret( $this->_site->getSystemConfig()->getAccessTokenSigningSecret() );
        $accessTokenManger->setTokenTTL( 600 );
        $oAuthAccessToken = $accessTokenManger->createAccessToken( $appKey, $this->getId(), null, false );

        return $oAuthAccessToken['access_token'];
    }

    /**
     * Deactivate the account
     *
     * When we deactivate the account, we are not going to actually delete it from the database, but
     * instead just mark the user as deleted and set all the badges, challenges, responses and comments
     * as inactive/hidden
     *
     * @return void
     */
    public function deactivateAccount()
    {
        $userId = $this->getId();

        $this->setStatus( BeMaverick_User::USER_STATUS_INACTIVE );

        $daResponse = BeMaverick_Da_Response::getInstance();
        $daResponse->deactivateUser( $userId );

        $daResponseBadge = BeMaverick_Da_ResponseBadge::getInstance();
        $daResponseBadge->deactivateUser( $userId );

        $daChallenge = BeMaverick_Da_Challenge::getInstance();
        $daChallenge->deactivateUser( $userId );

        $daContent = BeMaverick_Da_Content::getInstance();
        $daContent->deactivateUser( $userId );

        $daContentBadge = BeMaverick_Da_ContentBadge::getInstance();
        $daContentBadge->deactivateUser( $userId );

        $this->_site->deleteComments( $userId, 'false' );

        $this->_site->deleteMentions( $userId, 'false' );
    }

    /**
     * Reactivate the account
     *
     * @return void
     */
    public function reactivateAccount()
    {
        $userId = $this->getId();

        $this->setStatus( BeMaverick_User::USER_STATUS_ACTIVE );

        $daResponse = BeMaverick_Da_Response::getInstance();
        $daResponse->reactivateUser( $userId );

        $daResponseBadge = BeMaverick_Da_ResponseBadge::getInstance();
        $daResponseBadge->reactivateUser( $userId );

        $daChallenge = BeMaverick_Da_Challenge::getInstance();
        $daChallenge->reactivateUser( $userId );

        $daContent = BeMaverick_Da_Content::getInstance();
        $daContent->reactivateUser( $userId );

        $daContentBadge = BeMaverick_Da_ContentBadge::getInstance();
        $daContentBadge->reactivateUser( $userId );

        $this->_site->deleteComments( $userId, 'true' );

        // eventually need a deleteMentions( $userId, 'true' );
    }

    /**
     * Get the url
     *
     * @param string $page
     * @param array $params
     * @param boolean $relativeUrl
     * @param string $overwriteSite
     * @param boolean $sortParams
     * @param boolean $isSecure
     * @return string
     */
    public function getUrl( $page = 'user',
        $params = array(),
        $relativeUrl = true,
        $overwriteSite = null,
        $sortParams = true,
        $isSecure = false
    ) {

        $slyUrl = Sly_Url::getInstance();

        $params['userId'] = $this->getId();

        return $slyUrl->getUrl( $page, $params, $relativeUrl, $overwriteSite, $sortParams, $isSecure );
    }

    /**
     * Get the user badged responses
     *
     * @param integer $badgeId
     * @param array $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Response[]
     */
    public function getBadgedResponses( $badgeId = null, $sortBy = array(), $count = null, $offset = 0 )
    {
        return $this->_site->getUserBadgedResponses( $this->getId(), $badgeId, $count, $offset );
    }

    /**
     * Get the user badged responses count
     *
     * @param integer $badgeId
     * @return integer
     */
    public function getBadgedResponseCount( $badgeId = null )
    {
        $filterBy = array(
            'responseStatus' => 'active',
            'badgedUserId' => $this->getId(),
            'badgeId' => $badgeId,
        );

        return $this->_site->getResponseCount( $filterBy );
    }

    /**
     * Get user getStatistics
     *
     * @return array
     */
    public function getStatistics()
    {

        $statistics = array();
        $user = $this;
        $site = $this->_site;

        $receivedBadgesCount = $user->getReceivedBadgesCount();
        $givenBadgesCount = $user->getGivenBadgesCount();

        $totalReceivedBadgeCount = 0;
        $totalGivenBadgeCount = 0;

        // add the badge stats
        $badges = $site->getBadges();
        foreach ( $badges as $badge ) {
            $badgeId = $badge->getId();
            $totalReceivedBadgeCount += (int) @$receivedBadgesCount[$badgeId]['count'];
            $totalGivenBadgeCount += (int) @$givenBadgesCount[$badgeId]['count'];
        }

        // add the stats
        $statistics['numReceivedBadges'] = $totalReceivedBadgeCount;
        $statistics['numGivenBadges'] = $totalGivenBadgeCount;
        $statistics['numFollowingUsers'] = (int)$user->getFollowingUserCount();
        $statistics['numFollowerUsers'] = (int)$user->getFollowersUserCount();

        return $statistics;
    }

    /**
     * Get user preferences
     *
     * @return array
     */
    public function getPreferences()
    {
        $userId = $this->getId();
        $preferences = $this->_daUserPreferences->getUserPreferences( $userId );
        $return = array();

        foreach($preferences as $preference) {
            $return[$preference['preference_type']] = (bool) $preference['value_bool'];
        }

        return $return;
    }

    /**
     * Update user preferences
     *
     * @param array $preferences
     * @return void
     */
    public function updatePreferences( $preferences )
    {
        $userId = $this->getId();
        $preferences = $this->_daUserPreferences->updateUserPreferences( $userId, $preferences );
    }

    /**
     * Save the user
     *
     * @return void
     */
    public function save()
    {
        $this->_daUser->save();

        $daUserLoginProviders = BeMaverick_Da_UserLoginProviders::getInstance();
        $daUserLoginProviders->save();
    }

    /**
     * Delete the user
     *
     * @return void
     */
    public function delete()
    {
        $filterBy = array(
            'userId' => $this->getId(),
        );

        $responses = $this->_site->getResponses( $filterBy );
        foreach ( $responses as $response ) {
            $response->delete();
        }

        $daUserLoginProviders = BeMaverick_Da_UserLoginProviders::getInstance();
        $daUserLoginProviders->deleteUser( $this->getId() );

        $daUserFollowingUsers = BeMaverick_Da_UserFollowingUsers::getInstance();
        $daUserFollowingUsers->deleteUser( $this->getId() );

        $daUserPreferences = BeMaverick_Da_UserPreferences::getInstance();
        $daUserPreferences->deleteUser( $this->getId() );

        $daUserSavedChallenges = BeMaverick_Da_UserSavedChallenges::getInstance();
        $daUserSavedChallenges->deleteUser( $this->getId() );

        $daUserSavedContents = BeMaverick_Da_UserSavedContents::getInstance();
        $daUserSavedContents->deleteUser( $this->getId() );

        $this->_daUser->deleteUser( $this->getId() );
    }

    /**
     * Load users from autocomplete query
     *
     * @param string $query
     * @return Array
     */
    public static function getAutocomplete( $site, $query )
    {
        $daUser = BeMaverick_Da_User::getInstance();

        $users = $daUser->getAutocomplete( $query );

        // Add Profile Image Data
        $users = array_map( function ( $user ) use ( $site ) {

            return array_merge(
                $user,
                array (
                    'profile_image' => 
                        $user['profile_image_id'] > 0
                        ? BeMaverick_Image::getImageDetails( $site, $user['profile_image_id'] )
                        : array(),
                    'isVerified' => $user['verified'] == '1' ? true : false,
                )
            );
        }, $users);

        // error_log('lib/User.php::getAutocomplete().$result => ' . print_r($result,true));

        return $users;
    }

    /**
     * get basic user data
     *
     * @return array
     */
    public function getUserDetails( )
    {
        // get vars
        $site = $this->getSite();
        $userId = $this->getId();
        $profileImage = $this->getProfileImage();

        // create user data
        $userData = array(
            'userId' => $userId,
            'username' => $this->getUsername(),
            'userType' => $this->getUserType(),
            'status' => $this->getStatus(),
            'firstName' => $this->getFirstName(),
            'lastName' => $this->getLastName(),
            'emailAddress' => $this->getEmailAddress(),
            'firstName' => $this->getFirstName(),
            'lastName' => $this->getLastName(),
            'bio' => method_exists(($this), 'getBio') ? $this->getBio() : null,
            'hashtags' => $this->getHashtags(),
            'birthdate' => $this->getBirthdate(),
            'phoneNumber' => $this->getPhoneNumber(),
            'verified' => method_exists(($this), 'getVerified') ? $this->getVerified() : null,
            'emailVerified' => method_exists(($this), 'getEmailVerified') ? $this->getEmailVerified() : null,
            'revokedReason' => $this->getRevokedReason(),
            'uuid' => $this->getUUID(),
            'registeredTimestamp' => $this->getRegisteredTimestamp(),
            'isVerified' => $this->isVerified() || false,
            'isEmailVerified' => $this->isEmailVerified() || false,
        );

        // add profile image info if user has custom profile image
        if ( $profileImage ) {
            $userData['profileImageId'] = $profileImage->getId();
            $profileImageUrlSmall = $profileImage ? $profileImage->getUrl( 50, 50 ) : null;
            $userData['profileImageUrls']['small'] = $profileImageUrlSmall;
            $profileImageUrlMedium = $profileImage ? $profileImage->getUrl( 200, 200 ) : null;
            $userData['profileImageUrls']['medium'] = $profileImageUrlMedium;
            $profileImageUrlOriginal = $profileImage ? $profileImage->getUrl() : null;
            $userData['profileImageUrls']['original'] = $profileImageUrlOriginal;

            $userData['profileImage'] = BeMaverick_Image::getImageDetails( $site, $profileImage->getId() );
        }

        return $userData;
    }


    /**
     * Publish the change to sns publish
     *
     * @param string $action
     *
     * @return void
     */
    public function publishChange( $action )
    {
        $site = $this->getSite();
        $data = $this->getUserDetails();

        // call sns publish
        return BeMaverick_Sns::publish( $site, 'user', $this->getId(), $action, $data );
    }

    /**
     * When following a user, publish to sns event
     *
     * @param BeMaverick_Site $site
     * @param string $eventType
     * @param integer $userId
     *
     * @return void
     */
    public function publishEvent( $site, $eventType, $userId )
    {
        $contentType = null;
        $contentId = null;
        $data = null;

        if ( $eventType == 'FOLLOW_USER' ) {
            $contentType = 'user';
            $contentId = $this->getId();

            $giveFollowUser = $site->getUser( $userId );

            $data = array(
                'users' => array(
                    $this->getUserDetails(),
                    $giveFollowUser->getUserDetails(),
                )
            );
        } elseif ( $eventType == 'COMPLETE_PROFILE' ) {
            if ( $this->getBio() && $this->getProfileImage() && $this->getFirstName() ) {
                $contentType = 'user';
                $contentId = $userId;

                $data = array(
                    'users' => array(
                        $this->getUserDetails(),
                    )
                );
            }
        }

        if ( $data ) {
            BeMaverick_Sns::publishEvent( $site, $eventType, $contentType, $contentId, $userId, $data );
        }
    }

    /**
     * Get the user level using lambda microservice
     *
     * @param bool $allowCache
     * @param number $ttl
     *
     * @return void
     */
    public function getCurrentLevelNumber( $allowCache = true, $ttl = 60 * 15)
    {
        /** Build the comments query */
        $userId = $this->getId();

        /** Check for cached data, first */
        $zendCache = Zend_Registry::get( 'cache' );
        $queryMd5 = md5(json_encode($userId));
        $cacheKey = 'bemaverick_users_' . $queryMd5;
        if ( $zendCache && $allowCache ) {
            $data = $zendCache->load( $cacheKey, $found );
//             error_log('cache : load : ' . $cacheKey . ' : ' . var_export($found));
            if ( $found ) {
                return json_decode($data, true);
            }
        }

        /** Load comments from the microservice, */
        $levelNumber = BeMaverick_Util::getUserCurrentLevelNumber($this->_site, $userId);

        /** Create userId tag array */
        $tags = array();
        if( $levelNumber ) {
            $tags[] = 'user:'.$userId;
        }

        /** Save comments to redis cache */
        if ( $zendCache ) {
//            error_log('cache : save : ' . $cacheKey);
            $zendCache->save( json_encode($levelNumber), $cacheKey, $tags, $ttl );
        }

        return $levelNumber;
    }

}

?>
