<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/SiteUtil.php' );

class BeMaverick_Api_ResponseData
{

    protected $_data;

    public function getData()
    {
        return $this->_data;
    }

    // ************************* Support Functions **********************

    /**
     * Merge arrays recursively
     *
     * Unlike php function array_merge_recursive this will use integer keys
     * as keys.
     *
     * @param array $array1
     * @param array $array2
     * @return array
     */
    function mergeArrayRecursive( &$array1, &$array2 )
    {
        foreach ( $array2 as $key => $value ) {
            // if not in $array1 we can just set it
            if ( !isset( $array1[$key] ) ) {
                $array1[$key] = $value;
                continue;
            }

            // if they are not both arrays overwrite the value in $array1
            if ( gettype( $array1[$key] ) != 'array' || gettype( $value ) != 'array' ) {
                $array1[$key] = $value;
                continue;
            }

            // both are arrays so we need to merge those too
            $this->mergeArrayRecursive( $array1[$key], $array2[$key] );
        }
    }

    /**
     * Merge the data into $this->_data
     *
     * @param array $data
     * @return void
     */
    public function mergeData( &$data )
    {
        $this->mergeArrayRecursive( $this->_data, $data );
    }

    /**
     * Add results data
     *
     * @param hash $results
     * @return void
     */
    public function addResults( $results )
    {
        $data['results'] = $results;
        $this->mergeData( $data );
    }

    /**
     * Add the status of the request
     *
     * @param string $status
     * @return void
     */
    public function addStatus( $status )
    {
        $data['status'] = $status;
        $this->mergeData( $data );
    }

    /**
     * Add the site config
     *
     * @param BeMaverick_Site $site
     * @return void
     */
    public function addSiteConfig( $site )
    {
        // check if already added
        if ( isset( $this->_data['config'] ) ) {
            return;
        }

        $profileCoverPresetImageIds = $site->getProfileCoverPresetImageIds();

        $configData = array(
            'profileCoverPresetImageIds' => $profileCoverPresetImageIds,
        );

        foreach ( $profileCoverPresetImageIds as $profileCoverPresetImageId ) {

            $image = $site->getProfileCoverPresetImage( $profileCoverPresetImageId );

            $configData['profileCoverPresetImageUrls'][$profileCoverPresetImageId] = array(
                'original' => $image->getUrl(),
                'medium' => $image->getUrl( 400, 400 ),
                'small' => $image->getUrl( 200, 200 ),
            );
        }

        $data['config'] = $configData;

        $this->mergeData( $data );
    }

    /**
     * Add the tag basic
     *
     * @param BeMaverick_Tag $tag
     * @return void
     */
    public function addTagBasic( $tag )
    {
        // check if already added
        if ( isset( $this->_data['tags'][$tag->getId()] ) ) {
            return;
        }

        $tagData = array(
            'tagId' => $tag->getId(),
            'type' => $tag->getType(),
            'name' => $tag->getName(),
        );

        $data['tags'][$tag->getId()] = $tagData;

        $this->mergeData( $data );
    }

    /**
     * Add the badge basic
     *
     * @param BeMaverick_Badge $badge
     * @return void
     */
    public function addBadgeBasic( $badge )
    {
        // check if already added
        if ( isset( $this->_data['badges'][$badge->getId()] ) ) {
            return;
        }

        $badgeId = $badge->getId();
        $badgeData = array(
            'badgeId' => $badgeId.'',
            'name' => $badge->getName(),
            'status' => $badge->getStatus(),
            'color' => $badge->getColor(),
            'sortOrder' => $badge->getSortOrder(),
            'primaryImageUrl' => $badge->getPrimaryImageUrl(),
            'secondaryImageUrl' => $badge->getSecondaryImageUrl(),
            'description' => $badge->getDescription(),
            'offsetX' => $badge->getOffsetX(),
            'offsetY' => $badge->getOffsetY(),
        );

        error_log('DESCRIPTION' . $badge->getDescription());
        $data['badges'][$badgeId] = $badgeData;

        $this->mergeData( $data );
    }

    /**
     * Add the video basic
     *
     * @param BeMaverick_Video $video
     * @return void
     */
    public function addVideoBasic( $video )
    {
        if(!$video) return;

        // check if already added
        if ( isset( $this->_data['videos'][$video->getId()] ) ) {
            return;
        }

        $width = $video->getWidth();
        $width = $width ? (int)$width : null;

        $height = $video->getHeight();
        $height = $height ? (int)$height : null;

        $videoData = array(
            'videoId' => $video->getId().'',
            'videoUrl' => $video->getVideoUrl(),
            'videoHLSUrl' => $video->getHLSPlaylistUrl(),
            'thumbnailUrl' => $video->getThumbnailUrl(),
            'width' => $width,
            'height' => $height,
        );

        $data['videos'][$video->getId()] = $videoData;

        $this->mergeData( $data );
    }

    /**
     * Add the image basic
     *
     * @param BeMaverick_Image $image
     * @return void
     */
    public function addImageBasic( $image )
    {
        // check if already added
        if ( isset( $this->_data['images'][$image->getId()] ) ) {
            return;
        }

        $site = $image->getSite();
        $systemConfig = $site->getSystemConfig();

        $width = $image->getWidth();
        $width = $width ? (int)$width : null;

        $height = $image->getHeight();
        $height = $height ? (int)$height : null;

        $imageData = array(
            'imageId' => $image->getId().'',
            'url' => $image->getUrl(),
            'urlProtocol' => $systemConfig->getSetting( 'SYSTEM_IMAGE_PROTOCOL' ),
            'urlHost' => $systemConfig->getSetting( 'SYSTEM_IMAGE_HOST' ),
            'filename' => $image->getFilename(),
            'width' => $width,
            'height' => $height,
        );

        $data['images'][$image->getId()] = $imageData;

        $this->mergeData( $data );
    }

    /**
     * Add the response basic
     *
     * @param BeMaverick_Response $response
     * @param boolean $allowPeekCache
     * @param boolean $includeTags
     * @param boolean $includeBadges
     * @param boolean $includePeekComments
     * @return void
     */
    public function addResponseBasic( $response, $allowPeekCache = true, $includeTags = true, $includeBadges = true, $includePeekComments = true )
    {
        // return quietly on null entries
        if ( is_null( $response ) ) {
            return;
        }

        // check if already added
        if ( isset( $this->_data['responses'][$response->getId()] ) ) {
            return;
        }

        $user = $response->getUser();
        $challenge = $response->getChallenge();

        $this->addUserBasic( null, $user, false );
        $challengeId = null;

        if ( $response->getPostType() == BeMaverick_Site::POST_TYPE_RESPONSE && $challenge ) {
            $this->addChallengeBasic( $challenge, $allowPeekCache, $includeBadges );
            $challengeId = $challenge->getId();
        }

        $responseType = $response->getResponseType();

        $coverImage = $response->getCoverImage();
        if ( $coverImage ) {
            $this->addImageBasic( $coverImage );
        }

        $responseData = array(
            'responseId' => $response->getId().'',
            'description' => $response->getDescription(),
            'responseType' => $responseType,
            'status' => $response->getStatus(),
            'userId' => $user->getId().'',
            'challengeId' => $challengeId ? $challengeId.'' : null,
            'videoId' => null,
            'imageId' => null,
            'mainImageUrl' => $response->getImageUrl(),
            'coverImageId' => $coverImage ? $coverImage->getId().'' : null,
            'coverImageUrl' => $response->getCoverImageUrl(),
            'favorite' => $response->isFavorited(),
            'isPublic' => $response->isPublic(),
            'shareUrl' => $response->getShareUrl(),
            'hashtags' => $response->getHashtags(),
        );

        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {
            $video = $response->getVideo();
            $this->addVideoBasic( $video );
            $responseData['videoId'] = $video->getId().'';

        } else if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {
            $image = $response->getImage();
            $this->addImageBasic( $image );
            $responseData['imageId'] = $image->getId().'';
        }

        // add the tags
        if ( $includeTags ) {

            $tags = $response->getTags();

            $tagIds = array();
            foreach ( $tags as $tag ) {
                $this->addTagBasic( $tag );

                $tagIds[] = $tag->getId();
            }

            $responseData['tagIds'] = $tagIds;
        }

        // add the badges
        if ( $includeBadges ) {

            $badges = $response->getBadges();

            $badgeCounts = $response->getBadgeCounts();

            foreach ( $badges as $badge ) {

                $badgeId = $badge->getId();

                $responseData['badges'][$badgeId] = array(
                    'badgeId' => $badgeId . '',
                    'numReceived' => (int)@$badgeCounts[$badgeId]['count'],
                );
            }
        }

        // add the peek comments
        if ( $includePeekComments ) {

            $query = array(
                'sort' => '-created',
                'limit' => 3,
            );
            $peekComments = $response->getComments( $query, $allowPeekCache );
            $responseData['peekComments'] = $peekComments ?? array();
        }

        $data['responses'][$response->getId()] = $responseData;

        $this->mergeData( $data );
    }

