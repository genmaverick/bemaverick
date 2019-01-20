<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Image/BackingStore/Interface.php' );

class Sly_Image_BackingStore_Local implements Sly_Image_BackingStore_Interface
{

    /**
     * @var string
     * @access private
     */
    private $_baseDir;

    /**
     * @param string $baseDir
     * @return void
     */
    public function __construct( $baseDir )
    {
        $this->_baseDir = $baseDir;
    }

    /**
     * @param string $filename
     * @return string
     */
    public function getRelativePath( $filename )
    {
        $levelOnePath = substr( $filename, 0, 2 );

        return $levelOnePath . "/" . substr( $filename, 2, 2 );
    }

    /**
     * @param string $filename
     * @return string
     */
    public function getFullPath( $filename )
    {
        return sprintf( '%s/%s/%s', $this->_baseDir, $this->getRelativePath( $filename ), $filename );
    }

    /**
     * @param string $filename
     * @return string
     */
    public function getImageBlob( $filename )
    {
        $fullPath = $this->getFullPath( $filename );

        if ( file_exists( $fullPath ) ) {
            return file_get_contents( $fullPath );
        }

        return null;
    }

    /**
     * Saves the image to the local filesystem. This method
     * assumes that the filename of the file is the md5 hash
     * of the file contents.
     *
     * Location of the file is:
     *
     * $baseDir/<first 2 chars of filename>/<second 2 chars of filename>/<file>
     *
     * @param binary $imageBlob
     * @param string $filename
     * @return boolean
     */
    public function putImageBlob( $imageBlob, $filename )
    {
        if ( ! $filename ) {
            return false;
        }

        $levelTwoPath = $this->getRelativePath( $filename );
        $levelTwoDir = $this->_baseDir . '/' . $levelTwoPath;

        if ( ! file_exists( $levelTwoDir ) ) {
            if ( ! @mkdir( $levelTwoDir, 0777, true ) ) {
                
                // there is a chance we got here even though the directory exists, because
                // there are several images being served at the exact same time and so all of them
                // think the directory DOES NOT exist, but only 1 is going to win the battle to
                // create it.  so not really an error
                
                // lets check to see if it really does exist already
                if ( ! file_exists( $levelTwoDir ) ) {
                    error_log( "Sly_Image_BackingStore_Local::putImage couldn't create dir $levelTwoDir, probably already exists." );
                    return false;
                }
            }
        }

        $fullImagePath = $levelTwoDir . "/" . $filename;

        file_put_contents( $fullImagePath, $imageBlob );
        chmod( $fullImagePath, 0777 );

        return true;
    }
    
}


?>
