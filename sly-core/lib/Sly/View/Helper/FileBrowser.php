<?php

/**
 * Helper for creating javascript for file browsing
 *
 */
class Sly_View_Helper_FileBrowser
{
    /**
     * The view object that created this helper object.
     * @var Zend_View
     */
    public $view;


    /**
     * Create the js for file browsing
     *
     * @param  string $directory
     * @return string
     */ 
    public function fileBrowser( $path, $baseUrl )
    {
        $list = array();

        if ($dir=@opendir($path)) {

            while (($element=readdir($dir))!== false) {
                if ( $element == '.' || $element == '..' ) {
                    continue;
                }

                if ( is_dir( "$path/$element" ) ) {

                    $childList = $this->fileBrowser( "$path/$element", "$baseUrl/$element" );

                    $list[] = array(
                        'title' => $element,
                        'postTitleContent' => $this->view->linkList( $childList ),                       
                    );
                }
                else {
                    $pathParts = pathinfo($element);

                    $extension = ( isset( $pathParts['extension'] ) ) ? $pathParts['extension'] : '';

                    $list[] = array(
                        'title' => '<span class="type type-'.$extension.'">'.$element.'</span>',
                        'link' => "$baseUrl/$element",
                        'linkAttributes' => array( 'target' => 'popup' ),
                    );
                }
            }

            closedir($dir);

            return $list;
        }

        return $list;
    }

    public function setView(Zend_View_Interface $view)
    {
        $this->view = $view;
    }
}
