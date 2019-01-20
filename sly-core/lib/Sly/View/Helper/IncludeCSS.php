<?php
require_once( ZEND_ROOT_DIR . '/lib/Zend/Registry.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/FileFinder.php' );

/**
 * Helper for creating one cached css file from a list of them
 *
 */
class Sly_View_Helper_IncludeCSS
{
    /**
     * The view object that created this helper object.
     * 
     * @var Zend_View
     */
    public $view;

    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;        
    }
    
    /**
     * Minify all the css files
     *
     * Creates a single file that includes all the given css files
     *
     * @param  array $files The list of css files
     * @return string $file The file with contents of all other css files
     */ 
    public function includeCSS( $files )
    {
        $cssDirs = Zend_Registry::get( 'systemConfig' )->getCSSDirs();

        // loop through files and include
        foreach( $files as $file ) {
            $fullPathFile = Sly_FileFinder::findFile( $file, $cssDirs );

            if ( $fullPathFile ) {
                include( $fullPathFile );
            }
        }
    }

}
