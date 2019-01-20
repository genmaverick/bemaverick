<?php
/**
 * Class for formatting activity objects
 *
 * @category BeMaverick
 * @package  BeMaverick_View_Helper
 */
class BeMaverick_View_Helper_FormatActivity
{
    const ACTIVITY_TYPE_BADGED_RESPONSE         = 'badged_response';
    const ACTIVITY_TYPE_POSTED_CHALLENGE        = 'posted_challenge';
    const ACTIVITY_TYPE_POSTED_RESPONSE_COMMENT = 'posted_response_comment';
    const ACTIVITY_TYPE_POSTED_RESPONSE         = 'posted_response';
    const ACTIVITY_TYPE_STARTED_FOLLOWING       = 'started_following';

    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public $view;

    /**
     * Returns this helper
     *
     * @return BeMaverick_View_Helper_FormatActivity
     */
    public function formatActivity()
    {
        return $this;
    }

    /**
     * Get a list of the activity types
     *
     * @return array
     */
    public function getActivityTypes() {
        return $this->_activityTypes;
    }

    /**
     * Get the markup for one activity row
     *
     * @param Array $activity
     * @return string
     */
    public function getActivityMarkUp( $activity )
    {
        $site = $this->view->site;
        $formatUser = $this->view->formatUser();

        $html = array();
        $body = $activity['notificationCopy'];
        $id = $activity['subjectId'];
        $requestType = $activity['requestType'];
        $subjectType = $activity['subjectType'];
        $timestamp = $activity['timeStamp'];
        $sourceUserId = $activity['sourceUserId'];

        $type = '';
        if( $requestType == 'badged' )
        {
            $type = self::ACTIVITY_TYPE_BADGED_RESPONSE;
        }else if( $requestType == 'follows' )
        {
            $type = self::ACTIVITY_TYPE_STARTED_FOLLOWING;
        }else if( $requestType == 'postedResponse' )
        {
            $type = self::ACTIVITY_TYPE_POSTED_RESPONSE;
        }else if( $requestType == 'commented' )
        {
            $type = self::ACTIVITY_TYPE_POSTED_RESPONSE_COMMENT;
        }else if( $requestType == 'postedChallenge' )
        {
            $type = self::ACTIVITY_TYPE_POSTED_CHALLENGE;
        }

        $sourceUser = $site->getUser( $sourceUserId );
        $link =getLinkToItem( $subjectType, $id );

        $timeSince = '<div class="time-since">'.$this->view->formatDate()->getSinceTime( $timestamp ).'</div>';
        $body .= ' '.$timeSince;

        $imageConfig = array(
            'imageHeight' => 128,
            'imageWidth' => 128,
            'imageSize' => 'medium',
            'showMaverickLevel' => true,
            'siteBadges' => $site->getBadges()
        );
        $image = $formatUser->getProfileImage( $sourceUser, $imageConfig );
        $activityClasses = array(
            'activity-item',
            'activity-item--'.$type,
            'link'
        );

        return '
            <div class="'.join( ' ', $activityClasses ).'" data-href="'.$link.'">
                <div class="activity-item__image">'.$image.'</div>
                <div class="activity-item__body">'.$body.'</div>
                <div class="activity-item__extra">'.$extra.'</div>
            </div>
        ';
    }

    /**
     * Get the url to link to based on what the main object in an activity is
     *
     * @param String type
     * @param String id
     * @return string
     */
    public function getLinkToItem( $type, $id )
    {
        $url = '';
        if ( $type == 'response' ) {
            $site = $this->view->site;
            $response = $site->getResponse( $id );
            $url = $response->getUrl();
        } else if ( $type == 'challenge' ) {
            $site = $this->view->site;
            $challenge = $site->getChallenge( $id );
            $url = $challenge->getUrl();
        }
        return $url;
    }



    /**
     * Get a number of fake activities
     *
     * @param integer $num
     * @param BeMaverick_User[] $suggestedUsers
     * @return Sly_DataObject[]
     */
    public function getFakeActivities( $num, $suggestedUsers = array() )
    {
        if ( ! $suggestedUsers ) {
            return null;
        }

        $site = $this->view->site;
        $activityTypes = $this->getActivityTypes();
        $challenges = $site->getChallenges( array() );
        $responses = $site->getResponses( array() );
        $badges = $site->getBadges();
        $activities = array();
        $extraObj = null;
        for ( $i = 0; $i < $num; $i++ ) {
            $type = $activityTypes[array_rand( $activityTypes, 1 )];
            $fromUser = $suggestedUsers[array_rand( $suggestedUsers, 1)];
            $toUser = null;
            $object = null;
            if ( $type == self::ACTIVITY_TYPE_POSTED_CHALLENGE ) {
                $challenge = $challenges[array_rand( $challenges, 1 )];
                $object = $challenge;
                $fromUser = $challenge->getUser();
            } else {


                if ( $type == self::ACTIVITY_TYPE_BADGED_RESPONSE ) {
                    $extraObj = $badges[array_rand($badges,1)];
                }
                $response = $responses[array_rand( $responses, 1 )];
                $toUser = $response->getUser();
                $object = $response;
                if ( mt_rand(0,1) ) {
                    $tempUser = $fromUser;
                    $fromUser = $toUser;
                    $toUser = $tempUser;
                }
            }
            $activities[] = $this->getFakeActivity( $type, $object, $fromUser, $toUser, $extraObj );

        }
        return $activities;
    }

