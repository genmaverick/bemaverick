<?php

/**
 * Helper for getting page title info
 *
 */
class Sly_View_Helper_GetPageTitleInfo
{
    /**
     * Get all the page tracker info
     *
     * @return array
     */
    public function getPageTitleInfo()
    {
        static $pageTitleInfo = null;

        if ( $pageTitleInfo ) {
            return $pageTitleInfo;
        }
        $translator = $this->view->translator;
        $input = $this->view->input;
       
        $pageConfig = $this->view->pageConfig;
        $titleChunks = array();

        if ($pageConfig->useTitlePrefix()  ) {
            $titleChunks[] = $translator ? $translator->_($pageConfig->getTitlePrefix()) : $pageConfig->getTitlePrefix();
        }

        $name = $pageConfig->getTitle();       
        $titleChunks[] = $translator ? $translator->_($name) : $name;

        $titleChunks  = array_reverse($titleChunks);
        $pageTitleInfo = join( $titleChunks, $pageConfig->getTitlePrefixDelimiter() );
        return $pageTitleInfo;
    }

    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

}
