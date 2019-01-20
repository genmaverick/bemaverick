<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Image/BackingStore/Amazon.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Image.php' );

class BeMaverick_Image
{
    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = array();

    /**
     * @access protected
     */
    protected $_site;

    /**
     * @var integer
     * @access protected
     */
    protected $_imageId;

    /**
     * @var BeMaverick_Da_Image
     * @access protected
     */
    protected $_daImage;
        
    /**
     * Class constructor
     *
     * @param BeMaverick_Site $site
     * @param integer $imageId
     * @return void
     */
    public function __construct( $site, $imageId )
    {
        $this->_site = $site;
        $this->_imageId = $imageId;
        $this->_daImage = BeMaverick_Da_Image::getInstance();
    }

    /**
     * Retrieves the image instance.
     *
     * @param BeMaverick_Site $site
     * @param integer $imageId
     * @return BeMaverick_Image
     */
    public static function getInstance( $site, $imageId )
    {
        if ( ! $imageId ) {
            return false;
        }

        if ( ! isset( self::$_instance[$imageId] ) ) {
            self::$_instance[$imageId] = new self( $site, $imageId );
        }

        return self::$_instance[$imageId];
    }

    /**
     * Create a new image
     *
     * @param BeMaverick_Site $site
     * @param string $filename
     * @param string $contentType
     * @param integer $width
     * @param integer $height
     * @return BeMaverick_Image
     */
    public static function createImage( $site, $filename, $contentType, $width, $height )
    {
        $daImage = BeMaverick_Da_Image::getInstance();
        
        $imageId = $daImage->createImage( $filename, $contentType, $width, $height );

        return self::getInstance( $site, $imageId );
    }

    /**
     * Save the image that was uploaded
     *
     * @param BeMaverick_Site $site
     * @param string $imageName
     * @param Sly_Errors $errors
     * @return void
     */
    public static function saveOriginalImage( $site, $imageName, &$errors )
    {
        $systemConfig = $site->getSystemConfig();

        $validTypeToExtension = array(
            'image/gif'   => 'gif',
            'image/png'   => 'png',
            'image/x-png' => 'png',
            'image/jpg'   => 'jpg',
            'image/jpeg'  => 'jpg',
            'image/pjpeg' => 'jpg',
        );

        $file = @$_FILES[$imageName];

        $type = @$file['type'];

        if ( ! isset( $validTypeToExtension[$type] ) ) {
            $errors->setError( '', 'IMAGE_TYPE_UNSUPPORTED' );
            return;
        }

        $filename = null;

        if ( ! is_uploaded_file( $file['tmp_name'] ) && ! file_exists( $file['tmp_name'] ) ) {
            $errors->setError( '', 'IMAGE_UNKNOWN_ERROR' );
            return;
        }

        $img = new Imagick( $file['tmp_name'] );

        //  hash the processed file to get the name of the file.
        $imageBlob = $img->getImagesBlob();
        $filename = md5( $imageBlob ) . '.' . $validTypeToExtension[$type];

        // get the backing store
        $amazonConfig = $site->getAmazonConfig();
        $bucketName = $systemConfig->getSetting( 'AWS_S3_IMAGE_BUCKET_NAME' );
        $amazonBackingStore = new Sly_Image_BackingStore_Amazon( $bucketName, $amazonConfig );

        $rc = $amazonBackingStore->putImageBlob( $imageBlob, $filename );

        // error_log('$amazonConfig => '.json_encode($amazonConfig, JSON_PRETTY_PRINT));
        // error_log('$rc => '.json_encode($rc, JSON_PRETTY_PRINT));
        // error_log('$filename => '.$filename);

        if ( ! $rc ) {
            $errors->setError( '', 'IMAGE_UNKNOWN_ERROR' );
            return;
        }

        $width = $img->getImageWidth();
        $height = $img->getImageHeight();

        return BeMaverick_Image::createImage( $site, $filename, $type, $width, $height );
    }

    /**
     * Get the image id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->_imageId;
    }

    /**
     * Get the site
     *
     * @return BeMaverick_Site
     */
    public function getSite()
    {
        return $this->_site;
    }

    /**
     * Get the filename
     *
     * @return string
     */
    public function getFilename()
    {
        return $this->_daImage->getFilename( $this->getId() );
    }

    /**
     * Get the content type
     *
     * @return string
     */
    public function getContentType()
    {
        return $this->_daImage->getContentType( $this->getId() );
    }

    /**
     * Get the width
     *
     * @return string
     */
    public function getWidth()
    {
        return $this->_daImage->getWidth( $this->getId() );
    }
    
    /**
     * Get the height
     *
     * @return string
     */
    public function getHeight()
    {
        return $this->_daImage->getHeight( $this->getId() );
    }

    /**
     * Get the crop x
     *
     * @return string
     */
    public function getCropX()
    {
        return $this->_daImage->getCropX( $this->getId() );
    }

    /**
     * Set the crop x
     *
     * @param integer $cropX
     * @return void
     */
    public function setCropX( $cropX )
    {
        $this->_daImage->setCropX( $this->getId(), $cropX );
    }
    
    /**
     * Get the crop y
     *
     * @return string
     */
    public function getCropY()
    {
        return $this->_daImage->getCropY( $this->getId() );
    }

    /**
     * Set the crop y
     *
     * @param integer $cropY
     * @return void
     */
    public function setCropY( $cropY )
    {
        $this->_daImage->setCropY( $this->getId(), $cropY );
    }

    /**
     * Get the crop width
     *
     * @return string
     */
    public function getCropWidth()
    {
        return $this->_daImage->getCropWidth( $this->getId() );
    }

