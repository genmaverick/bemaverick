<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Content.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/ContentBadge.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/ContentTags.php' );

class BeMaverick_Content
{
    const CONTENT_TYPE_VIDEO     = 'video';
    const CONTENT_TYPE_IMAGE     = 'image';

    const CONTENT_STATUS_DRAFT     = 'draft';
    const CONTENT_STATUS_ACTIVE    = 'active';
    const CONTENT_STATUS_INACTIVE  = 'inactive';
    const CONTENT_STATUS_DELETED   = 'deleted';

    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = array();

    /**
     * @access protected
     */
    protected $_site;

    /**
     * @var integer
     * @access protected
     */
    protected $_contentId = null;

    /**
     * @var BeMaverick_Da_Content
     * @access protected
     */
    protected $_daContent;

    /**
     * Class constructor
     *
     * @param BeMaverick_Site $site
     * @param integer $contentId
     * @return void
     */
    public function __construct( $site, $contentId )
    {
        $this->_site = $site;
        $this->_contentId = $contentId;
        $this->_daContent = BeMaverick_Da_Content::getInstance();
    }

    /**
     * Retrieves the content instance.
     *
     * @param BeMaverick_Site $site
     * @param integer $contentId
     * @return BeMaverick_Content
     */
    public static function getInstance( $site, $contentId )
    {
        if ( ! $contentId ) {
            return null;
        }
        
        if ( ! isset( self::$_instance[$contentId] ) ) {

            $daContent = BeMaverick_Da_Content::getInstance();

            // make sure content exists
            if ( ! $daContent->isKeysExist( array( $contentId ) ) ) {
                self::$_instance[$contentId] = null;
            } else {
                self::$_instance[$contentId] = new self( $site, $contentId );
            }
        }

        return self::$_instance[$contentId];

    }