    /**
     * Get one fake activity
     *
     * @param string $type
     * @param object $object
     * @param BeMaverick_User $toUser
     * @param BeMaverick_User $fromUser
     * @param mixed $extraObj
     * @return Sly_DataObject
     */
    public function getFakeActivity( $type, $object = null, $fromUser = null, $toUser = null, $extraObj = null )
    {
        $activity = array(
            'type' => $type,
            'toUser' => $toUser,
            'fromUser' => $fromUser,
            'object' => $object,
            'timestamp' => strtotime( 'now -'.mt_rand(0,120).' minutes')
        );

        if ( $type == self::ACTIVITY_TYPE_BADGED_RESPONSE ) {
            $activity['badge'] = $extraObj;
        }

        return new Sly_DataObject( $activity );
    }

    /**
     * Get the markup for one activity row
     *
     * @param Sly_DataObject $activity
     * @return string
     */
    public function getItem( $activity )
    {
        $site = $this->view->site;
        $formatUser = $this->view->formatUser();
        $type = $activity['requestType'];

        $activityClasses = array(
            'activity-item',
            'activity-item--'.$type,
            'link'
        );

        $timeStamp = $this->getTimeSince( $activity );

        // source image
        $srcUser = $site->getUser((int)$activity['sourceUserId']);

        $srcImage = (isset($srcUser) ? $this->getUserImage( $srcUser) : '');

        // target image
        // todo: eventually modularize this, and add other activity types
        if ($activity['subjectType'] == "challenge") {
            $targetImage = $this->getChallengeImage($activity);
        } elseif ($activity['subjectType'] == "response") {
            $targetImage = $this->getResponseImage($activity);

        } elseif ($activity['subjectType'] == "user") {
            $targetUser = $site->getUser((int)$activity['targetUserId']);
            $targetImage = $this->getUserImage( $targetUser);
        }
        else {
            $targetImage ='';
        }

        return '
            <div class="'.join( ' ', $activityClasses ).'">
                <div class="activity-item__image">'.$srcImage.'</div>
                <div class="activity-item__body">'.$activity['notificationCopy'].$timeStamp.'</div>
                <div class="activity-item__extra">'.$targetImage.'</div>
            </div>
        ';
    }

    /**
     * Get the message content for an activity of type 'badged_response'
     *
     * @param Sly_DataObject $activity
     * @return string
     */
    public function getBadgedResponseMessage( $activity )
    {
        $formatUser = $this->view->formatUser();
        $loginUser = $this->view->loginUser;
        $translator = $this->view->translator;

        $toUser = $activity->getToUser();
        $fromUser = $activity->getFromUser();
        $response = $activity->getObject();

        if ( $loginUser && $loginUser == $fromUser ) {
            $displayFromName = 'You';
        } else {
            $displayFromName = $formatUser->getDisplayName( $fromUser );
        }
        if ( $loginUser && $loginUser == $toUser ) {
            $displayToName = 'your';
        } else {
            $displayToName = $formatUser->getDisplayName( $toUser, array( 'isPossessive' => true ) );
        }

        $challenge = $response->getChallenge();
        $challengeTitle = $challenge->getTitle();

        $text = sprintf( $translator->_( "%s badged %s response to %s" ), $displayFromName, $displayToName, $challengeTitle );

        return $text;
    }

    /**
     * Get the message content for an activity of type 'posted_response'
     *
     * @param Sly_DataObject $activity
     * @return string
     */
    public function getPostedResponseMessage( $activity )
    {
        $formatUser = $this->view->formatUser();
        $loginUser = $this->view->loginUser;
        $translator = $this->view->translator;

        $fromUser = $activity->getFromUser();
        $toUser = $activity->getToUser();
        $response = $activity->getObject();

        if ( $loginUser && $loginUser == $fromUser ) {
            $displayFromName = 'You';
        } else {
            $displayFromName = $formatUser->getDisplayName( $fromUser );
        }

        if ( $loginUser && $loginUser == $toUser ) {
            $displayToName = 'your';
        } else {
            $displayToName = $formatUser->getDisplayName( $toUser, array( 'isPossessive' => true ) );
        }

        $challenge = $response->getChallenge();
        $challengeTitle = $challenge->getTitle();

        return sprintf( $translator->_( "%s posted a response on %s response to " ), $displayFromName, $displayToName, $challengeTitle );
    }

