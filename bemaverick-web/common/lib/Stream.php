<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Stream.php' );

class BeMaverick_Stream
{
    const DEFAULT_DISPLAY_LIMIT = 10;
    const DEFAULT_ROTATE_FREQUENCY = 12;
    const DEFAULT_ROTATE_COUNT = 10;
    const DEFAULT_DELAY = 0;
    const STREAM_TYPES = [
        'AD_BLOCK' => 'Advertisement Block',
        'FEATURED_RESPONSES' => 'Featured Responses',
        'FEATURED_CHALLENGES' => 'Featured Challenges',
        'LATEST_RESPONSES' => 'Latest Responses',
    ];

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
    protected $_streamId = null;

    /**
     * @var BeMaverick_Da_Stream
     * @access protected
     */
    protected $_daStream;

    /**
     * Class constructor
     *
     * @param BeMaverick_Site $site
     * @param integer $streamId
     * @return void
     */
    public function __construct( $site, $streamId )
    {
        $this->_site = $site;
        $this->_streamId = $streamId;
        $this->_daStream = BeMaverick_Da_Stream::getInstance();
    }

    /**
     * Retrieves the stream instance.
     *
     * @param BeMaverick_Site $site
     * @param integer $streamId
     * @return BeMaverick_Stream
     */
    public static function getInstance( $site, $streamId )
    {
        if ( ! $streamId ) {
            return null;
        }
        
        if ( ! isset( self::$_instance[$streamId] ) ) {

            $daStream = BeMaverick_Da_Stream::getInstance();

            // make sure stream exists
            if ( ! $daStream->isKeysExist( array( $streamId ) ) ) {
                self::$_instance[$streamId] = null;
            }
            else {
                self::$_instance[$streamId] = new self( $site, $streamId );
            }
        }

        return self::$_instance[$streamId];

    }

    /**
     * Create a stream
     *
     * @param BeMaverick_Site $site
     * @param string $label
     * @param hash $definition
     * @param integer $sortOrder
     * @return BeMaverick_Stream
     */
    public static function createStream( $site, $label, $definition, $sortOrder, $modelType='challenge', $streamType=null, $status='active' )
    {
        $daStream = BeMaverick_Da_Stream::getInstance();

        $streamId = $daStream->createStream( $label, $definition, $sortOrder, $modelType, $streamType, $status );
        
        // we might have already tried to get this stream for some reason, so update
        // the self instance here and return it
        self::$_instance[$streamId] = new self( $site, $streamId );
        
        return self::$_instance[$streamId];
    }

    /**
     * Get a list of streams
     *
     * @param BeMaverick_Site $site
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Stream[]
     */
    public static function getStreams( $site, $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $daStream = BeMaverick_Da_Stream::getInstance();

        $streamIds = $daStream->getStreamIds( $filterBy, $sortBy, $count, $offset );

        $streams = array();
        foreach ( $streamIds as $streamId ) {
            $streams[] = self::getInstance( $site, $streamId );
        }

        return $streams;
    }

    /**
     * Get a count of streams
     *
     * @param hash $filterBy
     * @return integer
     */
    public static function getStreamCount( $filterBy = null )
    {
        $daStream = BeMaverick_Da_Stream::getInstance();

        return $daStream->getStreamCount( $filterBy );
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
        return $this->_streamId;
    }

    /**
     * Get the label
     *
     * @return string
     */
    public function getLabel()
    {
        return $this->_daStream->getLabel( $this->getId() );
    }

    /**
     * Set the label
     *
     * @param string $label
     * @return void
     */
    public function setLabel( $label )
    {
        $this->_daStream->setLabel( $this->getId(), $label );
    }

    /**
     * Get the modelType
     *
     * @return string
     */
    public function getModelType()
    {
        return $this->_daStream->getModelType( $this->getId() );
    }

    /**
     * Set the modelType
     *
     * @param string $modelType
     * @return void
     */
    public function setModelType( $modelType )
    {
        $this->_daStream->setModelType( $this->getId(), $modelType );
    }

    /**
     * Get the streamType
     *
     * @return string
     */
    public function getStreamType()
    {
        return $this->_daStream->getStreamType( $this->getId() );
    }

