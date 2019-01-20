<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/ImageProcessor.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Google/Storage.php' );

class Sly_GoogleImageBackingStore extends Sly_LocalImageBackingStore
{

    public function putImage( $img, $filename )
    {
        return Sly_Service_Google_Storage::putFileContents( $img->getImagesBlob(), $filename );
    }

    public function getImageHandle( $filename )
    {
        // check to see if the image is local, if so, use that.
        $fh = parent::getImageHandle( $filename );
        if ( ! empty( $fh ) ) {
            return $fh;
        }

        // it's not local, fetch it from Google Storage
        $imageBlob = Sly_Service_Google_Storage::getFileContents( $filename );
        
        $img = new Imagick();
        $img->readImageBlob( $imageBlob );
        
        /*
            It's slightly unfortunately that putImage takes
            an Imagick object. This situation should hopefully
            be rare so maybe it's acceptable for now.
        */

        parent::putImage( $img, $filename );

        return parent::getImageHandle( $filename );
    }
    
}

?>
