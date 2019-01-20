<?php
/**
 * Helper for creating html elements. Not using the zend stuff, not a fan.
 */
class Sly_View_Helper_FormatCSS
{
    /**
     * The view object that created this helper object.
     * 
     * @var Zend_View
     */
    public $view;

 
    public function formatCSS()
    {
        return $this;
    }
    
    public function getFloatClear( $selectors = null ){   

        if ( !$selectors ) {
            return '';    
        }
        if (!is_array($selectors) ) {
            $selectors = array( $selectors ) ;    
        }
        $standards = array();

        foreach ( $selectors as $selector ) {
             $standards[] = $selector.':after';   
        }
           
        $xhtml = join(',',$standards).'{content: "."; display: block; height: 0; clear: both; visibility: hidden;}'."\n";
        $xhtml .= join(',',$selectors)."{zoom:1;}\n";

        return $xhtml;
    }    
     
    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }
}
