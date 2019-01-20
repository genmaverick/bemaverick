<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_ProfileCoverPresetImage extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_ProfileCoverPresetImage
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'profile_cover_preset_image';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'profile_cover_preset_image_id' );

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
        'getImageId'     => 'image_id',

        'setImageId'     => 'image_id',
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_ProfileCoverPresetImage
     */
    public function getInstance()
    {
        if (null === self::$_instance) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }

    /**
     * Constructor to set tags
     */
    public function __construct()
    {
        $this->_tags = array( $this->_database.'.'.$this->_table );
    }

    /**
     * Create a new preset
     *
     * @param string $imageId
     * @return integer
     */
    public function createProfileCoverPresetImage( $imageId )
    {
        $data = array(
            'image_id' => $imageId,
        );

        return $this->insert( $data, $this->_tags );
    }

    /**
     * Get a list of preset ids
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getProfileCoverPresetImageIds( $filterBy, $sortBy, $count, $offset )
    {
        $select = array( 'profile_cover_preset_image_id' );

        $where = array();

        $orderBy = array( 'profile_cover_preset_image_id asc' );

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, null, $count, $offset );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Get image_id using profile_cover_preset_image_id
     *
     * @param integer $presetImageId
     * @return integer
     */
    public function getProfileCoverPresetRealImageId( $presetImageId )
    {
        $select = array( 'image_id' );

        $where = array();
        $where[] = "profile_cover_preset_image_id = '" . strval($presetImageId) . "'";

        $sql = $this->createSqlStatement( $select, $where, null, null, null, null, null );

        return $this->fetchOne( $sql );
    }

    /**
     * Get a random preset image_id
     *
     * @return integer
     */
    public function getRandomProfileCoverPresetImageId() {

        $select = array( 'profile_cover_preset_image_id' );
        $where = array( rand(1,9999999).' > 0' ); // random clause to disable query caching
        $orderBy = array( 'RAND()' );
        $count = 1;
        $offset = 0;
        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, null, $count, $offset );

        $result = $this->fetchColumns( $sql, $this->_tags );

        return $result[0];
    }

}

?>
