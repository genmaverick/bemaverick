<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Video.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/VideoEncoderJob.php' );

class BeMaverick_Video
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
    protected $_videoId = null;

    /**
     * @var BeMaverick_Da_Video
     * @access protected
     */
    protected $_daVideo;

    /**
     * @var BeMaverick_Da_VideoEncoderJob
     * @access protected
     */
    protected $_daVideoEncoderJob;

    /**
     * Class constructor
     *
     * @param BeMaverick_Site $site
     * @param integer $videoId
     * @return void
     */
    public function __construct( $site, $videoId )
    {
        $this->_site = $site;
        $this->_videoId = $videoId;
        $this->_daVideo = BeMaverick_Da_Video::getInstance();
        $this->_daVideoEncoderJob = BeMaverick_Da_VideoEncoderJob::getInstance();
    }

    /**
     * Retrieves the video instance.
     *
     * @param BeMaverick_Site $site
     * @param integer $videoId
     * @return BeMaverick_Video
     */
    public static function getInstance( $site, $videoId )
    {
        if ( ! $videoId ) {
            return null;
        }
        
        if ( ! isset( self::$_instance[$videoId] ) ) {

            $daVideo = BeMaverick_Da_Video::getInstance();

            // make sure video exists
            if ( ! $daVideo->isKeysExist( array( $videoId ) ) ) {
                self::$_instance[$videoId] = null;
            }
            else {
                self::$_instance[$videoId] = new self( $site, $videoId );
            }
        }

        return self::$_instance[$videoId];

    }

    /**
     * Create a video
     *
     * @param BeMaverick_Site $site
     * @param string $filename
     * @param integer $width
     * @param integer $height
     * @return BeMaverick_Video
     */
    public static function createVideo( $site, $filename, $width = null, $height = null )
    {
        $daVideo = BeMaverick_Da_Video::getInstance();

        $videoId = $daVideo->createVideo( $filename, $width, $height );
        
        // we might have already tried to get this video for some reason, so update
        // the self instance here and return it
        self::$_instance[$videoId] = new self( $site, $videoId );
        
        return self::$_instance[$videoId];
    }

    /**
     * Get a list of videos
     *
     * @param BeMaverick_Site $site
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Video[]
     */
    public static function getVideos( $site, $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $daVideo = BeMaverick_Da_Video::getInstance();

        $videoIds = $daVideo->getVideoIds( $filterBy, $sortBy, $count, $offset );

        $videos = array();
        foreach ( $videoIds as $videoId ) {
            $videos[] = self::getInstance( $site, $videoId );
        }

        return $videos;
    }

    /**
     * Get a count of videos
     *
     * @param hash $filterBy
     * @return integer
     */
    public static function getVideoCount( $filterBy = null )
    {
        $daVideo = BeMaverick_Da_Video::getInstance();

        return $daVideo->getVideoCount( $filterBy );
    }

    /**
     * Get the toString function
     *
     * @return string
     */
    public function __toString()
    {
        return $this->getId();
    }

    /**
     * Get the id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->_videoId;
    }

    /**
     * Get the filename
     *
     * @return string
     */
    public function getFilename()
    {
        return $this->_daVideo->getFilename( $this->getId() );
    }

    /**
     * Set the filename
     *
     * @param string $filename
     * @return void
     */
    public function setFilename( $filename )
    {
        $this->_daVideo->setFilename( $this->getId(), $filename );
    }

    /**
     * Get the HLS playlist name
     *
     * @return string
     */
    public function getHLSPlaylistname()
    {
        return $this->_daVideo->getHLSPlaylistname( $this->getId() );
    }

    /**
     * Get the HLS playlist name
     *
     * @param string $playlistname
     * @return void
     */
    public function setHLSPlaylistname( $playlistname )
    {
        $this->_daVideo->setHLSPlaylistname( $this->getId(), $playlistname );
    }

    /**
     * Get the width
     *
     * @return string
     */
    public function getWidth()
    {
        return $this->_daVideo->getWidth( $this->getId() );
    }

    /**
     * Set the width
     *
     * @param string $width
     * @return void
     */
    public function setWidth( $width )
    {
        $this->_daVideo->setWidth( $this->getId(), $width );
    }

    /**
     * Get the height
     *
     * @return string
     */
    public function getHeight()
    {
        return $this->_daVideo->getHeight( $this->getId() );
    }

    /**
     * Set the height
     *
     * @param string $height
     * @return void
     */
    public function setHeight( $height )
    {
        $this->_daVideo->setHeight( $this->getId(), $height );
    }

    /**
     * Create video encoding job
     *
     * @param string $jobId
     * @param string $jobStatus
     * @return void
     */
    public function createEncodingJob( $jobId, $jobStatus )
    {
        $this->_daVideoEncoderJob->createEncodingJob( $this->getId(), $jobId, $jobStatus );
    }

    /**
     * Set the job status of video encoder job
     *
     * @param BeMaverick_Site $site
     * @param string $jobId
     * @param string $jobStatus
     * @param string $playlistname
     * @return void
     */
    public static function setVideoEncoderJobStatus( $site, $jobId, $jobStatus, $playlistname = null )
    {
        $daVideoEncoderJob = BeMaverick_Da_VideoEncoderJob::getInstance();
        $daVideoEncoderJob->setStatus( $jobId, $jobStatus );

        if( $playlistname ) {
            $videoId = $daVideoEncoderJob->getVideoIdByJobId( $jobId );
            $video = self::getInstance( $site, $videoId );
            $video->setHLSPlaylistname( $playlistname );
        }


    }

    /**
     * Get the thumbnail url
     *
     * @return string
     */
    public function getThumbnailUrl()
    {
        $systemConfig = $this->_site->getSystemConfig();
        $videoDomainURL = $systemConfig->getSetting( 'AWS_VIDEO_CLOUD_FRONT_URI' );

        $pathinfo = pathinfo( $this->getFilename() );
        $url = $videoDomainURL . $pathinfo['filename'] . '-thumbnail-00001.jpg';

        return $url;
    }

    /**
     * Get the video url
     *
     * @return void
     */
    public function getVideoUrl()
    {
        $systemConfig = $this->_site->getSystemConfig();
        $videoDomainURL = $systemConfig->getSetting( 'AWS_VIDEO_CLOUD_FRONT_URI' );
        $url = $videoDomainURL . $this->getFilename();

        return $url;
    }

    /**
     * Get the hls video playlist url
     *
     * @return void
     */
    public function getHLSPlaylistUrl()
    {
        $systemConfig = $this->_site->getSystemConfig();
        $videoDomainURL = $systemConfig->getSetting( 'AWS_VIDEO_CLOUD_FRONT_URI' );

        $isHLS = $this->_daVideo->getHLSFormat( $this->getId() );
        if( $isHLS ) {
            $pathInfo = pathinfo( $this->getFilename() );
            $output_prefix = $pathInfo['filename'];
            $url = $videoDomainURL . $output_prefix . "/" . $this->getHLSPlaylistname();
        }else {
            return null;
        }
        return $url;
    }

    /**
     * Check if the video is HLS format
     *
     * @return boolean
     */
    public function isHLSFormat()
    {
        $value = $this->_daVideo->getHLSFormat( $this->getId() );
        return ( $value == 1 ) ? true : false;
    }

    /**
     * Set the video format as HLS
     *
     * @param boolean $isHLS
     * @return void
     */
    public function setHLSFormat( $isHLS )
    {
        $value = $isHLS ? 1 : 0;
        $this->_daVideo->setHLSFormat( $this->getId(), $value );
    }

    /**
     * Save the video
     *
     * @return void
     */
    public function save()
    {
        $this->_daVideo->save();
    }

    /**
     * Delete the video
     *
     * @return void
     */
    public function delete()
    {
        $this->_daVideo->deleteVideo( $this->getId() );
    }

    /**
     * get basic video data
     *
     * @param BeMaverick_Site $site
     * @param integer $videoId
     *
     * @return array
     */
    public static function getVideoDetails( $site, $videoId )
    {
        // get video
        $video = self::getInstance( $site, $videoId );
        if(!$video) return;

        // get vars
        $width = $video->getWidth();
        $width = $width ? (int)$width : null;

        $height = $video->getHeight();
        $height = $height ? (int)$height : null;

        // create video data
        $videoData = array(
            'videoId' => $video->getId().'',
            'videoUrl' => $video->getVideoUrl(),
            'videoHLSUrl' => $video->getHLSPlaylistUrl(),
            'thumbnailUrl' => $video->getThumbnailUrl(),
            'width' => $width,
            'height' => $height,
        );

        return $videoData;
    }

}

?>
