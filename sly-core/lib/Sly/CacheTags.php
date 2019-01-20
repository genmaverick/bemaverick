<?php

/**
 * Base class for handling tags with the memcache
 *
 * @description Base class for handling tags with the memcache.
 * @category Sly
 * @package Sly_CacheTags
 */
class Sly_CacheTags
{
    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = null;

    /**
     * @var Zend_Cache_Core
     * @access protected
     */
    protected $_cache;

    /**
     * @var boolean
     * @access protected
     */
    protected $_cacheSupportsTags;

    /**
     * @var boolean
     * @access protected
     */
    public $_debugLegend;

    /**
     * Constructor
     *
     * @var Zend_Cache_Core
     */
    public function __construct( $cache )
    {
        $this->_cache = $cache;
        $this->_cacheSupportsTags = $cache->isTagSupported();
    }

    /**
     * Retrieves the cache tags instance.
     *
     * @return Sly_CacheTags
     */
    public static function getInstance( $cache )
    {
        if ( ! self::$_instance ) {
            self::$_instance = new self( $cache );
        }

        return self::$_instance;
    }
    
    /**
     * Set the cache.
     *
     * @var Zend_Cache_Core
     */
    public function setCache( $cache )
    {
        $this->_cache = $cache;
        $this->_cacheSupportsTags = $cache->isTagSupported();
    }
    
    /**
     * Get the cache.
     *
     * @return Zend_Cache_Core
     */
    public function getCache()
    {
        return $this->_cache;
    }
            
    /**
     * Attach the key to the tag
     *
     * @var string $key
     * @var string $tag
     */
    public function setTag( $cacheId, $tag )
    {
        if ( $this->_cacheSupportsTags ) {
            return $this->_cache->addKeyToTag( $cacheId, $tag );
        }
        
        //check if tag already exists
        if ( ! $keyData = $this->_cache->load( $tag ) ) {
            $keyData = array();
            $keyData[] = $cacheId;
            $this->_cache->save( $keyData, $tag );
        }
        else if ( ! in_array( $cacheId, $keyData ) ) {
            $keyData[] = $cacheId;
            $this->_cache->save( $keyData, $tag );
        }
    }
    
    /**
     * Attach the key to all the tags
     *
     * @var string $key
     * @var array $tags
     */
    public function setTags( $cacheId, $tags )
    {
        foreach( $tags as $tag) {
            $this->setTag( $cacheId, $tag );
        }

    }

    /**
     * Clear all keys for an array of tags and clear the tags.
     *
     * @var array $tags
     * @return boolean $success
     */
    public function clearCacheIdsByTags( $tags )
    {
        // make sure we don't do duplicates
        $tags = array_unique( $tags );
        
        $success = true;
        
        foreach( $tags as $tag ) {
            if ( ! $this->clearCacheIdsByTag( $tag ) ) {
                $success = false;
            }
        }
        
        return $success;
    }
    
    /**
     * Clear all keys for a tag and clear the tag
     *
     * @var string $tag
     * @return boolean $success
     */
    public function clearCacheIdsByTag( $tag )
    {
        if ( $this->_cacheSupportsTags ) {
            return $this->_cache->clearCacheIdsByTag( $tag );
        }
        
        if ( ! $this->_cache->waitForLock( $tag ) ) {
            // wait for lock failed.  Should throw an exception
            return false;
        }
        
        $cacheIds = $this->_cache->load( $tag );

        if ( $cacheIds ) {
            foreach( $cacheIds as $cacheId ) {
                $this->_cache->remove( $cacheId );
            }
        }
        
        $this->_cache->remove( $tag );
        
        $this->_cache->clearLock( $tag );
        
        return true;
    }

    public function clearCacheIdsByTagCallback( $tag, $callback )
    {
        if ( ! $this->_cache->waitForLock( $tag ) ) {
            // wait for lock failed.  Should throw an exception
            return false;
        }
        
        $cacheIds = $this->_cache->load( $tag );

        if ( $cacheIds ) {
            foreach( $cacheIds as $cacheId ) {
                call_user_func($callback, $cacheId);
                $this->_cache->remove( $cacheId );
            }
        }
        
        $this->_cache->remove( $tag );
        
        $this->_cache->clearLock( $tag );
        
        return true;
    }
    
    /**
     * Clear the entire cache completely
     *
     * @return void
     */
    public function clearAll()
    {
        $this->_cache->clean( 'all' );
    }
    
    /**
     * Encode a string
     *
     * @var string $item
     * @return string $encodedItem
     */
    public function encodeItem( $item )
    {
        $encoded = md5( $item );

        if ( defined( 'SYSTEM_DEBUG_MODE' ) && SYSTEM_DEBUG_MODE ) {
            $this->_debugLegend[$encoded] = $item;
        }

        return $encoded;
    }

}

?>