    /**
     * Add the response limited
     * (Limits the number of fields and dependencies returned 
     * to improve response time)
     *
     * @param BeMaverick_Response $response
     * @param boolean $allowPeekCache
     * @return void
     */
    public function addResponseLimited( $response )
    {
        // return quietly on null entries
        if (is_null($response)) {
            return;
        }

        // check if already added
        if ( isset( $this->_data['responses'][$response->getId()] ) ) {
            return;
        }

        $responseType = $response->getResponseType();

        $coverImage = $response->getCoverImage();
        if ( $coverImage ) {
            $this->addImageBasic( $coverImage );
        }

        $responseData = array(
            'responseId' => $response->getId().'',
            'description' => $response->getDescription(),
            'responseType' => $responseType,
            'status' => $response->getStatus(),
            'userId' => $response->getUserId().'',
            'challengeId' => $response->getChallengeId() ?? null,
            'videoId' => null,
            'imageId' => null,
            'coverImageId' => $coverImage ? $coverImage->getId().'' : null,
            'coverImageUrl' => $response->getCoverImageUrl(),
            'favorite' => $response->isFavorited(),
            'isPublic' => $response->isPublic(),
            'shareUrl' => $response->getShareUrl(),
            'tagIds' => array(),
            'hashtags' => $response->getHashtags(),
            'badges' => array(),
            'peekComments' => array(),
        );

        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {
            $video = $response->getVideo();
            $this->addVideoBasic( $video );
            $responseData['videoId'] = $video->getId().'';

        } else if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {
            $image = $response->getImage();
            $this->addImageBasic( $image );
            $responseData['imageId'] = $image->getId().'';
        }

        $data['responses'][$response->getId()] = $responseData;

        $this->mergeData( $data );
    }

    /**
     * Add the notification basic
     *
     * @param BeMaverick_Notification $notification
     * @return void
     */
    public function addNotificationBasic( $notification )
    {
        // check if already added
        if ( isset( $this->_data['notifications'][$notification->getId()] ) ) {
            return;
        }

        $object = $notification->getObject();
        $objectType = $notification->getObjectType();

        if ( $objectType == BeMaverick_Site::MODEL_TYPE_CHALLENGE ) {
            $this->addChallengeBasic( $object );
        } else if ( $objectType == BeMaverick_Site::MODEL_TYPE_RESPONSE ) {
            $this->addResponseBasic( $object );
        } else if ( $objectType == BeMaverick_Site::MODEL_TYPE_CONTENT ) {
            $this->addContentBasic( $object );
        } else if ( $objectType == BeMaverick_Site::MODEL_TYPE_USER ) {
            $this->addUserBasic( null, $object );
        }

        $notificationData = array(
            'notificationId' => $notification->getId(),
            'userId' => $notification->getUser()->getId().'',
            'action' => $notification->getAction(),
            'object_id' => $object->getId().'',
            'object_type' => $objectType,
        );

        $data['notifications'][$notification->getId()] = $notificationData;

        $this->mergeData( $data );
    }

    /**
     * Add the challenge basic
     *
     * @param BeMaverick_Challenge $challenge
     * @param boolean $allowPeekCache
     * @param boolean $includeFullDetails
     * @return void
     */
    public function addChallengeBasic( $challenge, $allowPeekCache = true, $includeFullDetails = true )
    {
        // return quietly on null entries
        if (is_null( $challenge )) {
            return;
        }

        // check if already added
        if ( isset( $this->_data['challenges'][$challenge->getId()] ) ) {
            return;
        }

        $challengeType = $challenge->getChallengeType();

        $user = $challenge->getUser();
        $this->addUserBasic( null, $user, false );

        $video = $challenge->getVideo();
        $this->addVideoBasic( $video );

        $startTime = $challenge->getStartTime();
        $startTime = $startTime ? Sly_Date::formatDate( $startTime, 'ISO_8601' ) : null;

        $endTime = $challenge->getEndTime();
        $endTime = $endTime ? Sly_Date::formatDate( $endTime, 'ISO_8601' ) : null;

        $winnerResponse = $challenge->getWinnerResponse();
        $winnerResponseId = $winnerResponse ? $winnerResponse->getId() : null;

        if ( $winnerResponse ) {
            $this->addResponseBasic( $winnerResponse );
        }

        $numResponses = (int)$challenge->getResponseCount(
            array(
                'responseStatus' => 'active'
            )
        );

        $image = $challenge->getImage();
        if ( $image ) {
            $this->addImageBasic( $image );
        }

        $mainImage = $challenge->getMainImage();
        if ( $mainImage ) {
            $this->addImageBasic( $mainImage );
        }

        $cardImage = $challenge->getCardImage();
        if ( $cardImage ) {
            $this->addImageBasic( $cardImage );
        }

        $challengeData = array(
            'challengeId' => $challenge->getId().'',
            'challengeType' => $challenge->getChallengeType().'',
            'status' => $challenge->getStatus(),
            'userId' => $user->getId(),
            'title' => $challenge->getTitle(),
            'description' => $challenge->getDescription(),
            'videoId' => !empty($video) ? $video->getId().'' : null,
            'imageId' => !empty($image) ? $image->getId().'' : null,
            'imageUrl' => $challenge->getImageUrl(),
            'imageText' => $challenge->getImageText(),
            'linkUrl' => $challenge->getLinkUrl(),
            'mainImageId' => $mainImage ? $mainImage->getId().'' : null,
            'mainImageUrl' => $challenge->getMainImageUrl(),
            'cardImageId' => $cardImage ? $cardImage->getId().'' : null,
            'cardImageUrl' => $challenge->getCardImageUrl(),
            'startTime' => $startTime,
            'endTime' => $endTime,
            'winnerResponseId' => $winnerResponseId,
            'numResponses' => (int)$numResponses,
        );

        if ( $includeFullDetails ) {

            // add the tags
            $tags = $challenge->getTags();
            foreach ( $tags as $tag ) {
                $this->addTagBasic( $tag );

                $challengeData['tagIds'][] = $tag->getId();
            }

            // add the mentions
            $mentions = $challenge->getMentionedUserIds();
            $challengeData['mentionUserIds'] = $mentions;

            // add the badges
            $badges = $challenge->getBadges();
            foreach ( $badges as $badge ) {
                $this->addBadgeBasic( $badge );

                $challengeData['badgeIds'][] = $badge->getId().'';
            }

            // add the peek comments
            $query = array(
                'sort' => '-created',
                'limit' => 3,
            );
            $peekComments = $challenge->getComments( $query, $allowPeekCache );
            $challengeData['peekComments'] = $peekComments ?? array();
        }

        $data['challenges'][$challenge->getId()] = $challengeData;

        $this->mergeData( $data );
    }