    /**
     * Get the streamType
     *
     * @return string
     */
    public function getStreamTypePretty($streamType = null)
    {
        $type = $streamType ?? $this->getStreamType();
        $pretty = self::STREAM_TYPES[$type] ?? $type;
        return $pretty;
    }

    /**
     * Set the streamType
     *
     * @param string $streamType
     * @return void
     */
    public function setStreamType( $streamType )
    {
        $this->_daStream->setStreamType( $this->getId(), $streamType );
    }

    /**
     * Get the definition of the stream
     *
     * @return hash
     */
    public function getDefinition($getEndpoint = true)
    {
        $definition = $this->_daStream->getDefinition( $this->getId() );
        $return = array();
        
        if ( $definition ) {
            $return = json_decode( $definition, true );
            $limit = $return['logic']['displayLimit'] ?? BeMaverick_Stream::DEFAULT_DISPLAY_LIMIT;
            $featuredType = $return['featuredType'] ?? null;
            $endpoint = $getEndpoint ? $this->getEndpoint($limit, $featuredType) : null;
            $return = array_merge($return, $endpoint);
        }

        // Stream Type
        $return['label'] = $this->getLabel();
        $return['status'] = $this->getStatus();
        $return['modelType'] = $this->getModelType();
        $return['streamType'] = $this->getStreamType();

        return $return;        
    }

    /**
     * Get the definition of the stream
     *
     * @return Array
     */
    public function getEndpoint($limit = 10, $featuredType = null)
    {
        $streamId = $this->getId();
        $systemConfig = $this->_site->getSystemConfig();
        $definition = json_decode($this->_daStream->getDefinition( $streamId ));
        $environment = $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );

        $streamType = $this->getStreamType();
        $featuredType = $featuredType ?? 'stream-'.$this->getId();
        $host = ( $environment == 'production' ) ? "api.bemaverick.com" : "dev-api.bemaverick.com";

        // if($streamId==12) die(print_r($definition,true)); // else return array();
        $challengeId = $definition->challengeId ?? null;
        $delay = $definition->logic->delay ?? BeMaverick_Stream::DEFAULT_DELAY;

        $endpoint = array();
        switch($streamType) {
            case 'FEATURED_CHALLENGES':
                $endpoint = array(
                    "url" => array(
                        "host" => $host,
                        "pathname" => "/v1/site/challenges",
                        "query" => array(
                            "appKey" => "__REQUIRED__",
                            "count" => $limit,
                            "sort" => "featuredAndStartTimestamp",
                            "featuredType" => $featuredType
                        ),
                    ),
                    "method" => "get",
                    "responseVersion" => "v1",
                );
                break;
            case 'FEATURED_RESPONSES':
                $endpoint = array(
                    "url" => array(
                        "host" => $host,
                        "pathname" => "/v1/site/responses",
                        "query" => array(
                            "appKey" => "__REQUIRED__",
                            "count" => $limit,
                            "sort" => "featured",
                            "featuredType" => $featuredType
                        ),
                    ),
                    "method" => "get",
                    "responseVersion" => "v1",
                );
                break;
            case 'LATEST_RESPONSES':
                $endpoint = array(
                    "url" => array(
                        "host" => $host,
                        "pathname" => "/v1/site/responses",
                        "query" => array(
                            "appKey" => "__REQUIRED__",
                            "count" => $limit,
                            "sort" => "createdTimestamp",
                            "sortOrder" => "desc",
                            "delay" => $delay,
                            "hideFromStreams" => 0,
                        ),
                    ),
                    "method" => "get",
                    "responseVersion" => "v1",
                );
                if( $challengeId ) {
                    $endpoint['url']['query']['challengeId'] = $challengeId;
                }
                break;
            case 'AD_BLOCK':
            default:
                break;
        }

