<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_VideoEncoderJob extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_VideoEncoderJob
     * @access protected
     */
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'video_encoder_job';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'job_id' );

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
        'getVideoId'    => 'video_id',
        'getStatus'     => 'job_status',

        'setVideoId'    => 'video_id',
        'setStatus'     => 'job_status',

    );

    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_VideoEncoderJob
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
     * Create a new encoding job
     *
     * @param integer $jobId
     * @param integer $videoId
     * @param String $status
     * @return void
     */
    public function createEncodingJob( $videoId, $jobId, $status )
    {
        $data = array(
            'job_id' => $jobId,
            'video_id' => $videoId,
            'job_status' => $status,
        );
        $this->insert( $data, $this->_tags, true );
    }

    /**
     * Get a list of job ids
     *
     * @param integer $videoId
     * @return integer[]
     */
    public function getJobIds( $videoId )
    {
        $select = array( 'job_id' );

        $where = array();
        $where[] = "video_id = $videoId";

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchColumns( $sql );
    }

    /**
     * Get a video object
     *
     * @param integer $jobId
     * @return BeMaverick_Video
     */
    public function getVideoIdByJobId( $jobId )
    {
        $where = array();
        $where[] = "job_id = '" . $this->quote( $jobId ) . "'";

        $sql = $this->createSqlStatement( array( 'video_id' ), $where );

        return $this->fetchOne( $sql, $this->_tags );
    }

    /**
     * Delete the video encoder job
     *
     * @param integer $jobId
     * @return void
     */
    public function deleteVideoEncoderJob( $jobId )
    {
        $this->deleteRow( array( $jobId ), $this->_tags );
    }

}

?>
