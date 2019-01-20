<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Response.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/ResponseBadge.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/ResponseTags.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Sns.php' );

class BeMaverick_Response
{

    const RESPONSE_TYPE_VIDEO     = 'video';
    const RESPONSE_TYPE_IMAGE     = 'image';

    const POST_TYPE_RESPONSE     = 'response';
    const POST_TYPE_CONTENT      = 'content';

    const RESPONSE_STATUS_DRAFT     = 'draft';
    const RESPONSE_STATUS_ACTIVE    = 'active';
    const RESPONSE_STATUS_INACTIVE  = 'inactive';
    const RESPONSE_STATUS_REVOKED   = 'revoked';
    const RESPONSE_STATUS_DELETED   = 'deleted';

    /**
     * This instance
     *
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = array();

    /**
     * This site
     *
     * @access protected
     */
    protected $_site;

    /**
     * Response id
     *
     * @var integer
     * @access protected
     */
    protected $_responseId = null;

    /**
     * Data Access
     *
     * @var BeMaverick_Da_Response
     * @access protected
     */
    protected $_daResponse;

    /**
     * Class constructor
     *
     * @param BeMaverick_Site $site
     * @param integer $responseId
     * @return void
     */
    public function __construct( $site, $responseId )
    {
        $this->_site = $site;
        $this->_responseId = $responseId;
        $this->_daResponse = BeMaverick_Da_Response::getInstance();
    }

    /**
     * Retrieves the response instance.
     *
     * @param BeMaverick_Site $site
     * @param integer $responseId
     * @return BeMaverick_Response
     */
    public static function getInstance( $site, $responseId )
    {
        if ( ! $responseId ) {
            return null;
        }

        if ( ! isset( self::$_instance[$responseId] ) ) {

            $daResponse = BeMaverick_Da_Response::getInstance();

            // make sure response exists
            if ( ! $daResponse->isKeysExist( array( $responseId ) ) ) {
                self::$_instance[$responseId] = null;
            } else {
                self::$_instance[$responseId] = new self( $site, $responseId );
            }
        }

        return self::$_instance[$responseId];

    }

