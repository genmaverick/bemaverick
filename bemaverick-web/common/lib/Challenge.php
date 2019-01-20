<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Challenge.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/ChallengeTags.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Mention.php' );

class BeMaverick_Challenge
{

    const CHALLENGE_TYPE_VIDEO     = 'video';
    const CHALLENGE_TYPE_IMAGE     = 'image';

    const CHALLENGE_STATUS_PUBLISHED = 'published';
    const CHALLENGE_STATUS_DRAFT     = 'draft';
    const CHALLENGE_STATUS_HIDDEN    = 'hidden';
    const CHALLENGE_STATUS_DELETED   = 'deleted';

    /**
     * This instance
     *
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = array();

    /**
     * Site
     *
     * @access protected
     */
    protected $_site;

    /**
     * Challenge id
     *
     * @var integer
     * @access protected
     */
    protected $_challengeId = null;

    /**
     * Data access
     *
     * @var BeMaverick_Da_Challenge
     * @access protected
     */
    protected $_daChallenge;

    /**
     * Class constructor
     *
     * @param BeMaverick_Site $site
     * @param integer $challengeId
     * @return void
     */
    public function __construct( $site, $challengeId )
    {
        $this->_site = $site;
        $this->_challengeId = $challengeId;
        $this->_daChallenge = BeMaverick_Da_Challenge::getInstance();
    }

    /**
     * Retrieves the challenge instance.
     *
     * @param BeMaverick_Site $site
     * @param integer $challengeId
     * @return BeMaverick_Challenge
     */
    public static function getInstance( $site, $challengeId )
    {
        if ( ! $challengeId ) {
            return null;
        }

        if ( ! isset( self::$_instance[$challengeId] ) ) {

            $daChallenge = BeMaverick_Da_Challenge::getInstance();

            // make sure challenge exists
            if ( ! $daChallenge->isKeysExist( array( $challengeId ) ) ) {
                self::$_instance[$challengeId] = null;
            } else {
                self::$_instance[$challengeId] = new self( $site, $challengeId );
            }
        }

        return self::$_instance[$challengeId];

    }

