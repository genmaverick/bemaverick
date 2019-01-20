<?php

/**
 *
 */
class Sly_View_Helper_FormatSocialMedia
{

    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public function setView( Zend_View_Interface $view ) {

        $this->view = $view;
    }

    public function formatSocialMedia() {
        return $this;
    }

    public function getFacebookLikeButton( $data )
    {
        $url = $data['facebook']['url'];
        $ref = (array_key_exists('ref', $data['facebook'])) ? $data['facebook']['ref'] : '';
        
        $html = <<< EOS
        <span class="socialButton socialButtonLike">
            <iframe src="http://www.facebook.com/plugins/like.php?href=$url&amp;layout=button_count&amp;show_faces=false&amp;width=90&amp;action=like&amp;colorscheme=light&amp;height=21&amp;ref=$ref" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:90px; height:21px;" allowTransparency="true"></iframe>
        </span>
EOS;
        return $html;
    }

    public function getFacebookFbmlLikeButton( $data )
    {
        $url = $data['facebook']['url'];
        $ref = (array_key_exists('ref', $data['facebook'])) ? $data['facebook']['ref'] : '';

        $html = <<< EOS
        <span class="socialButton socialButtonLike">
            <fb:like href="$url" ref="$ref" send="false" layout="button_count" show_faces="false" width="100" font="arial" colorscheme="light"></fb:like>
        </span>
EOS;
        return $html;
    }

    public function getTwitterTweetButton( $data )
    {
        $url          = $data['twitter']['url'];
        $canonicalUrl = $data['twitter']['canonicalUrl'];
        $text         = $data['twitter']['text'];

        $additionalAttributes = '';
        if (array_key_exists('size', $data['twitter'])) {
            $dataSize     = $data['twitter']['size'];
            $additionalAttributes .= 'data-size="' . $dataSize . '"';
        }


        $html = <<< EOS
        <span class="socialButton socialButtonTweet">
            <a href="http://twitter.com/share" class="twitter-share-button"
                data-url="$url"
                data-text="$text"
                data-counturl="$canonicalUrl"
                data-count="none"
                {$additionalAttributes}
                >Tweet</a>
        </span>
EOS;
        return $html;
    }

    public function getGooglePlusOneButton( $data )
    {
        $url          = $data['gPlus']['url'];
        $size = 'medium';

        if (array_key_exists('size', $data['gPlus'])) {
            $dataSize     = $data['gPlus']['size'];
            $size = $dataSize;
        }

        $html = <<<EOS
        <span class="socialButton socialButtonGooglePlusOne">
            <g:plusone size="{$size}" annotation="none" href="{$url}"></g:plusone>
        </span>
EOS;
        return $html;
    }

    public function getLinkedInShareButton( $data )
    {
        $url          = $data['linkedIn']['url'];
        $html = <<<EOS
        <span class="socialButton socialButtonLinkedInShare">
            <script type="IN/Share" data-url="{$url}"></script>
        </span>
EOS;
        return $html;
    }

    public function getWeiboShareButton( $data )
    {
        $paramData = array(
            'url' => $data['weibo']['url'],
            'type' => '3',
            'count' => '1',
            'appkey' => '',
            //'title' => '',
            //'pic' => '',
            //'ralateUid' => '',
            'language' => 'zh_cn',
            'rnd' => time(),
                        );
        $params = array();
        foreach ($paramData as $paramKey => $paramValue) {
            $params[] = $paramKey . '=' . urlencode($paramValue);
        }
        $params = implode($params, '&');

        $html = <<< EOS
        <span class="socialButton socialButtonWeiboShare">
            <iframe allowTransparency="true" frameborder="0" scrolling="no" src="http://hits.sinajs.cn/A1/weiboshare.html?{$params}" width="72" height="16"></iframe>
        </span>
EOS;
        return $html;
    }


