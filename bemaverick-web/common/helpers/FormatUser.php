<?php
/**
 * Class for formatting user objects
 *
 * @category BeMaverick
 * @package  BeMaverick_View_Helper
 */
class BeMaverick_View_Helper_FormatUser
{
    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public $view;

    /**
     * Returns this helper
     *
     * @return BeMaverick_View_Helper_FormatUser
     */
    public function formatUser()
    {
        return $this;
    }

    /**
     * Utility function to wrap a user in markup
     *
     * @param BeMaverick_User $user
     * @param string $content
     * @param array $config
     * @return string
     */
    public function getObjectWrap( $user, $content, $config = array() )
    {
        $defaultConfig = array(
            'urlIndex' => 'user'
        );
        return $this->view->FormatUtil()->getObjectWrap( $user, $content, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the user username markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getUsername( $user, $config = array() )
    {
        $defaultConfig = array(
            'link' => true,
            'type' => 'username'
        );

        $username = $user->getUsername();
        if ( ! trim( $username ) ) {
            return '';
        }

        return $this->getObjectWrap( $user, $username, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the user bio markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getBio( $user, $config = array() )
    {
        $defaultConfig = array(
            'type' => 'bio'
        );

        $bio = $user->getBio();
        // $bio = 'Lorem ipsum 🙈 dolor sit amet, consectetur adipiscing elit, sed do eiusmod. 😂';

        if ( ! trim( $bio ) ) {
            return '';
        }

        return $this->getObjectWrap( $user, $bio, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the follow or unfollow button markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getFollowUnfollowButton( $user, $config = array() )
    {
        if ( !$this->view->loginUser || !$this->view->loginUser->isKid() || !$user || $this->view->loginUser == $user ) {
            return '';
        }
        $translator = $this->view->translator;
        $loginUser = $this->view->loginUser;

        $defaultConfig = array(
            'type' => 'follow-cta'
        );

        $configObj = new Sly_DataObject( $config );
        $attributes = $configObj->getAttributes( array() );

        $isFollowing = $user->isFollowingUser($loginUser);

        $forms[] = '
            <div class="follow">
                <form action="'.$user->getUrl( 'userEditFollowingConfirm' ).'" method="post" data-request-name="userEditFollowingConfirm">
                    <button class="button button--primary-gradient button--follow">'.$translator->_( 'Follow' ).'</button>
                    <input type="hidden" name="followingAction" value="follow">
                    <input type="hidden" name="userId" value="'.$user->getId().'">
                </form>
            </div>
        ';
        $forms[] = '
            <div class="unfollow">
                <form action="'.$user->getUrl( 'userEditFollowingConfirm' ).'" method="post">
                    <button class="button button--primary button--unfollow">'.$translator->_( 'Unfollow' ).'</button>
                    <input type="hidden" name="followingAction" value="unfollow">
                    <input type="hidden" name="userId" value="'.$user->getId().'">
                </form>
            </div>
        ';
        $classNames = array();

        $isFollowingStatus = $isFollowing ? 'true' : 'false';

        $attributes['data-user-id'] = $user->getId();
        $attributes['data-is-following'] = $isFollowingStatus;

        $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );

        return $this->getObjectWrap( $user, join( '', $forms ), array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the user display name - $name if !$name then $username
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getDisplayName( $user, $config = array() )
    {
        $defaultConfig = array(
            'link' => true,
            'type' => 'display-name',
        );

        $name = $user->getName();
        if ( ! trim( $name ) ) {
            $name = $user->getUsername();
        }

        $configObj = new Sly_DataObject( $config );
        if ( $configObj->isPossessive() ) {
            $name .= "'s";
        }

        return $this->getObjectWrap( $user, $name, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the user name markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getName( $user, $config = array() )
    {
        $defaultConfig = array(
            'link' => true,
            'type' => 'name',
        );

        $name = $user->getName();
        if ( ! trim( $name ) ) {
            return '';
        }

        return $this->getObjectWrap( $user, $name, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the correct setting link markup based on user type
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getSettingsLink( $user, $config = array() )
    {
        $defaultConfig = array(
            'link' => true,
            'type' => 'settings-link',
        );

        $loginUser = $this->view->loginUser;
        $isParentOfKid = $loginUser ? $loginUser->isParentOfKid( $user ) : false;
        $isProfileOwner = $loginUser == $user;

        if ( !$isParentOfKid && ! $isProfileOwner ) {
            return '';
        }

        $iconConfig = array(
            'type' => 'settings-link-icon',
        );

        $urlIndex = $isParentOfKid ? 'userParentSettings' : 'userSettings';
        $iconLink = '<a href="'.$user->getUrl( $urlIndex ).'" class="svgicon--gear" data-transition-type="from-left"></a>';

        $html = $this->getObjectWrap( null, $iconLink, array_merge( $iconConfig, $config ) );
        return $this->getObjectWrap( null, $html, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get greeting in the profile markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getProfileIntroGreeting( $user, $config = array() )
    {
        if ( !$user ) {
            return '';
        }

        $defaultConfig = array(
            'link' => false,
            'type' => 'greeting',
        );

        $translator = $this->view->translator;
        $loginUser = $this->view->loginUser;

        $isParentOfKid = $loginUser ? $loginUser->isParentOfKid( $user ) : false;
        $isProfileOwner = $loginUser == $user;

        $greetingText = '';
        if ( $user->isMentor() ) {
            $greetingText = $translator->_( "Hey there, I'm" );
        } else if ( $user->isKid() && ! $isProfileOwner ) {
            $greetingText = $translator->_( "hi, I'm" );
        } else {
            $greetingText = $translator->_( "oh, hey!" );
        }

        return $this->getObjectWrap( $user, $greetingText, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the gradient settings for a marverick badges
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getMaverickGradient( $user, $config = array() )
    {
        $configObj = new Sly_DataObject( $config );
        $site = $this->view->site;
        $badgeCountDetails = $configObj->getBadgeCountDetails( array() );
        $siteBadges = $configObj->getSiteBadges();
        $minSize = $configObj->getBadgeMinSize( 24 );

        if ( ! $siteBadges || ! $minSize ) {
            return '';
        }

        $badgeColors = array(
            'daring' => '#40A382',
            'creative' => '#cda420',
            'unique' => '#6a034c',
            'unstoppable' => '#005870',
        );

        $offset = 5;
        $current = - $offset;
        $total = 0;

        foreach( $siteBadges as $badge ) {
            $scale = isset( $badgeCountDetails['details'] ) && isset( $badgeCountDetails['details'][$badge->getId()] ) ? $badgeCountDetails['details'][$badge->getId()]['scale'] : $minSize;
            $total += $scale;
        }

        $colorSections = array();
        $firstColor = null;
        foreach( $siteBadges as $badge ) {
            $scale = isset( $badgeCountDetails['details'] ) && isset( $badgeCountDetails['details'][$badge->getId()] ) ? $badgeCountDetails['details'][$badge->getId()]['scale'] : $minSize;
            $color = $badgeColors[strtolower($badge->getName())];
            if ( !$firstColor ) {
                $firstColor = $color;
            }
            $numDegrees = $scale / $total * 360;
            $start = $current + $offset;
            $end = $current + $numDegrees;
            $current = $end;
            $colorSections[] = $color .' '.$start.'deg';
            $colorSections[] = $color .' '.$end.'deg';


        }
        $colorSections[] = $firstColor;
        return join( ',', $colorSections );
    }

    /**
     * Get a badge
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getBadge( $user, $config = array() )
    {
        $site = $this->view->site;
        $configObj = new Sly_DataObject( $config );
        $attributes = $configObj->getAttributes( array() );
        $defaultConfig = array(
            'link' => false,
            'type' => 'maverick-badge',
        );

        $badgeTypesToIcons = array(
            'creative' => 'creative',
            'daring' => 'daring',
            'unique' => 'awesome',
            'awesome' => 'unique',
            'unstoppable' => 'unstoppable',
            'funny' => 'funny'
        );

        $badgeType = $config['badgeType'];
        $badgeId = $config['id'];
        $icon = isset( $badgeTypesToIcons[$badgeType] ) ? $badgeTypesToIcons[$badgeType] : '';


        $badgeScale = $configObj->getBadgeScale( null );
        if ( $badgeScale ) {
            $attributes['style'] = 'transform:scale('.$badgeScale.');';
        }

        $config['attributes'] = $this->view->formatUtil()->addItemToAttributes(
            $attributes,
            'class',
            'maverick-badge--'.$badgeType,
            'maverick-badge--id-'.$badgeId
        );

        $badge = $site->getBadge($badgeId);
        $imgUrl = $badge->getPrimaryImageUrl();
        $badge = '<img src="'.$imgUrl.'">';
        return $this->getObjectWrap( $user, $badge, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the badge count details
     *
     * @param array $badgeCounts
     * @param BeMaverick_Badge[] $siteBadges
     * @param integer $minSize
     * @param integer $maxSize
     * @return array
     */
    public function getBadgeCountDetails( $badgeCounts = array(), $siteBadges, $minSize = 10, $maxSize = 40 )
    {
        if ( !$badgeCounts ) {
            return null;
        }
        $total = 0;
        $maxBadgeCount = 0;
        $maxBadgeId = null;
        $minBadgeCount = null;

        $formatUtil = $this->view->formatUtil();

        $badgeCountsById = array();
        foreach( $siteBadges as $badge ) {

            $badgeId = $badge->getId();
            $curBadgeCount = null;
            foreach ( $badgeCounts as $badgeCount ){
                if ( $badgeCount['badge_id'] == $badgeId ) {
                    $curBadgeCount = $badgeCount;
                    break;
                }
            }
            if ( $curBadgeCount ) {
                $badgeCountsById[$badgeId] = $curBadgeCount;
            } else {
                $badgeCountsById[$badgeId] = array(
                    'badge_id' => $badgeId,
                    'count' => 0,
                );
            }
        }

        foreach( $badgeCountsById as $badgeId => $badgeCount ) {
            $total += $badgeCount['count'];
            if ( $badgeCount['count'] > $maxBadgeCount ) {
                $maxBadgeCount = $badgeCount['count'];
                $maxBadgeId = $badgeCount['badge_id'];
            }
            if ( is_null( $minBadgeCount ) || $badgeCount['count'] < $minBadgeCount ) {
                $minBadgeCount = $badgeCount['count'];
            }
        }

        $badgeRatios = array();
        foreach( $badgeCountsById as $badgeId => $badgeCount ) {
            $badgeRatios[ $badgeCount['badge_id'] ] = array_merge(
                $badgeCount,
                array(
                    'ratio' => $total ? $badgeCount['count']/$total : 0,
                    'scale' => $maxBadgeCount ? $formatUtil->rangeFinder( $badgeCount['count'], $minSize, $maxSize, $minBadgeCount, $maxBadgeCount ) : -1
                )
            );
        }

        return array(
            'primaryBadgeId' => $maxBadgeId,
            'details' => $badgeRatios,
            'total' => $total,
            'minBadgeCount' => $minBadgeCount,
            'maxBadgeCount' => $maxBadgeCount,
            'badgeCounts'=>$badgeCountsById
        );
    }

    /**
     * Get badges section on profile
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getBadges( $user, $config )
    {
        if ( !$user || !$user->isKid() ) {
            return '';
        }

        $defaultConfig = array();
        $configObj = new Sly_DataObject( $config );
        $classPrefix = $configObj->getClassPrefix();
        $badges = $configObj->getSiteBadges( array() );

        // get power-bar badge percentages for css
        $badgeCountDetails = $configObj->getBadgeCountDetails( array() );
        $badgeCounts = isset( $badgeCountDetails['badgeCounts'] ) ? $badgeCountDetails['badgeCounts'] : array();
        $totalBadges = isset( $badgeCountDetails['total'] ) ? $badgeCountDetails['total'] : 0;

        foreach ($badgeCounts as $badgeCount) {
            $badgeId = $badgeCount['badge_id'];
            $badgeCounts[$badgeId]['percent'] = $totalBadges ? floor(100 * ($badgeCounts[$badgeId]['count']/$totalBadges) ) : 25;
        }

        $badgeColors = array(
            'creative'=>'#DD9933',
            'unique'=>'#5A175D',
            'awesome'=>'#5A175D',
            'daring'=>'#379155',
            'unstoppable'=>'#186A88',
            'funny'=>'#379155'
        );

        $badgeContent = array();
        $powerBarContent = array();
        foreach( $badges as $badge ) {
            $type = strtolower( $badge->getName() );
            $id = $badge->getId();

            $badgeContent[] = $this->getBadge( $user, array_merge( $defaultConfig, array( 'badgeType' => $type, 'badgeScale' => 1, 'id' => $id ), $config ) );

            $percent = $badgeCounts[$id]['percent'];

            if ($percent > 4) {
                $cssPercent = $percent - 2;
            } elseif ($percent == 0) {
                $cssPercent = 2;
            } else {
                $cssPercent = $percent;
            }

            if (is_nan($percent)) {
                $percent = 0;
            }

            $powerBarContent[] = '
            <div style="width: '.$cssPercent.'%; color: '.$badgeColors[$type].';" class="single-container">
                <div style="background-color: '.$badgeColors[$type].';" class="single"></div>
                <div class="percent">'.$percent.'%</div>
            </div>';
        }
        $classNames = array(
            'badges',
        );

        if ( $classPrefix ) {
            $classNames[] = $classPrefix.'__badges';
        }

        return '
            <div class="'.join( ' ', $classNames ).'">
                '.join( '', $badgeContent ).'
                <div class="power-bar">'.implode($powerBarContent ).'</div>
            </div>
        ';
    }


    /**
     * Get a user profile image markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getProfileImage( $user, $config = array() )
    {
        $configObj = new Sly_DataObject( $config );
        $height = $configObj->getImageHeight( 400 );
        $attributes = $configObj->getAttributes(array());
        $width = $configObj->getImageWidth( 400 );
        $imageSize = $configObj->getImageSize( 'small' );
        $classPrefix = $configObj->getClassPrefix();
        $showMaverickLevel = $configObj->getShowMaverickLevel( false );

        $profileImage = $user->getProfileImage();
        $maverickLevel = '';

        $classNames = array(
            'profile-image--'.$imageSize,
            'profile-image--'.$user->getUserType()
        );

//        if ( $user->isKid() && $showMaverickLevel ) {
//            $maverickLevelClassNames = array(
//                'profile-image-maverick-level'
//            );
//            if ( $classPrefix ) {
//                $maverickLevelClassNames[] = $classPrefix.'__profile-image-maverick-level';
//            }
//
//            $maverickLevel = '<div class="'.join( ' ', $maverickLevelClassNames ).'" data-maverick-level="'.$this->getMaverickGradient( $user, $config ).'"></div>';
//        }

        if ( $profileImage ) {
            $profileImageUrl = $profileImage->getUrl( $width, $height );
            $proxyClassNames = array(
                'proxy-img',
                'profile-image-proxy'
            );
            if ( $classPrefix ) {
                $proxyClassNames[] = $classPrefix.'__profile-image-proxy';
            }
            $classNames[] = 'profile-image--custom';
            $image = '<div class="'.join( ' ', $proxyClassNames ).'" data-img-src="'.$profileImageUrl.'"></div>';

        } else {
            $avatarClassNames = array(
                'profile-image-placeholder',
                'svgicon--profile-default'
            );
            if ( $classPrefix ) {
                $avatarClassNames[] = $classPrefix.'__profile-image-placeholder';
            }
            $classNames[] = 'profile-image--default';
            $image = '<div class="'.join( ' ', $avatarClassNames ).'"></div>';
        }

        $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );

        $defaultConfig = array(
            'link' => true,
            'type' => 'profile-image',
        );

        return $this->getObjectWrap( $user, $image.$maverickLevel, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the follow stats on user profile
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getFollowStats( $user, $config )
    {
        if ( !$user || !$user->isKid() ) {
            return '';
        }
        $translator = $this->view->translator;
        $defaultConfig = array(
            'link' => false,
            'type' => 'follow-stats',
        );


        $textPieces = array();
        $textPieces[] = '
            <a href="'.$user->getUrl( 'userFollowing' ).'">
                <span class="label">'.$translator->_( 'Following' ).'</span>
            </a>
        ';
        $textPieces[] = '
            <a href="'.$user->getUrl( 'userFollowers' ).'">
                <span class="label">'.$translator->_( 'Followers' ).'</span>
            </a>
        ';

        return $this->getObjectWrap(
            $user,
            join( '<span class="delimiter"></span>', $textPieces ),
            array_merge( $defaultConfig, $config )
        );
    }

    /**
     * Get a user display first name if !$firstName - $username
     *
     * @param BeMaverick_User $user
     * @return string
     */
    public function getDisplayFirstName( $user )
    {
        if ( !$user ) {
            return '';
        }
        if ( $user->getFirstName() ) {
            return $user->getFirstName();
        }
        return $user->getUsername();
    }

    /**
     * Get a user's profile cover markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getProfileCover( $user, $config = array() )
    {
        if ( !$user || !$user->isKid() ) {
            return '';
        }
        $site = $this->view->site;
        $loginUser = $this->view->loginUser;

        $defaultConfig = array(
            'type' => 'profile-cover'
        );
        $absoluteConfig = array(
            'link' => false
        );

        $configObj = new Sly_DataObject( $config );
        $attributes = $configObj->getAttributes( array() );
        $classNames = array();
        $styles = array();

        $classNames[] = 'profile-cover--tint-default';

        $coverContent = '';
        $coverImageType = $user->getProfileCoverImageType();
        $coverImageUrl = '';
        if ( $coverImageType ) {
            if ( $coverImageType == 'preset' ) {
                $imageId = $user->getProfileCoverPresetRealImageId();
                if ( $imageId ) {
                    $coverImage = $site->getImage( $imageId );
                }
            } else {
                $coverImage = $user->getProfileCoverImage();
            }
            if ( $coverImage ) {
                $coverImageUrl = $coverImage->getUrl( 600, 600 );
            }
            if ( $coverImageUrl ) {
                $coverContent = '
                    <div class="profile-cover-image">
                        <div class="profile-cover-image-destination proxy-img" data-img-src="'.$coverImageUrl.'"></div>
                    </div>
                ';
            }
        }

        if ( $user->getId() == $loginUser->getId() ) {
            $coverContent .= '<a href="'.$user->getUrl( 'userCover' ).'"><div class="edit-cover">Change Cover</div></a>';
        }

        $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'style', join( ' ', $styles ) );
        $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );
        return $this->getObjectWrap( $user, $coverContent, array_merge( $defaultConfig, $config, $absoluteConfig ) );
    }

    /**
     * Get a user's profile intro module markup
     *
     * @param BeMaverick_User $user
     * @return string
     */
    public function getProfileIntroModule( $user )
    {
        $site = $this->view->site;
        $loginUser = $this->view->loginUser;
        $formatModule = $this->view->formatModule();

        $userType = $user->getUserType();

        $isKidProfile = $userType == 'kid' ? true : false;
        $isMentorProfile = $userType == 'mentor' ? true : false;

        $siteBadges = $site->getBadges();
        $badgeMaxSize = 50;
        $badgeMinSize = 50;

        $moduleClassPrefix = 'user-profile-intro';
        $typeClassPrefix = 'content-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix
        );

        $valuesConfig = array(
            'classPrefix' => $moduleClassPrefix,
            'link' => false,
            'showMaverickLevel' => true,
            'badgeMaxSize' => $badgeMaxSize,
            'badgeMinSize' => $badgeMinSize,
            'siteBadges' => $siteBadges
        );

        if ( $isKidProfile ) {
            $badgeCountDetails = $this->getBadgeCountDetails( $user->getReceivedBadgesCount(), $siteBadges, $badgeMinSize, $badgeMaxSize );
            $valuesConfig['badgeCountDetails'] = $badgeCountDetails;
        }

        $headerContent = array(
            $this->getObjectWrap( null, '', array_merge( array( 'type' => 'header-text-wrap' ), $valuesConfig ) ),
            $this->getProfileCover( $user, $valuesConfig ),
            $this->getProfileImage( $user, array_merge( $valuesConfig, array( 'imageSize' => 'large' ) ) )
        );

        if ( $loginUser->getId() == $user->getId() ) {
            $headerContent[] = '<a class="user-profile-intro__edit-link svgicon--edit"
                href="'.$loginUser->getUrl( 'userProfileEdit' ).'"></a>';
        }

        $kidSelect = null;

        // display select menu if user is parent, viewing kid profile, and has multiple kids
        $isParentOfKid = $loginUser ? $loginUser->isParentOfKid( $user ) : false;

        if ( $isKidProfile && $isParentOfKid && count($loginUser->getKids()) > 1) {
            $kids = $loginUser->getKids();
            $kidOptions = array();

            foreach ($kids as $kid) {
                $kidOptions[] = '<a href="'.$kid->getUrl( "user" ).'">'.$kid->getUsername().'</a>';
            }

            $userName = '
                <div class="username-container">
                    '.$this->getUsername( $user, $valuesConfig ). '
                    <div>
                        <div id="kidselect-icon">
                            <div class="svgicon--person-empty"></div>
                            <div class="svgicon--down-arrow"></div>
                        </div>
                        <div id="kidselect-menu">'.join( '', $kidOptions).'</div>
                        </div>
                </div>';
        }
        else {
            $userName = $this->getUsername( $user, $valuesConfig );
        }

        // display access toggle
        if ( $isKidProfile && $isParentOfKid ) {
            if ($user->getStatus() == 'active') {
                $toggleState = 'toggle-on';
                $toggleText = 'Access On';
                $toggleUrl = $user->getUrl( 'userRevokeAccess' );
            } else {
                $toggleState = 'toggle-off';
                $toggleText = 'Access Off';
                $toggleUrl = $user->getUrl( 'userReinstateAccess' );
            }

            $accessToggle = '
            <div class="access-'.$toggleState.'">
                '.$toggleText.'
                <form action="'.$toggleUrl.'" method="post">
                    <button type="submit">
                        <div class="svgicon--'.$toggleState.'"></div>
                    </button>
                </form>
            </div>
            ';
        } else {
            $accessToggle = '';
        }

        // bodyContent
        $classNames = array();
        if ( $isMentorProfile ) {
            $bodyContent = array(
                $this->getName( $user, $valuesConfig ),
                $this->getBio( $user, $valuesConfig ),
                $this->getFollowStats( $user, $valuesConfig ),
                $this->getFollowUnfollowButton( $user, $valuesConfig )
            );

            $bodyContentBadges = array();

            $classNames[] = 'is-mentor-profile';
        } else if ( $isKidProfile ) {
            $bodyContent = array(
                $userName,
                '<div class="name-container">'.$this->getName( $user, $valuesConfig ).'</div>',
                $kidSelect,
                $accessToggle,
                $this->getBio( $user, $valuesConfig ),
                $this->getFollowStats( $user, $valuesConfig ),
                $this->getFollowUnfollowButton( $user, $valuesConfig )
            );

            $bodyContentBadges = array(
                $this->getBadges( $user, $valuesConfig ),
            );

            $classNames[] = 'is-kid-profile';
        }

        return $formatModule->getModule(
            array(
                'header' => array(
                    'content' => '
                        <div class="'.join( ' ', $formatModule->getPrefixedClasses( 'hd-content', $classPrefixes ) ).'">
                            '.join( '', $headerContent ).'
                        </div>
                    '
                ),
                'body' => array(
                    'content' => '
                        <div class="info-container">
                            <div class="'.join( ' ', $formatModule->getPrefixedClasses( 'bd-content', $classPrefixes ) ).'">
                                '.join( '', $bodyContent ).'
                            </div>
                        </div>
                        <div class="badge-container">
                            <div class="powers-title">MY BADGES</div>
                            '.join( '', $bodyContentBadges ).'
                        </div>
                    '
                ),
                'attributes' => array(
                    'class' => join( ' ', $classNames )
                ),
                'classPrefixes' => $classPrefixes
            )
        );
    }

    /**
     * Get a user's profile detaisl module markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getProfileDetailsModule( $user, $config = array() )
    {
        if ( !$user ) {
            return '';
        }

        $site = $this->view->site;
        $loginUser = $this->view->loginUser;
        $translator = $this->view->translator;
        $formatModule = $this->view->formatModule();
        $formatUtil = $this->view->formatUtil();

        $userType = $user->getUserType();
        $configObj = new Sly_DataObject( $config );

        $profileDetailsTab = $configObj->getUserProfileDetailsTab( 'responses' );

        $isKidProfile = $userType == 'kid' ? true : false;
        $isMentorProfile = $userType == 'mentor' ? true : false;
        $isProfileOwner = $loginUser == $user ? true : false;
        $isParentOfKid = $loginUser ? $loginUser->isParentOfKid( $user ) : false;

        $moduleClassPrefix = 'user-profile-details';
        $typeClassPrefix = 'content-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix
        );

        $valuesConfig = array(
            'classPrefix' => $moduleClassPrefix,
        );

        $tabs = array();
        $classNames = array();

        if ( $isKidProfile && ( $isParentOfKid ) ) {
            $profileDetailsTab = $configObj->getUserProfileDetailsTab( 'overview' );
            $tabs = array(
                'overview' => array(
                    'title' => $translator->_( 'Overview' ),
                    'link' => $user->getUrl( 'user' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
                'activity' => array(
                    'title' => $translator->_( 'Activity' ),
                    'link' => $user->getUrl( 'userActivity' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
                'challenges' => array(
                    'title' => $translator->_( 'Challenges' ),
                    'link' => $user->getUrl( 'userChallenges' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
                'responses' => array(
                    'title' => $translator->_( 'Responses' ),
                    'link' => $user->getUrl( 'userResponses' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
                'badged' => array(
                    'title' => $translator->_( 'Badged' ),
                    'link' => $user->getUrl( 'userBadged' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
            );

            $classNames[] = 'is-profile-parent';

        } else if ( $isKidProfile && ( $isProfileOwner ) ) {
            $profileDetailsTab = $configObj->getUserProfileDetailsTab( 'responses' );
            $tabs = array(
                'activity' => array(
                    'title' => $translator->_( 'Activity' ),
                    'link' => $user->getUrl( 'userActivity' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
                'challenges' => array(
                    'title' => $translator->_( 'Challenges' ),
                    'link' => $user->getUrl( 'userChallenges' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
                'responses' => array(
                    'title' => $translator->_( 'Responses' ),
                    'link' => $user->getUrl( 'userResponses' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
                'badged' => array(
                    'title' => $translator->_( 'Badged' ),
                    'link' => $user->getUrl( 'userBadged' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
            );

            $classNames[] = 'is-profile-owner';
        } else if ( $isKidProfile ) {
            $tabs = array(
                'challenges' => array(
                    'title' => $translator->_( 'Challenges' ),
                    'link' => $user->getUrl( 'user' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
                'responses' => array(
                    'title' => $translator->_( 'Responses' ),
                    'link' => $user->getUrl( 'userResponses' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
                'badged' => array(
                    'title' => $translator->_( 'Badged' ),
                    'link' => $user->getUrl( 'userBadged' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
            );
//            $classNames[] = 'is-kid-profile';
            $classNames[] = 'is-parent-profile';
        } else if ( $isMentorProfile ) {
            $tabs = array(
                'challenges' => array(
                    'title' => $translator->_( 'Challenges' ),
                    'link' => $user->getUrl( 'user' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
                'responses' => array(
                    'title' => $translator->_( 'Posts' ),
                    'link' => $user->getUrl( 'userResponses' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
                'badged' => array(
                    'title' => $translator->_( 'Badged' ),
                    'link' => $user->getUrl( 'userBadged' ),
                    'linkAttributes' => array(
                        'data-request-name' => 'userProfileDetails'
                    )
                ),
            );
            $classNames[] = 'is-mentor-profile';
        }

        if ( count( $tabs ) && !isset( $tabs[$profileDetailsTab] ) ) {
            $profileDetailsTab = key( $tabs );
        }

        $tabConfig = array(
            'selectedIndex' => $profileDetailsTab,
            'classPrefix' => $moduleClassPrefix
        );

        $headerContent = array(
            $formatUtil->getTabs( $tabs, $tabConfig ),
        );

        $bodyContent = array();

        $responsesConfig = array(
            'classPrefix' => $moduleClassPrefix
        );

        if ( $profileDetailsTab == 'overview' ) {
            $bodyContent[] = $this->getProfileOverview( $user, $responsesConfig );
        } else if ( $profileDetailsTab == 'responses' ) {
            $profileResponsesConfig = array(
                'classPrefix' => 'profile-responses',
                'includePagination' => true,
                'paginationConfig' => array(
                    'urlIndex' => 'userResponses',
                ),
                'previewsType' => 'full'
            );
            $profileResponses = $this->getProfileResponses( $user, array_merge( $config, $profileResponsesConfig ) );
            if ( $configObj->getReturnType() == 'content' ) {
                return $profileResponses;
            }
            $bodyContent[] = $profileResponses;
        } else if ( $profileDetailsTab == 'badged' ) {
            $badgedConfig = array(
                'classPrefix' => 'profile-badged',
                'includePagination' => true,
                'paginationConfig' => array(
                    'urlIndex' => 'userBadged',
                ),
                'previewsType' => 'full'
            );
            $profileBadged = $this->getProfileBadged( $user, array_merge( $config, $badgedConfig ) );
            if ( $configObj->getReturnType() == 'content' ) {
                return $profileBadged;
            }
            $bodyContent[] = $profileBadged;
        } else if ( $profileDetailsTab == 'challenges' ) {
            $challengesConfig = array(
                'classPrefix' => 'profile-challenges',
                'includePagination' => true,
                'paginationConfig' => array(
                    'urlIndex' => 'user',
                )
            );
            $profileChallenges = $this->getProfileChallenges( $user, array_merge( $config, $challengesConfig ) );
            if ( $configObj->getReturnType() == 'content' ) {
                return $profileChallenges;
            }
            $bodyContent[] = $profileChallenges;
        } else if ( $profileDetailsTab == 'activity' ) {
            $activitiesConfig = array(
                'classPrefix' => 'profile-activities',
                'includePagination' => true,
                'paginationConfig' => array(
                    'urlIndex' => 'userActivity',
                )
            );
            $profileActivities = $this->getProfileActivities( $user, array_merge( $config, $activitiesConfig ) );
            if ( $configObj->getReturnType() == 'content' ) {
                return $profileActivities;
            }
            $bodyContent[] = $profileActivities;
        }

        $classNames[] = $moduleClassPrefix.'--'.$profileDetailsTab;

        return $formatModule->getModule(
            array(
                'header' => array(
                    'content' => '
                        <div class="'.join( ' ', $formatModule->getPrefixedClasses( 'hd-content', $classPrefixes ) ).'">
                            '.join( '', $headerContent ).'
                        </div>
                    '
                ),
                'body' => array(
                    'content' => '
                        <div class="'.join( ' ', $formatModule->getPrefixedClasses( 'bd-content', $classPrefixes ) ).'">
                            '.join( '', $bodyContent ).'
                        </div>
                    '
                ),
                'attributes' => array(
                    'class' => join( ' ', $classNames )
                ),
                'classPrefixes' => $classPrefixes
            )
        );
    }


    /**
     * Get a user's overview list markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getProfileOverview( $user, $config = array() )
    {
        $contents = array(
            $this->getProfileActivities( $user, array( 'count' => 3 ) ),
            $this->getProfileResponses( $user, array( 'count' => 3, 'previewsType' => 'mini' ) ),
            $this->getProfileBadged( $user, array( 'count' => 3, 'previewsType' => 'mini' ) ),
        );

        return '
            <div>
                '.join( '', $contents ).'
            </div>
        ';
    }

    /**
     * Get a row for a user
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getUserRow( $user, $config = array() )
    {
        $defaultConfig = array(
            'type' => 'user-row'
        );

        $profileImageSettings = array(
            'imageSize' => 'medium',
            'imageWidth' => 100,
            'imageHeight' => 100
        );

        $rowPieces = array(
            $this->getProfileImage( $user, $profileImageSettings ),
            $this->getUsername( $user )
        );

        return $this->getObjectWrap( $user, join( $rowPieces ), array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get a user row list markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getUserRows( $users = array(), $config = array() )
    {
        $defaultConfig = array(
            'type' => 'user-rows'
        );

        $userRows = array();
        foreach ( $users as $user )
        {
            $userRows[] = $this->getUserRow( $user, $config );
        }

        return $this->getObjectWrap( null, join( '', $userRows ), array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get a user's following or followers module markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getUsersModule( $user, $config = array() )
    {
        $site = $this->view->site;
        $translator = $this->view->translator;
        $formatModule = $this->view->formatModule();

        $userType = $user->getUserType();
        $isKidProfile = $userType == 'kid' ? true : false;
        $isMentorProfile = $userType == 'mentor' ? true : false;

        $configObj = new Sly_DataObject( $config );
        $moduleType = $configObj->getModuleType();
        $username = $user->getUsername();

        $emptyMessage = '';
        $title = '';
        $users = array();
        if ( $moduleType == 'followers' ) {
            $title = $translator->_( 'Followers' );
            $users = $user->getFollowerUsers();
            $emptyMessage = $translator->_( 'No followers yet!' );
        } else if ( $moduleType == 'following' ) {
            $title = $translator->_( 'Following' );
            $users = $user->getFollowingUsers();
            $emptyMessage = $translator->_( 'Not following anyone yet!' );
        }

        $moduleClassPrefix = 'users';
        $typeClassPrefix = 'content-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix
        );

        $valuesConfig = array(
            'classPrefix' => $moduleClassPrefix,
            'user' => $user
        );

        $this->view->AddItem( 'popupSettings', $title, 'title' );
        $this->view->AddItem( 'popupSettings', 'users', 'type' );

        $headerContent = array();

        $bodyContent = array();

        if ( count( $users ) ) {
            $bodyContent[] = $this->getUserRows( $users, $valuesConfig );
        } else {
            $bodyContent[] = $this->view->formatUtil()->getEmptyMessage( $emptyMessage, array( 'class' => 'empty-message' ) );
        }
        $classNames = array();

        return $formatModule->getModule(
            array(
                'header' => array(
                    'content' => '
                        <div class="'.join( ' ', $formatModule->getPrefixedClasses( 'hd-content', $classPrefixes ) ).'">
                            '.join( '', $headerContent ).'
                        </div>
                    '
                ),
                'body' => array(
                    'content' => '
                        <div class="'.join( ' ', $formatModule->getPrefixedClasses( 'bd-content', $classPrefixes ) ).'">
                            '.join( '', $bodyContent ).'
                        </div>
                    '
                ),
                'attributes' => array(
                    'class' => join( ' ', $classNames )
                ),
                'classPrefixes' => $classPrefixes
            )
        );
    }

    /**
     * Get a user's edit cover photo module markup
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getEditCoverModule( $user, $config = array() )
    {
        // globals
        $site = $this->view->site;
        $translator = $this->view->translator;
        $formatModule = $this->view->formatModule();
        $formatFormBootstrap = $this->view->formatFormBootstrap2();

        // variables
        $defaultCoverIds = $site->getProfileCoverPresetImageIds();
        $currentCoverImageId = $user->getProfileCoverPresetImageId();

        $defaultCoverImages = array();
        foreach ($defaultCoverIds as $id) {
            $image = $site->getProfileCoverPresetImage( $id );
            $url = $image->getUrl();
            $checked = $id == $currentCoverImageId ? 'checked' : '';

            $defaultCoverImages[] ='
                <div class="carousel-item">
                    <label for="'.$id.'">
                        <input type="radio" name="profileCoverPresetImageId"
                            value="'.$id.'" id="'.$id.'" '.$checked.'>
                        <div class="cover-thumb">
                            <img src="'.$url.'">
                        </div>
                    </label>
                </div>
            ';

        }

        $configObj = new Sly_DataObject( $config );

        $title = $translator->_( 'Change Cover Photo' );

        $moduleClassPrefix = 'edit-cover';
        $typeClassPrefix = 'content-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix
        );


        $this->view->AddItem( 'popupSettings', $title, 'title' );
        $this->view->AddItem( 'popupSettings', 'users', 'type' );

        $headerContent = array();

        $bodyContent = array();
        $bodyContent[] = '
            <form action="'.$user->getUrl( 'userCoverConfirm' ).'" method="post">
                <div class="cover-choices-container carousel">
                    <div class="carousel-wrap">
                        '.implode( $defaultCoverImages ).'
                    </div>
                </div>
                <button class="button button--primary">Save</button>
            </form>
        ';

        $classNames = array();

        return $formatModule->getModule(
            array(
                'header' => array(
                    'content' => '
                        <div class="'.join( ' ', $formatModule->getPrefixedClasses( 'hd-content', $classPrefixes ) ).'">
                            '.join( '', $headerContent ).'
                        </div>
                    '
                ),
                'body' => array(
                    'content' => '
                        <div class="'.join( ' ', $formatModule->getPrefixedClasses( 'bd-content', $classPrefixes ) ).'">
                            '.join( '', $bodyContent ).'
                        </div>
                    '
                ),
                'attributes' => array(
                    'class' => join( ' ', $classNames )
                ),
                'classPrefixes' => $classPrefixes
            )
        );
    }

    /**
     * Function to get a formatted responses module for a user
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getProfileResponses( $user, $config = array() )
    {
        $translator = $this->view->translator;
        $formatResponse = $this->view->formatResponse();
        $loginUser = $this->view->loginUser;

        $configObj = new Sly_DataObject( $config );
        $count = $configObj->getCount( 12 );
        $offset = $configObj->getOffset( 1 );
        $startCount = $configObj->getStartCount( 0 );
        $filterBy = $configObj->getFilterBy( array() );
        $sortBy = $configObj->getSortBy( null );
        $title = $configObj->getTitle( $translator->_( 'Responses' ) );
        $classPrefix = $configObj->getClassPrefix( 'profile-responses' );
        $returnType = $configObj->getReturnType( 'module' );
        $previewsType = $configObj->getPreviewsType( 'basic' );
        $paginationConfig = $configObj->getPaginationConfig( array() );
        $includePagination = $configObj->getIncludePagination( false );

        if ( $startCount ) {
            $paginationOffset = $startCount + 1;
        } else {
            $paginationOffset = $offset;
            $startCount = $count;
        }

        $moduleClassPrefix = $classPrefix;
        $typeClassPrefix = 'mini-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix
        );

        $responses = $user->getResponses(
            $filterBy,
            $sortBy,
            $startCount,
            $offset - 1
        );

        $isMentor = $user->isMentor();
        if ( $user == $loginUser ) {
            if ( $isMentor ) {
                $emptyMessage = $translator->_( 'You have no posts to display' );
            } else {
                $emptyMessage = $translator->_( 'You have no responses to display' );
            }
        } else {
            if ( $isMentor ) {
                $emptyMessage = sprintf( $translator->_( ' %s has no posts to display' ), $user->getUsername() );
            } else {
                $emptyMessage = sprintf( $translator->_( ' %s has no responses to display' ), $user->getUsername() );
            }

        }

        $moduleConfig = array(
            'classPrefixes' => $classPrefixes,
            'title' => $title,
            'emptyMessage' => $emptyMessage,
            'returnType' => $returnType,
            'previewsType' => $previewsType
        );

        if ( $includePagination ) {
            $responseCount = $user->getResponseCount( $filterBy );
            $defaultPaginationConfig = array(
                'urlIndex' => 'user',
                'paginationParams' => array(
                    'userId' => $user->getId()
                ),
                'linkAttributes' => array(
                    'data-request-name' => 'user'
                ),
                'perPage' => $count,
                'offset' => $paginationOffset > $responseCount ? $responseCount : $paginationOffset,
                'totalItems' => $responseCount,
                'hideIfEmpty' => true,
                'hideFirstLast' => true,
                'itemType' => 'items',
                'displayPrefix' => '',
                'unsetIfDefault' => true,
                'containerAttributes' => array(
                    'class' => 'pagination pagination--item pagination--see-more'
                ),
                'labels' => array(
                    '',
                    'Prev',
                    $translator->_( 'See More' ),
                    ''
                )
            );

            $moduleConfig['paginationConfig'] = array_merge( $defaultPaginationConfig, $paginationConfig );
        }

        return $formatResponse->getPreviewsModule( $responses, $moduleConfig );
    }

    /**
     * Function to get a formatted badged module for a user
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getProfileBadged( $user, $config = array() )
    {
        $translator = $this->view->translator;
        $formatResponse = $this->view->formatResponse();
        $loginUser = $this->view->loginUser;

        $configObj = new Sly_DataObject( $config );
        $count = $configObj->getCount( 12 );
        $startCount = $configObj->getStartCount( 0 );
        $offset = $configObj->getOffset( 1 );
        $badgeId = $configObj->getBadgeId( null );
        $sortBy = $configObj->getSortBy( null );
        $title = $configObj->getTitle( $translator->_( 'Badged' ) );
        $classPrefix = $configObj->getClassPrefix( 'profile-badged' );
        $returnType = $configObj->getReturnType( 'module' );
        $paginationConfig = $configObj->getPaginationConfig( array() );
        $includePagination = $configObj->getIncludePagination( false );
        $previewsType = $configObj->getPreviewsType( 'basic' );

        if ( $startCount ) {
            $paginationOffset = $startCount + 1;
        } else {
            $paginationOffset = $offset;
            $startCount = $count;
        }

        $moduleClassPrefix = $classPrefix;
        $typeClassPrefix = 'mini-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix,
        );

        $responses = $user->getBadgedResponses(
            $badgeId,
            $sortBy,
            $startCount,
            $offset - 1
        );

        if ( $user == $loginUser ) {
            $emptyMessage = $translator->_( 'You have no badged content to display' );
        } else {
            $emptyMessage = sprintf( $translator->_( ' %s has no badged content to display' ), $user->getUsername() );
        }

        $moduleConfig = array(
            'classPrefixes' => $classPrefixes,
            'title' => $title,
            'emptyMessage' => $emptyMessage,
            'returnType' => $returnType,
            'previewsType' => $previewsType
        );

        if ( $includePagination ) {
            $responseCount = $user->getBadgedResponseCount( $badgeId );
            $defaultPaginationConfig = array(
                'urlIndex' => 'user',
                'paginationParams' => array(
                    'userId' => $user->getId()
                ),
                'linkAttributes' => array(
                    'data-request-name' => 'user'
                ),
                'perPage' => $count,
                'offset' => $paginationOffset > $responseCount ? $responseCount : $paginationOffset,
                'totalItems' => $responseCount,
                'hideIfEmpty' => true,
                'hideFirstLast' => true,
                'itemType' => 'items',
                'displayPrefix' => '',
                'unsetIfDefault' => true,
                'containerAttributes' => array(
                    'class' => 'pagination pagination--item pagination--see-more'
                ),
                'labels' => array(
                    '',
                    'Prev',
                    $translator->_( 'See More' ),
                    ''
                )
            );

            $moduleConfig['paginationConfig'] = array_merge( $defaultPaginationConfig, $paginationConfig );
        }

        return $formatResponse->getPreviewsModule( $responses, $moduleConfig );
    }

    /**
     * Function to get a formatted saved module for a user
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getProfileSaved( $user, $config = array() )
    {
        $translator = $this->view->translator;
        $formatChallenge = $this->view->formatChallenge();
        $loginUser = $this->view->loginUser;

        $configObj = new Sly_DataObject( $config );
        $count = $configObj->getCount( 12 );
        $startCount = $configObj->getStartCount( 0 );
        $offset = $configObj->getOffset( 1 );
        $title = $configObj->getTitle( $translator->_( 'Saved' ) );
        $classPrefix = $configObj->getClassPrefix( 'profile-saved' );
        $returnType = $configObj->getReturnType( 'module' );
        $paginationConfig = $configObj->getPaginationConfig( array() );
        $includePagination = $configObj->getIncludePagination( false );
        $previewsType = $configObj->getPreviewsType( 'basic' );

        if ( $startCount ) {
            $paginationOffset = $startCount + 1;
        } else {
            $paginationOffset = $offset;
            $startCount = $count;
        }

        $moduleClassPrefix = $classPrefix;
        $typeClassPrefix = 'mini-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix,
        );

        $challenges = $user->getSavedChallenges(
            $startCount,
            $offset - 1
        );

        if ( $user == $loginUser ) {
            $emptyMessage = $translator->_( 'You have no saved challenges to display' );
        } else {
            $emptyMessage = sprintf( $translator->_( ' %s has no saved challenges to display' ), $user->getUsername() );
        }

        $moduleConfig = array(
            'classPrefixes' => $classPrefixes,
            'title' => $title,
            'emptyMessage' => $emptyMessage,
            'returnType' => $returnType,
            'previewsType' => $previewsType
        );

        if ( $includePagination ) {
            $challengeCount = $user->getSavedChallengesCount();
            $defaultPaginationConfig = array(
                'urlIndex' => 'user',
                'paginationParams' => array(
                    'userId' => $user->getId()
                ),
                'linkAttributes' => array(
                    'data-request-name' => 'user'
                ),
                'perPage' => $count,
                'offset' => $paginationOffset > $challengeCount ? $challengeCount : $paginationOffset,
                'totalItems' => $challengeCount,
                'hideIfEmpty' => true,
                'hideFirstLast' => true,
                'itemType' => 'items',
                'displayPrefix' => '',
                'unsetIfDefault' => true,
                'containerAttributes' => array(
                    'class' => 'pagination pagination--item pagination--see-more'
                ),
                'labels' => array(
                    '',
                    'Prev',
                    $translator->_( 'See More' ),
                    ''
                )
            );

            $moduleConfig['paginationConfig'] = array_merge( $defaultPaginationConfig, $paginationConfig );
        }

        return $formatChallenge->getPreviewsModule( $challenges, $moduleConfig );
    }

    /**
     * Function to get a formatted challenges module for a user
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getProfileChallenges( $user, $config = array() )
    {
        $translator = $this->view->translator;
        $formatChallenge = $this->view->formatChallenge();
        $loginUser = $this->view->loginUser;

        $configObj = new Sly_DataObject( $config );
        $count = $configObj->getCount( 12 );
        $offset = $configObj->getOffset( 1 );
        $startCount = $configObj->getStartCount( 0 );
        $filterBy = $configObj->getFilterBy( array() );
        $sortBy = $configObj->getSortBy( null );
        $title = $configObj->getTitle( $translator->_( 'Challenges' ) );
        $classPrefix = $configObj->getClassPrefix( 'profile-challenges' );
        $returnType = $configObj->getReturnType( 'module' );
        $paginationConfig = $configObj->getPaginationConfig( array() );
        $includePagination = $configObj->getIncludePagination( false );

        if ( $startCount ) {
            $paginationOffset = $startCount + 1;
        } else {
            $paginationOffset = $offset;
            $startCount = $count;
        }

        $moduleClassPrefix = $classPrefix;
        $typeClassPrefix = 'mini-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix
        );

        $challenges = $user->getChallenges(
            $filterBy,
            $sortBy,
            $startCount,
            $offset - 1
        );

        if ( $user == $loginUser ) {
            $emptyMessage = $translator->_( 'You have no challenges to display' );
        } else {
            $emptyMessage = sprintf( $translator->_( ' %s has no challenges to display' ), $user->getName() );
        }

        $moduleConfig = array(
            'classPrefixes' => $classPrefixes,
            'title' => $title,
            'emptyMessage' => $emptyMessage,
            'returnType' => $returnType
        );

        if ( $includePagination ) {
            $challengeCount = $user->getChallengeCount( $filterBy );
            $defaultPaginationConfig = array(
                'urlIndex' => 'user',
                'paginationParams' => array(
                    'userId' => $user->getId()
                ),
                'linkAttributes' => array(
                    'data-request-name' => 'user'
                ),
                'perPage' => $count,
                'offset' => $paginationOffset > $challengeCount ? $challengeCount : $paginationOffset,
                'totalItems' => $challengeCount,
                'hideIfEmpty' => true,
                'hideFirstLast' => true,
                'itemType' => 'items',
                'displayPrefix' => '',
                'unsetIfDefault' => true,
                'containerAttributes' => array(
                    'class' => 'pagination pagination--item pagination--see-more'
                ),
                'labels' => array(
                    '',
                    'Prev',
                    $translator->_( 'See More' ),
                    ''
                )
            );

            $moduleConfig['paginationConfig'] = array_merge( $defaultPaginationConfig, $paginationConfig );
        }

        return $formatChallenge->getPreviewsModule( $challenges, $moduleConfig );
    }

    /**
     * Function to get a formatted activities module for a user
     *
     * @param BeMaverick_User $user
     * @param array $config
     * @return string
     */
    public function getProfileActivities( $user, $config = array() )
    {
        $translator = $this->view->translator;
        $formatActivity = $this->view->formatActivity();
        $loginUser = $this->view->loginUser;
        $site = $this->view->site;

        $configObj = new Sly_DataObject( $config );
        $count = $configObj->getCount( 12 );
        $offset = $configObj->getOffset( 1 );
        $startCount = $configObj->getStartCount( 0 );
        $filterBy = $configObj->getFilterBy( array() );
        $sortBy = $configObj->getSortBy( null );
        $title = $configObj->getTitle( $translator->_( 'Activity' ) );
        $classPrefix = $configObj->getClassPrefix( 'profile-activities' );
        $returnType = $configObj->getReturnType( 'module' );
        $paginationConfig = $configObj->getPaginationConfig( array() );
        $includePagination = $configObj->getIncludePagination( false );

        if ( $startCount ) {
            $paginationOffset = $startCount + 1;
        } else {
            $paginationOffset = $offset;
            $startCount = $count;
        }

        $moduleClassPrefix = $classPrefix;
        $typeClassPrefix = 'mini-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix
        );

        $activities = $site->getActivities( $user, $startCount );

        if ( $user == $loginUser ) {
            $emptyMessage = $translator->_( 'You have no activity to display' );
        } else {
            $emptyMessage = sprintf( $translator->_( ' %s has no activity to display' ), $user->getUsername() );
        }

        $moduleConfig = array(
            'classPrefixes' => $classPrefixes,
            'title' => $title,
            'emptyMessage' => $emptyMessage,
            'returnType' => $returnType
        );

        if ( $includePagination ) {
            $activityCount = $site->getActivityCount( $user );
            $defaultPaginationConfig = array(
                'urlIndex' => 'userActivity',
                'paginationParams' => array(
                    'userId' => $user->getId()
                ),
                'linkAttributes' => array(
                    'data-request-name' => 'user'
                ),
                'perPage' => $count,
                'offset' => $paginationOffset > $activityCount ? $activityCount : $paginationOffset,
                'totalItems' => $activityCount,
                'hideIfEmpty' => true,
                'hideFirstLast' => true,
                'itemType' => 'items',
                'displayPrefix' => '',
                'unsetIfDefault' => true,
                'containerAttributes' => array(
                    'class' => 'pagination pagination--item pagination--see-more'
                ),
                'labels' => array(
                    '',
                    'Prev',
                    $translator->_( 'See More' ),
                    ''
                )
            );

            $moduleConfig['paginationConfig'] = array_merge( $defaultPaginationConfig, $paginationConfig );
        }

        return $formatActivity->getActivitiesModule( $activities, $moduleConfig );
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

}
