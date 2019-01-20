<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Date.php' );

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/FeaturedModels.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/ProfileCoverPresetImage.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Site.php' );

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/App.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/AWSTranscoder.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Badge.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Challenge.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Content.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Comment.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Coppa.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Image.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Mention.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Moderation.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Notification.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Redirect.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Response.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Stream.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Tag.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Util.php' );
//require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/User/Kid.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/User/Parent.php' );
//require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/User/Mentor.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/WordPress.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Video.php' );

/**
 * Class for management of a site
 *
 */
class BeMaverick_Site
{
    const TAG_TYPE_PREDEFINED  = 'predefined';
    const TAG_TYPE_USER        = 'user';

    const MODEL_TYPE_CHALLENGE = 'challenge';
    const MODEL_TYPE_RESPONSE  = 'response';
    const MODEL_TYPE_CONTENT   = 'content';
    const MODEL_TYPE_USER      = 'user';

    const POST_TYPE_RESPONSE     = 'response';
    const POST_TYPE_CONTENT      = 'content';

    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = array();

    /**
     * @var BeMaverick_Da_Site
     * @access protected
     */
    protected $_daSite;

    /**
     * @var array
     * @access protected
     */
    protected $_data;

    /**
     * Class constructor
     *
     * @param BeMaverick_Factory $factory
     * @param integer $siteId
     * @return void
     */
    public function __construct( $factory, $siteId )
    {
        $this->_factory = $factory;
        $this->_siteId = $siteId;

        $this->_daSite = BeMaverick_Da_Site::getInstance();
    }

    /**
     * Retrieves the site instance.
     *
     * @param BeMaverick_Factory $factory
     * @param integer $siteId
     * @return BeMaverick_Site
     */
    public static function getInstance( $factory, $siteId )
    {
        $key = $factory->getSiteCode() . $siteId;

        if ( !isset( self::$_instance[$key] ) ) {
            self::$_instance[$key] = new self( $factory, $siteId );
        }

        return self::$_instance[$key];
    }

    /**
     * Get the url
     *
     * @return string
     */
    public function getUrl( $page = 'home',
                            $params = array(),
                            $relativeUrl = true,
                            $overwriteSite = null,
                            $sortParams = true,
                            $isSecure = false )
    {
        $slyUrl = Sly_Url::getInstance();
        return $slyUrl->getUrl( $page, $params, $relativeUrl, $overwriteSite, $sortParams, $isSecure );
    }

    /**
     * Get the id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->_siteId;
    }

    /**
     * Get the factory
     *
     * @return BeMaverick_Factory
     */
    public function getFactory()
    {
        return $this->_factory;
    }

    /**
     * Get the system config
     *
     * @return object
     */
    public function getSystemConfig()
    {
        return $this->_factory->getSystemConfig();
    }

    /**
     * Get the app
     *
     * @param string $appKey
     * @return BeMaverick_App
     */
    public function getApp( $appKey )
    {
        return BeMaverick_App::getInstance( $this, $appKey );
    }

    /**
     * Get the image
     *
     * @param integer $imageId
     * @return BeMaverick_Image
     */
    public function getImage( $imageId )
    {
        return BeMaverick_Image::getInstance( $this, $imageId );
    }

    /**
     * Get image url for AWS S3
     *
     * @param string $imageName
     * @param string $path
     * @return string
     */
    public function getAwsImageUrl( $imageName, $path )
    {
        return 'https://s3.amazonaws.com/bemaverick-website-images/'.$path.'/'.$imageName;
    }

    /**
     * Get the user
     *
     * @param integer $userId
     * @return BeMaverick_User_Kid|BeMaverick_User_Parent|null
     */
    public function getUser( $userId )
    {
        if ( ! $userId ) {
            return null;
        }

        $daUser = BeMaverick_Da_User::getInstance();

        $userType = $daUser->getUserType( $userId );

        if ( $userType == BeMaverick_User::USER_TYPE_KID ) {
//            return $this->getKid( $userId );
            return BeMaverick_User::getInstance( $this, $userId );
        } else if ( $userType == BeMaverick_User::USER_TYPE_PARENT ) {
            return $this->getParent( $userId );
        } else if ( $userType == BeMaverick_User::USER_TYPE_MENTOR ) {
            return BeMaverick_User::getInstance( $this, $userId );
        }

        return null;
    }


    /**
     * Get the user from the cookie
     *
     * @return BeMaverick_User
     */
    public function getUserByCookie()
    {
        $userId = BeMaverick_Cookie::getUserId();

        return $this->getUser( $userId );
    }

    /**
     * Get the kid
     *
     * @param integer $userId
     * @return BeMaverick_User_Kid
     */
    public function getKid( $userId )
    {
        return BeMaverick_User_Kid::getInstance( $this, $userId );
    }

    /**
     * Get the parent
     *
     * @param integer $userId
     * @return BeMaverick_User_Parent
     */
    public function getParent( $userId )
    {
        return BeMaverick_User_Parent::getInstance( $this, $userId );
    }

    /**
     * Get the mentor
     *
     * @param integer $userId
     * @return BeMaverick_User_Mentor
     */
    public function getMentor( $userId )
    {
        return BeMaverick_User_User::getInstance( $this, $userId );
    }

    /**
     * Get the user by username
     *
     * @param string $username
     * @param string $status
     * @return BeMaverick_User
     */
    public function getUserByUsername( $username, $status = 'active' )
    {
        return BeMaverick_User::getUserByUsername( $this, $username, $status );
    }