    /**
     * Create a challenge
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @param string $title
     * @param string $challengeDescription
     * @param string $challengeType
     * @param BeMaverick_Video $video
     * @param BeMaverick_Image $image
     * @return BeMaverick_Challenge
     */
    public static function createChallenge( $site, $user, $title, $challengeDescription, $challengeType = null, $video = null, $image = null )
    {
        $daChallenge = BeMaverick_Da_Challenge::getInstance();

        $challengeType = $challengeType ?? self::CHALLENGE_TYPE_VIDEO;
        $videoId = $video ? $video->getId() : null;
        $imageId = $image ? $image->getId() : null;

        $challengeId = $daChallenge->createChallenge( $user->getId(), $title, $challengeDescription, $challengeType, $videoId, $imageId );

        $challenge = new self( $site, $challengeId );

        // we might have already tried to get this challenge for some reason, so update
        // the self instance here and return it
        self::$_instance[$challengeId] = $challenge;

        return $challenge;
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
    public static function getChallengeIds( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $daChallenge = BeMaverick_Da_Challenge::getInstance();

        return $daChallenge->getChallengeIds( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get a list of challenges
     *
     * @param BeMaverick_Site $site
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Challenge[]
     */
    public static function getChallenges( $site, $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $daChallenge = BeMaverick_Da_Challenge::getInstance();

        $challengeIds = $daChallenge->getChallengeIds( $filterBy, $sortBy, $count, $offset );

        $challenges = array();
        foreach ( $challengeIds as $challengeId ) {
            $challenges[] = self::getInstance( $site, $challengeId );
        }

        return $challenges;
    }

    /**
     * Get a count of challenges
     *
     * @param hash $filterBy
     * @return integer
     */
    public static function getChallengeCount( $filterBy = null )
    {
        $daChallenge = BeMaverick_Da_Challenge::getInstance();

        return $daChallenge->getChallengeCount( $filterBy );
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
        return $this->_challengeId;
    }

    /**
     * Get the uuid
     *
     * @return string
     */
    public function getUUID()
    {
        return $this->_daChallenge->getUUID( $this->getId() );
    }

    /**
     * Set the uuid
     *
     * @param string $uuid
     * @return void
     */
    public function setUUID( $uuid )
    {
        $this->_daChallenge->setUUID( $this->getId(), $uuid );
    }

    /**
     * Get the channel id - used for twilio comments
     *
     * @return string
     */
    public function getChannelId()
    {
        return BeMaverick_Site::MODEL_TYPE_CHALLENGE . '_' . $this->getId();
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
     * Get the mentor
     *
     * @return BeMaverick_User_Mentor
     */
    public function getMentor()
    {
        $mentorId = $this->_daChallenge->getMentorId( $this->getId() );

        return $this->_site->getMentor( $mentorId );
    }

    /**
     * Set the mentor
     *
     * @param BeMaverick_User_Mentor $mentor
     * @return void
     */
    public function setMentor( $mentor )
    {
        $this->_daChallenge->setMentorId( $this->getId(), $mentor->getId() );
    }

    /**
     * Get the user
     *
     * @return BeMaverick_User
     */
    public function getUser()
    {
        $userId = $this->_daChallenge->getUserId( $this->getId() );

        return $this->_site->getUser( $userId );
    }

    /**
     * Set the user
     *
     * @param BeMaverick_User $user
     * @return void
     */
    public function setUser( $user )
    {
        $this->_daChallenge->setUserId( $this->getId(), $user->getId() );
    }


    /**
     * Get the user id
     *
     * @return integer
     */
    public function getUserId()
    {
        $userId = $this->_daChallenge->getUserId( $this->getId() );

        return $userId;
    }

    /**
     * Set the user id
     *
     * @param integer $userId
     * @return void
     */
    public function setUserId( $userId )
    {
        $this->_daChallenge->setUserId( $this->getId(), $userId );
    }

    /**
     * Get the video
     *
     * @return BeMaverick_Video
     */
    public function getVideo()
    {
        $videoId = $this->_daChallenge->getVideoId( $this->getId() );

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
        $videoId = $video ? $video->getId() : null;

        $this->_daChallenge->setVideoId( $this->getId(), $videoId );
    }

    /**
     * Get the image
     *
     * @return BeMaverick_Image
     */
    public function getImage()
    {
        $imageId = $this->_daChallenge->getImageId( $this->getId() );
        $image = $this->_site->getImage( $imageId );

        return $image;
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

        $this->_daChallenge->setImageId( $this->getId(), $imageId );
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
            $imageUrl = $image->getUrl( $width, $height );
            return $imageUrl;
        }

        $video = $this->getVideo();

        if ( ! $video ) {
            return '';
        }

        return $video->getThumbnailUrl();
    }


    /**
     * Get the main image
     *
     * @return BeMaverick_Image
     */
    public function getMainImage()
    {
        $imageId = $this->_daChallenge->getMainImageId( $this->getId() );

        return $this->_site->getImage( $imageId );
    }

    /**
     * Set the main image
     *
     * @param BeMaverick_Image $image
     * @return void
     */
    public function setMainImage( $image )
    {
        $imageId = $image ? $image->getId() : null;

        $this->_daChallenge->setMainImageId( $this->getId(), $imageId );
    }

    /**
     * Get the main image url
     *
     * @param integer $width
     * @param integer $height
     * @return string
     */
    public function getMainImageUrl( $width = null, $height = null )
    {
        $mainImage = $this->getMainImage();

        if ( $mainImage ) {
            return $mainImage->getUrl( $width, $height );
        }

        $video = $this->getVideo();

        if ( ! $video ) {
            return '';
        }

        return $video->getThumbnailUrl();
    }

    /**
     * Get the card image
     *
     * @return BeMaverick_Image
     */
    public function getCardImage()
    {
        $imageId = $this->_daChallenge->getCardImageId( $this->getId() );

        if( $imageId ) {
            return $this->_site->getImage( $imageId );
        }
    }

    /**
     * Set the card image
     *
     * @param BeMaverick_Image $image
     * @return void
     */
    public function setCardImage( $image )
    {
        $imageId = $image ? $image->getId() : null;

        $this->_daChallenge->setCardImageId( $this->getId(), $imageId );
    }

    /**
     * Get the card image url
     *
     * @param integer $width
     * @param integer $height
     * @return string
     */
    public function getCardImageUrl( $width = null, $height = null )
    {
        $cardImage = $this->getCardImage();

        if ( $cardImage ) {
            return $cardImage->getUrl( $width, $height );
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
        return $this->_daChallenge->getTitle( $this->getId() );
    }

    /**
     * Set the title
     *
     * @param string $title
     * @return void
     */
    public function setTitle( $title )
    {
        $this->_daChallenge->setTitle( $this->getId(), $title );
    }

    /**
     * Get the description
     *
     * @return string
     */
    public function getDescription()
    {
        return $this->_daChallenge->getDescription( $this->getId() );
    }

    /**
     * Set the description
     *
     * @param string $description
     * @return void
     */
    public function setDescription( $description )
    {
        $this->_daChallenge->setDescription( $this->getId(), $description );
    }

    /**
     * Get the hashtags
     *
     * @return array
     */
    public function getHashtags()
    {
        $arrayString = $this->_daChallenge->getHashtags( $this->getId() );

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

        $this->_daChallenge->setHashtags( $this->getId(), $hashtags );
    }

    /**
     * Get the image text
     *
     * @return string
     */
    public function getImageText()
    {
        return $this->_daChallenge->getImageText( $this->getId() );
    }

    /**
     * Set the link url attached to challenge
     *
     * @param string $linkUrl
     * @return void
     */
    public function setLinkUrl( $linkUrl )
    {
        $this->_daChallenge->setLinkUrl( $this->getId(), $linkUrl );
    }

    /**
     * Get the link url attached to challenge
     *
     * @return string
     */
    public function getLinkUrl()
    {
        return $this->_daChallenge->getLinkUrl( $this->getId() );
    }

    /**
     * Set the imageText
     *
     * @param string $imageText
     * @return void
     */
    public function setImageText( $imageText )
    {
        $this->_daChallenge->setImageText( $this->getId(), $imageText );
    }

    /**
     * Get the start time
     *
     * @return string
     */
    public function getStartTime()
    {
        return $this->_daChallenge->getStartTime( $this->getId() );
    }

    /**
     * Set the start time
     *
     * @param string $startTime
     * @return void
     */
    public function setStartTime( $startTime )
    {
        $this->_daChallenge->setStartTime( $this->getId(), $startTime );
    }

    /**
     * Get the end time
     *
     * @return string
     */
    public function getEndTime()
    {
        return $this->_daChallenge->getEndTime( $this->getId() );
    }

    /**
     * Set the end time
     *
     * @param string $endTime
     * @return void
     */
    public function setEndTime( $endTime )
    {
        $this->_daChallenge->setEndTime( $this->getId(), $endTime );
    }

    /**
     * Get the winner response
     *
     * @return BeMaverick_Response
     */
    public function getWinnerResponse()
    {
        $responseId = $this->_daChallenge->getWinnerResponseId( $this->getId() );

        return $this->_site->getResponse( $responseId );
    }

    /**
     * Set the winner response
     *
     * @param integer $responseId
     * @return void
     */
    public function setWinnerResponseId( $responseId )
    {
        $this->_daChallenge->setWinnerResponseId( $this->getId(), $responseId );
    }

    /**
     * Get the status
     *
     * @return string
     */
    public function getStatus()
    {
        return $this->_daChallenge->getStatus( $this->getId() );
    }

    /**
     * Set the status
     *
     * @param string $status
     * @return void
     */
    public function setStatus( $status )
    {
        $this->_daChallenge->setStatus( $this->getId(), $status );
    }

    /**
     * Check if the response should be hidden from stream
     *
     * @return boolean
     */
    public function isHideFromStreams()
    {
        $value = $this->_daChallenge->getHideFromStreams( $this->getId() );
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
        $this->_daChallenge->setHideFromStreams( $this->getId(), $value );
    }

    /**
     * Get the moderation status
     *
     * @return string
     */
    public function getModerationStatus()
    {
        return $this->_daChallenge->getModerationStatus( $this->getId() );
    }

    /**
     * Set the moderation status
     *
     * @param string $status
     * @return void
     */
    public function setModerationStatus( $status )
    {
        $this->_daChallenge->setModerationStatus( $this->getId(), $status );
    }

    /**
     * Get the challengeType
     *
     * @return string
     */
    public function getChallengeType()
    {
        $challengeType = $this->_daChallenge->getChallengeType( $this->getId() );
        return ( ! empty( $challengeType ) ) ? $challengeType : self::CHALLENGE_TYPE_VIDEO;
    }

    /**
     * Set the challengeType
     *
     * @param string $challengeType
     * @return void
     */
    public function setChallengeType( $challengeType )
    {
        $this->_daChallenge->setChallengeType( $this->getId(), $challengeType );
    }

    /**
     * Get the tags for this challenge
     *
     * @return BeMaverick_Tag[]
     */
    public function getTags()
    {
        $daChallengeTags = BeMaverick_Da_ChallengeTags::getInstance();

        $tagIds = $daChallengeTags->getChallengeTagIds( $this->getId() );

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
     * Set the tags for this challenge
     *
     * @param string[] $tagNames
     * @return void
     */
    public function setTagNames( $tagNames )
    {
        $daChallengeTags = BeMaverick_Da_ChallengeTags::getInstance();

        $daChallengeTags->deleteChallenge( $this->getId() );

        if ( is_array( $tagNames ) ) {

            $tagNames = array_unique( $tagNames );

            foreach ( $tagNames as $tagName ) {
                $tagName = trim( $tagName );

                $tag = $this->_site->getTagByName( $tagName );

                if ( ! $tag ) {
                    $tag = $this->_site->createTag( BeMaverick_Site::TAG_TYPE_PREDEFINED, $tagName );
                }

                $daChallengeTags->addChallengeTag( $this->getId(), $tag->getId() );
            }
        }
    }

    /**
     * Get a list of responses for this challenge
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Response[]
     */
    public function getResponses( $filterBy, $sortBy, $count, $offset )
    {
        $filterBy['challengeId'] = $this->getId();

        return $this->_site->getResponses( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get a the count of responses for this challenge
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getResponseCount( $filterBy = null )
    {
        $filterBy['challengeId'] = $this->getId();

        return $this->_site->getResponseCount( $filterBy );
    }

    /**
     * Get a list of unique users that have given a response for this challenge
     *
     * @param integer $count
     * @return BeMaverick_User[]
     */
    public function getUniqueUsersWithResponse( $count )
    {
        return $this->_site->getUniqueUsersWithResponseToChallenge( $this, $count );
    }

    /**
     * Add a new response for this challenge
     *
     * @param string $responseType
     * @param BeMaverick_User $user
     * @param BeMaverick_Video $video
     * @param BeMaverick_Image $image
     * @param string[] $tagNames
     * @param string $description
     * @param boolean $skipComments
     * @param string $postType
     * @return BeMaverick_Response
     */
    public function addResponse(
        $responseType,
        $user,
        $video = null,
        $image = null,
        $tagNames = array(),
        $description = null,
        $skipComments = null,
        $postType = null
    ) {
        $response = $this->_site->createResponse( $responseType, $user, $this, $video, $image, $skipComments, $postType );

        $response->setTags( $tagNames );
        $response->setDescription( $description );

        // Publish challenge to SNS
        $this->publishChange( $this->_site, 'UPDATE' );

        return $response;
    }

    /**
     * Get a list of badges that are allowed for this challenge
     *
     * @return BeMaverick_Badge[]
     */
    public function getBadges()
    {
        // for now we will allow all site badges
        return $this->_site->getBadges();
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
    public function getUrl( $page = 'challenge',
        $params = array(),
        $relativeUrl = true,
        $overwriteSite = null,
        $sortParams = true,
        $isSecure = false
    ) {

        $slyUrl = Sly_Url::getInstance();

        $params['challengeId'] = $this->getId();

        return $slyUrl->getUrl( $page, $params, $relativeUrl, $overwriteSite, $sortParams, $isSecure );
    }

    /**
     * Get the comments for this challenge
     *
     * @return Array    array('meta' => ..., 'data' => [...]);
     */
    public function getComments($query = array(), $allowCache)
    {
        return $this->_site->getComments( 'challenge', $this->getId(), $query, $allowCache );
    }

    /**
     * Save the challenge
     *
     * @return void
     */
    public function save()
    {
        $this->_daChallenge->save();

        $daChallengeTags = BeMaverick_Da_ChallengeTags::getInstance();

        $daChallengeTags->save();
    }

    /**
     * Delete the challenge
     *
     * @return void
     */
    public function delete()
    {
        $daChallengeTags = BeMaverick_Da_ChallengeTags::getInstance();
        $daChallengeTags->deleteChallenge( $this->getId() );

        $this->_daChallenge->deleteChallenge( $this->getId() );
    }

    /**
     * Get the share url if response is public
     *
     * @return string
     */
    public function getShareUrl()
    {
        if ( ! $this->getStatus() == 'published'  ) {
            return null;
        }

        $systemConfig = $this->_site->getSystemConfig();

        $websiteHttpHost = $systemConfig->getSetting( 'SYSTEM_WEBSITE_HTTP_HOST' );

        return $this->getUrl( 'challenge', array(), false, $websiteHttpHost );
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
        $challengeType = $this->getChallengeType();

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
        if ($challengeType == self::CHALLENGE_TYPE_VIDEO) {
            $video = $this->getVideo() ?? null;
            $image = $this->getCardImage() ?? null;
            if ( ! is_null( $video ) ) {
                $openGraph['og:type'] = 'video.other';
                $openGraph['og:video:url'] = $video->getVideoUrl() ?? null;
                $openGraph['og:video:secure_url'] = $openGraph['og:video:url'] ?? null;
                $openGraph['og:video:type'] = "video/mp4";
                $openGraph['og:video:width'] = $video->getWidth() ?? 1080;
                $openGraph['og:video:height'] = $video->getHeight() ?? 1440;
            }
            if ( ! is_null( $image ) ) {
                $openGraph['og:image:url'] = $image->getUrl() ?? null;
                $openGraph['og:image:width'] = $image->getWidth() ?? 1080;
                $openGraph['og:image:height'] = $image->getHeight() ?? 1440;
            }
        } else if ( $challengeType == self::CHALLENGE_TYPE_IMAGE ) {
            $image = $this->getCardImage() ?? null;
            if ( ! is_null( $image ) ) {
                $openGraph['og:image:url'] = $image->getUrl() ?? null;
                $openGraph['og:image:width'] = $image->getWidth() ?? 1080;
                $openGraph['og:image:height'] = $image->getHeight() ?? 1440;
            }
        }

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
        $openGraph['twitter:app:url:iphone'] = "$deepLinkProtocol://maverick/challenge/" . $this->getId();
        $openGraph['twitter:app:name:ipad'] = 'Maverick';
        $openGraph['twitter:app:id:ipad'] = $appStoreAppId;
        $openGraph['twitter:app:url:ipad'] = "$deepLinkProtocol://maverick/challenge/" . $this->getId();

        // Facebook fields
        if ( $facebookAppId ) {
            $openGraph['fb:app_id'] = $facebookAppId;
        }

        // return values
        return $openGraph;
    }

    /**
     * Get mentioned user ids
     *
     * @param string $modelType
     * @param integer $modelId
     * @return integer[]
     */
    public function getMentionedUserIds( )
    {
        return BeMaverick_Mention::getMentionedUserIds( 'challenge', $this->getId() );
    }

    /**
     * Set the mentions
     *
     * @param string $modelType
     * @param integer $modelId
     * @param integer[] $mentions
     * @return void
     */
    public function setMentions( $mentions )
    {
        $site = $this->_site;
        BeMaverick_Mention::setMentions( $site, 'challenge', $this->getId(), $mentions );
    }

    /**
     * Get the created timestamp
     *
     * @return string
     */
    public function getCreatedTimestamp()
    {
        return $this->_daChallenge->getCreatedTimestamp( $this->getId() );
    }

    /**
     * Get the updated timestamp
     *
     * @return string
     */
    public function getUpdatedTimestamp()
    {
        return $this->_daChallenge->getUpdatedTimestamp( $this->getId() );
    }

    /**
     * Set the updated timestamp
     *
     * @param string $updatedTimestamp
     * @return void
     */
    public function setUpdatedTimestamp( $updatedTimestamp )
    {
        $this->_daChallenge->setUpdatedTimestamp( $this->getId(), $updatedTimestamp );
    }

    /**
     * Get the details
     */
    public function getDetails() {
        return self::getChallengeDetails($this->_site, $this->getId(), false);
    }

    /**
     * Create challenge data object
     *
     * @param BeMaverick_Site $site
     * @param integer $challengeId
     *
     * @return array
     */
    public static function getChallengeDetails( $site, $challengeId, $allowCache = true )
    {
        // get challenge
        $challenge = self::getInstance( $site, $challengeId );
        if(!$challenge) return;

        // get vars
        $challengeType = $challenge->getChallengeType();
        $user = $challenge->getUser();
        $video = $challenge->getVideo();
        $image = $challenge->getImage();
        $mainImage = $challenge->getMainImage();
        $cardImage = $challenge->getCardImage();

        // create challenge data
        $data = array(
            'challengeId' => $challengeId.'',
            'challengeType' => $challengeType,
            'linkUrl' => $challenge->getLinkUrl(),
            'description' => $challenge->getDescription(),
            'status' => $challenge->getStatus(),
            'user' => $user->getUserDetails(),
            'title' => $challenge->getTitle(),
            'hashtags' => $challenge->getHashtags(),
            'hideFromStreams' => $challenge->isHideFromStreams(),
        );

        // add comments preview
        $allowPeekCache = $allowCache;
        $data['peekComments'] = $challenge->getComments(
            array(
                'sort' => '-created', 
                'limit' => 3
            ),
            $allowPeekCache
        );

        // add number of responses
        $data['numResponses'] = (int)$challenge->getResponseCount(
            array(
                'responseStatus' => 'active'
            )
        );

        // add media to data object
        if ( $video ) {
            $data['video'] = BeMaverick_Video::getVideoDetails( $site, $video->getId() );
        }

        // image
        if ( $image ) {
            $data['image'] = BeMaverick_Image::getImageDetails( $site, $image->getId() );
        } elseif ( $mainImage ) {
            $data['image'] = BeMaverick_Image::getImageDetails( $site, $mainImage->getId() );
        } elseif ( $cardImage ) {
            $data['image'] = BeMaverick_Image::getImageDetails( $site, $cardImage->getId() );
        }

        // mainImage
        if ( $mainImage ) {
            $data['mainImage'] = BeMaverick_Image::getImageDetails( $site, $mainImage->getId() );
        }

        // cardImage
        if ( $cardImage ) {
            $data['cardImage'] = BeMaverick_Image::getImageDetails( $site, $cardImage->getId() );
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
        $allowCache = false;
        $data = $this->getChallengeDetails( $site, $this->getId(), $allowCache );

        // call sns publish
        return BeMaverick_Sns::publish( $site, 'challenge', $this->getId(), $action, $data );
    }

    /**
     * When creating a challenge, publish to sns event
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

        if ( $eventType == 'CREATE_CHALLENGE' ) {
            $contentType = 'challenge';
            $contentId = $this->getId();

            $data = array(
                'challenge' => $this->getDetails()
            );
        }

        if ( $data ) {
            BeMaverick_Sns::publishEvent( $site, $eventType, $contentType, $contentId, $userId, $data );
        }
    }

}

?>
