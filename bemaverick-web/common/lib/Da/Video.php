<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_Video extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Video
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'video';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'video_id' );

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
        'getFilename'       => 'filename',
        'getWidth'          => 'width',
        'getHeight'         => 'height',
        'getHLSFormat'      => 'hls_format',
        'getHLSPlaylistname'=> 'hls_playlistName',

        'setFilename'       => 'filename',
        'setWidth'          => 'width',
        'setHeight'         => 'height',
        'setHLSFormat'      => 'hls_format',
        'setHLSPlaylistname'=> 'hls_playlistName',
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Video
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
     * Create a new video
     *
     * @param string $filename
     * @param integer $width
     * @param integer $height
     * @return integer
     */
    public function createVideo( $filename,  $width, $height )
    {
        $data = array(
            'filename' => $filename,
            'width' => $width,
            'height' => $height,
        );

        return $this->insert( $data, $this->_tags );
    }

    /**
     * Get a list of video ids
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getVideoIds( $filterBy, $sortBy, $count, $offset )
    {
        $select = array( 'video_id' );

        $where = array();
        if ( @$filterBy['userId'] ) {
            $where[] = "challenge.user_id = " . $filterBy['userId'];
        }

        $orderBy = array( 'video_id asc' );

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, null, $count, $offset );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Get the count of videos
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getVideoCount( $filterBy )
    {
        $select = array( 'count(distinct(video_id))' );

        $where = array();

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchCount( $sql, $this->_tags );
    }

    /**
     * Delete the video
     *
     * @param integer $videoId
     * @return void
     */
    public function deleteVideo( $videoId )
    {
        $this->deleteRow( array( $videoId ), $this->_tags );
    }

}

?>