    /**
     * Set the crop width
     *
     * @param integer $cropWidth
     * @return void
     */
    public function setCropWidth( $cropWidth )
    {
        $this->_daImage->setCropWidth( $this->getId(), $cropWidth );
    }
    
    /**
     * Get the crop height
     *
     * @return string
     */
    public function getCropHeight()
    {
        return $this->_daImage->getCropHeight( $this->getId() );
    }

    /**
     * Set the crop height
     *
     * @param integer $cropHeight
     * @return void
     */
    public function setCropHeight( $cropHeight )
    {
        $this->_daImage->setCropHeight( $this->getId(), $cropHeight );
    }

    /**
     * Check if the image is a gif
     *
     * @return boolean
     */
    public function isGif()
    {
        if ( $this->getContentType() == 'image/gif' ) {
            return true;
        }
        
        return false;
    }

    /**
     * Get the image url
     *
     * @param integer $width
     * @param integer $height
     * @param integer $cropX
     * @param integer $cropY
     * @param integer $cropWidth
     * @param integer $cropHeight
     * @param string $algorithm
     * @param integer $compressionQuality
     * @param integer $frame
     * @return string
     */
    public function getUrl( $width = null, $height = null, $cropX = null, $cropY = null, $cropWidth = null, $cropHeight = null, $algorithm = null, $compressionQuality = null, $frame = null )
    {
        $filename = $this->getFilename();

        $systemConfig = $this->_site->getSystemConfig();
        $imageHost = $systemConfig->getSetting( 'SYSTEM_IMAGE_HOST' );
        $imageProtocol = $systemConfig->getSetting( 'SYSTEM_IMAGE_PROTOCOL' );
        $imageSalt = $systemConfig->getSetting( 'SYSTEM_IMAGE_SALT' );

        // we always want some kind of compression by default, so they have to explicitly
        // put a -1 if they don't want compression
        if ( $compressionQuality === null ) {
            $compressionQuality = $systemConfig->getSetting( 'SYSTEM_IMAGE_COMPRESSION_QUALITY' );
        }

        $baseUri = "/image/$filename?";

        if ( $width )                  { $baseUri .= "&x=$width"; }
        if ( $height )                 { $baseUri .= "&y=$height"; }
        if ( $cropX !== null )         { $baseUri .= "&cx=$cropX"; }
        if ( $cropY !== null )         { $baseUri .= "&cy=$cropY"; }
        if ( $cropWidth )              { $baseUri .= "&cw=$cropWidth"; }
        if ( $cropHeight )             { $baseUri .= "&ch=$cropHeight"; }
        if ( $algorithm )              { $baseUri .= "&nmd=$algorithm"; }
        if ( $compressionQuality > 0 ) { $baseUri .= "&icq=$compressionQuality"; }
        if ( $frame )                  { $baseUri .= "&frame=$frame"; }

        $signature = md5( $imageSalt . $baseUri );

        return "$imageProtocol://$imageHost$baseUri&sig=$signature";
    }

    /**
     * get basic image data
     *
     * @param BeMaverick_Site $site
     * @param Int $imageId
     * @return void
     */
    public static function getImageDetails( $site, $imageId )
    {
        // check if already added
        $image = self::getInstance( $site, $imageId );
        $systemConfig = $site->getSystemConfig();

        $width = $image->getWidth();
        $width = $width ? (int)$width : null;

        $height = $image->getHeight();
        $height = $height ? (int)$height : null;

        $imageData = array(
            'imageId' => $image->getId().'',
            'url' => $image->getUrl(),
            'urlProtocol' => $systemConfig->getSetting( 'SYSTEM_IMAGE_PROTOCOL' ),
            'urlHost' => $systemConfig->getSetting( 'SYSTEM_IMAGE_HOST' ),
            'filename' => $image->getFilename(),
            'width' => $width,
            'height' => $height,
        );

        $data = $imageData;

        return $data;
    }

    /**
     * Save the image from values only (no upload)
     *
     * @param BeMaverick_Site $site
     * @param string $filename
     * @param int $height
     * @param int $width
     * @param string $mimeType
     * @param Sly_Errors $errors
     * @return void
     */
    public static function saveImageBasic( 
        $site, 
        $filename, 
        $width,
        $height,
        $mimeType = null,
        &$errors = null 
    ) {

        // $systemConfig = $this->_site->getSystemConfig();
        // $imageBucketName = $systemConfig->getSetting( 'AWS_S3_IMAGE_BUCKET_NAME' );

        if ( ! $mimeType ) {
            $mimeType = self::getMimeTypeFromFilename( $filename );
        }

        if ( is_null($mimeType) ) {
            $errors->setError( '', 'IMAGE_TYPE_UNSUPPORTED' );
            return;
        }

        /** TODO: Head the s3 object based on the $imageBucketName and $filename
         * to see if it exists
         */ 

        return self::createImage( $site, $filename, $mimeType, $width, $height );
    }

    public static function getMimeTypeFromFilename( $filename ) {

        $filenameParts = explode('.', $filename);
        $extension = $filenameParts[count($filenameParts) - 1];
        $mimeType = null;

        $validTypeToExtension = array(
            'image/gif'   => 'gif',
            'image/png'   => 'png',
            'image/x-png' => 'png',
            'image/jpg'   => 'jpg',
            'image/jpeg'  => 'jpg',
            'image/pjpeg' => 'jpg',
        );

        $validExtensionToType = array(
            'gif' => 'image/gif',
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
        );

        if (isset($validExtensionToType[$extension])) {
            $mimeType = $validExtensionToType[$extension];
        }
        
        return $mimeType;
    }

}

?>