    /**
     * Get the user by email address
     *
     * @param string $emailAddress
     * @param string $status
     * @return BeMaverick_User
     */
    public function getUserByEmailAddress( $emailAddress, $status = 'active' )
    {
        return BeMaverick_User::getUserByEmailAddress( $this, $emailAddress, $status );
    }

    /**
     * Get the user by phone number
     *
     * @param string $phoneNumber
     * @param string $status
     * @return BeMaverick_User
     */
    public function getUserByPhoneNumber( $phoneNumber, $status = 'active' )
    {
        return BeMaverick_User::getUserByPhoneNumber( $this, $phoneNumber, $status );
    }

    /**
     * Get the user by login provider
     *
     * @param string $loginProvider
     * @param string $loginProviderUserId
     * @return BeMaverick_User
     */
    public function getUserByLoginProvider( $loginProvider, $loginProviderUserId )
    {
        return BeMaverick_User::getUserByLoginProvider( $this, $loginProvider, $loginProviderUserId );
    }

    /**
     * Check if username is taken
     *
     * @param string $username
     * @return BeMaverick_User
     */
    public function isUsernameTaken( $username )
    {
        return BeMaverick_User::isUsernameTaken( $username );
    }

    /**
     * Check if email address is taken
     *
     * @param string $emailAddress
     * @return BeMaverick_User
     */
    public function isEmailAddressTaken( $emailAddress )
    {
        return BeMaverick_User::isEmailAddressTaken( $emailAddress );
    }

