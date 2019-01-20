<?php
/**
 * Class for formatting challenge objects
 *
 * @category BeMaverick
 * @package  BeMaverick_View_Helper
 */
class BeMaverick_View_Helper_FormatChallenge
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
     * @return BeMaverick_View_Helper_FormatChallenge
     */
    public function formatChallenge()
    {
        return $this;
    }

    /**
     * Utility function to wrap a challenge in markup
     *
     * @param BeMaverick_Challenge $challenge
     * @param string $content
     * @param array $config
     * @return string
     */
    public function getObjectWrap( $challenge, $content, $config = array() )
    {
        $defaultConfig = array(
            'urlIndex' => 'challenge'
        );
        $config = array_merge( $defaultConfig, $config );
        return $this->view->FormatUtil()->getObjectWrap( $challenge, $content, $config );
    }

    /**
     * Get the challenge response cta markup
     *
     * @param BeMaverick_Challenge $challenge
     * @param array $config
     * @return string
     */
    public function getAddResponseCTA( $challenge, $config = array() )
    {
        $loginUser = $this->view->loginUser;
        $translator = $this->view->translator;

        if ( !$loginUser || !$loginUser->isKid() ) {
            return '';
        }


        $defaultConfig = array(
            'type' => 'challenge-add-response-cta',
            'false' => true,
        );

        $content = '<a class="button button--primary" href="'.$challenge->getUrl( 'challengeAddResponse' ).'">'.$translator->_( 'Do your thing!' ).'</a>';

        return $this->view->FormatUtil()->getObjectWrap( $challenge, $content, array_merge( $defaultConfig, $config ) );
    }


    /**
     * Get the challenge video player content markup
     *
     * @param BeMaverick_Challenge $challenge
     * @param array $config
     * @return string
     */
    public function getVideoContent( $challenge, $config = array() )
    {
        if ( !$challenge ) {
            return '';
        }

        $video = $challenge->getVideo();

        $formatVideo = $this->view->formatVideo();

        $player = '<div class="video-wrap media-wrap">'.$formatVideo->getPlayer( $video, $config ).'</div>';
        $addResponseCTA = $this->getAddResponseCTA( $challenge, $config );

        $defaultConfig = array(
            'link' => false,
            'type' => 'media-content'
        );

        if ( $addResponseCTA ) {
            $configObj = new Sly_DataObject( $config );
            $attributes = $configObj->getAttributes( array() );
            $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', 'has-cta' );
        }

        return $this->getObjectWrap( $challenge, $addResponseCTA.$player, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the challenge image content markup
     *
     * @param BeMaverick_Challenge $challenge
     * @param array $config
     * @return string
     */
    public function getImageContent( $challenge, $config = array() )
    {
        if ( !$challenge ) {
            return '';
        }

        $image = $challenge->getImage();
        $imageUrl = '';
        if ( $image ) {
            $resizedImageDimensions = $this->view->formatUtil()->getResizedImageDimensions( $image );
            $imageUrl = $image->getUrl( $resizedImageDimensions['width'], $resizedImageDimensions['height'] );
        }

        $media = '<div class="image-wrap media-wrap"><div class="proxy-img image-wrap__image" data-img-src="'.$imageUrl.'"></div></div>';
        $addResponseCTA = $this->getAddResponseCTA( $challenge, $config );

        $defaultConfig = array(
            'link' => false,
            'type' => 'media-content',
        );

        if ( $addResponseCTA ) {
            $configObj = new Sly_DataObject( $config );
            $attributes = $configObj->getAttributes( array() );
            $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', 'has-cta' );
        }

        return $this->getObjectWrap( $challenge, $addResponseCTA.$media, array_merge( $defaultConfig, $config ) );
    }


    /**
     * Get the challenge image markup
     *
     * @param BeMaverick_Challenge $challenge
     * @param array $config
     * @return string
     */
    public function getImage( $challenge, $config = array() )
    {
        if ( !$challenge ) {
            return '';
        }

        $configObj = new Sly_DataObject( $config );
        $classPrefix = $configObj->getClassPrefix();
        $attributes = $configObj->getAttributes( array() );
        $size = $configObj->getSize( 'medium' );
        $imageType = $configObj->getImageType( 'main' ); // card, main
        $challengeType = $challenge->getChallengeType();

        $defaultConfig = array(
            'link' => false,
            'type' => 'image-wrap'
        );

        $classNames = array(
            'proxy-img'
        );

        $sizeToImageDimensions = array(
            'card' => array(
                'small' => array(
                    'width' => 270,
                    'height' => 180
                ),
                'medium' => array(
                    'width' => 540,
                    'height' => 360
                ),
                'large' => array(
                    'width' => 1080,
                    'height' => 720
                )
            ),
            'main' => array(
                'small' => array(
                    'width' => 270,
                    'height' => 360
                ),
                'medium' => array(
                    'width' => 540,
                    'height' => 720
                ),
                'large' => array(
                    'width' => 1080,
                    'height' => 1440
                )
            )
        );
        $imageUrl = '';
        if ( $imageType == 'card' ) {
            $imageDimensions = isset( $sizeToImageDimensions['card'][$size] ) ? $sizeToImageDimensions['card'][$size] : array( 'width' => null, 'height' => null );
            $cardImage = $challenge->getCardImage();
            $imageUrl = $cardImage ? $cardImage->getUrl( $imageDimensions['width'], $imageDimensions['height'] ) : '';
        } else {
            $image = null;
            if ( $challengeType == 'image' ) {
                $image = $challenge->getImage();
            } else {
                $image = $challenge->getMainImage();
            }
            $imageDimensions = isset( $sizeToImageDimensions['main'][$size] ) ? $sizeToImageDimensions['main'][$size] : array( 'width' => null, 'height' => null );

            $imageUrl = $image ? $image->getUrl( $imageDimensions['width'], $imageDimensions['height'] ) : '';
        }

        $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );
        $config['attributes']['data-img-src'] = $imageUrl;

        return $this->getObjectWrap( $challenge, '', array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the challenge preview item markup
     *
     * @param BeMaverick_Challenge $challenge
     * @param array $config
     * @return string
     */
    public function getPreview( $challenge, $config = array() )
    {
        $site = $this->view->site;

        if ( !$challenge ) {
            return '';
        }

        if(in_array(gettype($challenge), ['string', 'integer'])) {
            $challenge = $site->getChallenge( $challenge );
        }

        $formatUser = $this->view->formatUser();
        $formatUtil = $this->view->formatUtil();
        $loginUser = $this->view->loginUser;

        $user = $challenge->getUser();
        $title = $challenge->getTitle();
        $status= $challenge->getStatus();

        $configObj = new Sly_DataObject( $config );
        $size = $configObj->getSize( 'medium' );
        $imageType = $configObj->getImageType( 'card' );
        $attributes = $configObj->getAttributes( array() );

        $classNames = array(
            'challenge-preview--size-'.$size,
            'challenge--status-'.$status,
            'challenge--image-type-'.$imageType,
            'challenge--id-'.$challenge->getId(),
            'preview-item'
        );

        $wrapConfig = array( 'classPrefix' => 'challenge-preview' );

        $image = $this->getImage( $challenge, array_merge( $config, $wrapConfig ) );
        $displayName = $formatUser->getDisplayName( $user, array_merge( $wrapConfig, array( 'link' => false ) ) );

        $challengeHtml = '
            <div class="challenge-preview__wrap">
                '.$image.'
                <div class="challenge-preview__content-wrap">
                    <a href="'.$challenge->getUrl( 'challenge' ).'" class="challenge-preview__link"></a>
                    <div class="challenge-preview__text-wrap">
                        '.$displayName.'
                        <!--<div class="challenge-preview__title">'.$title.'</div>-->
                    </div>
                </div>

            </div>
        ';

        $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );

        $defaultConfig = array(
            'link' => false,
            'type' => 'challenge-preview'
        );

        return $this->getObjectWrap( $challenge, $challengeHtml, array_merge( $defaultConfig, $config ) );
    }

    public function getStatus( $challenge, $config )
    {
        if ( !$challenge ) {
            return '';
        }

        $status = $challenge->getStatus();

        $endTime = strtotime( $challenge->getEndTime() );
        $now = time();
        $timeLeft = '';

        $timeDiff = '';

        if ( $now < $endTime ) {
            $timeDiff = $this->view->formatUtil()->getTimeLeft( $now, $endTime );
        }

        $defaultConfig = array(
            'link' => false,
            'type' => 'challenge-status',
        );

        return $this->getObjectWrap( $challenge, $timeDiff, array_merge( $defaultConfig, $config ) );
    }

    public function getMediaDescription( $challenge, $config )
    {
        if ( !$challenge ) {
            return '';
        }

        $formatUser = $this->view->formatUser();
        $formatUtil = $this->view->formatUtil();
        $content = array();
        $user = $challenge->getUser();

        $content = array(
            $this->view->formatUser()->getProfileImage( $user, array_merge( $config, array( 'imageSize' => 'medium' ) ) ),
            '<div class="text-wrap">
                '.$formatUser->getDisplayName( $user, array_merge( $config, array() ) ).'
                '.$challenge->getDescription().'
                '.$formatUtil->getTags( $challenge, array_merge( $config, array() ) ).'
            </div>'
        );

        $defaultConfig = array(
            'link' => false,
            'type' => 'media-description',
        );

        return $this->getObjectWrap( $challenge, join( '', $content ), array_merge( $defaultConfig, $config ) );
    }


    /**
     * Get the challenge media text (comments, )
     *
     * @param BeMaverick_Challenge $challenge
     * @param array $config
     * @return string
     */
    public function getMediaText( $challenge, $config = array() )
    {
        if ( !$challenge ) {
            return '';
        }

        $formatUtil = $this->view->formatUtil();

        $defaultConfig = array(
            'link' => false,
            'type' => 'media-text__status',
        );

        $content = array(
            // $this->getStatus( $challenge, $config ),
            $this->getMediaDescription( $challenge, $config ),
        );

        $statusAndDescription = $this->getObjectWrap( $challenge, join( '', $content ), array_merge( $defaultConfig, $config ) );

        $content = array(
            $statusAndDescription,
            $formatUtil->getComments( $challenge, $config, 'challenge' ),
            $formatUtil->getCommentForm( $challenge, array() )
        );

        $defaultConfig = array(
            'link' => false,
            'type' => 'media-text',
        );

        return $this->getObjectWrap( $challenge, join( '', $content ), array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get the challenge media module markup
     *
     * @param BeMaverick_Challenge $challenge
     * @param array $config
     * @return string
     */
    public function getChallengeMediaModule( $challenge, $config = array() )
    {
        $site = $this->view->site;
        $formatUtil = $this->view->formatUtil();
        $formatModule = $this->view->formatModule();
        $loginUser = $this->view->loginUser;

        $configObj = new Sly_DataObject( $config );
        $autoplay = $configObj->getAutoplay( false );

        $title = $challenge->getTitle();

        $moduleClassPrefix = 'challenge-media';
        $typeClassPrefix = 'media-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix
        );

        $valuesConfig = array(
            'classPrefix' => $moduleClassPrefix,
        );

        $headerContent = array(
            '<div>'.$title.'</div>'
        );

        $challengeType = $challenge->getChallengeType();
        if ( $challengeType == 'image' ) {
            $mediaContent = $this->getImageContent( $challenge, $valuesConfig );
        } else {
            $mediaContent = $this->getVideoContent( $challenge, array_merge( $valuesConfig, array( 'autoplay' => $autoplay ) ) );
        }

        $bodyContent = array(
            $mediaContent,
            ( $loginUser ? $this->getMediaText( $challenge, array_merge( $valuesConfig, array() ) ) : $formatUtil->getJoinModule( $challenge ) )
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
     * Function to get a formatted responses module for a challenge
     *
     * @param BeMaverick_Challenge[] $challenges
     * @param array $config
     * @return string
     */
    public function getResponsesModule( $challenge, $config = array() )
    {
        if ( !$challenge ){
            return '';
        }

        $formatResponse = $this->view->formatResponse();
        $translator = $this->view->translator;

        $configObj = new Sly_DataObject( $config );
        $count = $configObj->getCount( 12 );
        $startCount = $configObj->getStartCount( 0 );
        $offset = $configObj->getOffset( 1 );
        $filterBy = $configObj->getFilterBy( array() );
        $sortBy = $configObj->getSortBy( null );
        $title = $configObj->getTitle( $translator->_( 'Responses' ) );
        $includePagination = $configObj->getIncludePagination( false );
        $returnType = $configObj->getReturnType( 'module' );
        $paginationConfig = $configObj->getPaginationConfig( array() );
        $previewsType = $configObj->getPreviewsType( 'basic' );

        if ( $startCount ) {
            $paginationOffset = $startCount + 1;
        } else {
            $paginationOffset = $offset;
            $startCount = $count;
        }

        $moduleClassPrefix = 'challenge-responses';
        $typeClassPrefix = 'mini-module';

        $classPrefixes = array(
            $moduleClassPrefix,
            $typeClassPrefix
        );

        $defaultFilterBy = array(
            'responseStatus' => 'active'
        );

        $filterBy =  array_merge( $defaultFilterBy, $filterBy );

        $responses = $challenge->getResponses(
            $filterBy,
            $sortBy,
            $startCount,
            $offset - 1
        );

        $moduleConfig = array(
            'title' => $title,
            'classPrefixes' => $classPrefixes,
            'returnType' => $returnType,
            'previewsType' => $previewsType
        );

        if ( $includePagination ) {

            $responseCount = $challenge->getResponseCount( $filterBy );
            $defaultPaginationConfig = array(
                'urlIndex' => 'challenge',
                'paginationParams' => array(
                    'challengeId' => $challenge->getId()
                ),
                'linkAttributes' => array(
                    'data-request-name' => 'challenge'
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
     * Function to get a formatted challenges module
     *
     * @param BeMaverick_Challenge[] $challenges
     * @param array $config
     * @return string
     */
    public function getPreviewsModule( $challenges, $config = array() )
    {
        $translator = $this->view->translator;

        $formatModule = $this->view->formatModule();

        $configObj = new Sly_DataObject( $config );
        $classPrefixes = $configObj->getClassPrefixes( array( 'mini-module' ) );
        $title = $configObj->getTitle( $translator->_( 'Challenges' ) );
        $emptyMessage = $configObj->getEmptyMessage( $translator->_( "There are no challenges to display" ) );
        $paginationConfig = $configObj->getPaginationConfig( array() );
        $returnType = $configObj->getReturnType( 'module' ); // module or content
        $previewConfig = $configObj->getPreviewConfig( array() ); // small, medium, large
        $previewsType = $configObj->getPreviewsType( 'basic' );

        $config['classPrefixes'] = $classPrefixes;


        $headerContent = array();
        $headerContent[] = $formatModule->getTitleBar(
            array(
                'classPrefixes' => $classPrefixes,
                'title' => $title,
            )
        );

        $challengePreviews = array();
        foreach( $challenges as $challenge ) {
            $challengePreviews[] = $this->getPreview( $challenge, $previewConfig );
        }

        if ( $challengePreviews ) {
            $defaultConfig = array(
                'link' => false,
                'type' => 'challenge-previews',
                'attributes' => array(
                    'class' => 'preview-items preview-items--'.$previewsType
                )
            );

            if ( $paginationConfig ) {
                $challengePreviews[] = $this->view->itemPagination( $paginationConfig );
            }
            if ( $returnType == 'content' ) {
                return join( '', $challengePreviews );
            }
            $bodyContent = $this->getObjectWrap( null, '<div class="challenge-previews__content preview-items__content">'.join( '', $challengePreviews ).'</div>', array_merge( $defaultConfig, $config ) );
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
