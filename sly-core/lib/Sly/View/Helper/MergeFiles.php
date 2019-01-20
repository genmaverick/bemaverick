<?php
require_once( ZEND_ROOT_DIR . '/lib/Zend/Registry.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/FileFinder.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Url.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Minify/CSS.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Minify/JS.php' );

/**
 * Helper for creating one cached css/js file from a list of them
 *
 */
class Sly_View_Helper_MergeFiles
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
     * @param  array $files The list of css files
     * @return string $file The file with contents of all other css files
     */ 
    public function mergeFiles( $type, $files, $returnAsString = false )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );
        $htdocsCacheDir = $systemConfig->getHtdocsCacheDir();
        $namespace = false;
        
        switch($type) {
            case 'css':
                $searchDirs = $systemConfig->getCSSDirs();
                $namespace = $systemConfig->getCSSNamespace();
                $mergedCacheDir = "$htdocsCacheDir/css";
                if ( $namespace ) {
                    $mergedCacheDir .= "/$namespace";
                }
                break;
            case 'js':
                $searchDirs = $systemConfig->getJSDirs();
                $mergedCacheDir = "$htdocsCacheDir/js";                
                break;
        }

        list($maxModTime, $fullPathFiles) = $this->findFullFiles( $files, $searchDirs );

        if (false) {
            error_log("$maxModTime");
            error_log(print_r($fullPathFiles, true));
        }
        
        $string = implode(';', $files);        
        $string = strtr(base64_encode($string), '+/=', '-_.');
        
        list($uri, $cacheFile) = $this->getFullCachePath( $type,
                                                          $htdocsCacheDir,
                                                          $maxModTime,
                                                          $string,
                                                          $namespace );
        
        if (false) {
            error_log($uri);
            error_log($cacheFile);
        }
        
        // file doesn't exist, so create it
        if ( ! file_exists( $cacheFile ) ) {
            @mkdir( $mergedCacheDir, 0777, true );
            @chmod( $mergedCacheDir, 0777 );
            $this->combineFiles( $fullPathFiles, $cacheFile, $type );
        }
        
        if ( $returnAsString ) {
            return file_get_contents( $cacheFile );
        }
        
        return $uri;
    }

    public function getFullCachePath( $type,
                                      $htdocsCacheDir,
                                      $maxModTime,
                                      $filesString,
                                      $namespace = false )
    {
        static $url = null;
        if (is_null($url)) {
            $url = new Sly_Url();
        }

        switch($type) {

            case 'css':
                if ( $namespace ) {
                    $uri = $url->getUrl('cssStaticWithNamespace',
                                        array('maxModTime' => $maxModTime,
                                              'cssFiles' => $filesString,
                                              'namespace' => $namespace));
                }
                else {
                    $uri = $url->getUrl('cssStatic',
                                        array('maxModTime' => $maxModTime,
                                              'cssFiles' => $filesString ) );
                }
                
                $md5String = md5( $uri );
                $cacheFile = "$htdocsCacheDir/css";
                if ( $namespace ) {
                    $cacheFile .= "/$namespace";
                }
                $cacheFile .= "/${md5String}.css";
                break;

            case 'js':
                $uri = $url->getUrl('jsStatic',
                                    array('maxModTime' => $maxModTime,
                                          'jsFiles' => $filesString));
                
                $md5String = md5( $uri );
                $cacheFile = "$htdocsCacheDir/js/${md5String}.js";
                break;
        }

        return(array($uri, $cacheFile));
    }
    
    /*!
        Use the Sly_FileFinder to find the full paths for all partial reference
        files in [files].

        @return array - [0] - maxModTime, [1] - array of full file paths
    */
    public function findFullFiles( $files, $dirs ) {

        $systemConfig = Zend_Registry::get( 'systemConfig' );

        $maxModTime = 0;        
        $fullPathFiles = array();

        // loop through files and get the most recent last modified timestamp
        foreach( $files as $file ) {

            $fullPathFile = Sly_FileFinder::findFile( $file, $dirs );

            if ($systemConfig->isLessEnabled() && $this->getCorrespondingLessFullPathFile($file, $dirs)) {
                $lessFullPathFile = $this->getCorrespondingLessFullPathFile($file, $dirs);
                // Only care about the mod time of the less file
                $modified = filemtime( $lessFullPathFile );
                if (! $fullPathFile) {
                    // Compile less file for the first time to generate the missing CSS file
                    error_log( "notice: compiling less file to create missing css file: $file" );
                    $fullPathFile = $this->getLessCompilationTargetFullPathFile($file, $dirs);
                    $this->recompileLessFile($lessFullPathFile, $fullPathFile, $dirs);
                }
                else if (filemtime( $fullPathFile ) < $modified) {
                    // Recompile since less file has changed since last compilation
                    error_log( "notice: compiling less file to update css file: $file" );
                    $this->recompileLessFile($lessFullPathFile, $fullPathFile, $dirs);
                }
                else if (@$_REQUEST['compileless'] == 1 || @$_REQUEST['cless'] == 1) {
                    // Recompile since less file has changed since last compilation
                    error_log( "notice: forcing less compilation to update css file: $file" );
                    $this->recompileLessFile($lessFullPathFile, $fullPathFile, $dirs);
                }
            } else {
                if ( ! $fullPathFile ) {
                    // TODO - We really should make it so we pass another variable, that says
                    // we didn't find the file, so lets not cache the response
                    error_log( "error: unable to find file: $file" );
                    continue;
                } else {
                    $modified = filemtime( $fullPathFile );
                }
            }

            $fullPathFiles[] = $fullPathFile;

            if ($modified > $maxModTime) {
                $maxModTime = $modified;
            }
        }

        return array($maxModTime, $fullPathFiles);
    }

    public function combineFiles( $sourceFiles,
                                  $destinationFile,
                                  $type,
                                  $writeToDisk = true )
    {
        $fileContents = '';

        $systemConfig = Zend_Registry::get( 'systemConfig' );
        $cssDirs = $systemConfig->getCSSDirs();

        foreach( $sourceFiles as $sourceFile ) {
            ob_start();
            include( $sourceFile );
            $processedFile = ob_get_clean();

            $fileContents .= $processedFile;
        }

        // apache re-write rules won't consider a file that is 0 bytes to exist
        // so we need the file to have a space in it, so it doesn't become
        // a file not found
        if ( ! $fileContents ) {
            $fileContents = ' ';
        }

        if ($writeToDisk) {

            if ( $systemConfig->isMinifyCssJsEnabled() ) {
                if ( $type == 'css' ) {
                    $fileContents = Sly_Minify_CSS::process( $fileContents );
                }
                else if ( $type == 'js' ) {
                    $fileContents = Sly_Minify_JS::minify( $fileContents );
                }
            }
            
            file_put_contents( $destinationFile, $fileContents );
        }

        return($fileContents);
    }

    protected function getLessCompilationTargetFullPathFile ($fileName, $dirs) {

        // Need to make sure the dir we have exists
        foreach ($dirs as $dir) {
            if (is_dir($dir)) {
                return implode('/', array($dir, $fileName));
            }
        }
    }

    protected function getCorrespondingLessFullPathFile ($fileName, $dirs) {
        $lessFileName = $this->getCorrespondingLessFile($fileName);
        if (!$lessFileName) {
            return false;
        }
        return Sly_FileFinder::findFile( $lessFileName, $dirs );        
    }

    protected function getCorrespondingLessFile ($filePath) {
        // either file name or path
        if (!$this->isFileLessable($filePath)) {
            return null;
        }
        return str_replace('.css', '.less', $filePath);
    }

    protected function isFileLessable ($filePath) {
        return strpos($filePath, ".css") !== false;
    }

    protected function recompileLessFile ($lessFilePath, $cssFilePath, $searchDirs) {

        // Run LESS
        $paths = array();
        foreach ($searchDirs as $searchDir) {
            $paths[] = urlencode($searchDir);
        }

        $url = "http://127.0.0.1:8000" . '/?lessFilePath=' . urlencode($lessFilePath) . '&' . 'cssFilePath=' . urlencode($cssFilePath) . '&' . 'paths=' . implode(',', $paths);

        //error_log($lessFilePath);
        //error_log($cssFilePath);
        //error_log($url);

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url); 
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE); 
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 3); 
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        $response = curl_exec($ch);
        $curl_errno = curl_errno($ch);
        $curl_error = curl_error($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE); 
        curl_close($ch);
        
        if ($curl_errno > 0) {
            error_log("Error communicating with LESS server: $curl_error");
        }
    }

}