    /**
     * Get the message content for an activity of type 'posted_response_comment'
     *
     * @param Sly_DataObject $activity
     * @return string
     */
    public function getPostedResponseCommentMessage( $activity )
    {
        $formatUser = $this->view->formatUser();
        $loginUser = $this->view->loginUser;
        $translator = $this->view->translator;

        $fromUser = $activity->getFromUser();
        $response = $activity->getObject();

        if ( $loginUser && $loginUser == $fromUser ) {
            $displayFromName = 'You';
        } else {
            $displayFromName = $formatUser->getDisplayName( $fromUser );
        }

        $challenge = $response->getChallenge();
        $challengeTitle = $challenge->getTitle();

        return sprintf( $translator->_( "%s commented on %s" ), $displayFromName, $challengeTitle );
    }

    /**
     * Get the message content for an activity of type 'posted_challenge'
     *
     * @param Sly_DataObject $activity
     * @return string
     */
    public function getPostedChallengeMessage( $activity )
    {
        $formatUser = $this->view->formatUser();
        $loginUser = $this->view->loginUser;
        $translator = $this->view->translator;

        $fromUser = $activity->getFromUser();
        $challenge = $activity->getObject();

        if ( $loginUser && $loginUser == $fromUser ) {
            $displayFromName = 'You';
        } else {
            $displayFromName = $formatUser->getDisplayName( $fromUser );
        }

        $challengeTitle = $challenge->getTitle();

        return sprintf( $translator->_( "%s posted a new challenge, %s" ), $displayFromName, $challengeTitle );
    }

    /**
     * Get the message content for an activity of type 'started_following'
     *
     * @param Sly_DataObject $activity
     * @return string
     */
    public function getStartedFollowingMessage( $activity )
    {
        $formatUser = $this->view->formatUser();
        $loginUser = $this->view->loginUser;
        $translator = $this->view->translator;

        $toUser = $activity->getToUser();
        $fromUser = $activity->getFromUser();

        if ( $loginUser && $loginUser == $fromUser ) {
            $displayFromName = 'You';
        } else {
            $displayFromName = $formatUser->getDisplayName( $fromUser );
        }
        if ( $loginUser && $loginUser == $toUser ) {
            $displayToName = 'you';
        } else {
            $displayToName = $formatUser->getDisplayName( $toUser );
        }

        return sprintf( $translator->_( "%s started following %s" ), $displayFromName, $displayToName );
    }


    /**
     * Get the url to link to based on what the main object in an activity is
     *
     * @param Sly_DataObject $activity
     * @return string
     */
    public function getPrimaryLinkToItem( $activity )
    {
        $object = $activity->getObject();
        $indexUrl = 'response';
        if ( get_class( $object ) == 'BeMaverick_Challenge' ) {
            $indexUrl = 'challenge';
        }
        return $object->getUrl( $indexUrl );
    }

    /**
     * Get extra content for challenge based activities
     *
     * @param Sly_DataObject $activity
     * @return string
     */
    public function getChallengeExtra( $activity )
    {
        return $this->view->formatChallenge()->getImage( $activity->getObject(), array( 'classPrefix' => 'activity-item' ) );
    }

    /**
     * Get extra content for response based activities
     *
     * @param Sly_DataObject $activity
     * @return string
     */
    public function getResponseExtra( $activity )
    {
        $type = $activity->getType();
        $extraContent = array();
        if ( $type == self::ACTIVITY_TYPE_BADGED_RESPONSE ) {
            $badge = $activity->getBadge();
            $extraContent[] = '<div class="badges">'.$this->view->formatUser()->getBadge( null, array( 'badgeType' => strtolower( $badge->getName() ) ) ).'</div>';
        }

        return join( '', $extraContent ).$this->view->formatResponse()->getImage( $activity->getObject(), array( 'classPrefix' => 'activity-item' ) );
    }

    /**
     * Get subject image for response based activities
     *
     * @param Sly_DataObject $response
     * @return string
     */
    public function getResponseImage( $activity )
    {
        $site = $this->view->site;

        $response = $site->getResponse((int)$activity['subjectId']);
        $image = $this->view->formatResponse()->getImage( $response, array( 'classPrefix' => 'activity-item' ) );
        $imageUrl = $response ? $response->getUrl() : '';

        return '<a href="'.$imageUrl.'">'.$image.'</a>';
    }

