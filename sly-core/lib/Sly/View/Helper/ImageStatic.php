<?php

/**
 * Helper for getting contents of static images
 *
 */
class Sly_View_Helper_ImageStatic
{
    /**
     * The view object that created this helper object.
     * @var Zend_View
     */
    public $view;

    /**
     * Get a url for a given page
     *
     * @param  string $page
     * @param  string $params
     * @param  string $relativeUrl Defaults to true
     * @return string
     */ 
    public function imageStatic( $imageName )
    {
        $systemConfig = $this->view->systemConfig;
        
        $imageDirs = $systemConfig->getImagesDir();

        if ( ! is_array($imageDirs) ) {
            $imageDirs = array( $imageDirs );
        }

        $fileInfo = Sly_FileFinder::findFileStat( $imageName, $imageDirs );

        if ( ! $fileInfo ) {
            return false;
        }
        
        return file_get_contents( $fileInfo['path'] );
    }

    public function setView(Zend_View_Interface $view)
    {
        $this->view = $view;
    }

}