    /**
     * Add the challenge limited
     *
     * @param BeMaverick_Challenge $challenge
     * @return void
     */
    public function addChallengeLimited( $challenge, $allowPeekCache = true )
    {
        // return quietly on null entries
        if (is_null( $challenge )) {
            return;
        }

        // check if already added
        if ( isset( $this->_data['challenges'][$challenge->getId()] ) ) {
            return;
        }

        $challengeType = $challenge->getChallengeType();

        $userId = $challenge->getUserId();
        $video = $challenge->getVideo();
        $this->addVideoBasic( $video );

        $startTime = $challenge->getStartTime();
        $startTime = $startTime ? Sly_Date::formatDate( $startTime, 'ISO_8601' ) : null;

        $endTime = $challenge->getEndTime();
        $endTime = $endTime ? Sly_Date::formatDate( $endTime, 'ISO_8601' ) : null;

        $image = $challenge->getImage();
        if ( $image ) {
            $this->addImageBasic( $image );
        }

        $mainImage = $challenge->getMainImage();
        if ( $mainImage ) {
            $this->addImageBasic( $mainImage );
        }

        $cardImage = $challenge->getCardImage();
        if ( $cardImage ) {
            $this->addImageBasic( $cardImage );
        }

        $challengeData = array(
            'challengeId' => $challenge->getId().'',
            'challengeType' => $challenge->getChallengeType().'',
            'status' => $challenge->getStatus(),
            'userId' => $userId,
            'title' => $challenge->getTitle(),
            'description' => $challenge->getDescription(),
            'videoId' => !empty($video) ? $video->getId().'' : null,
            'imageId' => !empty($image) ? $image->getId().'' : null,
            'imageUrl' => $challenge->getImageUrl(),
            'imageText' => $challenge->getImageText(),
            'mainImageId' => $mainImage ? $mainImage->getId().'' : null,
            'mainImageUrl' => $challenge->getMainImageUrl(),
            'cardImageId' => $cardImage ? $cardImage->getId().'' : null,
            'cardImageUrl' => $challenge->getCardImageUrl(),
            'startTime' => $startTime,
            'endTime' => $endTime,
            'winnerResponseId' => null,
            'numResponses' => null,
            'tagIds' => array(),
            'mentionUserIds' => array(),
            'badgeIds' => array(),
            'peekComments' => array(),
        );

        // add the tags
        $tags = $challenge->getTags();
        foreach ( $tags as $tag ) {
            $challengeData['tagIds'][] = $tag->getId();
        }

        // add the mentions
        $mentions = $challenge->getMentionedUserIds();
        $challengeData['mentionUserIds'] = $mentions;

        // add the peek comments
        $challengeData['peekComments'] =  array();

        $data['challenges'][$challenge->getId()] = $challengeData;

        $this->mergeData( $data );
    }

    /**
     * Add the stream basic
     *
     * @param BeMaverick_Stream $stream
     * @return void
     */
    public function addStreamBasic( $stream )
    {
        // check if already added
        if ( isset( $this->_data['streams'][$stream->getId()] ) ) {
            return;
        }

        $streamData = array(
            'streamId' => $stream->getId(),
        );

        $definition = $stream->getDefinition();

        if ( $definition ) {
            $streamData = array_merge( $streamData, $definition );
        }

        $data['streams'][$stream->getId()] = $streamData;

        $this->mergeData( $data );
    }

    /**
     * Add the challenge responses
     *
     * @param BeMaverick_Challenge $challenge
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addChallengeResponses( $challenge, $count = 10, $offset = 0 )
    {
        $this->addChallengeBasic( $challenge );

        $filterBy = array(
            'responseStatus' => 'active',
        );

        $sortBy = array(
            'sort' => 'favorite',
            'sortOrder' => 'desc',
        );

        $responses = $challenge->getResponses( $filterBy, $sortBy, $count, $offset );

        $responseIds = array();

        foreach ( $responses as $response ) {

            $this->addResponseBasic( $response );

            $responseIds[] = $response->getId();
        }

        $data['challenges'][$challenge->getId()]['searchResults'] = array(
            'responses' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'responseIds' => $responseIds,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the created responses by user
     *
     * @param BeMaverick_User $user
     * @param integer $badgeId
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addUserResponses( $user, $badgeId = null, $count = 10, $offset = 0 )
    {
        $this->addUserBasic( null, $user );

        $filterBy = array(
            'responseStatus' => 'active',
            'badgeId' => $badgeId,
        );

        $sortBy = null;

        $responses = $user->getResponses( $filterBy, $sortBy, $count, $offset );

        $responseIds = array();

        foreach ( $responses as $response ) {

            $this->addResponseBasic( $response );

            $responseIds[] = $response->getId();
        }

        $data['users'][$user->getId()]['searchResults'] = array(
            'responses' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'responseIds' => $responseIds,
            ),
        );

        $this->mergeData( $data );
    }
    /**
     * Add the response details
     *
     * @param BeMaverick_Response $response
     * @return void
     */
    public function addResponseDetails( $response )
    {
        $this->addResponseBasic( $response );
    }

    /**
     * Add the response badge users
     *
     * @param BeMaverick_Response $response
     * @param BeMaverick_Badge|null $badge
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addResponseBadgeUsers( $response, $badge, $count, $offset )
    {
        $this->addResponseBasic( $response );

        $users = $response->getBadgeUsers( $badge, $count, $offset );
        $userCount = $response->getBadgeUserCount( $badge );

        $userIds = array();

        foreach ( $users as $user ) {
            $this->addUserBasic( null, $user );
            $this->addUserResponseBadges( $user, $response );

            $userIds[] = $user->getId();
        }

        $data['responses'][$response->getId()]['searchResults'] = array(
            'badgeUsers' => array(
                'params' => array(
                    'badgeId' => $badge ? $badge->getId().'' : null,
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'totalUserCount' => (int)$userCount,
                'userIds' => $userIds,
            ),
        );

        $this->mergeData( $data );

    }

    /**
     * Add the content basic
     *
     * @param BeMaverick_Content $content
     * @return void
     */
    public function addContentBasic( $content )
    {
        // check if already added
        if ( isset( $this->_data['contents'][$content->getId()] ) ) {
            return;
        }

        $user = $content->getUser();
        $this->addUserBasic( null, $user );

        $contentType = $content->getContentType();

        $coverImage = $content->getCoverImage();
        if ( $coverImage ) {
            $this->addImageBasic( $coverImage );
        }

        $contentData = array(
            'contentId' => $content->getId().'',
            'contentType' => $content->getContentType(),
            'userId' => $user->getId().'',
            'title' => $content->getTitle(),
            'description' => $content->getDescription(),
            'videoId' => null,
            'imageId' => null,
            'coverImageId' => $coverImage ? $coverImage->getId().'' : null,
            'coverImageUrl' => $content->getCoverImageUrl(),
            'tagIds' => array(),
            'badges' => array(),
        );

        if ( $contentType == BeMaverick_Content::CONTENT_TYPE_VIDEO ) {
            $video = $content->getVideo();
            $this->addVideoBasic( $video );
            $contentData['videoId'] = $video->getId().'';

        } else if ( $contentType == BeMaverick_Content::CONTENT_TYPE_IMAGE ) {
            $image = $content->getImage();
            $this->addImageBasic( $image );
            $contentData['imageId'] = $image->getId().'';
        }

        // add the tags
        $tags = $content->getTags();
        foreach ( $tags as $tag ) {
            $this->addTagBasic( $tag );

            $contentData['tagIds'][] = $tag->getId().'';
        }

        // add the badges
        $badges = $content->getBadges();

        $badgeCounts = $content->getBadgeCounts();

        foreach ( $badges as $badge ) {

            $this->addBadgeBasic( $badge );
            $badgeId = $badge->getId();

            $contentData['badges'][$badgeId] = array(
                'badgeId' => $badgeId.'',
                'numReceived' => (int) @$badgeCounts[$badgeId]['count'],
            );
        }

        $data['contents'][$content->getId()] = $contentData;

        $this->mergeData( $data );
    }

