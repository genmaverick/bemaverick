<?php
require_once( SLY_ROOT_DIR . '/lib/Sly/View/Helper/FormatUtil.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/DataObject.php' );

class BeMaverick_View_Helper_FormatUtil extends Sly_View_Helper_FormatUtil
{

    /**
     * get some formatting settings
     *
     * @param string $setting
     * @return array|null
     */
    public function getSetting( $setting )
    {
        $settings = array(
            'button-options' => array( 'className' => 'button', 'classDelimiter' => '--' )
        );

        if ( isset( $settings[$setting] ) ) {
            return $settings[$setting];
        }
        return null;
    }

    /**
     * get the markup for a popup
     *
     * @param array $attributes
     * @return string
     */
    public function getPopupWrap( $attributes = array() )
    {
        $htmlElement = $this->view->htmlElement();
        $attributes = new Sly_DataObject( $attributes );
        //set config properties
        $header  = $attributes->getHeader();        //header content - goes in 'popup-hd'
        $title   = $attributes->getTitle();         //title - wraps by h4 goes in 'popup-hd'
        $content = $attributes->getContent();       //content - bd content
        $footer  = $attributes->getFooter();        //footer - popup-ft content
        $type    = $attributes->getType( 'confirm' ); //type - type of popup - default to confirm
        $form    = $attributes->getForm();
        $wrapButton    = $attributes->getWrapButton();          //form - form attributes to wrap everything in
        $closeUrl = $attributes->getCloseUrl();
        $closeTracking = $attributes->getCloseTracking();
        $closeMaskTracking = $attributes->getCloseMaskTracking();
        //create the content html
        $html = array();
        $closeButton = '<a href="#" class="close pass"><span class="svgicon--ex"></span></a>';
        if ( $wrapButton ) {
            $closeButton = '<span class="btn-wrap"><a href="#" class="btn close pass"><span class="svgicon--ex"></span></a></span>';
        }
        $html[] = '<div class="popup-hd">'.$closeButton;
        if ( $title ) {
            $html[] = '<h4>'.$title.'</h4>';
        }
        if ( $header ) {
            $html[] = $header;
        }
        $html[] = '</div>';
        $html[] = '<div class="popup-bd">';
        if ( $content ) {
            $html[] = $content;
        }
        $html[] = '</div>';

        if ( $footer )  {
            $html[] = '<div class="popup-ft">';
            $html[] = $footer;
            $html[] = '</div>';
        }

        //wrap in a form if necessary - put that form inside the popup-wrap
        $content = array();
        $content[] = '<div class="popup-wrap popup-wrap--'.$type.'" data-close-url="'.$closeUrl.'" data-link-track-google=\''.$closeTracking.'\'" data-close-mask-tracking=\''.$closeMaskTracking.'\'>';
        $content[] = '<div class="popup-content">';
        if ( $form ) {
            if ( !$this->view->ajax && isset( $form['data-request-name'] ) ) {
                unset( $form['data-request-name'] );
            }
            $content[] = $htmlElement->getContainingTag( 'form', join( '', $html ), $form );
        } else {
            $content[] = join( '', $html );
        }
        $content[] = '</div>';
        $content[] = '</div>';
        return join( '', $content );
    }

    /**
     * get the markup for tabs
     *
     * @param array[] $items
     * @param array $config
     * @return string
     */
    public function getTabs( $items, $config = array() )
    {
        if ( !$items ) {
            return '';
        }

        $configObj = new Sly_DataObject( $config );
        $classPrefix = $configObj->getClassPrefix( '' );
        $selectedIndex = $configObj->getSelectedIndex( '' );
        $attributes = $configObj->getAttributes( array() );

        $type = $configObj->getTabType( 'maverick' );
        $classNames = array(
            $type.'-tabs'
        );
        if ( $classPrefix ) {
            $classNames[] = $classPrefix.'--'.$type.'-tabs';
        }
        $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );

        foreach( $items as $index => $item ) {

            $itemAttributes = isset( $item['itemAttributes'] ) ? $item['itemAttributes'] : array();
            $item['itemAttributes'] = $this->view->formatUtil()->addItemToAttributes( $itemAttributes, 'class', 'maverick-tab' );
            $items[$index] = $item;

        }

