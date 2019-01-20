<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/S3.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Image/BackingStore/Interface.php' );

class Sly_Image_BackingStore_Amazon implements Sly_Image_BackingStore_Interface
{

    /**
     * @var Sly_Image_BackingStore_Local
     * @access private
     */
    private $_localBackingStore;

    /**
     * @var string $bucketName
     * @access private
     */
    private $_bucketName;

    /**
     * @var hash $_amazonConfig
     * @access private
     */
    private $_amazonConfig;

    /**
     * @param string $bucketName
     * @param hash $amazonConfig
     * @param Sly_Image_BackingStore_Local $localBackingStore
     * @return void
     */
    public function __construct( $bucketName, $amazonConfig, $localBackingStore = null )
    {
        $this->_bucketName = $bucketName;
        $this->_amazonConfig = $amazonConfig;
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

        $imageBlob = Sly_Service_Amazon_S3::getFileContents( $filename, $this->_bucketName, $this->_amazonConfig );

        if ( $this->_localBackingStore ) {
            $this->_localBackingStore->putImageBlob( $imageBlob, $filename );
        }

        return $imageBlob;
    }

    /**
     * @param binary $imageBlob
     * @param string $filename
     * @return boolean
     */
    public function putImageBlob( $imageBlob, $filename )
    {
        return Sly_Service_Amazon_S3::putFileContents( $imageBlob, $filename, $this->_bucketName, $this->_amazonConfig );
    }

}

?>
