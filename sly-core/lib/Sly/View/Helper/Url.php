<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Url.php' );

/**
 * Helper for creating urls
 *
 */
class Sly_View_Helper_Url
{
    /**
     * Get a url for a given page
     *
     * @param  string $page
     * @param  string $params
     * @param  string $relativeUrl Defaults to true
     * @return string
     */ 
    public function url( $page, $params = array(), $relativeUrl = true, $site = null, $sortParams = true, $isSecure = false )
    {
        $url = Sly_Url::getInstance();
        return $url->getUrl( $page, $params, $relativeUrl, $site, $sortParams, $isSecure );
    }
}
