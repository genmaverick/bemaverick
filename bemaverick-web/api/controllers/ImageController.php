<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Image/BackingStore/Local.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Image/BackingStore/Amazon.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Image/Processor.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/ImageProcessor.php' );

class ImageController extends BeMaverick_Controller_Base
{

    public function indexAction()
    {
        // get the view variables
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;

        // set the input params
        $requiredParams = array(
            'imageFilename',
        );

        // process the input and validate
        $this->processInput( $requiredParams, null, $errors );

        // check for errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'notfound' );
        }

        $requestUri = $this->getRequest()->getRequestUri();

        // error_log('ImageController::$requestUri => '.$requestUri);

        $amazonConfig = $site->getAmazonConfig();
        $imageSalt = $systemConfig->getSetting( 'SYSTEM_IMAGE_SALT' );
        $bucketName = $systemConfig->getSetting( 'AWS_S3_IMAGE_BUCKET_NAME' );
        $assetsDir = $systemConfig->getAssetsDir();
        $localBackingStore = new Sly_Image_BackingStore_Local( $assetsDir );
        $amazonBackingStore = new Sly_Image_BackingStore_Amazon( $bucketName, $amazonConfig, $localBackingStore );
        $imageProcessor = new BeMaverick_Image_Processor( $amazonBackingStore, $localBackingStore, $requestUri );

        $imageBlob = $imageProcessor->getProcessedImageBlob( $imageSalt, $_GET );

        if ( $imageBlob ) {

            $now = time();
            $ttl = 31536000; // 365 days
                            
            $expires = Sly_Date::formatDate( $now+$ttl, 'D, d M Y H:i:s', 'UTC' ) . ' GMT';
            $lastModified = Sly_Date::formatDate( $now, 'D, d M Y H:i:s', 'UTC' ) . ' GMT';
                
            // lets add the last modified
            $lastModified = Sly_Date::formatDate( time(), 'D, d M Y H:i:s', 'UTC' ) . ' GMT';

            header( $imageProcessor->getContentTypeHeader() );
            header( 'Content-Length: ' . strlen( $imageBlob ) );
            header( "Expires: $expires" );
            header( "Cache-Control: max-age=$ttl,public" );
            header( "Last-Modified: $lastModified" );
            header( "Pragma: " );
            
            print $imageBlob;
            return;
        }

        return $this->renderPage( 'notfound' );
    }

}

?>