    /**
     * Add the content badge users
     *
     * @param BeMaverick_Content $content
     * @param BeMaverick_Badge|null $badge
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addContentBadgeUsers( $content, $badge, $count, $offset )
    {
        $this->addContentBasic( $content );

        $users = $content->getBadgeUsers( $badge, $count, $offset );
        $userCount = $content->getBadgeUserCount( $badge );

        $userIds = array();

        foreach ( $users as $user ) {

            $this->addUserBasic( null, $user );
            $this->addUserContentBadges( $user, $content );

            $userIds[] = $user->getId();
        }

        $data['contents'][$content->getId()]['searchResults'] = array(
            'badgeUsers' => array(
                'params' => array(
                    'badgeId' => $badge ? $badge->getId().'' : null,
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'totalUserCount' => (int)$userCount,
                'userIds' => $userIds,
            ),
        );

        $this->mergeData( $data );

    }

    /**
     * Add the user content badges
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_Content $content
     * @return void
     */
    public function addUserContentBadges( $user, $content )
    {
        $badgeIds = $user->getGivenContentBadgeIds( $content );

        $data['users'][$user->getId()]['content'][$content->getId()]['badgeIds'] = $badgeIds;

        $this->mergeData( $data );
    }

    /**
     * Add the created content by user
     *
     * @param BeMaverick_User $user
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addUserContents( $user, $count = 10, $offset = 0 )
    {
        $this->addUserBasic( null, $user);

        $filterBy = array(
            'contentStatus' => 'active',
        );

        $sortBy = null;

        $contents = $user->getContents( $filterBy, $sortBy, $count, $offset );

        $contentIds = array();

        foreach ( $contents as $content ) {

            $this->addContentBasic( $content );

            $contentIds[] = $content->getId();
        }

        $data['users'][$user->getId()]['searchResults'] = array(
            'contents' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'contentIds' => $contentIds,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the login user
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $loginUser
     * @param String
     * @return void
     */
    public function addLoginUser( $site, $loginUser, $isBasic )
    {
        if ( $isBasic ) {

            $this->addUserBasic( $site, $loginUser );
        }else {

            $this->addUserDetails($site, $loginUser);
        }
        
        $userType = $loginUser->getUserType();

        $parentEmailAddress = null;
        $vpcStatus = false;
        if ( $userType == BeMaverick_User::USER_TYPE_KID ) {
            $parentEmailAddress = $loginUser->getParentEmailAddress();
            $vpcStatus = $loginUser->getVPCStatus();
        }else if ( $userType == BeMaverick_User::USER_TYPE_MENTOR ) {
            $vpcStatus = true; //set vpcstatus to true for all catalysts.
        }

        $loginUserData = array(
            'userId' => $loginUser->getId().'',
            'userUUID' => $loginUser->getUUID(),
            'userType' => $userType,
            'isVerified' => method_exists(($loginUser), 'isVerified') ? $loginUser->isVerified() : null,
            'isEmailVerified' => method_exists(($loginUser), 'isEmailVerified') ? $loginUser->isEmailVerified() : null,
            'vpcStatus' => $vpcStatus,
            'emailAddress' => $loginUser->getEmailAddress(),
            'parentEmailAddress' => $parentEmailAddress,
            'birthdate' => $loginUser->getBirthdate(),
        );

        $data['loginUser'] = $loginUserData;

        $this->mergeData( $data );
    }

    /**
     * Add the user basic
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @param boolean $includeStatsBadgesPreferences
     * @param boolean $includeUserLevel
     * @return void
     */
    public function addUserBasic( $site, $user, $includeStatsBadgesPreferences = true, $includeUserLevel = false )
    {
        // check if already added
        if ( isset( $this->_data['users'][$user->getId()] ) ) {
            return;
        }

        $userData = array(
            'userId' => $user->getId(),
            'username' => $user->getUsername(),
            'userType' => $user->getUserType(),
            'status' => $user->getStatus(),
            'firstName' => $user->getFirstName(),
            'lastName' => $user->getLastName(),
            'userUUID' => $user->getUUID(),
            'emailAddress' => $user->getEmailAddress(),
            'bio' => method_exists( $user, 'getBio' ) ? $user->getBio() : null,
            'isVerified' => $user->isVerified() || false,
            'isEmailVerified' => $user->isEmailVerified() || false,
        );

        $profileImage = $user->getProfileImage();

        if ( $profileImage ) {
            $this->addImageBasic( $profileImage );
        }

        $userData['profileImageId'] = $profileImage ? $profileImage->getId().'' : null;

        // add some default image urls
        $profileImageUrl = $profileImage ? $profileImage->getUrl() : null;
        $mediumProfileImageUrl = $profileImage ? $profileImage->getUrl( 200, 200 ) : null;
        $smallProfileImageUrl = $profileImage ? $profileImage->getUrl( 50, 50 ) : null;

        $userData['profileImageUrls'] = array(
            'original' => $profileImageUrl,
            'medium' => $mediumProfileImageUrl,
            'small' => $smallProfileImageUrl,
        );

        $profileCoverImageType = $user->getProfileCoverImageType();

        $userData['profileCoverImageType'] = $profileCoverImageType;

        if ( $profileCoverImageType == BeMaverick_User::PROFILE_COVER_IMAGE_TYPE_CUSTOM ) {

            $profileCoverImage = $user->getProfileCoverImage();

            if ( $profileCoverImage ) {
                $this->addImageBasic( $profileCoverImage );
            }

            $userData['profileCoverImageId'] = $profileCoverImage ? $profileCoverImage->getId().'' : null;

            // add some default image urls
            $profileCoverImageUrl = $profileCoverImage ? $profileCoverImage->getUrl() : null;
            $mediumProfileCoverImageUrl = $profileCoverImage ? $profileCoverImage->getUrl( 200, 200 ) : null;
            $smallProfileCoverImageUrl = $profileCoverImage ? $profileCoverImage->getUrl( 50, 50 ) : null;

            $userData['profileCoverImageUrls'] = array(
                'original' => $profileCoverImageUrl,
                'medium' => $mediumProfileCoverImageUrl,
                'small' => $smallProfileCoverImageUrl,
            );
        } else if ( $profileCoverImageType == BeMaverick_User::PROFILE_COVER_IMAGE_TYPE_PRESET ) {

            $userData['profileCoverPresetImageId'] = $user->getProfileCoverPresetImageId().'';
            $userData['profileCoverTint'] = $user->getProfileCoverTint();
        }

        if ( $user->getUserType() == BeMaverick_User::USER_TYPE_MENTOR ) {

            $userData['bio'] = $user->getBio();

        }

        if ( $includeStatsBadgesPreferences ) {

            // set the badges
            $this->addBadges( $site, $user );

            // set the statistics
            $userData['stats'] = $user->getStatistics();

            // add user preferences
            $preferences = $user->getPreferences();
            $userData['preferences'] = is_array( $preferences ) ? $preferences : array();
        }

        // add user level
        if ( $includeUserLevel ) {
            $currentLevelNumber = $user->getCurrentLevelNumber();
            $userData['currentLevelNumber'] = $currentLevelNumber;
        }

        $data['users'][$user->getId()] = $userData;

        $this->mergeData( $data );
    }

