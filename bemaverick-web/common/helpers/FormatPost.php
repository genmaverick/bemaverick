<?php
/**
 * Class for formatting post objects
 *
 * @category BeMaverick
 * @package  BeMaverick_View_Helper
 */
class BeMaverick_View_Helper_FormatPost
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
     * @return BeMaverick_View_Helper_FormatPost
     */
    public function formatPost()
    {
        return $this;
    }

    /**
     * Utility function to wrap a postObj in markup
     *
     * @param Sly_DataObject $postObj
     * @param string $content
     * @param array $config
     * @return string
     */
    public function getObjectWrap( $postObj, $content = '', $config = array() )
    {
        $configObj = new Sly_DataObject( $config );
        $urlIndex = $configObj->getUrlIndex( 'post' );
        $urlParams = $configObj->getUrlParams( array() );
        $defaultUrlParams = array( 'postId' => $postObj->getId() );
        $urlParams = $urlParams ? array_merge( $defaultUrlParams, $urlParams ) : $defaultUrlParams;
        $attributes = $configObj->getAttributes( array() );

        if ( $configObj->getLink() ) {
            $attributes['href'] = isset( $attributes['href'] ) ? $attributes['href'] : $this->view->url( $urlIndex, $urlParams );
        }
        $config['attributes'] = $attributes;

        return $this->view->FormatUtil()->getObjectWrap( $postObj, $content, $config );
    }

    /**
     * get a data object that has processed a wordpress response
     *
     * @param array $postId
     * @param array $postArray
     * @param array $config
     * @return Sly_DataObject
     */
    public function getPostObject( $postId = null, $postArray = array(), $config = array() )
    {
        $site = $this->view->site;
        $formatUtil = $this->view->formatUtil();
        if ( ! $postId && !$postArray  ) {
            return null;
        }
        if ( ! $postArray && $postId ) {
            $postResponse = $site->getPost( $postId );
        } else {
            $postResponse = $postArray;
        }

        $newPost = array();
        foreach( $postResponse as $key => $value ) {
            $key = $formatUtil->camelize( $key );
            if ( is_array( $value ) && isset( $value['rendered'] ) ) {
                $newPost[$key] = $value['rendered'];
            } else {
                $newPost[$key] = $value;
            }
        }

        $configObj = new Sly_DataObject( $config );
        $includeFeaturedMedia = $configObj->getIncludeFeaturedMedia( true );

        if ( $postResponse && $includeFeaturedMedia && isset( $postResponse['featured_media'] ) ) {
            $media = $site->getMedia( $postResponse['featured_media'] );
            $newMedia = array();
            if ( $media ) {
                foreach( $media as $key => $value ) {
                    if ( $key == 'media_details' ) {
                        if ( isset( $value['sizes'] ) ) {
                            foreach( $value['sizes'] as $sizeKey => $sizeValue ) {
                                $sizeKey = $formatUtil->camelize( $sizeKey );
                                $newSizeValue = array();
                                foreach( $sizeValue as $sizeValueKey => $sizeValueValue ) {
                                    $newSizeValue[ $formatUtil->camelize( $sizeValueKey) ] = $sizeValueValue;
                                }
                                $newMedia[$sizeKey] = new Sly_DataObject( $newSizeValue );
                            }
                        }
                    } else if ( is_array( $value ) && isset( $value['rendered'] ) ) {
                        $newMedia[$key] = $value['rendered'];
                    } else {
                        $newMedia[$key] = $value;
                    }
                }
            }
            $newPost['featuredMedia'] = $newMedia ? new Sly_DataObject( $newMedia ) : null;
        }

        $includeAuthor = $configObj->getIncludeAuthor( true );
        if ( $postResponse && $includeAuthor && isset( $postResponse['author'] ) ) {
            $author = $site->getAuthor( $postResponse['author'] );
            $newAuthor = array();
            foreach( $author as $key => $value ) {
                $key = $formatUtil->camelize( $key );
                if ( is_array( $value ) && isset( $value['rendered'] ) ) {
                    $newAuthor[$key] = $value['rendered'];
                } else {
                    $newAuthor[$key] = $value;
                }
            }
            $newPost['author'] = $newAuthor ? new Sly_DataObject( $newAuthor ) : null;
        }

        return new Sly_DataObject( $newPost );
    }

    /**
     * get a wordpress post card
     *
     * @param Sly_DataObject $postObj
     * @param array $config
     * @return string
     */
    public function getCard( $postObj, $config = array() )
    {
        if ( !$postObj ) {
            return '';
        }

        $configObj = new Sly_DataObject( $config );
        $attributes = $configObj->getAttributes( array() );
        $size = $configObj->getSize( 'small' );
        $imageName = $configObj->getImageName( 'portfolioSquare' );

        $classNames = array(
            'post-card--size-'.$size,
            'post-card--size-'.$imageName,
        );

        $wrapConfig = array( 'classPrefix' => 'post-card', 'imageName' => $imageName );
        $image = $this->getFeaturedImage( $postObj, $wrapConfig );

        $title = $this->getObjectWrap(
            $postObj,
            $postObj->getTitle(),
            array_merge(
                $wrapConfig,
                array(
                    'link' => false,
                    'type' => 'title'
                )
            )
        );

        $description = $this->getObjectWrap(
            $postObj,
            strip_tags( $postObj->getExcerpt() ),
            array_merge(
                $wrapConfig,
                array(
                    'link' => false,
                    'type' => 'description'
                )
            )
        );
        $cardHtml = $this->getObjectWrap(
            $postObj,
            '
                <div class="post-card__image-wrap">
                '.$image.'
                </div>
                <div class="post-card__text-wrap">
                    '.$title.'
                    '.$description.'
                </div>
            ',
            array_merge(
                $wrapConfig,
                array(
                    'link' => true,
                    'type' => 'wrap'
                )
            )
        );

        $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );

        $defaultConfig = array(
            'link' => false,
            'type' => 'post-card'
        );

        return $this->getObjectWrap( $postObj, $cardHtml, array_merge( $defaultConfig, $config ) );
    }

    /**
     * Function to get formatted post preview module
     *
     * @param integer $numPosts
     * @param string $title
     * @return string
     */
    public function getPostPreviewModule($numPosts, $title = 'Parental Resources')
    {
        $formatModule = $this->view->formatModule();
        $translator = $this->view->translator;
        $site = $this->view->site;

        $classPrefixes = array(
            'parent-home-latest-resources',
            'mini-module'
        );

        $headerContent = array();
        $headerContent[] = $formatModule->getTitleBar(
            array(
                'classPrefixes' => $classPrefixes,
                'title' => $translator->_( $title ),
                'titleLink' => $this->view->url( 'posts' ),
                'moreTitle' => $translator->_( 'See all' ),
                'moreTitleLink' => $this->view->url( 'posts' )
            )
        );

        $bodyContent = array();

        $cards = array();
        $posts = $site->getPosts( $numPosts, BeMaverick_WordPress::CATEGORY_PARENTAL_RESOURCES );

        if ( $posts ) {
            foreach ( $posts as $post ) {
                $postObj = $this->getPostObject( null, $post );
                if ( !$postObj ) {
                    continue;
                }
                $card = $this->getCard(
                    $postObj,
                    array(
                        'imageName' => 'mediumLarge'
                    )
                );
                if ( $card ) {
                    $cards[] = $card;
                }
            }
        }

        $bodyContent[] = '
            <div class="'.join( ' ', $formatModule->getPrefixedClasses( 'post-cards', $classPrefixes ) ).' post-cards">
            ' .join( '', $cards ). '
            </div>
        ';

        return $formatModule->getMiniModule(
            array(
                'headerContent' => join( '', $headerContent ),
                'bodyContent' => join( '', $bodyContent ),
                'classPrefixes' => $classPrefixes,
                'attributes' => array(
                    'class' => join( ' ', array() )
                )
            )
        );
    }


    /**
     * Get the post image markup
     *
     * @param Sly_DataObject $postObj
     * @param array $config
     * @return string
     */
    public function getFeaturedImage( $postObj, $config = array() )
    {
        if ( !$postObj && ! $postObj->getFeaturedMedia() ) {
            return '';
        }

        $configObj = new Sly_DataObject( $config );
        $classPrefix = $configObj->getClassPrefix();
        $attributes = $configObj->getAttributes( array() );
        $imageName = $configObj->getImageName( 'portfolioSquare' );

        $featuredMedia = $postObj->getFeaturedMedia();

        $defaultConfig = array(
            'link' => false,
            'type' => 'featured-image'
        );

        $classNames = array(
            'proxy-img',
            'image'
        );

        $imageMethod = 'get'.ucfirst( $imageName );
        $mediaImage = $featuredMedia->{$imageMethod}( array() );
        if ( ! $mediaImage ) {
            $mediaImage = $featuredMedia->getMedium( $featuredMedia->getThumbnail() );
        }

        $mediaImageUrl = $mediaImage ? $mediaImage->getSourceUrl() : '';
        $config['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );
        $config['attributes']['data-img-src'] = $mediaImageUrl;

        return $this->getObjectWrap( $postObj, '', array_merge( $defaultConfig, $config ) );
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