    public function getBasicFacebookLikeButton( $data )
    {
        $url = rawurlencode($data['facebook']['url']);
        $appId = $data['facebook']['appId'];
        $ref = (array_key_exists('ref', $data['facebook'])) ? $data['facebook']['ref'] : '';

        $html = <<< EOS
        <span class="socialButton socialButtonLike">
            <a href="https://www.facebook.com/dialog/share?app_id={$appId}&display=popup&href={$url}&redirect_uri={$url}" onclick="javascript:window.open(this.href, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">Facebook<i></i></a>
        </span>
EOS;
        return $html;
    }

    public function getBasicTwitterTweetButton( $data )
    {
        $url          = rawurlencode($data['twitter']['url']);
        $canonicalUrl = $data['twitter']['canonicalUrl'];
        $text         = rawurlencode($data['twitter']['text']);

        $additionalAttributes = '';
        if (array_key_exists('size', $data['twitter'])) {
            $dataSize     = $data['twitter']['size'];
            $additionalAttributes .= 'data-size="' . $dataSize . '"';
        }


        $html = <<< EOS
        <span class="socialButton socialButtonTweet">
            <a href="http://twitter.com/intent/tweet?text={$text}&url={$url}" onclick="javascript:window.open(this.href, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">Twitter<i></i></a>
        </span>
EOS;
        return $html;
    }

    public function getBasicGooglePlusOneButton( $data )
    {
        $url          = rawurlencode($data['gPlus']['url']);
        $size = 'medium';

        if (array_key_exists('size', $data['gPlus'])) {
            $dataSize     = $data['gPlus']['size'];
            $size = $dataSize;
        }

        // http://stackoverflow.com/a/10347059/822164
        $html = <<<EOS
        <span class="socialButton socialButtonGooglePlusOne">
            <a href="https://plus.google.com/share?url={$url}" onclick="javascript:window.open(this.href, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">Google+<i></i></a>
        </span>
EOS;
        return $html;
    }

    public function getBasicLinkedInButton( $data )
    {
        $url          = rawurlencode($data['linkedIn']['url']);
        $html = <<<EOS
        <span class="socialButton socialButtonLinkedIn">
            <a href="https://www.linkedin.com/shareArticle?url={$url}" onclick="javascript:window.open(this.href, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">LinkedIn<i></i></a>
        </span>
EOS;
        return $html;
    }


    public function getBasicWeiboButton( $data )
    {
        $paramData = array(
            'url' => $data['weibo']['url'],
            'type' => '3',
            'count' => '1',
            'appkey' => '',
            //'title' => '',
            //'pic' => '',
            //'ralateUid' => '',
            'language' => 'zh_cn',
            'rnd' => time(),
                        );
        $params = array();
        foreach ($paramData as $paramKey => $paramValue) {
            $params[] = $paramKey . '=' . rawurlencode($paramValue);
        }
        $params = implode($params, '&');


        $html = <<<EOS
        <span class="socialButton socialButtonWeibo">
            <a href="http://service.weibo.com/share/share.php?{$params}" onclick="javascript:window.open(this.href, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');return false;">Weibo<i></i></a>
        </span>
EOS;
        return $html;
    }

    public function getBasicEmailButton( $subject = '', $body = '' )
    {
        $html = <<<EOS
        <span class="socialButton socialButtonEmail">
            <a href="mailto:?subject={$subject}&body={$body}">Email<i></i></a>
        </span>
EOS;
        return $html;
    }

    public function getBasicSMSButton( $text = '', $textDelimiter = '?' )
    {
        $html = <<<EOS
        <span class="socialButton socialButtonSMS">
            <a href="sms:{$textDelimiter}body={$text}">SMS<i></i></a>
        </span>
EOS;
        return $html;
    }



    public function NOT_USED_getStumbleUpon( $sUrl = '', $sMagellanParams )
    {
        $slyUrl = new Sly_Url();
        $url = $slyUrl->getUrl( $sUrl, $sMagellanParams, false );
        $url = urlencode($url);
        return '<span class="like"><script src="http://www.stumbleupon.com/hostedbadge.php?s=1&r=' . $url .'"></script></span>';

    }
    
    
}

?>