    /**
     * Add the user details
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @return void
     */
    public function addUserDetails( $site, $user )
    {
        $this->addUserBasic( $site, $user );
        /**
         * Badges, Stats, Preferences and more included in addUserBasic(...)
         */

        $userData = array(
            'userId' => $user->getId().'',
            'bio' => $user->getBio(),
            'badges' => array(),
            'responseIds' => array(),
            'challengeIds' => array(),
            'stats' => array(),
            'isVerified' => $user->isVerified() || false,
            'isEmailVerified' => $user->isEmailVerified() || false,
        );

        // set the responses
        $responses = $user->getResponses();
        foreach ( $responses as $response ) {
            $this->addResponseBasic( $response );

            $userData['responseIds'][] = $response->getId();
        }

        // set the challenges
        $challenges = $user->getChallenges();
        foreach ( $challenges as $challenge ) {
            $this->addChallengeBasic( $challenge );

            $userData['challengeIds'][] = $challenge->getId();
        }

        $data['users'][$user->getId()] = $userData;

        $this->mergeData( $data );
    }

    public function addBadges($site, $user = null) {

        if (empty($site)) {
            return;
        }

        $userData = array(
            'badges' => array(),
        );

        // get user/badge activity count
        if (!empty($user)) {
            $receivedBadgesCount = $user->getReceivedBadgesCount();
            $givenBadgesCount = $user->getGivenBadgesCount();
        }

        // add the badges
        $badges = $site->getBadges();
        foreach ( $badges as $badge ) {
            $badgeId = $badge->getId();
            $this->addBadgeBasic( $badge );

            // add user's individual badge counts
            if (!empty($user)) {
                $userData['badges'][$badgeId] = array(
                    'badgeId' => $badgeId.'',
                    'numReceived' => (int) @$receivedBadgesCount[$badgeId]['count'],
                    'numGiven' => (int) @$givenBadgesCount[$badgeId]['count'],
                );
            }
        }

        if(!empty($user)) {
            $data['users'][$user->getId()] = $userData;
        }
        $this->mergeData( $data );
    }

    /**
     * Add the user badged responses
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @param integer $badgeId
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addUserBadgedResponses( $site, $user, $badgeId, $count, $offset )
    {
        $this->addUserBasic( $site, $user, false );

        $responses = $user->getBadgedResponses( $badgeId, null, $count, $offset );
        $responseCount = $user->getBadgedResponseCount( $badgeId );

        $responseIds = array();

        foreach ( $responses as $response ) {

            $this->addResponseBasic( $response, true, false, true, false );
            $this->addUserResponseBadges( $user, $response );

            $responseIds[] = $response->getId().'';
        }

        $data['users'][$user->getId()]['searchResults'] = array(
            'badgedResponses' => array(
                'params' => array(
                    'badgeId' => $badgeId,
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'totalResponseCount' => (int)$responseCount,
                'responseIds' => $responseIds,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the user response badges
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_Response $response
     * @return void
     */
    public function addUserResponseBadges( $user, $response )
    {
        $badgeIds = $user->getGivenResponseBadgeIds( $response );

        $data['users'][$user->getId()]['responses'][$response->getId()]['badgeIds'] = $badgeIds;

        $this->mergeData( $data );
    }

