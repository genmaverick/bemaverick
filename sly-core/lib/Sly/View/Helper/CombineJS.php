<?php
require_once( ZEND_ROOT_DIR . '/lib/Zend/Registry.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/FileFinder.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Minify/JS.php' );

/**
 * Helper for creating one cached css file from a list of them
 *
 */
class Sly_View_Helper_CombineJS
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
    public function combineJS( $files )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        $string = '';

        $fullPathFiles = array();

        $jsDirs = $systemConfig->getJSDirs();
        $htdocsCacheDir = $systemConfig->getHtdocsCacheDir();
        $rootDir = $systemConfig->getRootDir();

        // loop through files and get last modified timestamp
        foreach( $files as $file ) {
            $fullPathFile = Sly_FileFinder::findFile( $file, $jsDirs );

            $fullPathFiles[] = $fullPathFile;
             
            $modified = filemtime( $fullPathFile );

            // we need to strip the rootDir before creating the string
            // to md5 and then compare with, because different environments
            // will have different rootDirs, so they won't compare nicely
            $pathFile = str_replace( $rootDir, '', $fullPathFile );

            $string .= "${pathFile}-${modified}";
        }

        // md5 the string and see if that file exists
        $md5String = md5( $string );

        $cacheFile = "$htdocsCacheDir/js/${md5String}.js";

        // file doesn't exist, so create it
        if ( ! file_exists( $cacheFile ) || 
             ! $systemConfig->isJsCaching() ) {
            @mkdir( "$htdocsCacheDir/js", 0777, true );
            @chmod( "$htdocsCacheDir/js", 0777 );
            $this->combineFiles( $fullPathFiles, $cacheFile );
        }

        // return new uri
        return $this->view->url( 'jsStatic', array( 'jsName' => "${md5String}.js" ) );
    }

    protected function combineFiles( $sourceFiles, $destinationFile )
    {
        $fileContents = '';

        foreach( $sourceFiles as $sourceFile ) {
            ob_start();
            include( $sourceFile );
            $fileContents .= ob_get_clean();
        }

        $systemConfig = Zend_Registry::get( 'systemConfig' );

        if ( $systemConfig->isMinifyCssJsEnabled() ) {
            $fileContents = Sly_Minify_JS::minify( $fileContents );
        }

        file_put_contents( $destinationFile, $fileContents );
    }
}