    /**
     * Create a content
     *
     * @param BeMaverick_Site $site
     * @param string $contentType
     * @param BeMaverick_User $user
     * @param BeMaverick_Video $video
     * @param BeMaverick_Image $image
     * @param string $title
     * @param string $description
     * @param boolean $skipComments
     * @return BeMaverick_Content
     */
    public static function createContent( $site, $contentType, $user, $video, $image, $title, $description, $skipComments = false )
    {
        $daContent = BeMaverick_Da_Content::getInstance();


        $videoId = $video ? $video->getId() : null;
        $imageId = $image ? $image->getId() : null;

        $contentId = $daContent->createContent( $contentType, $user->getId(), $videoId, $imageId, $title, $description );

        $content = new self( $site, $contentId );

        // we might have already tried to get this content for some reason, so update
        // the self instance here and return it
        self::$_instance[$contentId] = $content;

        return $content;
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
    public static function getContentIds( $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $daContent = BeMaverick_Da_Content::getInstance();

        return $daContent->getContentIds( $filterBy, $sortBy, $count, $offset );
    }

    /**
     * Get a list of contents
     *
     * @param BeMaverick_Site $site
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Content[]
     */
    public static function getContents( $site, $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $daContent = BeMaverick_Da_Content::getInstance();

        $contentIds = $daContent->getContentIds( $filterBy, $sortBy, $count, $offset );

        $contents = array();
        foreach ( $contentIds as $contentId ) {
            $contents[] = self::getInstance( $site, $contentId );
        }

        return $contents;
    }

    /**
     * Get a count of contents
     *
     * @param hash $filterBy
     * @return integer
     */
    public static function getContentCount( $filterBy = null )
    {
        $daContent = BeMaverick_Da_Content::getInstance();

        return $daContent->getContentCount( $filterBy );
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
        return $this->_contentId;
    }

    /**
     * Get the channel id - used for twilio comments
     *
     * @return string
     */
    public function getChannelId()
    {
        return BeMaverick_Site::MODEL_TYPE_CONTENT . '_' . $this->getId();
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
     * Get the content type
     *
     * @return string
     */
    public function getContentType()
    {
        return $this->_daContent->getContentType( $this->getId() );
    }

    /**
     * Set the content type
     *
     * @param string $contentType
     * @return void
     */
    public function setContentType( $contentType )
    {
        $this->_daContent->setContentType( $this->getId(), $contentType );
    }

    /**
     * Get the user
     *
     * @return BeMaverick_User
     */
    public function getUser()
    {
        $userId = $this->_daContent->getUserId( $this->getId() );

        return $this->_site->getUser( $userId );
    }

    /**
     * Set the user id
     *
     * @param integer $userId
     * @return void
     */
    public function setUserId( $userId )
    {
        $this->_daContent->setUserId( $this->getId(), $userId );
    }

    /**
     * Set the user
     *
     * @param BeMaverick_User $user
     * @return void
     */
    public function setUser( $user )
    {
        $this->_daContent->setUserId( $this->getId(), $user->getId() );
    }

    /**
     * Get the video
     *
     * @return BeMaverick_Video
     */
    public function getVideo()
    {
        $videoId = $this->_daContent->getVideoId( $this->getId() );

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

        $this->_daContent->setVideoId( $this->getId(), $videoId );
    }

    /**
     * Get the image
     *
     * @return BeMaverick_Image
     */
    public function getImage()
    {
        $imageId = $this->_daContent->getImageId( $this->getId() );

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

        $this->_daContent->setImageId( $this->getId(), $imageId );
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
        $imageId = $this->_daContent->getCoverImageId( $this->getId() );

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

        $this->_daContent->setCoverImageId( $this->getId(), $imageId );
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
        return $this->_daContent->getTitle( $this->getId() );
    }

    /**
     * Set the title
     *
     * @param string $title
     * @return void
     */
    public function setTitle( $title )
    {
        $this->_daContent->setTitle( $this->getId(), $title );
    }

    /**
     * Get the description
     *
     * @return string
     */
    public function getDescription()
    {
        return $this->_daContent->getDescription( $this->getId() );
    }

    /**
     * Set the description
     *
     * @param string $description
     * @return void
     */
    public function setDescription( $description )
    {
        $this->_daContent->setDescription( $this->getId(), $description );
    }

    /**
     * Get the status
     *
     * @return string
     */
    public function getStatus()
    {
        return $this->_daContent->getStatus( $this->getId() );
    }

    /**
     * Set the status
     *
     * @param string $status
     * @return void
     */
    public function setStatus( $status )
    {
        $this->_daContent->setStatus( $this->getId(), $status );
    }


    /**
     * Get the uuid
     *
     * @return string
     */
    public function getUUID()
    {
        return $this->_daContent->getUUID( $this->getId() );
    }

    /**
     * Set the uuid
     *
     * @param string $uuid
     * @return void
     */
    public function setUUID( $uuid )
    {
        $this->_daContent->setUUID( $this->getId(), $uuid );
    }

    /**
     * Get the created timestamp
     *
     * @return string
     */
    public function getCreatedTimestamp()
    {
        return $this->_daContent->getCreatedTimestamp( $this->getId() );
    }

    /**
     * Set the created timestamp
     *
     * @param string $createdTimestamp
     * @return void
     */
    public function setCreatedTimestamp( $createdTimestamp )
    {
        $this->_daContent->setCreatedTimestamp( $this->getId(), $createdTimestamp );
    }

    /**
     * Get the updated timestamp
     *
     * @return string
     */
    public function getUpdatedTimestamp()
    {
        return $this->_daContent->getUpdatedTimestamp( $this->getId() );
    }

    /**
     * Set the updated timestamp
     *
     * @param string $updatedTimestamp
     * @return void
     */
    public function setUpdatedTimestamp( $updatedTimestamp )
    {
        $this->_daContent->setUpdatedTimestamp( $this->getId(), $updatedTimestamp );
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
        $daContentBadge = BeMaverick_Da_ContentBadge::getInstance();

        $daContentBadge->addContentBadge( $this->getId(), $badge->getId(), $user->getId() );
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
        $daContentBadge = BeMaverick_Da_ContentBadge::getInstance();

        $daContentBadge->deleteContentBadge( $this->getId(), $badge->getId(), $user->getId() );
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
     * Get the tags for this content
     *
     * @return BeMaverick_Tag[]
     */
    public function getTags()
    {
        $daContentTags = BeMaverick_Da_ContentTags::getInstance();

        $tagIds = $daContentTags->getContentTagIds( $this->getId() );

        $tags = array();

        foreach ( $tagIds as $tagId ) {
            $tags[] = $this->_site->getTag( $tagId );
        }

        return $tags;
    }

    /**
     * Get the share url
     *
     * @return string
     */
    public function getShareUrl()
    {
        $systemConfig = $this->_site->getSystemConfig();

        $websiteHttpHost = $systemConfig->getSetting( 'SYSTEM_WEBSITE_HTTP_HOST' );

        return $this->getUrl( 'content', array(), false, $websiteHttpHost );
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
    public function getUrl( $page = 'content',
                            $params = array(),
                            $relativeUrl = true,
                            $overwriteSite = null,
                            $sortParams = true,
                            $isSecure = false
    ) {

        $slyUrl = Sly_Url::getInstance();

        $params['contentId'] = $this->getId();

        return $slyUrl->getUrl( $page, $params, $relativeUrl, $overwriteSite, $sortParams, $isSecure );
    }

    /**
     * Get badge counts
     *
     * @return hash
     */
    public function getBadgeCounts()
    {
        $daContentBadge = BeMaverick_Da_ContentBadge::getInstance();

        return $daContentBadge->getContentBadgeCounts( $this->getId() );
    }

    /**
     * Get the list of users that have badged this content
     *
     * @param BeMaverick_Badge|null $badge
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_User[]
     */
    public function getBadgeUsers( $badge, $count, $offset )
    {
        $daContentBadge = BeMaverick_Da_ContentBadge::getInstance();

        $badgeId = $badge ? $badge->getId() : null;

        $userIds = $daContentBadge->getUserIds( $this->getId(), $badgeId, $count, $offset );

        $users = array();
        foreach ( $userIds as $userId ) {
            $users[] = $this->_site->getUser( $userId );
        }

        return $users;
    }

    /**
     * Get the count of users that have badged this content
     *
     * @param BeMaverick_Badge|null $badge
     * @return void
     */
    public function getBadgeUserCount( $badge )
    {
        $daContentBadge = BeMaverick_Da_ContentBadge::getInstance();

        $badgeId = $badge ? $badge->getId() : null;

        return $daContentBadge->getUserCount( $this->getId(), $badgeId );
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
     * Set the tags for this content
     *
     * @param string[] $tagNames
     * @return void
     */
    public function setTagNames( $tagNames )
    {
        $daContentTags = BeMaverick_Da_ContentTags::getInstance();

        $daContentTags->deleteContent( $this->getId() );

        if ( is_array( $tagNames ) ) {

            $tagNames = array_unique( $tagNames );

            foreach ( $tagNames as $tagName ) {
                $tagName = trim( $tagName );

                $tag = $this->_site->getTagByName( $tagName );

                if ( ! $tag ) {
                    $tag = $this->_site->createTag( BeMaverick_Site::TAG_TYPE_PREDEFINED, $tagName );
                }

                $daContentTags->addContentTag( $this->getId(), $tag->getId() );
            }
        }
    }

    /**
     * Get the comments for this content
     *
     * @return Twilio\Rest\Api\V2010\Account\Message[]
     */
    public function getComments($query = array(), $allowCache = true)
    {
        return $this->_site->getComments( 'content', $this->getId(), $query, $allowCache );
    }


    /**
     * Save the content
     *
     * @return void
     */
    public function save()
    {
        $this->_daContent->save();

        $daContentBadge = BeMaverick_Da_ContentBadge::getInstance();
        $daContentBadge->save();

        $daContentTags = BeMaverick_Da_ContentTags::getInstance();
        $daContentTags->save();
    }

    /**
     * Delete the content
     *
     * @return void
     */
    public function delete()
    {
        $daContentTags = BeMaverick_Da_ContentTags::getInstance();
        $daContentTags->deleteContent( $this->getId() );

        $daContentBadge = BeMaverick_Da_ContentBadge::getInstance();
        $daContentBadge->deleteContent( $this->getId() );

        $this->_daContent->deleteContent( $this->getId() );
    }
}

?>