    /**
     * Add the user favorite challenges
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @return void
     */
    public function addUserSavedChallenges( $site, $user )
    {
        $this->addUserBasic( $site, $user );

        $userData = array(
            'userId' => $user->getId(),
            'savedChallengeIds' => array(),
        );

        $challenges = $user->getSavedChallenges();
        $challengesCount = $user->getSavedChallengesCount(); // cannot use because it includes inactive challenges
        $challengeIds = array_filter(
            array_map( function($challenge) { 
                return method_exists($challenge, 'getId') ? $challenge->getId() : null; 
            }, $challenges ),
            function($challenge) { return !empty($challenge); }
        );

        foreach ( $challenges as $challenge ) {
            if ( $challenge ) {
                $this->addChallengeBasic( $challenge );
                $userData['savedChallengeIds'][] = $challenge->getId();
            }
        }

        $data['users'][$user->getId()] = $userData;



        $data['site']['searchResults'] = array(
            'savedChallenges' => array(
                // 'params' => array(
                //     'count' => (int)$count,
                //     'offset' => (int)$offset,
                // ),
                'challengeIds' => $challengeIds,
                'count' => count($challengeIds),
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the user saved contents
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @return void
     */
    public function addUserSavedContents( $site, $user )
    {
        $this->addUserBasic( $site, $user );

        $userData = array(
            'userId' => $user->getId(),
            'savedContentIds' => array(),
        );

        $contents = $user->getSavedContents();
        foreach ( $contents as $content ) {
            $this->addContentBasic( $content );

            $userData['savedContentIds'][] = $content->getId();
        }

        $data['users'][$user->getId()] = $userData;

        $this->mergeData( $data );
    }

    /**
     * Add the user followers
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @return void
     */
    public function addUserFollowers( $site, $user )
    {
        $this->addUserBasic( $site, $user );

        $userData = array(
            'userId' => $user->getId(),
            'followingUserIds' => array(),
            'followerUserIds' => array(),
        );

        $followingUsers = $user->getFollowingUsers();
        foreach ( $followingUsers as $followingUser ) {
            $this->addUserBasic( $site, $followingUser, false );

            $userData['followingUserIds'][] = $followingUser->getId();
        }

        $followerUsers = $user->getFollowerUsers();
        foreach ( $followerUsers as $followerUser ) {
            $this->addUserBasic( $site, $followerUser, false );

            $userData['followerUserIds'][] = $followerUser->getId();
        }

        $data['users'][$user->getId()] = $userData;

        $this->mergeData( $data );
    }

    /**
     * Add the site users
     *
     * @param BeMaverick_Site $site
     * @param array $emailAddresses
     * @param array $phoneNumbers
     * @param string $loginProvider
     * @param array $loginProviderUserIds
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addFindMyFriends( $site, $emailAddresses, $phoneNumbers, $loginProvider, $loginProviderUserIds, $count, $offset )
    {
        $filterBy = array(
            'userStatus' => 'active',
            'userType' => BeMaverick_User::USER_TYPE_KID,
            'emailAddresses' => $emailAddresses,
            'phoneNumbers' => $phoneNumbers,
            'loginProvider' => $loginProvider,
            'loginProviderUserIds' => $loginProviderUserIds,
        );

        $users = $site->getUsers( $filterBy, null, $count, $offset );
        $userCount = $site->getUserCount( $filterBy );

        $data = array();
        $userIds = array();

        foreach ( $users as $user ) {
            $this->addUserBasic( $site, $user );

            $userIds[] = $user->getId().'';

            // we are going to add phone number only here, because we don't want to pass phone number
            // in addUserBasic anytime a user is used in other API calls. feels like phone number
            // is a bit more private and shouldn't be passed around so easily
            $data['users'][$user->getId()]['phoneNumber'] = $user->getPhoneNumber();
        }

        $data['site']['searchResults'] = array(
            'users' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'userIds' => $userIds,
                'totalUserCount' => $userCount,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the user My Feed
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addUserMyFeed( $site, $user, $count, $offset = 0 )
    {

        $userId = $user->getId();
        $contentIds = array();

        $myFeed = $site->getMyFeed( $userId, $count, $offset );
        $myFeedCount = $site->getMyFeedCount( $userId );

        // die('$myFeed => '.print_r($myFeed,true));
        foreach ( $myFeed as $record ) {


            $contentType = $record['contentType'];
            $contentId = $record['contentId'];

            switch($contentType) {
                case 'response':
                    $response = $site->getResponse($contentId);
                    $this->addResponseBasic( $response );
                    break;
                case 'challenge':
                    $challenge = $site->getChallenge($contentId);
                    $this->addChallengeBasic( $challenge );
                    break;
            }

        }

        $data['searchResults'] = array(
            'myFeed' => array(
                'params' => array(
                    'userId' => (int)$userId,
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'totalCount' => $myFeedCount,
                'data' => $myFeed,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the user response feed
     *
     * From ticket MVP-428:
     *
     * First response will be a response from people you follow. Order by most recent responses
     * Second response will be a curated/featured response.
     * Third response will be a response from your followers. Order by most recent responses
     * Above pattern of 3 responses will be repeated until end of the all responses.
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addUserResponseFeed( $site, $user, $count, $offset )
    {
        // get list of responses by users that this user is following
        $filterBy = array(
            'responseStatus' => 'active',
            'followerUserId' => $user->getId(),
            'hideFromStreams' => false,
        );

        $sortBy = array(
            'sort' => 'createdTimestamp',
            'sortOrder' => 'desc',
        );

        $followingResponseIds = $site->getResponseIds( $filterBy, $sortBy );

        $responseCount = count( $followingResponseIds );
        $responseIds = array_slice( $followingResponseIds, $offset, $count );

        // backfill with featuredResponses if the followingResponseIds are empty
        if ( $responseCount == 0 ) {
            // get list of featured responses
            $filterBy = array(
                'responseStatus' => 'active',
            );
            $sortBy = array(
                'sort' => 'featured',
                'sortOrder' => 'asc',
            );
            $featuredResponseIds = $site->getResponseIds( $filterBy, $sortBy );
            $responseCount = count( $featuredResponseIds );
            $responseIds = array_slice( $featuredResponseIds, $offset, $count );
        }

        foreach ( $responseIds as $responseId ) {

            $response = $site->getResponse( $responseId );

            $this->addResponseBasic( $response );
        }

        $data['users'][$user->getId()]['searchResults'] = array(
            'responseFeed' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'responseIds' => $responseIds,
                'totalResponseCount' => $responseCount,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the user notifications
     *
     * @param BeMaverick_User $user
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addUserNotifications( $user, $count, $offset )
    {
        $this->addUserBasic( null, $user );

        $filterBy = null;
        $sortBy = null;

        $notifications = $user->getNotifications( $filterBy, $sortBy, $count, $offset );
        $notificationCount = $user->getNotificationCount( $filterBy );

        $notificationIds = array();

        foreach ( $notifications as $notification ) {

            $this->addNotificationBasic( $notification );

            $notificationIds[] = $notification->getId().'';
        }

        $data['users'][$user->getId()]['searchResults'] = array(
            'notifications' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'totalNotificationCount' => (int)$notificationCount,
                'notificationIds' => $notificationIds,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the user badged responses and content
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @param integer $badgeId
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addUserBadged( $site, $user, $badgeId, $count, $offset )
    {
        $filterBy = array(
            'responseStatus' => 'active',
            'badgedUserId' => $user->getId(),
            'badgeId' => $badgeId,
        );

        $sortBy = null;

        $responses = $site->getResponses( $filterBy, $sortBy, $count, $offset );
        $responseCount = $site->getResponseCount( $filterBy );

        $responseIds = array();

        foreach ( $responses as $response ) {

            $this->addResponseBasic( $response );
            $this->addUserResponseBadges( $user, $response );

            $responseIds[] = $response->getId().'';
        }

        $filterBy = array(
            'contentStatus' => 'active',
            'badgedUserId' => $user->getId(),
            'badgeId' => $badgeId,
        );

        $sortBy = null;

        $contents = $site->getContents( $filterBy, $sortBy, $count, $offset );
        $contentCount = $site->getContentCount( $filterBy );

        $contentIds = array();

        foreach ( $contents as $content ) {

            $this->addContentBasic( $content );
            $this->addUserContentBadges( $user, $content );

            $contentIds[] = $content->getId().'';
        }

        $totalCount = $responseCount + $contentCount;

        $data['users'][$user->getId()]['searchResults'] = array(
            'badgedResponses' => array(
                'params' => array(
                    'badgeId' => $badgeId,
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'totalCount' => (int)$totalCount,
                'responseIds' => $responseIds,
                'contentIds'  => $contentIds,
            ),
        );

        $this->mergeData( $data );
    }


    /**
     * Add the site challenges
     *
     * @param BeMaverick_Site $site
     * @param string $status
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addSiteChallenges( $site, $status, $sortBy, $count, $offset, $filterBy = array() )
    {
        $systemConfig = $site->getSystemConfig();
        $numUsersWithResponseToChallenge = $systemConfig->getSetting( 'SYSTEM_NUM_USERS_WITH_RESPONSE_TO_CHALLENGE' );
        $data = array();

        // Add status to the filter array
        $filterBy['challengeStatus'] = $status;

        $challenges = $site->getChallenges( $filterBy, $sortBy, $count, $offset );
        $challengeCount = $site->getChallengeCount( $filterBy );

        if(isset($_GET['debug']) && false) {
            $debug = array_map(function($challenge) {

                $datetime1 = new DateTime($challenge->getCreatedTimestamp());
                $datetime2 = new DateTime();
                $interval = $datetime1->diff($datetime2);
                $age = $interval->format('%a days old');
                $user = $challenge->getUser();
                $responseCount = (int)$challenge->getResponseCount(
                    array(
                        'responseStatus' => 'active'
                    )
                );
                $fields = array (
                    'title' => $challenge->getTitle(),
                    'username' => $user->getUsername(),
                    'age' => $age,
                    'responseCount' => "$responseCount responses",
                    // 'id' => "id:".$challenge->getId(),
                    'url' => "https://www.genmaverick.com/challenges/".$challenge->getId(),
                );
                // if ($challenge->getId() == 987) {
                //     die(print_r($challenge,true));
                // }
                return implode(' -- ', $fields);
            }, $challenges);
            print("-- DEBUG -- \n");
            print(print_r($debug,true));
            exit();
        }

        $challengeIds = array();
        foreach ( $challenges as $challenge ) {
            $this->addChallengeBasic( $challenge );
            $challengeIds[] = $challenge->getId().'';
            $userIds = array();
            $users = $challenge->getUniqueUsersWithResponse( $numUsersWithResponseToChallenge );
            foreach ( $users as $user ) {
                $userIds[] = $user->getId();
                $this->addUserBasic( $site, $user );
            }
            $data['challenges'][$challenge->getId()] = array(
                'challengeId' => $challenge->getId().'',
                'userIdsWithMostRecentResponse' => $userIds,
            );
        }
        $data['site']['searchResults'] = array(
            'challenges' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'totalChallengeCount' => (int)$challengeCount,
                'challengeIds' => $challengeIds,
            ),
        );
        $this->mergeData( $data );
    }


    /**
     * Add the site challenge stream challenges
     *
     * @param BeMaverick_Site $site
     * @param string $status
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @param integer $stagger
     * @return void
     */
    public function addSiteChallengeStreamChallenges( $site, $count, $offset /* ,$stagger */ )
    {
        // declare vars
        $systemConfig = $site->getSystemConfig();

        $numUsersWithResponseToChallenge = $systemConfig->getSetting( 'SYSTEM_NUM_USERS_WITH_RESPONSE_TO_CHALLENGE' );

        $data = array();

        $filterBy = array(
            'challengeStatus' => 'active',
        );

        $challengeCount = $site->getChallengeCount( $filterBy );

        // get challenge stream challenges
        $challengeIds = $site->getChallengeStreamChallenges($count, $offset /*, $stagger */);

        foreach ( $challengeIds as $challengeId ) {

            $challenge = $site->getChallenge( $challengeId );
            $this->addChallengeBasic( $challenge );

            $userIds = array();

            $users = $challenge->getUniqueUsersWithResponse( $numUsersWithResponseToChallenge );
            foreach ( $users as $user ) {
                $userIds[] = $user->getId();

                $this->addUserBasic( $site, $user );
            }

            $data['challenges'][$challenge->getId()] = array(
                'challengeId' => $challenge->getId().'',
                'userIdsWithMostRecentResponse' => $userIds,
            );
        }

        $data['site']['searchResults'] = array(
            'challenges' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'totalChallengeCount' => (int)$challengeCount,
                'challengeIds' => $challengeIds,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the site responses
     *
     * @param BeMaverick_Site $site
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addSiteResponses( $site, $filterBy, $sortBy, $count, $offset )
    {
        // error_log('ResponseData.php:addSiteResponses() ... getResponses()');
        $responses = $site->getResponses( $filterBy, $sortBy, $count, $offset );
        $responseCount = $site->getResponseCount( $filterBy );

        $responseIds = array();

        foreach ( $responses as $response ) {

            $this->addResponseBasic( $response );

            $responseIds[] = $response->getId().'';
        }

        $data['site']['searchResults'] = array(
            'responses' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'responseIds' => $responseIds,
                'totalResponseCount' => $responseCount,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the site contents
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addSiteContents( $site, $user, $sortBy, $count, $offset )
    {
        $data = array();

        $filterBy = array(
            'contentStatus' => 'active'
        );

        if ( $user ) {
            $filterBy['userId'] = $user->getId();
        }

        $contents = $site->getContents( $filterBy, $sortBy, $count, $offset );
        $contentCount = $site->getContentCount( $filterBy );

        $contentIds = array();

        foreach ( $contents as $content ) {

            $this->addContentBasic( $content );

            $contentIds[] = $content->getId().'';
        }

        $data['site']['searchResults'] = array(
            'contents' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'totalContentCount' => (int)$contentCount,
                'contentIds' => $contentIds,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the site users
     *
     * NOTE: This will not work if you try to do a count/offset pagination because
     * the code is ALWAYS adding the featured users to the front of the list.  It is
     * also not handling the total count properly because of the followed users by
     * the login user.  At the moment, I believe it is only getting a total of 20 users
     * to show in the app and that is all, so this does work.
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $loginUser
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addSiteUsers( $site, $loginUser, $count, $offset )
    {
        $filterBy = array(
            'userStatus' => 'active',
            'userType' => 'kid',
            'notUserId' => $loginUser ? $loginUser->getId() : null,
        );

        $sortBy = array(
            'sort' => 'engagedUsers',
            'sortOrder' => 'desc',
        );

        $users = $site->getUsers( $filterBy, $sortBy, $count, $offset );

        $featuredUsers = $site->getFeaturedUsers( 'maverick-user' );
        $followingUsers = $loginUser ? $loginUser->getFollowingUsers() : array();

        // remove any featured users from the list
        $users = array_diff( $users, $featuredUsers );

        // now add the featured users to the front of the list
        $users = array_merge( $featuredUsers, $users );

        // now remove any users the login user is already following
        $users = array_diff( $users, $followingUsers );

        $userCount = count( $users );

        $userIds = array();

        foreach ( $users as $user ) {
            if ( $user ) {
                $this->addUserBasic( $site, $user );

                $userIds[] = $user->getId().'';
            }
        }

        $data['site']['searchResults'] = array(
            'users' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'userIds' => $userIds,
                'totalUserCount' => $userCount,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the site tags
     *
     * @param BeMaverick_Site $site
     * @param string $query
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addSiteTags( $site, $query, $count, $offset )
    {
        $filterBy = array(
            'query' => $query,
        );

        $sortBy = array(
            'sort' => 'name',
            'sortOrder' => 'asc',
        );

        $tags = $site->getTags( $filterBy, $sortBy, $count, $offset );

        $tagIds = array();

        foreach ( $tags as $tag ) {

            $this->addTagBasic( $tag );

            $tagIds[] = $tag->getId();
        }

        $data['site']['searchResults'] = array(
            'tags' => array(
                'params' => array(
                    'query' => $query,
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'tagIds' => $tagIds,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the site streams
     *
     * @param BeMaverick_Site $site
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addSiteStreams( $site, $count, $offset )
    {
        $streams = $site->getStreams();
        $streamCount = $site->getStreamCount();

        $streamIds = array();

        foreach ( $streams as $stream ) {

            $this->addStreamBasic( $stream );

            $streamIds[] = $stream->getId().'';
        }

        $data['site']['searchResults'] = array(
            'streams' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'streamIds' => $streamIds,
                'totalStreamCount' => $streamCount,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Add the maverick stream feed
     *
     * From ticket MVP-428:
     *
     * This will be a pattern of 9 cards repeated in a infinite scroll.
     * First card will be a featured challenge (large size with CTAs)
     * Second and Third cards will be a featured responses
     * Fourth and Fifth cards will be responses from engaged users.
     *     Engaged users are determined by the # of badges given and # of responses created within last 2 weeks.
     *     Responses are weighed 5:1 against the badges.
     * Sixth card will be a featured response (large size with CTAs )
     * Seven, Eight and Nineth cards will be recent responses.
     *
     * @param BeMaverick_Site $site
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addSiteMaverickStream( $site, $count, $offset )
    {
        $date = Sly_Date::subDays( date( 'Y-m-d' ), 14 );

        // get list of featured challenges
        $featuredChallengeIds = $site->getFeaturedChallengeIds( 'maverick-stream' );

        // get list of featured response ids
        $featuredResponseIds = $site->getFeaturedResponseIds( 'maverick-stream' );

        // get list of recent response ids
        $recentResponseIds = BeMaverick_SiteUtil::getRecentResponseIds( $site, ( $offset + $count ) );

        // get list of engaged users response ids
        $engagedUsersResponseIds = $site->getEngagedUsersResponseIds( $date );

        // we need to remove any duplicates that the lists might have
        $engagedUsersResponseIds = array_diff( $engagedUsersResponseIds, $featuredResponseIds );
        $recentResponseIds = array_diff( $recentResponseIds, $featuredResponseIds );

        // recent response ids will have them all, so just add those + featured challenges
        $objectCount = count( $featuredChallengeIds ) + count( $recentResponseIds ) + count( $featuredResponseIds );

        $objectIds = array();

        while ( count( $objectIds ) < $count + $offset
            && ( $featuredResponseIds || $recentResponseIds || $engagedUsersResponseIds )
        ) {

            // first card
            if ( $featuredChallengeIds && ( (count($objectIds) % 9) == 0 ) ) {
                $challengeId = array_shift( $featuredChallengeIds );
                $objectIds[] = "challenge-$challengeId";
            }

            // second card (if no featured, then put in a recent one instead)
            if ( $featuredResponseIds ) {
                $responseId = array_shift( $featuredResponseIds );
                $objectIds[] = "response-$responseId";
            } else if ( $recentResponseIds ) {
                $responseId = array_shift( $recentResponseIds );
                $engagedUsersResponseIds = array_diff( $engagedUsersResponseIds, array( $responseId ) );
                $objectIds[] = "response-$responseId";
            }

            // third card (if no featured, then put in a recent one instead)
            if ( $featuredResponseIds ) {
                $responseId = array_shift( $featuredResponseIds );
                $objectIds[] = "response-$responseId";
            } else if ( $recentResponseIds ) {
                $responseId = array_shift( $recentResponseIds );
                $engagedUsersResponseIds = array_diff( $engagedUsersResponseIds, array( $responseId ) );
                $objectIds[] = "response-$responseId";
            }

            // fourth card (if no engaged, then put in a recent one instead)
            if ( $engagedUsersResponseIds ) {
                $responseId = array_shift( $engagedUsersResponseIds );
                $recentResponseIds = array_diff( $recentResponseIds, array( $responseId ) );
                $objectIds[] = "response-$responseId";
            } else if ( $recentResponseIds ) {
                $responseId = array_shift( $recentResponseIds );
                $objectIds[] = "response-$responseId";
            }

            // fifth card (if no featured, then put in a recent one instead)
            if ( $featuredResponseIds ) {
                $responseId = array_shift( $featuredResponseIds );
                $objectIds[] = "response-$responseId";
            } else if ( $recentResponseIds ) {
                $responseId = array_shift( $recentResponseIds );
                $engagedUsersResponseIds = array_diff( $engagedUsersResponseIds, array( $responseId ) );
                $objectIds[] = "response-$responseId";
            }

            // sixth card(if no engaged, then put in a recent one instead)
            if ( $engagedUsersResponseIds ) {
                $responseId = array_shift( $engagedUsersResponseIds );
                $recentResponseIds = array_diff( $recentResponseIds, array( $responseId ) );
                $objectIds[] = "response-$responseId";
            }else if ( $recentResponseIds ) {
                $responseId = array_shift( $recentResponseIds );
                $objectIds[] = "response-$responseId";
            }

            // seventh card
            if ( $recentResponseIds ) {
                $responseId = array_shift( $recentResponseIds );
                $engagedUsersResponseIds = array_diff( $engagedUsersResponseIds, array( $responseId ) );
                $objectIds[] = "response-$responseId";
            }

            // eight card
            if ( $recentResponseIds ) {
                $responseId = array_shift( $recentResponseIds );
                $engagedUsersResponseIds = array_diff( $engagedUsersResponseIds, array( $responseId ) );
                $objectIds[] = "response-$responseId";
            }

            // ninth card
            if ( $recentResponseIds ) {
                $responseId = array_shift( $recentResponseIds );
                $engagedUsersResponseIds = array_diff( $engagedUsersResponseIds, array( $responseId ) );
                $objectIds[] = "response-$responseId";
            }
        }

        $objectIds = array_slice( $objectIds, $offset, $count );

        foreach ( $objectIds as $objectId ) {

            list( $thisObjectType, $thisObjectId ) = explode( '-', $objectId );
            if ( $thisObjectType == 'response' ) {

                $response = $site->getResponse( $thisObjectId );
                $this->addResponseBasic( $response );
            } else if ( $thisObjectType == 'challenge' ) {

                $challenge = $site->getChallenge( $thisObjectId );
                $this->addChallengeBasic( $challenge );

            }

        }

        $data['site']['searchResults'] = array(
            'maverickStream' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'objectIds' => $objectIds,
                'totalObjectCount' => $objectCount,
            ),
        );
        // Add md5 hash for result signature
        $data['site']['searchResults']['maverickStream']['md5'] = md5(print_r($data['site']['searchResults']['maverickStream'],true));

        $this->mergeData( $data );
    }

    /**
     * Add the site challenge stream
     *
     * @param BeMaverick_Site $site
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addSiteChallengeStream( $site, $count, $offset )
    {
        $systemConfig = $site->getSystemConfig();

        $numUsersWithResponseToChallenge = $systemConfig->getSetting( 'SYSTEM_NUM_USERS_WITH_RESPONSE_TO_CHALLENGE' );

        $data = array();

        // get the rest of the challenges in timestamp order
        $filterBy = array(
            'challengeStatus' => 'active',
        );

        $sortBy = array(
            'sort' => 'featuredAndStartTimestamp',
            'sortOrder' => 'desc',
            'featuredType' => 'challenge-stream',
        );

        $challenges = $site->getChallenges( $filterBy, $sortBy, $count, $offset );
        $challengeCount = $site->getChallengeCount( $filterBy );

        $challengeIds = array();

        foreach ( $challenges as $challenge ) {

            $this->addChallengeBasic( $challenge );

            $challengeIds[] = $challenge->getId().'';

            $userIds = array();

            $users = $challenge->getUniqueUsersWithResponse( $numUsersWithResponseToChallenge );
            foreach ( $users as $user ) {
                $userIds[] = $user->getId();

                $this->addUserBasic( $site, $user );
            }

            $data['challenges'][$challenge->getId()] = array(
                'challengeId' => $challenge->getId().'',
                'userIdsWithMostRecentResponse' => $userIds,
            );
        }

        $data['site']['searchResults'] = array(
            'challengeStream' => array(
                'params' => array(
                    'count' => (int)$count,
                    'offset' => (int)$offset,
                ),
                'totalChallengeCount' => (int)$challengeCount,
                'challengeIds' => $challengeIds,
            ),
        );

        $this->mergeData( $data );
    }

    /**
     * Generates the access token for the user using an app.
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_App $app
     * @param BeMaverick_User $user
     * @return void
     */
    public function addUserAccessToken( $site, $app, $user )
    {
        require_once( BEMAVERICK_COMMON_ROOT_DIR . '/config/autoload_oauth_dependencies.php' );
        $config = array(
            // 'refresh_token_lifetime' => 5184000 // 60 days
            'refresh_token_lifetime' => 60 * 60 * 24 * 120 // 120 days
        );
        $accessTokenManger = new Sly_OAuth_AccessTokenManager( $site->getOAuthStorage(), $config );
        $accessTokenManger->setAccessTokenSigningSecret( $site->getSystemConfig()->getAccessTokenSigningSecret() );
        $accessTokenManger->setTokenTTL( (int) $app->getAuthTokenTTL() );
        $scope = null;
        $includeRefreshToken = true;
        $oAuthAccessToken = $accessTokenManger->createAccessToken( $app->getKey(), $user->getId(), $scope, $includeRefreshToken );
        $this->mergeData( $oAuthAccessToken );
    }

    /**
     * Generates the access token for accessing the comments third party provider
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @param String $deviceId
     * @return void
     */
    public function addCommentUserToken( $site, $user, $deviceId )
    {
        $token = $site->createCommentAccessToken( $user, $deviceId );
        $data = array();
        $data['comment'] = array('accessToken' => $token);
        $this->mergeData( $data );
    }

    public function addParentVerificationResponse( $idVerificationResponse, $retry )
    {
        $data = array();
        $status = "PASS";
        $message = "";
        if($idVerificationResponse['result'] && $idVerificationResponse['result']['action'] ) {
            $action =  $idVerificationResponse['result']['action'];
            $status = $action;
            $message = $idVerificationResponse['result']['detail'];
            if ( $retry && ( $action == 'FAIL' || $action == 'REVIEW' ) ) {
                $status = "REJECT";
                $message = "ID Verification failed";
            }
        }

        $data['coppa'] = array(
            'status' => $status,
            'message'=> $message );

        $this->mergeData( $data );
    }

    /**
     * Add the site badges
     *
     * @param BeMaverick_Site $site
     * @param string $status
     * @param integer $count
     * @param integer $offset
     * @return void
     */
    public function addSiteBadges( $site, $status /*, $count, $offset */ )
    {
        $badges = $site->getBadges( $status );

        $badgeIds = array();

        foreach ( $badges as $badge ) {

            $this->addBadgeBasic( $badge );

            $badgeIds[] = $badge->getId();
        }

        $data['site']['searchResults'] = array(
            'badges' => array(
                'params' => array(
                    'status' => $status,
                    // 'count' => (int)$count,
                    // 'offset' => (int)$offset,
                ),
                'badgeIds' => $badgeIds,
            ),
        );

        $this->mergeData( $data );
    }

}

?>