    /**
     * Get subject image for challenge based activities
     *
     * @param Sly_DataObject $response
     * @return string
     */
    public function getChallengeImage( $activity )
    {
        $site = $this->view->site;

        $challenge = $site->getChallenge((int)$activity['subjectId']);
        $image = $this->view->formatChallenge()->getImage( $challenge, array( 'classPrefix' => 'activity-item' ) );
        $imageUrl = $challenge ? $challenge->getUrl() : '';

        return '<a href="'.$imageUrl.'">'.$image.'</a>';
    }

    /**
     * Get image for user based activities
     *
     * @param Sly_DataObject $response
     * @return string
     */
    public function getUserImage( $user )
    {
        $site = $this->view->site;
        $formatUser = $this->view->formatUser();

        $imageConfig = array(
            'imageHeight' => 128,
            'imageWidth' => 128,
            'imageSize' => 'medium',
            'showMaverickLevel' => false,
            'siteBadges' => $site->getBadges()
        );

        return $formatUser->getProfileImage( $user, $imageConfig );
    }

    /**
     * Get extra content for follow based activities
     *
     * @param Sly_DataObject $activity
     * @return string
     */
    public function getFollowExtra( $activity )
    {
        $loginUser = $this->view->loginUser;
        $toUser = $activity->getToUser();
        $fromUser = $activity->getFromUser();
        if ( $loginUser->isParent() ) {
            return '';
        }

        $user = null;
        if ( $fromUser == $loginUser  ) {
            $user = $fromUser;
        } else if ( $toUser == $loginUser ) {
            $user = $toUser;
        }

        return $this->view->formatUser()->getFollowUnfollowButton( $user );
    }

    /**
     * Get the time since activity occured
     *
     * @param Sly_DataObject $activity
     * @return string
     */
    public function getTimeSince( $activity )
    {
        $timestamp = $activity['timeStamp']/1000;
        return '<div class="time-since">'.$this->view->formatDate()->getSinceTime( $timestamp ).'</div>';
    }

    /**
     * Function to get a formatted activities module
     *
     * @param Sly_DataObject[] $activities
     * @param array $config
     * @return string
     */
    public function getActivitiesModule( $activities, $config = array() )
    {
        $translator = $this->view->translator;

        $formatModule = $this->view->formatModule();

        $configObj = new Sly_DataObject( $config );
        $classPrefixes = $configObj->getClassPrefixes( array( 'mini-module' ) );
        $title = $configObj->getTitle( $translator->_( 'Activity' ) );
        $emptyMessage = $configObj->getEmptyMessage( $translator->_( "There is no activity to display" ) );
        $paginationConfig = $configObj->getPaginationConfig( array() );
        $returnType = $configObj->getReturnType( 'module' ); // module or content

        $config['classPrefixes'] = $classPrefixes;

        $headerContent = array();
        $headerContent[] = $formatModule->getTitleBar(
            array(
                'classPrefixes' => $classPrefixes,
                'title' => $title,
            )
        );

        $activityItems = array();
        foreach( $activities as $activity ) {
            $activityItems[] = $this->getItem( $activity );
        }

        if ( $activityItems ) {
            $defaultConfig = array(
                'link' => false,
                'type' => 'activity-items'
            );
            if ( $paginationConfig ) {
                $activityItems[] = $this->view->itemPagination( $paginationConfig );
            }
            if ( $returnType == 'content' ) {
                return join( '', $activityItems );
            }
            $bodyContent = $this->view->formatUtil()->getObjectWrap( null, '<div class="activity-items__content">'.join( '', $activityItems ).'</div>', array_merge( $defaultConfig, $config ) );
        } else {
            $bodyContent = $this->view->formatUtil()->getEmptyMessage( $emptyMessage, array( 'class' => 'empty-message' ) );
        }

        if ( $returnType == 'content' ) {
            return '';
        }

        return $formatModule->getMiniModule(
            array(
                'headerContent' => join( '', $headerContent ),
                'bodyContent' => $bodyContent ,
                'classPrefixes' => $classPrefixes,
                'attributes' => array(
                    'class' => join( ' ', array() )
                )
            )
        );
    }

    /**
     * Set the view to this object
     *
     * @param Zend_View_Interface $view
     * @return void
     */
    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

    /**
     * The list of all possible activity types
     *
     * @var array
     */
    protected $_activityTypes = array(
        self::ACTIVITY_TYPE_BADGED_RESPONSE,
        self::ACTIVITY_TYPE_POSTED_CHALLENGE,
        self::ACTIVITY_TYPE_POSTED_RESPONSE_COMMENT,
        self::ACTIVITY_TYPE_POSTED_RESPONSE,
        self::ACTIVITY_TYPE_STARTED_FOLLOWING
    );


}