        return '
            <div '.$this->view->htmlAttributes( $attributes ).'>
                '.$this->view->linkList( $items, array( 'selected' => $selectedIndex, 'attributes' => array( 'class' => $type.'-tabs__container' ) ) ).'
            </div>
        ';
    }

    /**
     * Utility to wrap objects in prefixed markup or links
     *
     * @param object $obj
     * @param string $content
     * @param array $config
     * @return string
     */
    public function getObjectWrap( $obj, $content, $config = array() )
    {
        $configObj = new Sly_DataObject( $config );

        $attributes = $configObj->getAttributes( array() );
        $link = $configObj->getLink( false );
        $urlIndex = $configObj->getUrlIndex( '' );
        $urlParams = $configObj->getUrlParams( array() );
        $urlObject = $configObj->getUrlObj( $obj );
        $classPrefix = $configObj->getClassPrefix( '' );
        $type = $configObj->getType( '' );
        $tag = 'div';

        $classNames = array();

        if ( $classPrefix && $type ) {
            $classNames[] = $classPrefix.'__'.$type;
        }
        if ( $type ) {
            $classNames[] = $type;
        }

        if ( $classNames ) {
            $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $classNames ) );
        }

        if ( $link && $urlObject && $urlIndex && !isset( $attributes['href'] ) ) {
            $tag = 'a';
            $attributes['href'] = $urlObject->getUrl( $urlIndex, $urlParams );
        } else if ( $link && isset( $attributes['href'] ) ) {
            $tag = 'a';
        }

        return '
            <'.$tag.' '.$this->view->htmlAttributes( $attributes ).'>
                '.$content.'
            </'.$tag.'>
        ';
    }

    /**
     * transform a hex color to rgba format, 3,6,or 8 format with or without #
     *
     * @param string $color
     * @return array
     */
    public function getRGBAfromHex( $color )
    {
        $color = str_replace( '#', '', $color );
        switch ( strlen( $color ) ) {
            case 3;
                list( $r, $g, $b ) = sscanf( $color, "%1s%1s%1s" );
                return [ hexdec( "$r$r" ), hexdec( "$g$g" ), hexdec( "$b$b" ), 1 ];
            case 6;
                return array_merge( array_map( 'hexdec', sscanf( $color, "%2s%2s%2s" ) ), array( 1 ) );
            case 8;
                $hexes = array_map( 'hexdec', sscanf( $color, "%2s%2s%2s%2s" ) );
                $hexes[3] = $hexes[3]/255;
                return $hexes;
            default:
                return array();
        }
    }

    /**
     * find where x should fall on a new range
     *
     * @param number $x
     * @param number $newMin
     * @param number $newMax
     * @param number $oldMin
     * @param number $oldMax
     * @return number
     */
    public function rangeFinder( $x, $newMin, $newMax, $oldMin, $oldMax)
    {
        return $newMin + (($x-$oldMin)*($newMax-$newMin)/($oldMax-$oldMin));
    }


    /**
     * get tags from an object that has a getTags method
     *
     * @param object $obj
     * @param array $config
     * @return string
     */
    public function getTags( $obj, $config = array() )
    {
        $defaultConfig = array(
            'link' => false,
            'type' => 'tags'
        );

        $tags = $obj->getTags();
        $tagList = array();
        $tagConfig = array(
            'link' => false,
            'type' => 'tag'
        );

        foreach( $tags as $tag ) {
            $tagName = trim( str_replace( '#', '', $tag->getName() ) );
            $subTags = explode( ' ', $tagName );
            foreach( $subTags as $tagName ) {
                $tagList[] = $this->getObjectWrap( $tag, '#'.$tagName, array_merge( $tagConfig, $config ) );
            }
        }

        return $this->getObjectWrap( $obj, join( '', $tagList ), array_merge( $defaultConfig, $config ) );
    }

    /**
     * markup for a back link
     *
     * @param string $link
     * @param string $title
     * @param string $transitionType
     * @return string
     */
    public function getReturnLink( $link, $title = '', $transitionType = '' )
    {
        if ( !$link ) {
            return '';
        }

        $titleHtml = $title ? '<div class="return-link__text"></div>' : '';
        return '
            <div class="return-link">
                <a class="return-link__link" href="'.$link.'" data-transition-type="'.$transitionType.'">
                    <div class="svgicon--caret return-link__icon"></div>
                    '.$title.'
                </a>
            </div>
        ';
    }


    public function camelize( $str, $noStrip = array())
    {
        // non-alpha and non-numeric characters become spaces
        $str = preg_replace('/[^a-z0-9' . implode("", $noStrip) . ']+/i', ' ', $str);
        $str = trim($str);
        // uppercase the first character of each word
        $str = ucwords($str);
        $str = str_replace(" ", "", $str);
        $str = lcfirst($str);

        return $str;
    }


    public function getTimeLeft( $time1, $time2, $wrap = true )
    {
        if ( $time1 > $time2 ) {
            return '';
        }

        $translator = $this->view->translator;

        $labels = array(
            'y' => array(
                $translator->_( '%s%s%s %syears%s' ),
                $translator->_( '%s%s%s %syear%s' )
            ),
            'f' => array(
                $translator->_( '%s%s%s %smonths%s' ),
                $translator->_( '%s%s%s %smonth%s' )
            ),
            'w' => array(
                $translator->_( '%s%s%s %sweeks%s' ),
                $translator->_( '%s%s%s %sweek%s' )
            ),
            'd' => array(
                $translator->_( '%s%s%s %sdays%s' ),
                $translator->_( '%s%s%s %sday%s' )
            ),
            'h' => array(
                $translator->_( '%s%s%s %shours%s' ),
                $translator->_( '%s%s%s %shour%s' )
            ),
            'm' => array(
                $translator->_( '%s%s%s %sminutes%s' ),
                $translator->_( '%s%s%s %sminute%s' )
            ),
            's' => array(
                $translator->_( '%s%s%s %sseconds%s' ),
                $translator->_( '%s%s%s %ssecond%s' )
            )
        );

        $timeDiff = $this->view->formatDate()->timeDiff( $time1, $time2, 'dhms' );

        $timeString = array();
        foreach ( $timeDiff as $valueToUse => $value ) {
            if ( !$value ) {
                continue;
            }
            $wrapValueStart = $wrap ? '<div class="time-left__item-value time-left__item-value--'.$valueToUse.'">' : '';
            $wrapValueEnd = $wrap ? '</div>' : '';

            $wrapLabelStart = $wrap ? '<div class="time-left__item-label time-left__item-label--'.$valueToUse.'">' : '';
            $wrapLabelEnd = $wrap ? '</div>' : '';

            $secondsLeft = $time2 - $time1;

            $wrapItemStart = $wrap ? '<div class="time-left__item">' : '';
            $wrapItemEnd = $wrap ? '</div>' : '';

            $label = isset( $labels[$valueToUse][$value] ) ? $labels[$valueToUse][$value] : $labels[$valueToUse][0];
            $timePieces[] = $wrapItemStart.sprintf( $label, $wrapValueStart, $value, $wrapValueEnd, $wrapLabelStart, $wrapLabelEnd ).$wrapItemEnd;
        }
        $wrapStart = $wrap ? '<div class="time-left" data-seconds-left="'.$secondsLeft.'">' : '';
        $wrapEnd = $wrap ? '</div>' : '';
        return $wrapStart.join( ' ', $timePieces ).$wrapEnd;
    }

    /**
     * get comments from an obj that has getComments method
     *
     * @param object $obj
     * @param array $config
     * @return string
     */
    public function getComments( $obj, $config = array(), $parentType = 'unknown' )
    {
        $loginUser = $this->view->loginUser;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
        $defaultConfig = array(
            'link' => false,
            'type' => 'comments'
        );

        if ( $loginUser && !$loginUser->isParent() ) {
            $defaultConfig['attributes'] = array(
                'data-twilio-key' => $site->createCommentAccessToken( $loginUser, 'web' ),
                'data-twilio-channel' => $obj->getChannelId(),
                'data-comments-api-key' => $loginUser->getOAuthAccessToken(),
                // 'data-comments-api-url' => 'http://localhost:3000/', 
                // 'data-comments-api-url' => 'https://edkza3zqdb.execute-api.us-east-1.amazonaws.com/dev/', 
                'data-comments-api-url' => $systemConfig->getSetting('AWS_LAMBDA_SERVICE_URL').'comments',
                'data-comments-parentId' => $obj->getId(),
                'data-comments-parentType' => $parentType // TODO: get type from $obj
            );
        }

        $comments = array();
        $commentsResponse = $obj->getComments();

        if ( $commentsResponse['data'] ) {
            // List the messages
            foreach ( array_reverse($commentsResponse['data']) as $comment ) {
                $authorName = preg_replace( '/\s+/', '', $comment['meta']['user']['username'] );
                $author = $site->getUserByUsername( $authorName );
                $authorUrl = $author ? $author->getUrl() : '#';
                $commentBody = $comment['body'];

                // add links to mentions
                foreach($comment['meta']['mentions'] as $mention) {
                    $username = $mention['username'];
                    $userId = (string)$mention['userId'];
                    $commentBody = str_replace(
                        '@'.$username, 
                        "<a href='/users/$userId'>@".$username."</a>",
                        $commentBody);
                }

                $comments[] = '
                    <div class="one-comment">
                        <a href="'.$authorUrl.'">'.$authorName.'</a>
                        '.$commentBody.'
                    </div>
                ';
            }
        }

        return $this->getObjectWrap( $obj, join( '', $comments ), array_merge( $defaultConfig, $config ) );
    }

    /**
     * Get comment form for an object with comments
     *
     * @param object $obj
     * @param array $config
     * @return string
     */
    public function getCommentForm( $obj, $config = array() )
    {
        $loginUser = $this->view->loginUser;    /* @var BeMaverick_User $loginUser */
        $formatUser = $this->view->formatUser(); /* @var BeMaverick_View_Helper_FormatUser $formatUser */

        if ( !$loginUser || $loginUser->isParent() ) return '';

        $formContent = '
            <div class="comments__form">
                '.$formatUser->getProfileImage( $loginUser ).'
                <form>
                    <input type="text" name="commentBody" class="commentBody" />
                    <div class="commentLoader" style="display: block; position: absolute; top: 5px; right: 40px;"></div>
                    <button>Post</button>
                </form>
            </div>
        ';

        return $formContent;
    }

    /**
     * get an inline svg image
     *
     * @param string $name
     */
    public function getSvg( $name )
    {
        $svgs = array(
            'logo' => '
                <svg xmlns="http://www.w3.org/2000/svg" width="393" height="87" viewBox="0 0 393 87">
                  <g fill-rule="evenodd" fill="currentColor">
                    <g transform="translate(92 23)">
                      <polyline points="6.121 .345 20.908 29.688 35.638 .345 41.299 .345 41.299 40.779 37.024 40.779 36.966 7.16 22.237 36.504 19.464 36.504 4.792 7.16 4.792 40.779 .402 40.779 .402 .345 6.121 .345"/>
                      <path d="M77.5913253,26.1645783 L68.406988,5.37012048 L59.3383133,26.1645783 L77.5913253,26.1645783 Z M79.439759,30.4390361 L57.4320482,30.4390361 L52.926747,40.7785542 L48.0168675,40.7785542 L66.1542169,0.344578313 L70.9486747,0.344578313 L89.0284337,40.7785542 L84.0031325,40.7785542 L79.439759,30.4390361 Z"/>
                      <polyline points="91.87 .345 105.791 35.58 119.77 .345 124.622 .345 108.101 40.779 103.307 40.779 86.903 .345 91.87 .345"/>
                      <polyline points="158.771 .345 158.771 4.619 135.955 4.619 135.955 18.193 156.345 18.193 156.345 22.41 135.955 22.41 135.955 36.504 159.523 36.504 159.523 40.779 131.334 40.779 131.334 .345 158.771 .345"/>
                      <path d="M183.481928,23.6807229 C190.816867,23.6807229 194.975904,20.3884337 194.975904,14.0344578 C194.975904,7.85373494 190.816867,4.61927711 183.481928,4.61927711 L172.737349,4.61927711 L172.737349,23.6807229 L183.481928,23.6807229 Z M194.573494,40.7785542 L186.081928,27.839759 C185.272289,27.8973494 184.407229,27.9551807 183.481928,27.9551807 L172.737349,27.9551807 L172.737349,40.7785542 L168.118072,40.7785542 L168.118072,0.344578313 L183.481928,0.344578313 C193.590361,0.344578313 199.424096,5.31228916 199.424096,13.9187952 C199.424096,20.5616867 196.13253,25.1248193 190.298795,26.973253 L199.828916,40.7785542 L194.573494,40.7785542 Z"/>
                      <polygon points="209.904 40.779 214.525 40.779 214.525 .345 209.904 .345"/>
                      <path d="M244.785542,4.44578313 C235.660241,4.44578313 228.322892,11.5506024 228.322892,20.5036145 C228.322892,29.3992771 235.660241,36.6195181 244.785542,36.6195181 C249.233735,36.6195181 253.566265,34.7710843 256.742169,31.7677108 L259.573494,34.8291566 C255.587952,38.5836145 250.159036,40.9518072 244.554217,40.9518072 C232.886747,40.9518072 223.645783,31.9407229 223.645783,20.5036145 C223.645783,9.18240964 233.00241,0.229156627 244.727711,0.229156627 C250.274699,0.229156627 255.645783,2.48168675 259.515663,6.12096386 L256.742169,9.47108434 C253.624096,6.35204819 249.233735,4.44578313 244.785542,4.44578313"/>
                      <polyline points="295.236 40.779 280.335 21.544 272.477 30.208 272.477 40.779 267.858 40.779 267.858 .345 272.477 .345 272.477 23.854 294.198 .345 299.684 .345 283.627 17.962 300.896 40.779 295.236 40.779"/>
                    </g>
                    <path d="M33.5068092,47.2434985 L19.1896386,65.0443611 L19.1896386,86.8915663 L0.0284337349,86.8915663 L0.0284337349,83.9443201 L-2.60902411e-15,83.9214458 L0.0284337349,83.8860938 L0.0284337349,0.638313253 L2.8059395,4.09158712 L2.80626506,4.0913253 L33.5069303,42.2619278 L64.2077108,4.0913253 L64.3698172,4.22171694 L67.2525301,0.660722892 L67.2525301,86.8915663 L48.0915663,86.8915663 L48.0915663,65.3769894 L33.5068092,47.2434985 Z M35.5102056,44.7526303 L48.0915663,60.3952267 L48.0915663,29.1099394 L35.5102056,44.7526303 Z M31.5035264,44.7527809 L19.1896386,29.4427026 L19.1896386,60.0627669 L31.5035264,44.7527809 Z M51.213494,69.2585383 L51.213494,83.7698795 L62.8849579,83.7698795 L51.213494,69.2585383 Z M51.213494,64.2767667 L64.1303614,80.3365038 L64.1303614,9.47903614 L51.213494,25.4351807 L51.213494,64.2767667 Z M3.15036145,80.0045683 L16.0677108,63.9442923 L16.0677108,25.5614458 L3.15036145,9.50144578 L3.15036145,80.0045683 Z M16.0677108,68.9259246 L4.12877065,83.7698795 L16.0677108,83.7698795 L16.0677108,68.9259246 Z"/>
                  </g>
                </svg>
            '
        );

        if ( isset( $svgs[$name] ) ) {
            return '<span class="svg svg--'.$name.'">'.$svgs[$name].'</span>';
        }
        return '';
    }

    public function getResizedImageDimensions( $image, $maxDimension = 1200 )
    {
        $dimensions = array(
            'width' => null,
            'height' => null
        );

        if  ( $image ) {
            $width = $image->getWidth();
            $height = $image->getHeight();
            if ( $width && $height ) {
                $ratio = $width / $height;
                $isHorizontal = $ratio > 1;
                if ( $isHorizontal ) {
                    $height = floor( $height / $width * $maxDimension );
                    $width = $maxDimension;
                } else {
                    $width = floor( $width / $height  * $maxDimension );
                    $height = $maxDimension;
                }
                $dimensions['width'] = $width;
                $dimensions['height'] = $height;
            }
        }
        return $dimensions;
    }

    /**
     * Get promo share module
     *
     * @param object $obj
     * @return string
     */
    public function getJoinModule( $object )
    {
        $translator = $this->view->translator;
        $appStoreBlackImg = $this->view->url( "imageStatic", array( "imageName" => "apple-store-black.svg") );
        $appStoreUrl = $this->view->systemConfig->getSetting( 'SYSTEM_APP_STORE_APPLE_URL' );

        $title = $object->getTitle();
        if ( ! $title && get_class( $object ) == 'BeMaverick_Response' ) {
            $challenge = $object->getChallenge();
            if ( $challenge ) {
                $title = $challenge->getTitle();
            }
        };

        $shareBar = '';
        if ( $object->getShareUrl() ) {
            $formatShare  = $this->view->formatShare();
            $shareLinks = $formatShare->getLinks(array(
                'fullUrl' => $object->getShareUrl(),
                'title' => $title
            ));
            $shareBar = '<div class="share-links-title">'.$translator->_( 'Share:' ).'</div>'.$formatShare->getBar( $shareLinks );
        }

        return '
            <div class="join-module">
                <div class="join-panel">
                    <div class="join-panel__content">
                        <div class="join_panel__body">
                            <div class="join-panel__logo"><span class="svgicon--logo-wordmark"></span></div>
                            <div class="join-panel__tagline">'.$translator->_( '#Doyourthing on the web and on the app!' ).'</div>
                            <div class="join_panel__cta">
                                <a href="'.$appStoreUrl.'" target="_blank" rel="noopener"><img src="'.$appStoreBlackImg.'"></a>
                            </div>
                        </div>
                        <div class="join_panel__footer">
                            '.$shareBar.'
                        </div>
                    </div>
                </div>
                <div class="join-bar">
                    <div class="join-bar__tagline">'.$translator->_( 'Download Maverick in the App Store!' ).'</div>
                    <div class="join_bar__cta">
                        <a href="'.$appStoreUrl.'" target="_blank" rel="noopener"><img src="'.$appStoreBlackImg.'"></a>
                    </div>
                </div>
            </div>
        ';
    }
}
