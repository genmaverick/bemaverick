<?php
/**
 * BeMaverick_View_Helper
 *
 * @category    BeMaverick
 * @package     BeMaverick
 */

/**
 * Class for helping formatting Share Buttons
 *
 * @category BeMaverick
 * @package BeMaverick_View_Helper_FormatUtil
 */
class BeMaverick_View_Helper_FormatShare
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
     * @return BeMaverick_View_Helper_FormatShare
     */
    public function formatShare()
    {
        return $this;
    }

    public $providersConfig = array(
        'facebook' => array(
            'base' => 'https://www.facebook.com/dialog/share?',
            'params' => array(
                'app_id' => ':FACEBOOK_APP_ID',
                'href' => ':URL',
                'display' => 'popup',
                'ref' => 'share_fb',
                // 'redirect_uri' => ':CLOSE_URL'
            ),
            'attributes' => array(
                'data-window-options' => 'width=520,height=500'
            ),
            'text' => 'Facebook',
            'id' => 'fb',
            'shorten' => false,
            'iconName' => 'facebook'
        ),
        'messenger-send' => array(
            'base' => 'https://www.facebook.com/dialog/send?',
            'params' => array(
                'app_id' => ':FACEBOOK_APP_ID',
                'link' => ':URL',
                // 'redirect_uri' => ':CLOSE_URL'
            ),
            'attributes' => array(
                'data-window-options' => 'width=520,height=500'
            ),
            'text' => 'Messenger',
            'id' => 'messenger',
            'shorten' => false,
            'iconName' => 'messenger',
            'itemAttributes' => array(
                'class' => 'only-platform only-platform--non-mobile'
            )
        ),
        'twitter' => array(
            'base' => 'https://twitter.com/intent/tweet?',
            'params' => array(
                'url' => ':URL',
                'text' => ':TITLE',
                'via' => ':TWITTER_HANDLE'
            ),
            'text' => 'Twitter',
            'attributes' => array(
                'data-window-options' => 'width=520,height=570'
            ),
            'id' => 'twtr',
            'shorten' => false,
            'iconName' => 'twitter'
        ),
        'pinterest' => array(
            'base' => 'https://www.pinterest.com/pin/create/button/?',
            'params' => array(
                'url' => ':URL',
                'media' => ':SHAREIMAGE',
                'description' => ':TITLE',
            ),
            'text' => 'Pinterest',
            'attributes' => array(
                'data-window-options' => 'width=520,height=570'
            ),
            'id' => 'pin',
            'shorten' => false,
            'iconName' => 'pinterest'
        ),
        'whatsapp' => array(
            'base' => 'whatsapp://send?',
            'params' => array(
                'text' => ':TITLE:URL'
            ),
            'text' => 'WhatsApp',
            'attributes' => array(
                'data-window-options' => 'width=520,height=570',
                'class' => 'ignore'
            ),
            'id' => 'pin',
            'shorten' => false,
            'iconName' => 'whatsapp',
            'itemAttributes' => array(
                'class' => 'only-platform only-platform--mobile'
            )
        ),
        'sms-ios' => array(
            'base' => 'sms:&',
            'params' => array(
                'body' => ':TITLE:URL'
            ),
            'attributes' => array(
                'class' => 'ignore'
            ),
            'text' => 'Text message',
            'id' => 'sms-ios',
            'shorten' => false,
            'iconName' => 'sms',
            'itemAttributes' => array(
                'class' => 'only-platform only-platform--ios'
            )
        ),
        'sms-android' => array(
            'base' => 'sms:?',
            'params' => array(
                'body' => ':TITLE:URL'
            ),
            'attributes' => array(
                'class' => 'ignore'
            ),
            'text' => 'Text message',
            'id' => 'sms-android',
            'shorten' => false,
            'iconName' => 'sms',
            'itemAttributes' => array(
                'class' => 'only-platform only-platform--android'
            )
        ),
        'mail' => array(
            'base' => 'mailto:?',
            'params' => array(
                'body' => ':URL',
                'subject' => ':TITLE'
            ),
            'text' => 'Email',
            'id' => 'mail',
            'shorten' => false,
            'iconName' => 'email',
            'itemAttributes' => array(
                'class' => 'only-platform only-platform--non-mobile'
            )
        )
    );

    public function getLinks( $config = array() )
    {
        $site = $this->view->site;
        $formatUtil = $this->view->formatUtil();
        $facebookAppId = $this->view->systemConfig->getSetting( 'FACEBOOK_APP_ID' );
        $twitterHandle = $this->view->systemConfig->getSetting( 'TWITTER_HANDLE' ) ?? 'genmaverick';
        $closeUrl = $this->view->site->getUrl( 'closePopup', array(), false );
        $providersConfig = $this->providersConfig;
        $translator = $this->view->translator;

        $configObj = new Sly_DataObject( $config );
        $providers = $configObj->getProviders( array( 'facebook', 'twitter' ) );
        $description = $configObj->getDescription();
        $fullUrl = $configObj->getFullUrl();
        $image = $configObj->getImage();
        $title = $configObj->getTitle();
        $urlIndex = $configObj->getUrlIndex();
        $urlObject = $configObj->getUrlObject();
        $urlParams = $configObj->getUrlParams( array() );

        $shareLinks = array();
        foreach ( $providers as $provider ) {

            if ( isset( $providersConfig[$provider] ) ) {
                $providerConfig = $providersConfig[$provider];
            } else {
                continue;
            }

            $params = $providerConfig['params'];
            $providerUrlParams = isset( $providerConfig['urlParams'] ) ? $providerConfig['urlParams'] : array();
            $shorten = isset( $providerConfig['shorten'] ) ? $providerConfig['shorten'] : false;
            $longUrl = '';
            foreach ( $params as $paramKey => $paramValue ) {
                $shareUrl = $fullUrl;
                if ( !$fullUrl ) {
                    if ( $urlObject ) {
                        $longUrl = $urlObject->getUrl( $urlIndex, array_merge( $providerUrlParams, $urlParams ), false );
                    } else {
                        $longUrl = $this->view->url( $urlIndex, array_merge( $providerUrlParams, $urlParams ), false );
                    }
                    $shareUrl = $shorten ? $site->getShortUrl( $longUrl ) : $longUrl;
                }

                if ( $paramValue == ':TITLE' ) {
                    $params[$paramKey] = $title;
                } else if ( $paramValue == ':URL' ) {
                    $params[$paramKey] = $shareUrl;
                } else if ( $paramValue == ':TITLE:URL' ) {
                    $params[$paramKey] = $title.' '.$shareUrl;
                } else if ( $paramValue == ':SHAREIMAGE' ) {
                    $params[$paramKey] = str_replace( $cdnHosts, $this->view->systemConfig->getHttpHost( false ), $imageUrl );
                } else if ( $paramValue == ':DESCRIPTION' ) {
                    $params[$paramKey] = $description;
                } else if ( $paramValue == ':FACEBOOK_APP_ID' ) {
                    $params[$paramKey] = $facebookAppId;
                } else if ( $paramValue == ':CLOSE_URL' ) {
                    $params[$paramKey] = $closeUrl;
                } else if ( $paramValue == ':TWITTER_HANDLE' ) {
                    $params[$paramKey] = $twitterHandle;
                }
            }
            $target = '';
            $query = '';
            if ( $provider != 'mail' ) {
                if ( $provider != 'sms-android' ) {
                    $target = '_blank';
                }
                $query = $formatUtil->httpBuildQuery3986( $params );
            } else {
                foreach ( $params as $name => $value ) {
                    if ( $name == 'body' ) {
                        $value = urlencode( $value );
                    }
                    $query.= '&'.$name.'='.$value;
                }
            }

            $href = $providerConfig['base'].$query;
            $text = $providerConfig['text'];
            $attributes = isset( $providerConfig['attributes'] ) ?  $providerConfig['attributes'] : array();

            if ( $target ) {
                $attributes['target'] = $target;
            }
            $attributes['rel'] = 'nofollow';
            $attributes['title'] = $text;
            $providerClasses = array(
                'share-link',
                'share-link--'.$provider
            );


            $itemAttributes = array();
            if ( isset( $providerConfig['itemAttributes'] ) ) {
                $itemAttributes = $providerConfig['itemAttributes'];
            }


            $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class', join( ' ', $providerClasses ) );
            $shareLinks[$provider] = array(
                'url' => $href,
                'longUrl' => $longUrl,
                'text' => $text,
                'icon' => '<b class="svgicon svgicon--'.$providerConfig['iconName'].'"></b>',
                'attributes' => $attributes,
                'itemAttributes' => $itemAttributes,
                'extraContent' => ''
            );
        }

        return $shareLinks;
    }

    public function getBar( $links, $config = array() )
    {
        $configObj = new Sly_DataObject( $config );

        $className = $configObj->getClassName( 'share-links-bar' );
        $barItems = array();
        foreach ( $links as $link ) {
            $barItem = array(
                'title' => $link['icon'].' <span class="text">'.$link['text'].'</span>'.$link['extraContent'],
                'linkAttributes' => $link['attributes'],
                'itemAttributes' => $link['itemAttributes']
            );
            if ( $link['url'] ) {
                $barItem['link'] = $link['url'];
            }
            $barItems[] = $barItem;
        }

        return $this->view->linkList( $barItems, array( 'noLinkWrap' => 'span', 'attributes' => array( 'class' => $className ) ) );
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
