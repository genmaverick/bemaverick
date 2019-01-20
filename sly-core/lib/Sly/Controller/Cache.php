<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/View/Helper/MergeFiles.php');
require_once( SLY_ROOT_DIR . '/lib/Sly/FileFinder.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Controller/Base.php' );

class Sly_Controller_Cache extends Sly_Controller_Base
{
    public function mergefilesAction()
    {
        $errors = $this->view->errors;

        $optionalParams = array(
            'type',
            'maxModTime',
            'files',
            'namespace',
        );

        // process the input and set input to the view
        $input = $this->processInput( null, $optionalParams, $errors );

        // make sure we have a categoryType
        if ( $errors->hasErrors() ) {
            return $this->_forward( 'notfound', 'error' );
        }

        return $this->renderPage( 'mergeFiles' );
    }

    public function imageAction()
    {
        $errors = $this->view->errors;
        $systemConfig = $this->view->systemConfig;

        $optionalParams = array(
            'imageFilename',
        );

        // process the input and set input to the view
        $input = $this->processInput( null, $optionalParams, $errors );

        // make sure we have a categoryType
        if ( $errors->hasErrors() ) {
            return $this->_forward( 'notfound', 'error' );
        }

        if ( ! preg_match( '/^(.*)_(\d+).(png|jpg|gif|svg)$/', $input->imageFilename, $matches ) ) {
            return $this->_forward( 'notfound', 'error' );
        }

        $imageName = $matches[1] . '.' . $matches[3];
        $timestamp = $matches[2];

        $imageDirs = $systemConfig->getImagesDir();
        $htdocsCacheDir = $systemConfig->getHtdocsCacheDir();

        if ( ! is_array($imageDirs) ) {
            $imageDirs = array( $imageDirs );
        }

        $fileInfo = Sly_FileFinder::findFileStat($imageName, $imageDirs);

        if ( ! $fileInfo ) {
            return $this->_forward( 'notfound', 'error' );
        }

        $originalFile = $fileInfo['path'];
        $modifiedTime = $fileInfo['mtime'];

        $pathInfo = pathinfo( $imageName );

        if ( $pathInfo['dirname'] == '.' ) {
            $imageName = $pathInfo['filename'] . '_' . $modifiedTime . '.' . $pathInfo['extension'];
        }
        else {
            $imageName = $pathInfo['dirname'] . '/' . $pathInfo['filename'] . '_' . $modifiedTime . '.' . $pathInfo['extension'];
        }

        $newFile = "$htdocsCacheDir/img/$imageName";

        if ( ! file_exists( $newFile ) ) {
            @mkdir( "$htdocsCacheDir/img/{$pathInfo['dirname']}", 0777, true );
            @chmod( "$htdocsCacheDir/img/{$pathInfo['dirname']}", 0777 );
            @copy( $originalFile, $newFile );
        }

        // lets add the last modified
        $lastModified = Sly_Date::formatDate( $modifiedTime, 'D, d M Y H:i:s', 'UTC' ) . ' GMT';

        // set the proper content type
        $contentType = 'image/'.$pathInfo['extension'];

        // expires and cache-control will be done by apache with this content Type
        header( "Content-Type: $contentType" );
        header( "Last-Modified: $lastModified" );

        if ( $modifiedTime != $timestamp ) {

            $ttl = 60;
            if ( defined( 'SYSTEM_MERGE_FILES_MISS_TTL' ) ) {
                $ttl = SYSTEM_MERGE_FILES_MISS_TTL;
            }

            $expires = Sly_Date::formatDate( time()+$ttl, 'D, d M Y H:i:s', 'UTC' ) . ' GMT';

            // overwrite apache's ttl
            header( "Expires: $expires" );
            header( "Cache-Control: max-age=$ttl" );
        }

        print file_get_contents( $newFile );
    }
}