    /**
     * Create a response
     *
     * @param BeMaverick_Site $site
     * @param string $responseType
     * @param BeMaverick_User $user
     * @param BeMaverick_Challenge $challenge
     * @param BeMaverick_Video $video
     * @param BeMaverick_Image $image
     * @param boolean $skipComments
     * @param string $postType
     * @param string $description
     * @param string[] $tagNames
     * @param string $responseStatus
     * @return BeMaverick_Response
     */
    public static function createResponse(
        $site,
        $responseType,
        $user,
        $challenge = null,
        $video,
        $image,
        $skipComments = false,
        $postType = null,
        $description = null,
        $tagNames = array(),
        $responseStatus = self::RESPONSE_STATUS_ACTIVE
    ) {

        $daResponse = BeMaverick_Da_Response::getInstance();

        $videoId = (!is_null( $video )) ? $video->getId() : null;
        $imageId = (!is_null( $image )) ? $image->getId() : null;
        $challengeId = $challenge ? $challenge->getId() : null;
        $postType = (!is_null( $postType )) ? $postType : BeMaverick_Response::POST_TYPE_RESPONSE;

        $responseId = $daResponse->createResponse(
            $responseType,
            $user->getId(),
            $challengeId,
            $videoId,
            $imageId,
            $postType,
            $responseStatus
        );

        $response = new self( $site, $responseId );

        // Add tags & description
        $response->setTags( $tagNames );
        $response->setDescription( $description );

        // Mark catalyst posts as public
        if ($user && $user->isMentor()) {
            $response->setPublic(true);
        }

        // we might have already tried to get this response for some reason, so update
        // the self instance here and return it
        self::$_instance[$responseId] = $response;

        return $response;
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
    public static function getResponseIds( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $daResponse = BeMaverick_Da_Response::getInstance();

        return $daResponse->getResponseIds( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get a response
     *
     * @param BeMaverick_Site $site
     * @param hash $filterBy
     * @return BeMaverick_Response
     */
    public static function getResponse( $site, $filterBy = null )
    {
        $daResponse = BeMaverick_Da_Response::getInstance();

        $responseId = $daResponse->getResponseId( $filterBy );

        $response = self::getInstance( $site, $responseId );

        return $response;
    }

    /**
     * Get a list of responses
     *
     * @param BeMaverick_Site $site
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Response[]
     */
    public static function getResponses( $site, $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $daResponse = BeMaverick_Da_Response::getInstance();

        $responseIds = $daResponse->getResponseIds( $filterBy, $sortBy, $count, $offset );

        $responses = array();
        foreach ( $responseIds as $responseId ) {
            $responses[] = self::getInstance( $site, $responseId );
        }

        return $responses;
    }

    /**
     * Get a count of responses
     *
     * @param hash $filterBy
     * @return integer
     */
    public static function getResponseCount( $filterBy = null )
    {
        $daResponse = BeMaverick_Da_Response::getInstance();

        return $daResponse->getResponseCount( $filterBy );
    }

    /**
     * Get a list of response ids from engaged users
     *
     * @param string $date
     * @return integer[]
     */
    public static function getEngagedUsersResponseIds( $date )
    {
        $daResponse = BeMaverick_Da_Response::getInstance();

        return $daResponse->getEngagedUsersResponseIds( $date );
    }

    /**
     * Get a list of unique users that have a response
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_Challenge $challenge
     * @param integer $count
     * @return BeMaverick_User[]
     */
    public static function getUniqueUsersWithResponseToChallenge( $site, $challenge, $count )
    {
        $daResponse = BeMaverick_Da_Response::getInstance();

        $userIds = $daResponse->getUniqueUserIds( $challenge->getId(), $count );

        $users = array();
        foreach ( $userIds as $userId ) {
            $users[] = $site->getUser( $userId );
        }

        return $users;
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
        return $this->_responseId;
    }

    /**
     * Get the channel id - used for twilio comments
     *
     * @return string
     */
    public function getChannelId()
    {
        return BeMaverick_Site::MODEL_TYPE_RESPONSE . '_' . $this->getId();
    }

    /**
     * Get the response type
     *
     * @return string
     */
    public function getResponseType()
    {
        return $this->_daResponse->getResponseType( $this->getId() );
    }

    /**
     * Set the response type
     *
     * @param string $responseType
     * @return void
     */
    public function setResponseType( $responseType )
    {
        $this->_daResponse->setResponseType( $this->getId(), $responseType );
    }

    /**
     * Get the post type
     *
     * @return string
     */
    public function getPostType()
    {
        $responseId =  $this->getId();
        $postType = $this->_daResponse->getPostType( $responseId );
        return $postType;
    }

    /**
     * Set the post type
     *
     * @param string $postType
     * @return void
     */
    public function setPostType( $postType )
    {
        $this->_daResponse->setPostType( $this->getId(), $postType );
    }

    /**
     * Get the user
     *
     * @return BeMaverick_User
     */
    public function getUser()
    {
        $userId = $this->_daResponse->getUserId( $this->getId() );

        return $this->_site->getUser( $userId );
    }

    /**
     * Get the user id
     *
     * @return integer
     */
    public function getUserId()
    {
        $userId = $this->_daResponse->getUserId( $this->getId() );

        return $userId;
    }
    /**
     * Get the challenge id
     *
     * @return integer
     */
    public function getChallengeId()
    {
        $challengeId = $this->_daResponse->getChallengeId( $this->getId() );

        return $challengeId;
    }

    /**
     * Set the user
     *
     * @param BeMaverick_User $user
     * @return void
     */
    public function setUser( $user )
    {
        $this->_daResponse->setUserId( $this->getId(), $user->getId() );
    }

    /**
     * Get the challenge
     *
     * @return BeMaverick_Challenge
     */
    public function getChallenge()
    {
        $challengeId = $this->_daResponse->getChallengeId( $this->getId() );

        return $this->_site->getChallenge( $challengeId );
    }

    /**
     * Set the challenge
     *
     * @param BeMaverick_Challenge $challenge
     * @return void
     */
    public function setChallenge( $challenge )
    {
        $this->_daResponse->setChallengeId( $this->getId(), !is_null( $challenge ) ? $challenge->getId() : null );
    }

    /**
     * Get the video
     *
     * @return BeMaverick_Video
     */
    public function getVideo()
    {
        $videoId = $this->_daResponse->getVideoId( $this->getId() );

        return $this->_site->getVideo( $videoId );
    }

    /**
     * Set the video
     *
     * @param BeMaverick_Video $video
     * @return void
     */
    public function setVideo( $video )
    {
        $this->_daResponse->setVideoId( $this->getId(), $video->getId() );
    }

    /**
     * Get the image
     *
     * @return BeMaverick_Image
     */
    public function getImage()
    {
        $imageId = $this->_daResponse->getImageId( $this->getId() );

        return $this->_site->getImage( $imageId );
    }

    /**
     * Set the image
     *
     * @param BeMaverick_Image $image
     * @return void
     */
    public function setImage( $image )
    {
        $imageId = $image ? $image->getId() : null;

        $this->_daResponse->setImageId( $this->getId(), $imageId );
    }

    /**
     * Get the image url
     *
     * @param integer $width
     * @param integer $height
     * @return string
     */
    public function getImageUrl( $width = null, $height = null )
    {
        $image = $this->getImage();

        if ( $image ) {
            return $image->getUrl( $width, $height );
        }

        return null;
    }

    /**
     * Get the cover image
     *
     * @return BeMaverick_Image
     */
    public function getCoverImage()
    {
        $imageId = $this->_daResponse->getCoverImageId( $this->getId() );

        return $this->_site->getImage( $imageId );
    }

    /**
     * Set the cover image
     *
     * @param BeMaverick_Image $image
     * @return void
     */
    public function setCoverImage( $image )
    {
        $imageId = $image ? $image->getId() : null;

        $this->_daResponse->setCoverImageId( $this->getId(), $imageId );
    }

    /**
     * Get the cover image url
     *
     * @param integer $width
     * @param integer $height
     * @return string
     */
    public function getCoverImageUrl( $width = null, $height = null )
    {
        $coverImage = $this->getCoverImage();

        if ( $coverImage ) {
            return $coverImage->getUrl( $width, $height );
        }

        return null;
    }

    /**
     * Get the title
     *
     * @return string
     */
    public function getTitle()
    {
        return $this->_daResponse->getTitle( $this->getId() );
    }

    /**
     * Set the title
     *
     * @param string $title
     * @return void
     */
    public function setTitle( $title )
    {
        $this->_daResponse->setTitle( $this->getId(), $title );
    }

    /**
     * Get the description
     *
     * @return string
     */
    public function getDescription()
    {
        return $this->_daResponse->getDescription( $this->getId() );
    }

    /**
     * Set the description
     *
     * @param string $description
     * @return void
     */
    public function setDescription( $description )
    {
        $this->_daResponse->setDescription( $this->getId(), $description );
    }

    /**
     * Get the hashtags
     *
     * @return array
     */
    public function getHashtags()
    {
        $arrayString = $this->_daResponse->getHashtags( $this->getId() );

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

        $this->_daResponse->setHashtags( $this->getId(), $hashtags );
    }

    /**
     * Get the status
     *
     * @return string
     */
    public function getStatus()
    {
        return $this->_daResponse->getStatus( $this->getId() );
    }

    /**
     * Set the status
     *
     * @param string $status
     * @return void
     */
    public function setStatus( $status )
    {
        $this->_daResponse->setStatus( $this->getId(), $status );
    }

    /**
     * Get the moderation status
     *
     * @return string
     */
    public function getModerationStatus()
    {
        return $this->_daResponse->getModerationStatus( $this->getId() );
    }

    /**
     * Set the moderation status
     *
     * @param string $status
     * @return void
     */
    public function setModerationStatus( $status )
    {
        $this->_daResponse->setModerationStatus( $this->getId(), $status );
    }

    /**
     * Get the uuid
     *
     * @return string
     */
    public function getUUID()
    {
        return $this->_daResponse->getUUID( $this->getId() );
    }

    /**
     * Set the uuid
     *
     * @param string $uuid
     * @return void
     */
    public function setUUID( $uuid )
    {
        $this->_daResponse->setUUID( $this->getId(), $uuid );
    }

    /**
     * Get the created timestamp
     *
     * @return string
     */
    public function getCreatedTimestamp()
    {
        return $this->_daResponse->getCreatedTimestamp( $this->getId() );
    }

    /**
     * Set the created timestamp
     *
     * @param string $createdTimestamp
     * @return void
     */
    public function setCreatedTimestamp( $createdTimestamp )
    {
        $this->_daResponse->setCreatedTimestamp( $this->getId(), $createdTimestamp );
    }

    /**
     * Get the updated timestamp
     *
     * @return string
     */
    public function getUpdatedTimestamp()
    {
        return $this->_daResponse->getUpdatedTimestamp( $this->getId() );
    }

    /**
     * Set the updated timestamp
     *
     * @param string $updatedTimestamp
     * @return void
     */
    public function setUpdatedTimestamp( $updatedTimestamp )
    {
        $this->_daResponse->setUpdatedTimestamp( $this->getId(), $updatedTimestamp );
    }
    /**
     * Add a badge
     *
     * @param BeMaverick_Badge $badge
     * @param BeMaverick_User $user
     * @return void
     */
    public function addBadge( $badge, $user )
    {
        // Delete existing badges
        $badges = $this->_site->getBadges('any');
        foreach( $badges as $thisBadge ) {
            if($thisBadge->getId() != $badge->getId() ) {
                $this->deleteBadge( $thisBadge, $user );
            }
        }

        $daResponseBadge = BeMaverick_Da_ResponseBadge::getInstance();

        $daResponseBadge->addResponseBadge( $this->getId(), $badge->getId(), $user->getId() );


        // Publish response to SNS
        $this->publishChange( $this->_site, 'UPDATE' );
    }

    /**
     * Delete a badge
     *
     * @param BeMaverick_Badge $badge
     * @param BeMaverick_User $user
     * @return void
     */
    public function deleteBadge( $badge, $user )
    {
        $daResponseBadge = BeMaverick_Da_ResponseBadge::getInstance();

        $daResponseBadge->deleteResponseBadge( $this->getId(), $badge->getId(), $user->getId() );
    }

    /**
     * Check if the response is favorited
     *
     * @return boolean
     */
    public function isFavorited()
    {
        $value = $this->_daResponse->getFavorite( $this->getId() );
        return ( $value == 1 ) ? true : false;
    }

    /**
     * Set if the response is favorited
     *
     * @param boolean $isFavorited
     * @return void
     */
    public function setFavorited( $isFavorited )
    {
        $value = $isFavorited ? 1 : 0;
        $this->_daResponse->setFavorite( $this->getId(), $value );
    }

    /**
     * Check if the response is public
     *
     * @return boolean
     */
    public function isPublic()
    {
        $value = $this->_daResponse->getPublic( $this->getId() );
        return ( $value == 1 ) ? true : false;
    }

    /**
     * Set if the response is public
     *
     * @param boolean $isPublic
     * @return void
     */
    public function setPublic( $isPublic )
    {
        $value = $isPublic ? 1 : 0;
        $this->_daResponse->setPublic( $this->getId(), $value );
    }

    /**
     * Check if the response should be hidden from stream
     *
     * @return boolean
     */
    public function isHideFromStreams()
    {
        $value = $this->_daResponse->getHideFromStreams( $this->getId() );
        return ( $value == 1 ) ? true : false;
    }

    /**
     * Set if the response should be hidden from stream
     *
     * @param boolean $isHideFromStreams
     * @return void
     */
    public function setHideFromStreams( $isHideFromStreams )
    {
        $value = $isHideFromStreams ? 1 : 0;
        $this->_daResponse->setHideFromStreams( $this->getId(), $value );
    }

    /**
     * Get the share url if response is public
     *
     * @return string
     */
    public function getShareUrl()
    {
        if ( ! $this->isPublic() ) {
            return null;
        }

        $systemConfig = $this->_site->getSystemConfig();

        $websiteHttpHost = $systemConfig->getSetting( 'SYSTEM_WEBSITE_HTTP_HOST' );

        return $this->getUrl( 'response', array(), false, $websiteHttpHost );
    }

    /**
     * Get badge counts
     *
     * @return hash
     */
    public function getBadgeCounts()
    {
        $daResponseBadge = BeMaverick_Da_ResponseBadge::getInstance();

        return $daResponseBadge->getResponseBadgeCounts( $this->getId() );
    }

    /**
     * Get a list of badges that are allowed
     *
     * @return BeMaverick_Badge[]
     */
    public function getBadges()
    {
        // for now we will allow all site badges
        return $this->_site->getBadges();
    }

    /**
     * Get the tags for this response
     *
     * @return BeMaverick_Tag[]
     */
    public function getTags()
    {
        $daResponseTags = BeMaverick_Da_ResponseTags::getInstance();

        $tagIds = $daResponseTags->getResponseTagIds( $this->getId() );

        $tags = array();

        foreach ( $tagIds as $tagId ) {
            $tags[] = $this->_site->getTag( $tagId );
        }

        return $tags;
    }

    /**
     * Get the tag names
     *
     * @return string[]
     */
    public function getTagNames()
    {
        $tagNames = array();

        $tags = $this->getTags();
        foreach ( $tags as $tag ) {
            $tagNames[] = $tag->getName();
        }

        return $tagNames;
    }

    /**
     * Set the tags for this response
     *
     * @param string[] $tagNames
     * @return void
     */
    public function setTags( $tagNames )
    {
        $daResponseTags = BeMaverick_Da_ResponseTags::getInstance();

        $daResponseTags->deleteResponse( $this->getId() );

        if ( is_array( $tagNames ) ) {

            $tagNames = array_unique( $tagNames );

            foreach ( $tagNames as $tagName ) {
                $tagName = trim( $tagName );

                $tag = $this->_site->getTagByName( $tagName );

                if ( ! $tag && $tagName ) {
                    $tag = $this->_site->createTag( BeMaverick_Site::TAG_TYPE_USER, $tagName );
                }

                $daResponseTags->addResponseTag( $this->getId(), $tag->getId() );
            }
        }
    }

    /**
     * Get a list of responses badged by a user
     *
     * @param BeMaverick_Site $site
     * @param hash $userId
     * @param hash $badgeId
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Response[]
     */
    public static function getBadgedResponses( $site, $userId, $badgeId, $count = null, $offset = 0 )
    {
        $daResponseBadge = BeMaverick_Da_ResponseBadge::getInstance();

        $responseIds = $daResponseBadge->getResponseIds( $userId, $badgeId, $count, $offset );

        $responses = array();
        foreach ( $responseIds as $responseId ) {
            $responses[] = self::getInstance( $site, $responseId );
        }

        return $responses;
    }

    /**
     * Get the list of users that have badged this response
     *
     * @param BeMaverick_Badge|null $badge
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function getBadgeUsers( $badge, $count, $offset )
    {
        $daResponseBadge = BeMaverick_Da_ResponseBadge::getInstance();

        $badgeId = $badge ? $badge->getId() : null;

        $userIds = $daResponseBadge->getUserIds( $this->getId(), $badgeId, $count, $offset );

        $users = array();
        foreach ( $userIds as $userId ) {
            $user = $this->_site->getUser( $userId );
            if(!is_null($user)) {
                $users[] = $user;
            }
        }

        return $users;
    }

    /**
     * Get the count of users that have badged this response
     *
     * @param BeMaverick_Badge|null $badge
     * @return void
     */
    public function getBadgeUserCount( $badge )
    {
        $daResponseBadge = BeMaverick_Da_ResponseBadge::getInstance();

        $badgeId = $badge ? $badge->getId() : null;

        return $daResponseBadge->getUserCount( $this->getId(), $badgeId );
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
    public function getUrl( $page = 'response',
        $params = array(),
        $relativeUrl = true,
        $overwriteSite = null,
        $sortParams = true,
        $isSecure = false
    ) {

        $slyUrl = Sly_Url::getInstance();

        $params['responseId'] = $this->getId();

        return $slyUrl->getUrl( $page, $params, $relativeUrl, $overwriteSite, $sortParams, $isSecure );
    }

    /**
     * Get the comments for this response
     *
     * @return Twilio\Rest\Api\V2010\Account\Message[]
     */
    public function getComments($query = array(), $allowCache = true)
    {
        return $this->_site->getComments( 'response', $this->getId(), $query, $allowCache );
    }

    /**
     * Save the response
     *
     * @return void
     */
    public function save()
    {
        $this->_daResponse->save();

        $daResponseBadge = BeMaverick_Da_ResponseBadge::getInstance();
        $daResponseBadge->save();

        $daResponseTags = BeMaverick_Da_ResponseTags::getInstance();
        $daResponseTags->save();
    }

    /**
     * Delete the response
     *
     * @return void
     */
    public function delete()
    {
        $daResponseBadge = BeMaverick_Da_ResponseBadge::getInstance();
        $daResponseBadge->deleteResponse( $this->getId() );

        $daResponseTags = BeMaverick_Da_ResponseTags::getInstance();
        $daResponseTags->deleteResponse( $this->getId() );

        $this->setStatus( self::RESPONSE_STATUS_DELETED );
    }



    /**
     * Get an array of Open Graph field values
     *
     * @return array
     */
    public function getOpenGraph()
    {
        $systemConfig = $this->_site->getSystemConfig();
        $protocol = $systemConfig->getSetting( 'SYSTEM_HTTP_PROTOCOL' ) ?? 'https';
        $host = $systemConfig->getSetting( 'SYSTEM_HTTP_HOST' );
        $twitterHandle = $systemConfig->getSetting( 'TWITTER_HANDLE' );
        $facebookAppId = $systemConfig->getSetting( 'FACEBOOK_APP_ID' );
        $appStoreAppId = $systemConfig->getSetting( 'APPLE_APPSTORE_APP_ID' );
        $deepLinkProtocol = $systemConfig->getSetting( 'AWS_LAMBDA_DEEP_LINK_PROTOCOL' );

        if (!$this) {
            return array();
        }

        // Open Graph fields
        $openGraph = array();
        $openGraph['og:url'] = $protocol."://".$host.$this->getUrl();
        $openGraph['og:title'] = $this->getTitle();
        $openGraph['og:type'] = 'website';
        $openGraph['og:description'] = $this->getDescription();


        // Media specific fields
        $video = $this->getVideo() ?? null;
        $image = $this->getImage() ?? null;
        if ( ! is_null( $video ) ) {
            $openGraph['og:type'] = 'video.other';
            $openGraph['og:video:url'] = $video->getVideoUrl() ?? null;
            $openGraph['og:video:secure_url'] = $openGraph['og:video:url'] ?? null;
            $openGraph['og:video:type'] = "video/mp4";
            $openGraph['og:video:width'] = $video->getWidth() ?? 1080;
            $openGraph['og:video:height'] = $video->getHeight() ?? 1440;
            $image = $this->getCoverImage();
            if ( is_null( $image ) || ! $image ) {
                $openGraph['og:image:url'] = $video->getThumbnailUrl() ?? null;
                $openGraph['og:image:width'] = $openGraph['og:video:width'] ?? 1080;
                $openGraph['og:image:height'] = $openGraph['og:video:height'] ?? 1440;
            }
        }
        if ( ! is_null( $image ) && $image ) {
            $openGraph['og:image:url'] = $image->getUrl() ?? null;
            $openGraph['og:image:width'] = $image->getWidth() ?? 1080;
            $openGraph['og:image:height'] = $image->getHeight() ?? 1440;
        }

        // Twitter fields
        // Twitter fields
        $openGraph['twitter:card'] = 'app';
        if ( $twitterHandle ) {
            $openGraph['twitter:site'] = '@'.$twitterHandle;
        }
        $openGraph['twitter:title'] = $openGraph['og:title'];
        $openGraph['twitter:description'] = $openGraph['og:description'];
        $openGraph['twitter:image'] = $openGraph['og:image:url'] ?? null;

        $openGraph['twitter:app:country'] = 'US';
        $openGraph['twitter:app:name:iphone'] = 'Maverick';
        $openGraph['twitter:app:id:iphone'] = $appStoreAppId;
        $openGraph['twitter:app:url:iphone'] = "$deepLinkProtocol://maverick/response/" . $this->getId();
        $openGraph['twitter:app:name:ipad'] = 'Maverick';
        $openGraph['twitter:app:id:ipad'] = $appStoreAppId;
        $openGraph['twitter:app:url:ipad'] = "$deepLinkProtocol://maverick/response/" . $this->getId();

        // Facebook fields
        if ( $facebookAppId ) {
            $openGraph['fb:app_id'] = $facebookAppId;
        }

        // return values
        return $openGraph;
    }

    /**
     * Get the transcription text
     *
     * @return string
     */
    public function getTranscriptionText()
    {
        return $this->_daResponse->getTranscriptionText( $this->getId() );
    }

    /**
     * Set the transcription text
     *
     * @param string $description
     * @return void
     */
    public function setTranscriptionText( $transcription )
    {
        $this->_daResponse->setTranscriptionText( $this->getId(), $transcription );
    }

    /**
     * Get my feed data
     *
     * @param integer $userId
     * @param integer $count
     * @param integer $offset
     * @return array
     */
    public function getMyFeed( $userId, $count = 10, $offset = 0 )
    {
        $daResponse = BeMaverick_Da_Response::getInstance();
        $feed = $daResponse->getMyFeed( $userId, $count, $offset );
        return self::convertKeysToCamelCase($feed);
    }

    /**
     * Get my feed data
     *
     * @param integer $userId
     * @return integer
     */
    public function getMyFeedCount( $userId )
    {
        $daResponse = BeMaverick_Da_Response::getInstance();
        return $daResponse->getMyFeedCount( $userId );
    }

    private function convertKeysToCamelCase($apiResponseArray) {
        $keys = array_map(function ($i) use (&$apiResponseArray) {
            if (is_array($apiResponseArray[$i]))
                $apiResponseArray[$i] = self::convertKeysToCamelCase($apiResponseArray[$i]);
    
            $parts = explode('_', $i);
            return array_shift($parts) . implode('', array_map('ucfirst', $parts));
        }, array_keys($apiResponseArray));
    
        return array_combine($keys, $apiResponseArray);
    }


    /**
     * Get the details
     */
    public function getDetails() {
        return self::getResponseDetails($this->_site, $this->getId(), false);
    }
    /**
     * Create response data object
     *
     * @param BeMaverick_Site $site
     * @param integer $responseId
     *
     * @return array
     */
    public static function getResponseDetails( $site, $responseId, $allowCache = true )
    {
        // get response
        $response = self::getInstance( $site, $responseId );
        if(!$response) return;

        // get vars
        $user = $response->getUser();
        $challenge = $response->getChallenge();
        $video = $response->getVideo();
        $image = $response->getImage();
        $coverImage = $response->getCoverImage();

        // create response data
        $data = array(
            'responseId' => $responseId.'',
            'responseType' => $response->getResponseType(),
            'status' => $response->getStatus(),
            'description' => $response->getDescription(),
            'user' => $user->getUserDetails(),
            'challenge' => null,
            'favorite' => $response->isFavorited(),
            'isPublic' => $response->isPublic(),
            'hashtags' => $response->getHashtags(),
            'hideFromStreams' => $response->isHideFromStreams(),
        );

        // add comments preview
        $allowPeekCache = $allowCache;
        $data['peekComments'] = $response->getComments(
            array(
                'sort' => '-created', 
                'limit' => 3
            ),
            $allowPeekCache
        );

        // add badge data
        $data['badges'] = array();
        $badges = $response->getBadges();
        $badgeCounts = $response->getBadgeCounts();
        foreach ( $badges as $badge ) {
            $badgeId = $badge->getId();
            $data['badges'][$badgeId] = array(
                'badgeId' => ''.$badgeId,
                'numReceived' => (int) @$badgeCounts[$badgeId]['count'] || 0,
            );
        }

        // add challenge to data object
        if ( $challenge ) {
            $data['challenge'] = BeMaverick_Challenge::getChallengeDetails( $site, $challenge->getId() );
        }

        // add media to data object
        if ( $video ) {
            $data['video'] = BeMaverick_Video::getVideoDetails( $site, $video->getId() );
        }

        // image
        if ( $image ) {
            $data['image'] = BeMaverick_Image::getImageDetails( $site, $image->getId() );
        } elseif ( $coverImage ) {
            $data['image'] = BeMaverick_Image::getImageDetails( $site, $coverImage->getId() );
        }

        // coverImage
        if ( $coverImage ) {
            $data['coverImage'] = BeMaverick_Image::getImageDetails( $site, $coverImage->getId() );
        }

        return $data;
    }

    /**
     * Publish the change to sns publish
     *
     * @param BeMaverick_Site $site
     * @param string $action
     *
     * @return void
     */
    public function publishChange( $site, $action )
    {
        $allowResponse = false;
        $data = $this->getResponseDetails( $site, $this->getId(), $allowResponse );

        // call sns publish
        return BeMaverick_Sns::publish( $site, 'response', $this->getId(), $action, $data );
    }

    /**
     * When creating a response, publish to sns event
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

        if ( $eventType == 'CREATE_RESPONSE' ) {
            $contentType = 'response';
            $contentId = $this->getId();

            $data = array(
                'response' => $this->getDetails()
            );
        } elseif ( $eventType == 'CREATE_IMAGE_RESPONSE') {
            if ( $this->getResponseType() == 'image' ) {
                $contentType = 'response';
                $contentId = $this->getId();

                $data = array(
                    'response' => $this->getDetails()
                );
            }
        } elseif ( $eventType == 'CREATE_VIDEO_RESPONSE') {
            if ( $this->getResponseType() == 'video' ) {
                $contentType = 'response';
                $contentId = $this->getId();

                $data = array(
                    'response' => $this->getDetails()
                );
            }
        } elseif ( $eventType == 'RECEIVE_RESPONSE' ) {
            $challenge = $this->getChallenge();

            if ( $challenge ) {
                $contentType = 'challenge';
                $contentId = $challenge->getId();

                $data = array(
                    'challenge' => $challenge->getDetails(),
                    'response' => $this->getDetails()
                );
            }
        } elseif ( $eventType == 'BADGE_RESPONSE') {
            $contentType = 'response';
            $contentId = $this->getId();

            $data = array(
                'response' => $this->getDetails()
            );
        }

        if ( $data ) {
            BeMaverick_Sns::publishEvent( $site, $eventType, $contentType, $contentId, $userId, $data );
        }
    }

}

?>
