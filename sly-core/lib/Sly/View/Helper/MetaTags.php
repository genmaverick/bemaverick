<?php

/**
 *
 */
class Sly_View_Helper_MetaTags
{

    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public function setView( Zend_View_Interface $view ) {

        $this->view = $view;
    }

    public function metaTags() {
        return $this;
    }

    public function getData()
    {
        $pageConfig = $this->view->pageConfig;
        $systemConfig = $this->view->systemConfig;
        
        $title             = $pageConfig->getTitle() . ' | ' . $pageConfig->getTitlePrefix();
        $description       = $pageConfig->getDescription();
        $keywords          = $pageConfig->getKeywords();
        $siteName          = $pageConfig->getTitlePrefix();
        $url               = $systemConfig->getCurrentUrl( false );
        $facebookAppAdmins = $systemConfig->getFacebookAppAdmins();
        $facebookAppId     = $systemConfig->getFacebookAppId();
        
        $data = array(
            'title'             => $title,
            'description'       => $description,
            'keywords'          => $keywords,
            'type'              => 'website',
            'siteName'          => $siteName,
            'url'               => $url,
            'facebookAppAdmins' => $facebookAppAdmins,
            'facebookAppId'     => $facebookAppId,
        );
        
        return $data;
    }

    public function getAdditionalTags()
    {
        return '';
    }

}

?>
