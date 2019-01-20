<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Google/Storage.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Image/BackingStore/Interface.php' );

class Sly_Image_BackingStore_Google implements Sly_Image_BackingStore_Interface
{

    /**
     * @var Sly_Image_BackingStore_Local
     * @access private
     */
    private $_localBackingStore;

    /**
     * @var hash $_googleConfig
     * @access private
     */
    private $_googleConfig;

    /**
     * @param hash $googleConfig
     * @param Sly_Image_BackingStore_Local $localBackingStore
     * @return void
     */
    public function __construct( $googleConfig, $localBackingStore = null )
    {
        $this->_googleConfig = $googleConfig;
        $this->_localBackingStore = $localBackingStore;
    }

    /**
     * @param string $filename
     * @return binary
     */
    public function getImageBlob( $filename )
    {
        if ( $this->_localBackingStore ) {
            $imageBlob = $this->_localBackingStore->getImageBlob( $filename );

            if ( $imageBlob ) {
                return $imageBlob;
            }
        }

        $imageBlob = Sly_Service_Google_Storage::getFileContents( $filename, $this->_googleConfig );

        if ( $this->_localBackingStore ) {
            $this->_localBackingStore->putImageBlob( $imageBlob, $filename );
        }

        return $imageBlob;
    }

    /**
     * @param binary $imageBlob
     * @param string $filename
     * @return void
     */
    public function putImageBlob( $imageBlob, $filename )
    {
        return Sly_Service_Google_Storage::putFileContents( $imageBlob, $filename, $this->_googleConfig );
    }

}

?>
