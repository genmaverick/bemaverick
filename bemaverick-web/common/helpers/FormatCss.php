<?php
/**
 * Class for helping get the correct CSS on the page
 *
 * @category BeMaverick
 * @package BeMaverick_View_Helper
 */
class BeMaverick_View_Helper_FormatCss
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
     * @return BeMaverick_View_Helper_FormatCss
     */
    public function formatCss()
    {
        return $this;
    }

    /**
     * Get the possible groups of css files
     *
     * @return hash
     */
    public function getCssFileGroups()
    {
        return array(
            'universal' => array(
                'yreset.css',
                'site.css',
                'fonts.css',
                'module.css',
                'buttons.css',
                'header.css',
                'footer.css',
                'popup.css'
            ),
            'widgets' => array(
                'responsive-menu.css',
                'content-module.css',
                'maverick-badges.css',
                'maverick-tabs.css',
                'profile-image.css',
                'response-preview.css',
                'challenge-preview.css',
                'video-player.css',
                'basic-module.css',
                'text-module.css',
                'mini-module.css',
                'pagination-see-more.css',
                'popup-basic.css',
                'popup-full.css',
                'preview-items.css',
                'croppie.css',
                'response-badger.css',
                'join-module.css'
            ),
            'index-home' => array(
                'home.css',
                'home-hero.css',
                'mav-live-splash.css',
                'home-details.css',
                'home-actions.css'
            ),
            'auth' => array(
                'auth.css'
            ),
            'errors' => array(
                'auth.css'
            ),
            'challenges-index' => array(
                'challenges.css'
            ),
            'challenges-challenge' => array(
                'dropzone.css',
                'media-module.css',
                'challenge.css',
                'challenge-media.css',
                'challenge-add-response.css',
            ),
            'users-user' => array(
                'users.css',
                'activity.css',
                'user-profile-intro.css',
                'user-profile-details.css',
                'user-profile-edit.css',
            ),
            'users-user-notifications-edit' => array(
                'user-settings.css'
            ),
            'users-user-password-edit' => array(
                'user-settings.css'
            ),
            'responses-response' => array(
                'media-module.css',
                'response.css',
                'response-media.css',
            ),
            'parents-parent-home' => array(
                'parent-home.css',
                'parent-home-challenges.css',
                'parent-home-mavericks.css',
                'activity.css',
                'post-card.css',
                'parent-home-latest-activity.css',
                'parent-home-latest-resources.css',
                'parent-settings.css'
            ),
            'posts-index' => array(
                'post-card.css',
                'posts.css'
            ),
            'posts-post' => array(
                'post.css'
            ),
        );
    }

    /**
     * Get the css group names to be included on all requests
     *
     * @return array
     */
    public function getDefaultGroupNames()
    {
         return array(
            'universal',
            'widgets',
        );
    }

    /**
     * Get the css files need on a crtical css request
     *
     * @param Sly_Config_Page $pageConfig
     * @return array
     */
    public function getCriticalFiles( $pageConfig )
    {
        $allGroups = $this->getCssFileGroups();
        $defaultGroupNames = $this->getDefaultGroupNames();
        $formatUtil = $this->view->formatUtil();

        $pageGroupNames = array();
        $pageType = $pageConfig->getType();
        $pageSubType = $pageConfig->getSubType();
        $pageDetail = $pageType.'-'.$pageSubType;

        // special case for posts since they are distinct types
        if ( strpos( $pageType, "post-" ) === 0 && $pageType != 'post-live-video' ) {
            $pageGroupNames[] = 'post';
        }

        if ( isset( $allGroups[$pageType] ) ) {
            $pageGroupNames[] = $pageType;
        }
        if ( $pageSubType && isset( $allGroups[$pageDetail] ) ) {
            $pageGroupNames[] = $pageDetail;
        }

        $groupNames = array_merge( $defaultGroupNames, $pageGroupNames );

        $files = array();
        foreach( $groupNames as $groupName ) {
            if ( isset( $allGroups[$groupName] ) ) {
                $files = array_merge( $files, $allGroups[$groupName]);
            }
        }
        return array_unique($files);
    }

    /**
     * Get the css files need on a default css request
     *
     * @return array
     */
    public function getDefaultFiles()
    {
        $allGroups = $this->getCssFileGroups();
        $defaultGroupNames = $this->getDefaultGroupNames();
        $useCriticalCss = $this->view->systemConfig->getSetting( 'SYSTEM_USE_CRITICAL_CSS' );

        $files = array();
        foreach ( $allGroups as $groupName => $group ) {
            if ( $useCriticalCss && in_array( $groupName, $defaultGroupNames ) ) {
                continue;
            }
            $files = array_merge( $files, $allGroups[$groupName]);
        }
        return array_unique( $files );
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