        return $endpoint;
    }

    /**
     * Set the definition
     *
     * @param hash $definition
     * @return void
     */
    public function setDefinition( $definition )
    {
        $definition = $definition ? json_encode( $definition ) : null;

        $this->_daStream->setDefinition( $this->getId(), $definition );
    }

    /**
     * Get the sort order
     *
     * @return string
     */
    public function getSortOrder()
    {
        return $this->_daStream->getSortOrder( $this->getId() );
    }

    /**
     * Set the sort order
     *
     * @param string $sortOrder
     * @return void
     */
    public function setSortOrder( $sortOrder )
    {
        $this->_daStream->setSortOrder( $this->getId(), $sortOrder );
    }

    /**
     * Get the sort logic
     *
     * @return string
     */
    public function getSortLogic()
    {
        $defaultSortLogic = 'custom';
        $definition = $this->getDefinition();
        return $definition['sortLogic'] ?? $defaultSortLogic;
    }

    /**
     * Get the status
     *
     * @return string
     */
    public function getStatus()
    {
        return $this->_daStream->getStatus( $this->getId() );
    }

    /**
     * Set the status
     *
     * @param string $status
     * @return void
     */
    public function setStatus( $status )
    {
        $this->_daStream->setStatus( $this->getId(), $status );
    }

    /** 
     * Rotate the related stream responses or challenges
     */
    public function rotate($modelType = null) {
        $site = $this->_site;

        $definition = $this->getDefinition();
        $rotateCount = $definition['logic']['rotateCount'];
        $featuredType = $definition['featuredType'] ?? 'stream-'.$this->getId();
        $modelType = $modelType ? $modelType : $this->getModelType();

        $records = array();
        if ($modelType == BeMaverick_Site::MODEL_TYPE_RESPONSE) {
            $records = $site->getFeaturedResponses( $featuredType );
        } elseif ($modelType == BeMaverick_Site::MODEL_TYPE_CHALLENGE) {
            $records = $site->getFeaturedChallenges( $featuredType );
        }

        // Load ids in order
        $ids = array();
        foreach($records as $i => $record) {
            $ids[] = $record->getId();
        }
        
        // Rotate elements to the end of the array
        for ($j=0; $j<$rotateCount; $j++) {
            $elem = array_shift($ids);
            $ids[] = $elem;
        }

        // update the featured models with this new order
        $site->updateFeaturedModels( $featuredType, $modelType, $ids );

        // Clear cache
        $this->clearCache();
    }

    /**
     * Set the Last Rotated Date
     *
     * @return void
     */
    public function setLastRotated($time = null)
    {
        $definition = $this->getDefinition();
        $definition['logic'] = is_array($definition['logic']) ? $definition['logic'] : [];
        // $lastRotated = $time ?? date('Y-m-d h:i:s a');
        $lastRotated = $time ?? time();
        $definition['logic']['lastRotated'] = $lastRotated;
        $this->setDefinition($definition);
    }

    /**
     * Check if a Rotation should be performed
     *
     * @return void
     */
    public function checkRotation()
    {
        // error_log('checkRotation()::'.$this->getId());
        $definition = $this->getDefinition();
        $rotateFrequency = $definition['logic']['rotateFrequency'] ?? 0;
        $lastRotated = $definition['logic']['lastRotated'] ?? null;
        $now = time();
        
        // If rotation frequncy is enabled
        if($rotateFrequency > 0) {

            if ($lastRotated) {
                // Check for next rotation time
                $nextRotation = $lastRotated + ($rotateFrequency * 60 * 60);  // hours => seconds
                if ($now > $nextRotation) {
                    $this->rotate();
                }
            } else {
                // Never rotated
                $this->rotate();
            }
        } 
    }

    /**
     * Set the Image
     *
     * @return void
     */
    public function setImage($image)
    {
        // die('setImage <pre>'.print_r($image,true));
        $site = $this->_site;
        $imageId = $image->getId();
        $definition = $this->getDefinition();
        $imageDetails = $image->getImageDetails($site, $imageId);
        $definition['image'] = $imageDetails;
        $definition['imageUri'] = $imageDetails['url'];
        $this->setDefinition($definition);
        $this->save();
    }

    /**
     * Save the stream
     *
     * @return void
     */
    public function save()
    {
        $this->clearCache();
        $this->_daStream->save();
    }

    /**
     * Delete the stream
     *
     * @return void
     */
    public function delete()
    {
        $this->_daStream->deleteStream( $this->getId() );
    }

    public function clearCache() {

        $definition = $this->getDefinition();
        $featuredType = $definition['featuredType'] ?? 'stream-'.$this->getId();

        // Clean cache with matching tags from redis cache
        $zendCache = Zend_Registry::get( 'cache' );
        $tag = "bemaverick.featured_type.".$featuredType;
        if ( $zendCache ) {
            $zendCache->clean(
                Zend_Cache::CLEANING_MODE_MATCHING_TAG,
                array($tag)
            );
        }
    }

    /**
     * Update the stream from an Input object
     *
     * @return void
     */
    public function updateStreamFromInput($input, $modelType = null) {


        $systemConfig = $this->_site->getSystemConfig();
        $environment = $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );

        if ($this->getId() && isset($input)) {
            $modelType = $modelType ?? null;
            $label = $input->label ?? null;
            $sortLogic = $input->sortLogic ?? 'custom';
            $paginated = $input->paginated ?? false;
            $contentStatus = $input->contentStatus ?? null;
            $displayLimit = $input->displayLimit ?? null;
            $rotateFrequency = $input->rotateFrequency ?? null;
            $rotateCount = $input->rotateCount ?? null;
            $rotateOnSave = $input->rotateOnSave ?? false;
            $deeplinkModelType = $input->deeplinkModelType ?? null;
            $deeplinkModelId = $input->deeplinkModelId ?? null;
            $delay = $input->delay ?? null;
            $challengeId = $input->challengeId ?? null;

            // Load and modify the definition
            $definition = $this->getDefinition();
            $definition['sortLogic'] = $sortLogic;
            $definition['paginated'] = $paginated ? true : false;
            $definition['logic'] = is_array($definition['logic']) ? $definition['logic'] : array();
            $definition['logic']['displayLimit'] = $displayLimit;
            $definition['logic']['rotateFrequency'] = $rotateFrequency;
            $definition['logic']['rotateCount'] = $rotateCount;
            $definition['logic']['delay'] = $delay;
            $definition['challengeId'] = $challengeId;

            // remove deeplink and set to null
            if(!$deeplinkModelType) {
                $definition['link'] = null;
            }
            switch ( $deeplinkModelType ) {
                case 'responses':
                    $linkModelType = BeMaverick_Site::MODEL_TYPE_RESPONSE;
                    break;
                case 'challenges':
                    $linkModelType = BeMaverick_Site::MODEL_TYPE_CHALLENGE;
                    break;
                case 'users':
                    $linkModelType = BeMaverick_Site::MODEL_TYPE_USER;
                    break;
                default:
                    $linkModelType = $deeplinkModelType;
            }

            switch ( $deeplinkModelType ) {
                case 'responses':
                    $linkModelType = BeMaverick_Site::MODEL_TYPE_RESPONSE;
                    break;
                case 'challenges':
                    $linkModelType = BeMaverick_Site::MODEL_TYPE_CHALLENGE;
                    break;
                case 'users':
                    $linkModelType = BeMaverick_Site::MODEL_TYPE_USER;
                    break;
                default:
                    $linkModelType = $deeplinkModelType;
            }

            if ($deeplinkModelType && $deeplinkModelId) {
                $prefix = ($environment == 'production') ? 'maverick://maverick' : 'devmaverick://maverick';
                $definition['link'] = array(
                    'modelType' => $deeplinkModelType,
                    'modelId' => $deeplinkModelId,
                    'deeplink' => "$prefix/$linkModelType/$deeplinkModelId",
                );
            }

            $this->setLabel($label);
            $this->setStatus($contentStatus);
            $this->setDefinition($definition);
            $this->save();

            /** Apply sorting changes based on rotation rules */
            if($rotateOnSave && $modelType) {
                $this->rotate($modelType);
            }  
        }

    }

    /**
     * Get the paginated flag
     *
     * @return string
     */
    public function getPaginated()
    {
        $definition = $this->getDefinition();
        $paginated = $definition['paginated'] ?? false;
        return $paginated;
    }

    /**
     * Set the paginated flag
     *
     * @return string
     */
    public function setPaginated($pagination)
    {
        $definition = $this->getDefinition();
        $definition['paginated'] = $pagination;
        $this->setDefinition($definition);
    }
}

?>
