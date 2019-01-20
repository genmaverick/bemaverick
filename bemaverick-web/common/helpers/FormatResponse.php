<?php
require_once( SLY_ROOT_DIR . '/lib/Sly/DataObject.php' );
/**
 * Class for formatting response objects
 *
 * @category BeMaverick
 * @package  BeMaverick_View_Helper
 */
class BeMaverick_View_Helper_FormatResponse
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
     * @return BeMaverick_View_Helper_FormatResponse
     */
    public function formatResponse()
    {
        return $this;
    }

    /**
     * Utility function to wrap a response in markup
     *
     * @param BeMaverick_Challenge $response
     * @param string $content
     * @param array $config
     * @return string
     */
    public function getObjectWrap( $response, $content, $config = array() )
    {
        $defaultConfig = array(
            'urlIndex' => 'response'
        );
        $config = array_merge( $defaultConfig, $config );
        return $this->view->FormatUtil()->getObjectWrap( $response, $content, $config );
    }


    public function getStatusEditLink( $response, $config )
    {
        $loginUser = $this->view->loginUser;
        $user = $response->getUser();
        $isParentOfKid = $loginUser ? $loginUser->isParentOfKid( $user ) : false;
        if ( !$isParentOfKid ) {
            return;
        }

        $defaultConfig = array(
            'type' => 'response-status-edit-link',
            'link' => false
        );

        $link = '<span data-href="'.$response->getUrl( 'responseStatusEdit' ).'" class="link svgicon--dots"></span>';

        return $this->getObjectWrap( null, $link, array_merge( $defaultConfig, $config ) );
    }

    public function getFlagLink( $response, $config )
    {
        $loginUser = $this->view->loginUser;
        $user = $response->getUser();
        $isParentOfKid = $loginUser ? $loginUser->isParentOfKid( $user ) : false;
        if ( $isParentOfKid || !$loginUser || $user == $loginUser ) {
            return;
        }

        $defaultConfig = array(
            'type' => 'response-flag-link',
            'link' => false
        );

        $link = '<span data-href="'.$response->getUrl( 'responseFlag' ).'" class="svgicon--dots link"></span>';

        return $this->getObjectWrap( null, $link, array_merge( $defaultConfig, $config ) );
    }


    /**
     * Get the tools a parent can perform on a profile - not being used this was menu style
     *
     * @param BeMaverick_Response $response
     * @param array $config
     * @return string
     */
    public function getParentsToolsMenu( $response, $config = array() )
    {
        $formatUser = $this->view->formatUser();
        $loginUser = $this->view->loginUser;


        $user = $response->getUser();
        $isParentOfKid = $loginUser ? $loginUser->isParentOfKid( $user ) : false;
        if ( !$isParentOfKid ) {
            return;
        }

        $configObj = new Sly_DataObject( $config );
        $classPrefix = $configObj->getClassPrefix();
        $attributes = $configObj->getAttributes( array() );

        $defaultConfig = array(
            'link' => false,
            'type' => 'parents-tools'
        );
        $classNames = array(
            'action-menu',
            'custom-hover-click'
        );

        $menuTriggerClassNames = array(
            'svgicon--ellipsis',
            'action-menu-trigger',
        );
        if ( $classPrefix ) {
            $menuTriggerClassNames[] = $classPrefix.'__action-menu-trigger';
            $classNames[] = $classPrefix.'__action-menu';
        }
        $menuTrigger = '<div class="'.join( ' ', $menuTriggerClassNames ).'"></div>';

        $menuClassNames = array(
            'action-menu-menu'
        );
        if ( $classPrefix ) {
            $menuClassNames[] = $classPrefix.'__action-menu-menu';
        }

        $menu = '
            <div class="'.join( ' ', $menuClassNames ).'">
                <div class="action-menu-item action-menu-item--hide-response">
                    <form action="'.$response->getUrl( 'responseStatusEditConfirm' ).'" method="post" data-request-name="responseEditStatusConfirm">
                        <input type="hidden" name="responseStatus" value="hidden">
                        <input type="hidden" name="accessToken" value="'.$accessToken.'">
                        <button type="submit">Hide Response</button>
                    </form>
                </div>
                <div class="action-menu-item action-menu-item--show-response">
                    <form action="'.$response->getUrl( 'responseStatusEditConfirm' ).'" method="post" data-request-name="responseEditStatusConfirm">
                        <input type="hidden" name="responseStatus" value="active">
                        <input type="hidden" name="accessToken" value="'.$accessToken.'">
                        <button type="submit">Show Response</button>
                    </form>
                </div>
            </div>
        ';

        $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );

        return $this->getObjectWrap( null, $menuTrigger.$menu, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the status message for a hidden response
     *
     * @param BeMaverick_Response $response
     * @param array $config
     * @return string
     */
    public function getHiddenStatusMessage( $response, $config = array() )
    {
        $defaultConfig = array(
            'link' => false,
            'type' => 'hidden-status'
        );

        $translator = $this->view->translator;
        $loginUser = $this->view->loginUser;
        if ( !$loginUser ) {
            return '';
        }

        $message = 'This response has been hidden';
        if ( $loginUser->isParent() ) {
            $message = 'This response is hidden';
        }

        $html = '
            <div class="hidden-status-content">
                '.$message.'
            </div>
        ';

        return $this->getObjectWrap( $response, $html, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the response image
     *
     * @param BeMaverick_Response $response
     * @param array $config
     * @return string
     */
    public function getImage( $response, $config = array() )
    {
        if ( !$response ) {
            return '';
        }

        $configObj = new Sly_DataObject( $config );
        $classPrefix = $configObj->getClassPrefix();
        $attributes = $configObj->getAttributes( array() );
        $size = $configObj->getSize( 'small' );

        $defaultConfig = array(
            'link' => false,
            'type' => 'image-wrap'
        );

        $classNames = array(
            'proxy-img'
        );

        $sizeToImageDimensions = array(
            'small' => array(
                'width' => 300,
                'height' => 400
            )
        );

        $imageDimensions = isset( $sizeToImageDimensions[$size] ) ? $sizeToImageDimensions[$size] : array( 'width' => null, 'height' => null );

        $responseType = $response->getResponseType();
        if ( $responseType == 'image' ) {
            $image = $response->getImage();
            $coverImageUrl = $image ? $image->getUrl( $imageDimensions['width'], $imageDimensions['height'] ) : '';
        } else {
            $video = $response->getVideo();
            $coverImageUrl = $video ? $video->getThumbnailUrl( $imageDimensions['width'], $imageDimensions['height'] ) : '';
        }

        $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );
        $config['attributes']['data-img-src'] = $coverImageUrl;

        return $this->getObjectWrap( $response, '', array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the response preview item
     *
     * @param BeMaverick_Response $response
     * @param array $config
     * @return string
     */
    public function getPreview( $response, $config = array() )
    {
        if ( !$response ) {
            return '';
        }

        $site = $this->view->site;
        $formatUser = $this->view->formatUser();
        $formatUtil = $this->view->formatUtil();
        $loginUser = $this->view->loginUser;
        $challenge = $response->getChallenge();
        $user = $response->getUser();
        $title = $challenge ? $challenge->getTitle() : '';
        $configObj = new Sly_DataObject( $config );
        $status = $response->getStatus();

        if ( $status == 'inactive' && ( !$loginUser || ( $loginUser != $user && !$loginUser->isParentOfKid( $user ) ) ) ) {
            return '';
        }

        $attributes = $configObj->getAttributes( array() );
        $size = $configObj->getSize( 'small' );

        $classNames = array(
            'response-preview--size-'.$size,
            'preview-item'
        );

        $attributes['data-response-id'] = $response->getId();
        $attributes['data-response-status'] = $status;

        $wrapConfig = array( 'classPrefix' => 'response-preview' );

        $image = $this->getImage( $response, $wrapConfig );

        $userImageConfig = array_merge( $wrapConfig, array( 'imageWidth' => 128, 'imageHeight' => 128, 'showMaverickLevel' => false ) );
        $userImage = ''; // $formatUser->getProfileImage( $user, $userImageConfig );

        $displayName = $formatUser->getDisplayName( $user, array_merge( $wrapConfig, array( 'link' => false ) ) );
        $actionLink = $this->getStatusEditLink( $response, $wrapConfig );

        if ( ! $actionLink && $user != $loginUser ) {
            $actionLink = $this->getFlagLink( $response, $wrapConfig );
        }

        $hiddenStatus = $this->getHiddenStatusMessage( $response, $wrapConfig );

        $tags = $formatUtil->getTags( $response, $userImageConfig );

        // marker for response favorited by challenge owner
        $favoriteResponse = '';
        if ($response->isFavorited()) {
            $imgUrl = $site->getAWSImageUrl('favorite-response-corner.png', 'app/icons');
            $favoriteResponse = '<img class="response-preview_favorite-response" src="'.$imgUrl.'">';
        }

        $responseHtml = '
            <div class="response-preview__wrap">
                '.$image.'
                <div class="response-preview__content-wrap">
                    <a href="'.$response->getUrl( 'response' ).'" class="response-preview__link"></a>
                    <div class="response-preview__text-wrap">
                        '.$displayName.'
                        '.$tags.'
                    </div>
                    '.$hiddenStatus.'
                    '.$userImage.'
                    '.$actionLink.'
                </div>
                '.$favoriteResponse.'
            </div>
        ';

        $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );

        $defaultConfig = array(
            'link' => false,
            'type' => 'response-preview'
        );

        return $this->getObjectWrap( $response, $responseHtml, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the response video content player
     *
     * @param BeMaverick_Response $response
     * @param array $config
     * @return string
     */
    public function getVideoContent( $response, $config = array() )
    {
        if ( !$response ) {
            return '';
        }

        $video = $response->getVideo();

        $formatVideo = $this->view->formatVideo();

        $player = '<div class="media-wrap video-wrap">'.$formatVideo->getPlayer( $video, $config ).'</div>';
        $badger = $this->getBadger( $response, $config );
        $defaultConfig = array(
            'link' => false,
            'type' => 'media-content',
        );
        return $this->getObjectWrap( $response, $badger.$player, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the response image content
     *
     * @param BeMaverick_Response $response
     * @param array $config
     * @return string
     */
    public function getImageContent( $response, $config = array() )
    {
        if ( !$response ) {
            return '';
        }

        $image = $response->getImage();
        $imageUrl = '';
        if ( $image ) {
            $resizedImageDimensions = $this->view->formatUtil()->getResizedImageDimensions( $image );
            $imageUrl = $image->getUrl( $resizedImageDimensions['width'], $resizedImageDimensions['height'] );
        }
        $player = '<div class="image-wrap media-wrap"><div class="proxy-img image-wrap__image" data-img-src="'.$imageUrl.'"></div></div>';
        $badger = $this->getBadger( $response, $config );
        $defaultConfig = array(
            'link' => false,
            'type' => 'media-content',
        );
        return $this->getObjectWrap( $response, $badger.$player, array_merge( $defaultConfig, $config ) );
    }



    public function getMediaDescription( $response, $config )
    {
        if ( !$response ) {
            return '';
        }

        $site = $this->view->site;
        $formatUser = $this->view->formatUser();
        $formatUtil = $this->view->formatUtil();
        $content = array();
        $user = $response->getUser();


        // marker for response favorited by challenge owner
        $favoriteResponse = '';
        if ($response->isFavorited()) {
            $imgUrl = $site->getAwsImageUrl('favorite-response-circle.png', 'app/icons');
            $favoriteResponse = '<div class="favorite-response"><img class="favorite-image" src="'.$imgUrl.'">CHALLENGER FAV</div>';
        }

        $content = array(
            $favoriteResponse,
            '<div class="info-container">'
                .$this->view->formatUser()->getProfileImage( $user, array_merge( $config, array( 'imageSize' => 'medium' ) ) ).
                '<div class="text-wrap">
                    '.$formatUser->getDisplayName( $user, array_merge( $config, array() ) ).'
                    '.$response->getDescription().'
                    '.$formatUtil->getTags( $response, array_merge( $config, array() ) ).'
                </div>
            </div>'
        );

        $defaultConfig = array(
            'link' => false,
            'type' => 'media-description',
        );

        return $this->getObjectWrap( $response, join( '', $content ), array_merge( $defaultConfig, $config ) );
    }

    public function getBadger( $response, $config = array() )
    {
        if ( !$response ) {
            return;
        }
        $site = $this->view->site;
        $loginUser = $this->view->loginUser;

        $configObj = new Sly_DataObject( $config );
        $wrap = $configObj->getWrap( true );
        $userCanViewBadgeDetails = $loginUser && $loginUser->isKid();
        if ( !$userCanViewBadgeDetails ) {
            return;
        }

        $canVote = true;
        $siteBadges = $site->getBadges('active');
        $givenResponseBadgeIds = $loginUser->getGivenResponseBadgeIds( $response );

        $classNames = array(
            'badger__content',
            'response-badger__content'
        );
        $badgeCountDetails = array();

        $total = 0;
        $maxUsers = 0;
        $maxBadgeId = null;
        foreach( $siteBadges as $badge ) {
            $badgeId = $badge->getId();
            $numUsers = $response->getBadgeUserCount( $badge );
            $total += $numUsers;
            $badgeCountDetails[$badgeId] = $numUsers;
            if ( $numUsers > $maxUsers ) {
                $maxBadgeId = $badgeId;
                $maxUsers = $numUsers;
            }
        }
        $votedBadgeId = null;
        if ( !$canVote && $maxBadgeId ) {
            $classNames[] = 'voted';
            $votedBadgeId = $maxBadgeId;
        } else if ( $canVote && $givenResponseBadgeIds ) {
            $classNames[] = 'voted';
            $votedBadgeId = $givenResponseBadgeIds[0];
        }
        if ( $votedBadgeId ) {
            $votedBadge = $site->getBadge( $votedBadgeId );
            $votedBadgeType = strtolower( $votedBadge->getName() );
            $classNames[] = 'voted--'.$votedBadgeType;
        }



        $badgeButtons = array();
        foreach( $siteBadges as $i => $badge ) {
            $type = strtolower( $badge->getName() );
            $badgeId = $badge->getId();
            $isMax = $badgeId == $maxBadgeId;
            $percent = $total ? floor( $badgeCountDetails[$badgeId] / $total  * 100 ).'%' : '0%';
            $form = $canVote ? '
                <form data-request-name="responseEditBadgeConfirm" method="post" action="'.$response->getUrl( 'responseEditBadgeConfirm' ).'">
                    <input type="hidden" value="'.$badgeId.'" name="badgeId">
                </form>
            ' : '';
            $badgeButtons[] = '
                <div
                    class="badge badge--id-'.$badgeId.' badge--num-'.($i+1).' badge--'.$type.' response-badger__badge response-badger__badge--'.$type.'"
                >
                    '.$form.'
                    <div class="badge__percent'.( $isMax ? ' badge__percent--max' : '').'">'.$percent.'</div>
                </div>
            ';
        }

        $defaultConfig = array(
            'link' => false,
            'type' => 'response-badger',
            'attributes' => array(
                'class' => 'badger badger--response-'.$response->getId()
            )
        );

        $content = '
            <div class="'.join( ' ', $classNames ).'">
                <div class="response-badger__trigger badger__trigger"></div>
                <div class="response-badger__menu badger__menu">
                    '.join( '', $badgeButtons ).'
                </div>
            </div>
        ';

        if ( ! $wrap ) {
            return $content;
        }
        return $this->getObjectWrap( $response, $content, array_merge( $defaultConfig, $config ) );
    }


    /**
     * Get the response media text (comments)
     *
     * @param BeMaverick_Response $response
     * @param array $config
     * @return string
     */
    public function getMediaText( $response, $config = array() )
    {
        if ( !$response ) {
            return '';
        }

        $formatUtil = $this->view->formatUtil();

        $defaultConfig = array(
            'link' => false,
            'type' => 'media-text__status',
        );

        $content = array(
            $this->getMediaDescription( $response, $config ),
        );

        $statusAndDescription = $this->getObjectWrap( $response, join( '', $content ), array_merge( $defaultConfig, $config ) );

        $content = array(
            $statusAndDescription,
            $formatUtil->getComments( $response, $config, 'response' ),
            $formatUtil->getCommentForm( $response, array() )
        );

        $defaultConfig = array(
            'link' => false,
            'type' => 'media-text',
        );

        return $this->getObjectWrap( $response, join( '', $content ), array_merge( $defaultConfig, $config ) );
    }


    /**
     * Get the response media module
     *
     * @param BeMaverick_Response $response
     * @param array $config
     * @return string
     */
    public function getResponseMediaModule( $response, $config = array() )
    {
        $site = $this->view->site;
        $formatModule = $this->view->formatModule();
        $formatUtil = $this->view->formatUtil();
        $loginUser = $this->view->loginUser;

        $configObj = new Sly_DataObject( $config );
        $autoplay = $configObj->getAutoplay( false );

        $challenge = $response->getChallenge();
        $title = $challenge ? $challenge->getTitle() : $response->getTitle();
        $isPublic = $response->isPublic();

        $moduleClassPrefix = 'response-media';
        $typeClassPrefix = 'media-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix
        );

        $valuesConfig = array(
            'classPrefix' => $moduleClassPrefix,
        );

        if ( $challenge ) {
            $headerContent = array(
                '<div><a href="'.$challenge->getUrl( 'challenge' ).'">'.$title.'</a></div>'
            );
        } else {
            $headerContent = array(
                '<div>'.$title.'</div>'
            );
        }

        $responseType = $response->getResponseType();
        if ( $isPublic || $loginUser ) {
            if ( $responseType == 'image' ) {
                $mediaContent = $this->getImageContent( $response, $valuesConfig );
            } else {
                $mediaContent = $this->getVideoContent( $response, array_merge( $valuesConfig, array( 'autoplay' => $autoplay ) ) );
            }
        } else {
            $mediaContent = '';
        }

        $bodyContent = array(
            $mediaContent,
            ( $loginUser ? $this->getMediaText( $response, array_merge( $valuesConfig, array() ) ) : $formatUtil->getJoinModule( $response ) )
        );

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
     * Function to get a formatted responses module
     *
     * @param BeMaverick_Response[] $responses
     * @param array $config
     * @return string
     */
    public function getPreviewsModule( $responses, $config = array() )
    {
        $translator = $this->view->translator;

        $formatModule = $this->view->formatModule();

        $configObj = new Sly_DataObject( $config );
        $classPrefixes = $configObj->getClassPrefixes( array( 'mini-module' ) );
        $title = $configObj->getTitle( $translator->_( 'Responses' ) );
        $emptyMessage = $configObj->getEmptyMessage( $translator->_( "There are no responses to display" ) );
        $paginationConfig = $configObj->getPaginationConfig( array() );
        $returnType = $configObj->getReturnType( 'module' ); // module or content
        $previewsType = $configObj->getPreviewsType( 'basic' ); // basic, full, mini

        $config['classPrefixes'] = $classPrefixes;
        $headerContent = array();
        $headerContent[] = $formatModule->getTitleBar(
            array(
                'classPrefixes' => $classPrefixes,
                'title' => $title,
            )
        );

        $responsePreviews = array();
        foreach( $responses as $response ) {
            $responsePreviews[] = $this->getPreview( $response );
        }

        if ( $responsePreviews ) {
            $defaultConfig = array(
                'link' => false,
                'type' => 'response-previews',
                'attributes' => array(
                    'class' => 'preview-items preview-items--'.$previewsType
                )
            );

            if ( $paginationConfig ) {
                $responsePreviews[] = $this->view->itemPagination( $paginationConfig );
            }
            if ( $returnType == 'content' ) {
                return join( '', $responsePreviews );
            }
            $bodyContent = $this->getObjectWrap( null, '<div class="response-previews__content preview-items__content">'.join( '', $responsePreviews ).'</div>', array_merge( $defaultConfig, $config ) );
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

}