    /**
     * Get the users
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_User[]
     */
    public function getUsers( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        return BeMaverick_User::getUsers( $this, $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the user count
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getUserCount( $filterBy = null )
    {
        return BeMaverick_User::getUserCount( $filterBy );
    }

    /**
     * Get the kids by parent email address
     *
     * @param string $emailAddress
     * @return BeMaverick_User_Kid[]
     */
    public function getKidsByParentEmailAddress( $emailAddress )
    {
        $filterBy = array(
            'parentEmailAddress' => $emailAddress,
        );

        return $this->getUsers( $filterBy );
    }

    /**
     * Create the kid
     *
     * @param string $username
     * @param string $password
     * @param string $birthdate
     * @param string $emailAddress
     * @param string $parentEmailAddress
     * @return BeMaverick_User_Kid
     */
    public function createKid( $username, $password, $birthdate, $emailAddress, $parentEmailAddress )
    {
        $kid = BeMaverick_User::createUser( $this, BeMaverick_User::USER_TYPE_KID, $username, $password, $emailAddress, $parentEmailAddress, $birthdate );

        $this->moderateUser( $kid );

        return $kid;
    }

    /**
     * Create the parent
     *
     * @param string $username
     * @param string $password
     * @param string $emailAddress
     * @return BeMaverick_User_Parent
     */
    public function createParent( $username, $password, $emailAddress )
    {
        return BeMaverick_User_Parent::createParent( $this, $username, $password, $emailAddress );
    }

    /**
     * Get the mentors
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return array
     */
    public function getMentors( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $filterBy['userType'] = BeMaverick_User::USER_TYPE_MENTOR;

        return $this->getUsers( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the mentor count
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getMentorCount( $filterBy = null )
    {
        $filterBy['userType'] = BeMaverick_User::USER_TYPE_MENTOR;

        return $this->getUserCount( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Create the mentor
     *
     * @param string $username
     * @param string $password
     * @param string $emailAddress
     * @return BeMaverick_User_Mentor
     */
    public function createMentor( $username, $password, $emailAddress = null )
    {
        return BeMaverick_User::createUser( $this, BeMaverick_User::USER_TYPE_MENTOR, $username, $password, $emailAddress );
    }

    /**
     * Get the challenge
     *
     * @param integer $challengeId
     * @return BeMaverick_Challenge
     */
    public function getChallenge( $challengeId )
    {
        return BeMaverick_Challenge::getInstance( $this, $challengeId );
    }

    /**
     * Get the challenge ids
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getChallengeIds( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        return BeMaverick_Challenge::getChallengeIds( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the challenges
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Challenge[]
     */
    public function getChallenges( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        return BeMaverick_Challenge::getChallenges( $this, $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the challenge stream challenges
     *
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Challenge[]
     */
    public function getChallengeStreamChallenges( $count = 10, $offset = 10 ) {
        
        // TODO: Load featuredOffset and featuredFrequency from database settings table
        $featuredOffset = 1; // The position (-1) where the first featured challenge appears in the stream
        $featuredFrequency = 5; // How frequently featured challenges appear after the first featured challenge
        $injectedChallenges = array(); // TODO: load injected challenges from Admin Tool into 1,2,3,4, and/or 5 positions (-1)

        /**
         * Featured Challenges
         */
        $featuredChallengeIds = $this->getFeaturedChallengeIds( 'challenge-stream', true );
        $featuredChallenges = array_map( function ( $challengeId, $key ) use ( $featuredFrequency, $featuredOffset ) {
            return [ 'challengeId' => $challengeId, 'index' => ($key * $featuredFrequency) + $featuredOffset ];
        }, $featuredChallengeIds, array_keys($featuredChallengeIds) ); // Adds calculated indices at $featuredChallenges['index']
        // Calculate skipped featured challenges based on offset
        $skippedFeaturedChallenges = array_filter( $featuredChallenges, function( $challenge ) use ( $offset ) { 
            return ($challenge['index'] < $offset);
        });
        // Calculate visible featured challenges based on offset and count (limit)
        $visibleFeaturedChallenges = array_filter( $featuredChallenges, function( $challenge ) use ( $count, $offset ) { 
            return ($challenge['index'] >= $offset && $challenge['index'] < ( $count + $offset ));
        });

        /**
         * Active Challenges
         */
        $filterBy = array(
            'challengeStatus' => 'active',
            'challengeStream' => false,
            'hideFromStreams' => false,
        );
        $activeCount = (int)$count - count($visibleFeaturedChallenges);
        $activeOffset = (int)$offset - count($skippedFeaturedChallenges);
        $activeChallengeIds = $this->getChallengeIds( $filterBy, null, $activeCount, $activeOffset );
         
        /**
         * Combine Active and Featured Challenges
         */
        $combinedChallengeIds = $activeChallengeIds;
        foreach($visibleFeaturedChallenges as $featuredChallenge) {
            $challengeId = $featuredChallenge['challengeId'];
            $index = $featuredChallenge['index'] - $offset;
            array_splice( $combinedChallengeIds, $index, 0, array($challengeId) );
        }

        /**
         * Return Combined Challenge Ids
         */
        return $combinedChallengeIds;

    }

    /**
     * Get the challenge count
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getChallengeCount( $filterBy = null )
    {
        return BeMaverick_Challenge::getChallengeCount( $filterBy );
    }

    /**
     * Create the challenge
     *
     * @param BeMaverick_User $user
     * @param string $title
     * @param string $challengeDescription
     * @return BeMaverick_Challenge
     */
    public function createChallenge( $user, $title, $challengeDescription, $challengeType=null, $video=null, $image=null )
    {
        return BeMaverick_Challenge::createChallenge( $this, $user, $title, $challengeDescription, $challengeType, $video, $image );
    }

    /**
     * Get the content
     *
     * @param integer $contentId
     * @return BeMaverick_Content
     */
    public function getContent( $contentId )
    {
        return BeMaverick_Content::getInstance( $this, $contentId );
    }

    /**
     * Get the content ids
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getContentIds( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        return BeMaverick_Content::getContentIds( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the contents
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Content[]
     */
    public function getContents( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        return BeMaverick_Content::getContents( $this, $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the content count
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getContentCount( $filterBy = null )
    {
        return BeMaverick_Content::getContentCount( $filterBy );
    }

    /**
     * Create a content
     *
     * @param string $contentType
     * @param BeMaverick_User $user
     * @param BeMaverick_Video $video
     * @param BeMaverick_Image $image
     * @param string $title
     * @param string $description
     * @param boolean $skipComments
     * @return BeMaverick_Content
     */
    public function createContent( $contentType, $user, $video, $image, $title, $description, $skipComments )
    {
        return BeMaverick_Content::createContent( $this, $contentType, $user, $video, $image, $title, $description, $skipComments );
    }

    /**
     * Get the video
     *
     * @param integer $videoId
     * @return BeMaverick_Video
     */
    public function getVideo( $videoId )
    {
        return BeMaverick_Video::getInstance( $this, $videoId );
    }

    /**
     * Get the videos
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Video[]
     */
    public function getVideos( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        return BeMaverick_Video::getVideos( $this, $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the video count
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getVideoCount( $filterBy = null )
    {
        return BeMaverick_Video::getVideoCount( $filterBy );
    }

    /**
     * Create the video
     *
     * @param string $filename
     * @param integer $width
     * @param integer $height
     * @return BeMaverick_Video
     */
    public function createVideo( $filename, $width = null, $height = null )
    {
        return BeMaverick_Video::createVideo( $this, $filename, $width, $height );
    }

    /**
     * Get the response
     *
     * @param integer $responseId
     * @return BeMaverick_Response
     */
    public function getResponse( $responseId )
    {
        return BeMaverick_Response::getInstance( $this, $responseId );
    }

    /**
     * Get the response ids
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getResponseIds( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        return BeMaverick_Response::getResponseIds( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the responses
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Response[]
     */
    public function getResponses( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        return BeMaverick_Response::getResponses( $this, $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the response ids from engaged users
     *
     * @param string $date
     * @return integer[]
     */
    public function getEngagedUsersResponseIds( $date )
    {
        return BeMaverick_Response::getEngagedUsersResponseIds( $date );
    }

    /**
     * Get the responses the user badged
     *
     * @param hash $userId
     * @param hash $badgeId
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Response[]
     */
    public function getUserBadgedResponses( $userId, $badgeId, $count = null, $offset = 0 )
    {
        return BeMaverick_Response::getBadgedResponses( $this, $userId, $badgeId, $count, $offset );
    }

    /**
     * Get the list of users with a response to challenge
     *
     * @param BeMaverick_Challenge $challenge
     * @param integer $count
     * @return BeMaverick_User[]
     */
    public function getUniqueUsersWithResponseToChallenge( $challenge, $count )
    {
        return BeMaverick_Response::getUniqueUsersWithResponseToChallenge( $this, $challenge, $count );
    }

    /**
     * Get the response count
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getResponseCount( $filterBy = null )
    {
        return BeMaverick_Response::getResponseCount( $filterBy );
    }

    /**
     * Create the response
     *
     * @param string $responseType
     * @param BeMaverick_User $user
     * @param BeMaverick_Challenge $challenge
     * @param BeMaverick_Video $video
     * @param BeMaverick_Image $image
     * @param boolean $skipComments
     * @return BeMaverick_Response
     */
    public function createResponse( 
        $responseType, 
        $user, 
        $challenge, 
        $video, 
        $image, 
        $skipComments, 
        $postType = null, 
        $description = null, 
        $tagNames = array(),
        $responseStatus = BeMaverick_Response::RESPONSE_STATUS_ACTIVE
    )
    {
        return BeMaverick_Response::createResponse( 
            $this, 
            $responseType, 
            $user, 
            $challenge, 
            $video, 
            $image, 
            $skipComments, 
            $postType, 
            $description, 
            $tagNames,
            $responseStatus 
        );
    }

    /**
     * Get the stream
     *
     * @param integer $streamId
     * @return BeMaverick_Stream
     */
    public function getStream( $streamId )
    {
        $stream = BeMaverick_Stream::getInstance( $this, $streamId );

        // Check Rotation Logic
        if ( $stream && method_exists ( $stream , 'checkRotation' ) )
        {
            $stream->checkRotation();
        }

        return $stream;
    }

    /**
     * Get the streams
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Stream[]
     */
    public function getStreams( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $streams = BeMaverick_Stream::getStreams( $this, $filterBy, $sortBy, $count, $offset );

        // Check Rotation Logic
        foreach($streams as $stream) {
            if ( $stream && method_exists ( $stream , 'checkRotation' ) )
            {
                $stream->checkRotation();
            }
        }
        
        return $streams;
    }

    /**
     * Get the stream count
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getStreamCount( $filterBy = null )
    {
        return BeMaverick_Stream::getStreamCount( $filterBy );
    }

    /**
     * Create the stream
     *
     * @param string $label
     * @param hash $definition
     * @param integer $sortOrder
     * @return BeMaverick_Stream
     */
    public function createStream( $label, $definition, $sortOrder, $modelType=null, $streamType=null, $status='active' )
    {
        return BeMaverick_Stream::createStream( $this, $label, $definition, $sortOrder, $modelType, $streamType, $status );
    }

    /**
     * Get the badge
     *
     * @param integer $badgeId
     * @return BeMaverick_Badge
     */
    public function getBadge( $badgeId )
    {
        return BeMaverick_Badge::getInstance( $this, $badgeId );
    }

    /**
     * Get the badges
     *
     * @return BeMaverick_Badge[]
     */
    public function getBadges($status = null)
    {
        return BeMaverick_Badge::getBadges( $this, $status );
    }

    /**
     * Get the tag
     *
     * @param integer $tagId
     * @return BeMaverick_Tag
     */
    public function getTag( $tagId )
    {
        return BeMaverick_Tag::getInstance( $this, $tagId );
    }

    /**
     * Get the tag by name
     *
     * @param string $tagName
     * @return BeMaverick_Tag
     */
    public function getTagByName( $tagName )
    {
        return BeMaverick_Tag::getTagByName( $this, $tagName );
    }

    /**
     * Get the tags
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Tag[]
     */
    public function getTags( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        return BeMaverick_Tag::getTags( $this, $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Create the tag
     *
     * @param string $type
     * @param string $tagName
     * @return BeMaverick_Tag
     */
    public function createTag( $type, $tagName )
    {
        return BeMaverick_Tag::createTag( $this, $type, $tagName );
    }

    /**
     * Get the notification
     *
     * @param integer $notificationId
     * @return BeMaverick_Notification
     */
    public function getNotification( $notificationId )
    {
        return BeMaverick_Notification::getInstance( $this, $notificationId );
    }

    /**
     * Get the notifications
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Notification[]
     */
    public function getNotifications( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        return BeMaverick_Notification::getNotifications( $this, $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get the notification count
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getNotificationCount( $filterBy = null )
    {
        return BeMaverick_Notification::getNotificationCount( $filterBy );
    }


    /**
     * Get the activities
     *
     * @param BeMaverick_User $user
     * @param integer $count
     * @param integer $offset
     * @return array[]
     */
    public function getActivities( $user, $count = null, $offset = 0 )
    {
        if ( $user ) {
            $activities = BeMaverick_Util::getActivities( $this, $user );

            if ( $activities ) {
                return array_slice( $activities, $offset, $count );
            }
        }

        return array();
    }

    /**
     * Get the notification count
     *
     * @param BeMaverick_User $user
     * @return integer
     */
    public function getActivityCount( $user )
    {
        $activities = $this->getActivities( $user );

        return count( $activities );
    }


    /**
     * Create the notification
     *
     * @param integer $userId
     * @param string $action
     * @param integer $objectId
     * @param string $objectType
     * @return BeMaverick_Notification
     */
    public function createNotification( $userId, $action, $objectId, $objectType )
    {
        return BeMaverick_Notification::createNotification( $this, $userId, $action, $objectId, $objectType );
    }

    /**
     * Create the preset profile cover image
     *
     * @param BeMaverick_Image $image
     * @return void
     */
    public function createProfileCoverPresetImage( $image )
    {
        $daPreset = BeMaverick_Da_ProfileCoverPresetImage::getInstance();

        return $daPreset->createProfileCoverPresetImage( $image->getId() );
    }

    /**
     * Get a list of profile cover preset image ids
     *
     * @return integer[]
     */
    public function getProfileCoverPresetImageIds()
    {
        $daPreset = BeMaverick_Da_ProfileCoverPresetImage::getInstance();

        return $daPreset->getProfileCoverPresetImageIds( null, null, null, 0 );
    }

    /**
     * Get a profile cover preset image
     *
     * @param integer $profileCoverPresetImageId
     * @return BeMaverick_Image
     */
    public function getProfileCoverPresetImage( $profileCoverPresetImageId )
    {
        $daPreset = BeMaverick_Da_ProfileCoverPresetImage::getInstance();

        $imageId = $daPreset->getImageId( $profileCoverPresetImageId );

        return $this->getImage( $imageId );
    }

    /**
     * Set a profile cover preset image
     *
     * @param integer $profileCoverPresetImageId
     * @param BeMaverick_Image $image
     * @return void
     */
    public function setProfileCoverPresetImage( $profileCoverPresetImageId, $image )
    {
        $daPreset = BeMaverick_Da_ProfileCoverPresetImage::getInstance();

        $daPreset->setImageId( $profileCoverPresetImageId, $image->getId() );
    }

    /**
     * Get the amazon config
     *
     * @return hash
     */
    public function getAmazonConfig()
    {
        $systemConfig = $this->getSystemConfig();

        $config = array(
            'version' => 'latest',
            'region' => $systemConfig->getSetting( 'AWS_REGION' ),
            'credentials' => array(
                'key'        => $systemConfig->getSetting( 'AWS_ACCESS_KEY_ID' ),
                'secret'     => $systemConfig->getSetting( 'AWS_ACCESS_KEY_SECRET' ),
            ),
        );

        return $config;
    }

    /**
     * Generate thumbnail url from the amazon video filename
     *
     * @param string $filename
     * @return string
     */
    public function generateAmazonVideoThumbnail( $filename )
    {
        $systemConfig = $this->getSystemConfig();

        $pathinfo = pathinfo( $filename );

        $bucketName = $systemConfig->getSetting( 'AWS_S3_VIDEO_THUMBNAIL_BUCKET_NAME' );

        return 'https://s3.amazonaws.com/' . $bucketName . '/' . $pathinfo['filename'] . '-thumbnail-00001.jpg';
    }

    /**
     * Upload the video contents to the Amazon S3
     *
     * @param string $videoFileContents
     * @param string $filename
     * @return void
     */
    public function uploadVideoToAmazon( $videoFileContents, $filename )
    {
        $systemConfig = $this->getSystemConfig();
        $amazonConfig = $this->getAmazonConfig();

        $bucketName = $systemConfig->getSetting( 'AWS_S3_VIDEO_INPUT_BUCKET_NAME' );

        Sly_Service_Amazon_S3::putFileContents( $videoFileContents, $filename, $bucketName, $amazonConfig );
    }

    /**
     * Create an image from an amazon file
     *
     * @param string $filename
     * @return string
     */
    public function createImageFromAmazonImage( $filename, $width = null, $height = null )
    {
        $systemConfig = $this->getSystemConfig();
        $amazonConfig = $this->getAmazonConfig();
        $bucketName = $systemConfig->getSetting( 'AWS_S3_IMAGE_BUCKET_NAME' );

        if ( ! ( $width && $height ) ) {
            // error_log("Site.php::createImageFromAmazonImage:: Download image from bucket :: $bucketName");
            $imageContents = Sly_Service_Amazon_S3::getFileContents( $filename, $bucketName, $amazonConfig );

            $img = new Imagick();
            $img->readImageBlob( $imageContents );

            $width = $img->getImageWidth();
            $height = $img->getImageHeight();
        } else {
            // error_log("Site.php::createImageFromAmazonImage:: User \$width and \$height :: $width x $height");
        }

        $contentType = null;

        $extension = pathinfo( $filename, PATHINFO_EXTENSION );

        if ( $extension == 'jpg' ) {
            $contentType = 'image/jpeg';
        } else if ( $extension == 'png' ) {
            $contentType = 'image/png';
        } else if ( $extension == 'gif' ) {
            $contentType = 'image/gif';
        }

        return BeMaverick_Image::createImage( $this, $filename, $contentType, $width, $height );
    }


    /**
     * Start the Amazon Transcoder Job
     *
     * @param BeMaverick_Video $video
     * @param string $videoType  Either 'challenge' or 'response'
     * @return string
     */
    public function startAmazonTranscoderJob( $video, $videoType )
    {
        $systemConfig = $this->getSystemConfig();
        $amazonConfig = $this->getAmazonConfig();

        $pipelineId = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_PIPELINE_ID' );
        $isHLSEnabled = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_HLS_ENABLED' );
        $filename = $video->getFilename();

        if ( $videoType == BeMaverick_Site::MODEL_TYPE_CHALLENGE  ) {
            $presetId = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_CHALLENGE_PRESET_ID' );
        } else if ( $videoType == BeMaverick_Site::MODEL_TYPE_RESPONSE || $videoType == BeMaverick_Site::MODEL_TYPE_CONTENT  ) {
            $presetId = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_RESPONSE_PRESET_ID' );}

        $job = BeMaverick_AWSTranscoder::createJob( $filename, $pipelineId, $presetId, $amazonConfig );

        $video->createEncodingJob( $job['Id'], $job['Status'] );
        error_log( print_r("BeMaverick_Site::startAmazonTranscoderJob::Job".json_encode( $job ), true) );

        if( $isHLSEnabled ) {
            $video->setHLSFormat( true );
            $job = BeMaverick_AWSTranscoder::createHLSJob( $filename, $pipelineId, $amazonConfig);
            $video->createEncodingJob( $job['Id'], $job['Status'] );
            error_log( print_r("BeMaverick_Site::startAmazonTranscoderJob::HLSJob".json_encode( $job ), true) );
        }
        return $job;
    }

    /**
     * Set the job status of video encoder job
     *
     * @param string $jobId
     * @param string $jobStatus
     * @param string $playlistname
     * @return void
     */
    public function setVideoEncoderJobStatus( $jobId, $jobStatus, $playlistname  )
    {
        BeMaverick_Video::setVideoEncoderJobStatus( $this, $jobId, $jobStatus, $playlistname  );
    }

    /**
     * The database that contain OAuth data
     *
     * @return Sly_OAuth_Pdo
     */
    public function getOAuthStorage()
    {
        require_once( BEMAVERICK_COMMON_ROOT_DIR . '/config/autoload_oauth_dependencies.php' );

        $dbConfig = Zend_Registry::get( 'databaseConfig' );
        $dbSettings = $dbConfig->getDatabaseSettings( 'bemaverick' );

        return new Sly_OAuth_Pdo(
            array(
                'dsn' => 'mysql:dbname='.$dbSettings['dbname'].';host='.$dbSettings['host'],
                'username' => $dbSettings['username'],
                'password' => $dbSettings['password'],
            )
        );
    }

    /**
     * Get the user by username for OAuth. OAuth users can be inactive or revoked status
     *
     * @param string $username
     * @return BeMaverick_User
     */
    public function getUserForOAuth( $username )
    {
        $filterBy = array(
            'username' => $username,
        );
        return BeMaverick_User::getUser( $this, $filterBy );
    }


    /**
     * Generates the access token for accessing the comments third party provider
     *
     * @param BeMaverick_User $user
     * @param String $deviceId
     * @return String
     */
    public function createCommentAccessToken( $user, $deviceId )
    {
        return BeMaverick_Comment::createAccessToken( $this, $user, $deviceId );
    }

    /**
     * Get the list of comments
     *
     * @param string $channelId
     * @return Twilio\Rest\Api\V2010\Account\Message[]
     */
    public function getTwilioComments( $channelId )
    {
        // return BeMaverick_Comment::getComments( $this, $channelId );
    }

    /**
     * Get the list of comments
     *
     * @param String $parentType      e.g. channel, response
     * @param String $parentId        e.g. 1, 900
     * @param Array $params           query object
     * @return Object
     */
    public function getComments( $parentType, $parentId, $query = array(), $allowCache )
    {
        return BeMaverick_Comment::getComments($this, $parentType, $parentId, $query, $allowCache );
    }

    /**
     * Delete the user's comments
     *
     * @param String $userId
     * @param String $active
     * @return Object
     */
    public function deleteComments( $userId, $active )
    {
        BeMaverick_Comment::deleteComments( $this, $userId, $active );
    }

    /**
     * Delete the comment mentions meta the user is included in
     *
     * @param String $userId
     * @param String $active
     * @return Object
     */
    public function deleteMentions( $userId, $active )
    {
        BeMaverick_Comment::deleteMentions( $this, $userId, $active );
    }

    /**
     * Verify the identity of the parent through a third party verification service.
     *
     * @param string $kidUserId
     * @param string $firstName
     * @param string $lastName
     * @param string $address
     * @param string $zip
     * @param string $ssn
     * @param string $testKey
     * @return String
     */
    public function verifyParentIdentity( $kidUserId, $firstName, $lastName, $address, $zip, $ssn, $testKey )
    {
        return BeMaverick_COPPA::verifyParentIdentity( $this, $kidUserId, $firstName, $lastName, $address, $zip, $ssn, $testKey );
    }

    /**
     * Moderate a response
     *
     * @param BeMaverick_Response $response
     * @param String $token
     * @return String
     */
    public function moderateResponse( $response, $token=null )
    {
        return BeMaverick_Moderation::moderateResponse( $this, $response, $token );
    }

    /**
     * Moderate a challenge
     *
     * @param BeMaverick_Challenge $challenge
     * @param String $token
     * @return String
     */
    public function moderateChallenge( $challenge, $token=null )
    {
        return BeMaverick_Moderation::moderateChallenge( $this, $challenge, $token );
    }

    /**
     * Flag a response
     *
     * @param BeMaverick_Response $response
     * @param BeMaverick_User $user
     * @param String $reason
     * @return String
     */
    public function flagResponse( $response, $user, $reason )
    {
        return BeMaverick_Moderation::flagResponse( $this, $response, $user, $reason );
    }

    /**
     * Flag a user
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_User $flaggedUser
     * @param String $reason
     * @return String
     */
    public function flagUser( $user, $flaggedUser, $reason )
    {
        return BeMaverick_Moderation::flagUser( $this, $user, $flaggedUser, $reason );
    }

    /**
     * Moderate a response
     *
     * @param String $approvals
     * @return String
     */
    public function moderateResponseApprovals( $approvals )
    {
        return BeMaverick_Moderation::moderateResponseApprovals( $this, $approvals );
    }

    /**
     * Moderate a response
     *
     * @param String $userAction
     * @return String
     */
    public function moderateUserActions( $userAction )
    {
        return BeMaverick_Moderation::moderateUserActions( $this, $userAction );
    }

    /**
     * Moderate a username
     *
     * @param String userName
     * @return String
     */
    public function moderateUserName( $userName )
    {
        return BeMaverick_Moderation::moderateUserName( $this, $userName );
    }

    /**
     * Moderate a user
     *
     * @param BeMaverick_User $user
     */
    public function moderateUser( $user )
    {
        BeMaverick_Moderation::moderateUser( $this, $user );
    }

    /**
     * Moderate user bio, profileImage, coverImage
     *
     * @param BeMaverick_User $user
     */
    public function moderateUserData ( $user )
    {
        BeMaverick_Moderation::moderateUserData( $this, $user );
    }

    /**
     * Moderate audio in a video response
     *
     * @param BeMaverick_Response $response
     * @param String $token
     */
    public function moderateAudio ( $response, $token )
    {
        BeMaverick_Moderation::moderateAudio( $this, $response, $token );
    }

    /**
     * Update the status of a response
     *
     * @param String $responseId
     * @param String $moderationStatus
     */
    public function updateResponseStatus ( $responseId, $moderationStatus  )
    {
        $response = $this->getResponse( $responseId );
        $response->setModerationStatus( $moderationStatus );
        $response->setUpdatedTimestamp( date( 'Y-m-d H:i:s' ) );

        if( $moderationStatus == 'allow' || $moderationStatus == 'error' )
        {
            $response->setStatus( BeMaverick_Response::RESPONSE_STATUS_ACTIVE );

        }else {
            $response->setStatus(BeMaverick_Response::RESPONSE_STATUS_INACTIVE);
            //todo email the user that the response is taken down.
            if ( $moderationStatus == BeMaverick_Moderation::MODERATION_STATUS_QUEUEDFORAPPROVAL) {

                $message = "Don’t stress, but your response was flagged by our system to be moderated.  Our team is reviewing it now & we’ll either repost it as soon as we can or will let you know why it has to come down.";

            } else if ( $moderationStatus == BeMaverick_Moderation::MODERATION_STATUS_REJECT ) {

                $message = "Sorry, but we had to remove your content because it violates our community guidelines.";
            }
            BeMaverick_Util::sendNotificationForModeration($this, $response, $message, 'response' );
        }
    }

    /**
     * Update the status of a challenge
     *
     * @param String $challengeId
     * @param String $moderationStatus
     */
    public function updateChallengeStatus ( $challengeId, $moderationStatus  )
    {
        $challenge = $this->getChallenge( $challengeId );
        $challenge->setModerationStatus( $moderationStatus );
        $challenge->setUpdatedTimestamp( date( 'Y-m-d H:i:s' ) );

        if( $moderationStatus == 'allow' || $moderationStatus == 'error' ) {
            $challenge->setStatus(BeMaverick_Challenge::CHALLENGE_STATUS_PUBLISHED);
        }else {
            $challenge->setStatus(BeMaverick_Challenge::CHALLENGE_STATUS_HIDDEN);
            // todo email the user that the challenge is taken down.
            if ( $moderationStatus == BeMaverick_Moderation::MODERATION_STATUS_QUEUEDFORAPPROVAL) {

                $message = "Don’t stress, but your challenge was flagged by our system to be moderated.  Our team is reviewing it now & we’ll either repost it as soon as we can or will let you know why it has to come down.";

            } else if ( $moderationStatus == BeMaverick_Moderation::MODERATION_STATUS_REJECT ) {

                $message = "Sorry, but we had to remove your content because it violates our community guidelines.";
            }
            BeMaverick_Util::sendNotificationForModeration($this, $challenge, $message, 'challenge' );
        }
    }


    /**
     * Get a list of featured model ids
     *
     * @param string $featuredType
     * @param string $modelType
     * @return integer[]
     */
    public function getFeaturedModelIds( $featuredType, $modelType, $activeOnly = true )
    {
        $daFeaturedModels = BeMaverick_Da_FeaturedModels::getInstance();

        return $daFeaturedModels->getFeaturedModelIds( $featuredType, $modelType, $activeOnly );
    }

    /**
     * Add featured model
     *
     * @param string $featuredType
     * @param integer $modelId
     * @param string $modelType
     * @param integer $sortOrder
     * @return void
     */
    public function addFeaturedModel( $featuredType, $modelId, $modelType, $sortOrder )
    {
        $daFeaturedModels = BeMaverick_Da_FeaturedModels::getInstance();

        // check if we have this model already and if so, just update the sort order
        if ( $daFeaturedModels->isKeysExist( array( $featuredType, $modelId, $modelType ) ) ) {
            $daFeaturedModels->setSortOrder( $featuredType, $modelId, $modelType, $sortOrder );
        } else {
            $daFeaturedModels->addFeaturedModel( $featuredType, $modelId, $modelType, $sortOrder );
        }
    }

    /**
     * Delete featured model
     *
     * @param string $featuredType
     * @param integer $modelId
     * @param string $modelType
     * @return void
     */
    public function deleteFeaturedModel( $featuredType, $modelId, $modelType )
    {
        $daFeaturedModels = BeMaverick_Da_FeaturedModels::getInstance();

        $daFeaturedModels->deleteFeaturedModel( $featuredType, $modelId, $modelType );
    }

    /**
     * Updated featured models
     *
     * @param string $featuredType
     * @param string $modelType
     * @param integer[] $modelIds
     * @param boolean $activeOnly This is only used for challenges
     * @return void
     */
    public function updateFeaturedModels( $featuredType, $modelType, $modelIds, $activeOnly = false )
    {
        $currentModelIds = $this->getFeaturedModelIds( $featuredType, $modelType, $activeOnly );

        $sortOrder = 1;
        foreach ( $modelIds as $modelId ) {

            // don't save something bad accidentally - should never hit this though
            if ( ! $modelId ) {
                continue;
            }

            $this->addFeaturedModel( $featuredType, $modelId, $modelType, $sortOrder );
            $sortOrder++;
        }

        $unusedModelIds = array_diff( $currentModelIds, $modelIds );
        foreach ( $unusedModelIds as $modelId ) {
            $this->deleteFeaturedModel( $featuredType, $modelId, $modelType );
        }

    }

    /**
     * Get a list of featured challenge ids
     *
     * @param string $featuredType
     * @return integer[]
     */
    public function getFeaturedChallengeIds( $featuredType, $activeOnly = true )
    {
        return $this->getFeaturedModelIds( $featuredType, BeMaverick_Site::MODEL_TYPE_CHALLENGE, $activeOnly );
    }

    /**
     * Get a list of featured challenges
     *
     * @param string $featuredType
     * @return BeMaverick_Challenge[]
     */
    public function getFeaturedChallenges( $featuredType, $activeOnly = true )
    {
        $challengeIds = $this->getFeaturedChallengeIds( $featuredType, $activeOnly );

        $challenges = array();
        foreach ( $challengeIds as $challengeId ) {
            $challenges[] = $this->getChallenge( $challengeId );
        }

        return $challenges;
    }

    /**
     * Get a list of featured response ids
     *
     * @param string $featuredType
     * @return integer[]
     */
    public function getFeaturedResponseIds( $featuredType )
    {
        return $this->getFeaturedModelIds( $featuredType, BeMaverick_Site::MODEL_TYPE_RESPONSE );
    }

    /**
     * Get a list of featured responses
     *
     * @param string $featuredType
     * @return BeMaverick_Response[]
     */
    public function getFeaturedResponses( $featuredType )
    {
        $responseIds = $this->getFeaturedResponseIds( $featuredType );

        $responses = array();
        foreach ( $responseIds as $responseId ) {
            $responses[] = $this->getResponse( $responseId );
        }

        return $responses;
    }

    /**
     * Get a list of featured user ids
     *
     * @param string $featuredType
     * @return integer[]
     */
    public function getFeaturedUserIds( $featuredType )
    {
        return $this->getFeaturedModelIds( $featuredType, BeMaverick_Site::MODEL_TYPE_USER );
    }

    /**
     * Get a list of featured users
     *
     * @param string $featuredType
     * @return BeMaverick_User[]
     */
    public function getFeaturedUsers( $featuredType )
    {
        $userIds = $this->getFeaturedUserIds( $featuredType );

        $users = array();
        foreach ( $userIds as $userId ) {
            $users[] = $this->getUser( $userId );
        }

        return $users;
    }

    /**
     * Get the automated featured maverick
     *
     * Note: This function will first check for featured maverick from the admin tool, and
     * if none found, then go to the automated one
     *
     * @return BeMaverick_User_Kid
     */
    public function getFeaturedMaverick()
    {
        // first check to see if it was overwritten via admin tool
        $featuredUsers = $this->getFeaturedUsers( 'maverick-user' );

        if ( $featuredUsers ) {

            // for now there can only be 1 featured maverick, but down the road I can see multiple
            // which is why the admin tool can return more than 1.  lets just grab the first one listed
            return $featuredUsers[0];
        }

        // since nothing was overwritten in the admin tools,
        return $this->getAutomatedFeaturedUser();
    }

    /**
     * Get the automated featured user
     *
     * @return BeMaverick_User
     */
    public function getAutomatedFeaturedUser()
    {
        $filterBy = array(
            'userType' => BeMaverick_User::USER_TYPE_KID,
        );

        $sortBy = array(
            'sort' => 'numResponses',
            'sortOrder' => 'desc',
            'responseStartCreatedTimestamp' => Sly_Date::subDays( date( 'Y-m-d' ), 10, 'Y-m-d H:i:s' ),
        );

        $users = $this->getUsers( $filterBy, $sortBy, 1, null );

        if ( $users ) {
            return $users[0];
        }

        return null;
    }

    /**
     * Get a post or page from wordpress
     *
     * @param integer $contentId
     * @param string $contentType
     * @return hash
     */
    public function getPost( $contentId, $contentType = 'posts' )
    {
        $cache = Zend_Registry::get( 'cache' );

        return BeMaverick_WordPress::getPost( $this, $contentId, $cache, $contentType );
    }

    /**
     * Get a list of posts from wordpress
     *
     * @param integer $numPosts
     * @param integer $categories
     * @return hash
     */
    public function getPosts( $numPosts, $categories )
    {
        $cache = Zend_Registry::get( 'cache' );

        return BeMaverick_WordPress::getPosts( $this, $numPosts, $categories, $cache );
    }

    /**
     * Get media details from wordpress
     *
     * @param integer $mediaId
     * @return hash
     */
    public function getMedia( $mediaId )
    {
        $cache = Zend_Registry::get( 'cache' );

        return BeMaverick_WordPress::getMedia( $this, $mediaId, $cache );
    }

    /**
     * Get author from wordpress.... not sure what else this should be called since it can be more generic
     *
     * @param integer $authorId
     * @return hash
     */
    public function getAuthor( $authorId )
    {
        $cache = Zend_Registry::get( 'cache' );

        return BeMaverick_WordPress::getUser( $this, $authorId, $cache );
    }

    /**
     * Get mentioned user ids
     *
     * @param string $modelType
     * @param integer $modelId
     * @return integer[]
     */
    public function getMentionedUserIds( $modelType, $modelId )
    {
        return BeMaverick_Mention::getMentionedUserIds( $modelType, $modelId );
    }

    /**
     * Set the mentions
     *
     * @param string $modelType
     * @param integer $modelId
     * @param integer[] $mentions
     * @return void
     */
    public function setMentions( $modelType, $modelId, $mentions )
    {
        BeMaverick_Mention::setMentions( $modelType, $modelId, $mentions );
    }

    /**
     * Convert usernames to user ids
     *
     * @param string[] $usernames
     * @return integer[]
     */
    public function usernamesToIds( $usernames )
    {
        $userIds = array();

        foreach ( $usernames as $username ) {
            if ($username) {
                $user = $this->getUserByUsername($username);
                $userIds[] = $user->getId();
            }
        }

        return $userIds;
    }

    /**
     * Get the my feed
     *
     * @param integer $userId
     * @param integer $count
     * @param integer $offset
     * @return array
     */
    public function getMyFeed( $userId, $count = 10, $offset = 0 )
    {
        return BeMaverick_Response::getMyFeed( $userId, $count, $offset );
    }

    /**
     * Get the my feed
     *
     * @param integer $userId
     * @param integer $count
     * @param integer $offset
     * @return integer
     */
    public function getMyFeedCount( $userId)
    {
        return BeMaverick_Response::getMyFeedCount( $userId );
    }
}

?>
