<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

/**
 * Class for access to the database table: image
 *
 */
class BeMaverick_Da_Image extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Image
     * @access protected
     */
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'image';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'image_id' );

    /**
     * @var array
     * @access protected
     */
    protected $_dataTypes = array( 'updated_ts' => 'timestamp' );

    /**
     * @var boolean
     * @access protected
     */
    protected $_rowCacheEnabled = true;

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array(
        'getFilename'     => 'filename',
        'getContentType'  => 'content_type',
        'getWidth'        => 'width',
        'getHeight'       => 'height',
        'getCropX'        => 'crop_x',
        'getCropY'        => 'crop_y',
        'getCropWidth'    => 'crop_width',
        'getCropHeight'   => 'crop_height',

        'setFilename'     => 'filename',
        'setContentType'  => 'content_type',
        'setWidth'        => 'width',
        'setHeight'       => 'height',
        'setCropX'        => 'crop_x',
        'setCropY'        => 'crop_y',
        'setCropWidth'    => 'crop_width',
        'setCropHeight'   => 'crop_height',
    );

    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Image
     */
    public static function getInstance()
    {
        if (null === self::$_instance) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }

    /**
     * Create a new image
     *
     * @param string $filename
     * @param string $contentType
     * @param integer $width
     * @param integer $height
     * @return integer
     */
    public function createImage( $filename, $contentType, $width, $height )
    {
        $data = array(
            'filename'     => $filename,
            'content_type' => $contentType,
            'width'        => $width,
            'height'       => $height,
        );

        return $this->insert( $data );
    }
    
}

?>
