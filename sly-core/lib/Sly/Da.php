<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Array.php' );

/**
 * Base class for access to the database tables.
 *
 * Note: If _rowCacheEnabled == true the each row will be cached with the 
 * primary key ids as the cache key.  This allows for fairly hands free cache maintenance.
 * However, there are some rules that you must follow when using row caching to
 * avoid having stale data in the cache:
 * 1) You cannot use direct sql to insert with wildcard criteria.  Single row 
 *    inserts using the function are ok.
 * 2) If you do use insert you must follow it with a deleteRowCache.
 * 3) You cannot use the _preloadEnabled option with row cache.
 * 4) You cannot do update or delete directly with row cache
 *
 * Problems we have encountered:
 * 1) delete() call was not clearing _data or _preloaded. When the
 * league_team_week_stats got preloaded and then deleted completely, then
 * later did a setField, the field was the same as the preloaded, so it
 * did not get saved and never got written to the database.  By adding
 * clearData() call to the delete(), it would save the data and clear the _data
 * so future setFields would save properly.  The problem with doing that is,
 * save() would do a query to save, which clears the setDatabaseKey() call,
 * so then the delete() no longer has a host and gets the "DatabaseKey must be
 * be set".
 * 2) do NOT use read db adapter with caching turned on
 *
 * @description This class is a one to one mapping to
 *              a table in the database.
 * @category Sly
 * @package Sly_Da
 */
class Sly_Da
{

    /**
     * The read and write db adapter object
     *
     * @var Sly_DbAdapter
     */
    protected static $_dbAdapter = null;

    /**
     * The read db adapter object
     *
     * @var Sly_DbAdapter
     */
    protected static $_readDbAdapter = null;
    
    /**
     * The cache object
     *
     * @var Zend_Cache_Core
     */
    protected static $_cache = null;
    
    /**
     * The Query Tags object for this cache
     *
     * @protected Sly_CacheTags
     */
    protected static $_cacheTags;

    /**
     * The list of tags recorded during page load, to clear if we are using database transactions
     *
     * @protected array
     */
    protected static $_recordedTags = array();

    /**
     * Set if we did a start database transaction
     *
     * @protected boolean
     */
    protected static $_isDatabaseTransaction = false;

    /**
     * The specific dbAdapter for this instance
     *
     * This can be used to override _dbAdapter if different instances need 
     * different dbAdapters
     *
     * @var Sly_DbAdapter
     * @access protected
     */
    protected $_instanceDbAdapter = null;
     
    /**
     * The specific read dbAdapter for this instance
     *
     * This can be used to override _readDdbAdapter if different instances need 
     * different dbAdapters
     *
     * @var Sly_DbAdapter
     * @access protected
     */
    protected $_instanceReadDbAdapter = null;
       
    /**
     * The database name (default null means current database)
     *
     * @var array
     */
    protected $_database = null;
     
    /**
     * @var string
     * @access protected
     */
    protected $_table;
    
    /**
     * @var array
     * @access protected
     */
    public $_data = array();

    /**
     * Array of rows that have been modified
     * @var array
     * @access protected
     */
    protected $_modifiedRows = array();

    /**
     * A has of column to data type
     * @var array
     * @access protected
     */
    protected $_dataTypes = array();
    
    /**
     * Boolean of if the da should cache the rows
     *
     * @var array
     */
    protected $_rowCacheEnabled = false;
        
    /**
     * Boolean of if the da should preload rows
     *
     * @var array
     */
    protected $_preloadEnabled = false;
            
    /**
     * Boolean of if the da has been preloaded
     *
     * @var array
     */
    protected $_preloaded = false;

    /**
     * @var array
     * @access protected
     */
    protected $_indexes = array();

    /**
     * Array of tag strings used for the cache tags
     *
     * @var array
     */
    protected $_tags = array();
    
    /**
     * Get the dbAdapter
     */
    public function getDbAdapter()
    {
        if ( $this->_instanceDbAdapter ) {
            return $this->_instanceDbAdapter;
        }
        
        return self::$_dbAdapter;
    }
        
    /**
     * Sets the db adapter for all objects
     *
     * @param  Sly_DbAdapter $db
     * @return void
     */
    public static function setAdapter( $dbAdapter )
    {
        self::$_dbAdapter = $dbAdapter;
        
        // if the read db adapter isn't set, then set it to this
        if ( ! self::$_readDbAdapter ) {
            self::setReadDbAdapter( $dbAdapter );
        }
    }

    /**
     * Get the read dbAdapter
     */
    public function getReadDbAdapter()
    {
        if ( $this->_instanceReadDbAdapter ) {
            return $this->_instanceReadDbAdapter;
        }
        
        return self::$_readDbAdapter;
    }
        
    /**
     * Sets the db adapter for this specific instance
     *
     * @param  Sly_DbAdapter $db
     * @return void
     */
    public function setInstanceDbAdapter( $dbAdapter )
    {
        $this->_instanceDbAdapter = $dbAdapter;
        
        // if the read db adapter isn't set, then set it to this
        if ( ! $this->_instanceReadDbAdapter ) {
            $this->setInstanceReadDbAdapter( $dbAdapter );
        }
    }
             
    /**
     * Sets the read db adapter for all objects
     *
     * @param  Sly_DbAdapter $db
     * @return void
     */
    public static function setReadDbAdapter( $readDbAdapter )
    {
        self::$_readDbAdapter = $readDbAdapter;
    }    
             
    /**
     * Sets the read db adapter for this instance
     *
     * @param  Sly_DbAdapter $db
     * @return void
     */
    public function setInstanceReadDbAdapter( $readDbAdapter )
    {
        $this->_instanceReadDbAdapter = $readDbAdapter;
    }    

    /**
     * Sets the cache for all objects
     *
     * @param  Zend_Cache_Core $cache
     * @return void
     */
    public static final function setCache( $cache )
    {
        self::$_cache = $cache;
    }

    /**
     * Sets the cacheTags for all objects
     *
     * @param  Sly_CacheTags $cacheTags
     * @return void
     */
    public static final function setCacheTags( $cacheTags )
    {
        self::$_cacheTags = $cacheTags;
    }

    /**
     * Gets the cacheTags for all objects
     *
     * @param  Sly_CacheTags $cacheTags
     * @return void
     */
    public static final function getCacheTags()
    {
        return self::$_cacheTags;
    }

    /**
     * Class destructor.  Save modified rows
     *
     * @return void
     */
    public function __destruct()
    {
        $this->save();
    }

    /**
     * Save to cache
     *
     * Wrapper to allow children classes to overwrite the behavior if needed
     *
     * @param mixed $data
     * @param string $cacheKey
     * @param array $tags
     * @return integer
     */
    public function saveCacheKey( $data, $cacheKey, $tags = null )
    {
        // if no tags then just save
        if ( ! $tags ) {
            return self::$_cache->save( $data, $cacheKey );
        }
        
        $lockedTags = array();
        $success = true;
        
        // grab all the locks
        foreach( $tags as $tag ) {
            if ( self::$_cache->getLock( $tag ) ) {
                $lockedTags[] = $tag;
            }
            else {
                $success = false;
                break;
            }  
        }
        
        // if we got ALL locks then update tags and save key
        if ( $success ) {
            self::$_cache->save( $data, $cacheKey );
            self::$_cacheTags->setTags( $cacheKey, $tags );  
        }
        
        // clear all the locks we got if successful or not
        foreach( $lockedTags as $lockedTag ) {
            self::$_cache->clearLock( $lockedTag );
        }
        
        return $success;        
    }
    
    /**
     * Get the databaseKey for the dbAdapter
     *
     * Only used with dbAdapter_Multi.  Where it MUST be set prior to each
     * database action.
     *
     * @return integer
     */
    public function getDatabaseKey()
    {
        return $this->getDbAdapter()->getDatabaseKey();
    }
    
    /**
     * Sets the databaseKey for the dbAdapter
     *
     * Only used with dbAdapter_Multi.  Where it MUST be set prior to each
     * database action.
     *
     * @param integer $databaseKey
     * @return void
     */
    public function setDatabaseKey( $databaseKey )
    {
        $this->getDbAdapter()->setDatabaseKey( $databaseKey );
    }
    
    /**
     * Get the field value in the row
     *
     * @param  string  $field The field to get
     * @param  int|array $id  The primary key in table
     * @return string
     */
    public function getField( $field, $primaryKeys )
    {
        if ( $this->_preloadEnabled && ! $this->_preloaded ) {
            $this->preload( $primaryKeys );
        }
        
        $primaryKeysId = $this->getPrimaryKeysId( $primaryKeys );

        if ( ! array_key_exists( $primaryKeysId, $this->_data ) ) {
            $this->_data[$primaryKeysId] = $this->getRowData( $primaryKeys );
        }

        if ( is_array( $this->_data[$primaryKeysId] ) &&
             array_key_exists( $field, $this->_data[$primaryKeysId] ) ) {
            return $this->_data[$primaryKeysId][$field];
        }

        return false;
    }

    /**
     * Set the field to a given value
     *
     * @param  string  $field  The field/column in the table
     * @param  integer  $primaryKey  The primary key in table
     * @param  string  $value  The new value for the field
     * @return void
     */
    public function setField( $field, $primaryKeys, $value, $tags = false )
    {
        $primaryKeysId = $this->getPrimaryKeysId( $primaryKeys );

        // we need to make sure we populate all the data before
        // setting a field. This is because we could set one field
        // and then do a getField on something else and at the moment
        // the getField code will return false.
        if ( ! isset( $this->_data[$primaryKeysId] ) ) {
            $this->_data[$primaryKeysId] = $this->getRowData( $primaryKeys );
        }
        
        // if row was not found then track that this is a new row
        // in PHP 7.0.0, we have to use the mysqli_* functions and if no rows are found
        // a NULL is returned unlike before it returned a false.
        if ( $this->_data[$primaryKeysId] === false || $this->_data[$primaryKeysId] === null ) {
            $this->_modifiedRows[$primaryKeysId]['new'] = true;
        }
        
        // check if the value we are about to set is the same as what we
        // got from the database, if so, no need to update it.
        if ( is_array( $this->_data[$primaryKeysId] ) &&
             array_key_exists( $field, $this->_data[$primaryKeysId] ) ) {


            // the mysql database will always return data as a string, but redis/memcache will store it as its proper
            // data type, so it depends on where $this->_data got populated.  If the data type that we are checking is
            // a string, then cast our value to check as a string too
            $valueToCheck = $value;

            if ( gettype( $this->_data[$primaryKeysId][$field] ) == 'string' &&
                 $valueToCheck !== null && $valueToCheck !== false ) {
                $valueToCheck = $valueToCheck.'';
            }

            if ( $this->_data[$primaryKeysId][$field] === $valueToCheck ) {
                return;
            }
        }

        $this->_data[$primaryKeysId][$field] = $value;

        $this->_modifiedRows[$primaryKeysId]['keys'] = $primaryKeys;

        if ( ! isset( $this->_modifiedRows[$primaryKeysId]['tags'] ) ) {
            $this->_modifiedRows[$primaryKeysId]['tags'] = array();
        }

        if ( $tags ) {
            // TODO - if the tag already exists, we don't need to add it again
            $this->_modifiedRows[$primaryKeysId]['tags'] = array_merge( $this->_modifiedRows[$primaryKeysId]['tags'], $tags );
        }
        
        // clear indexes
        $this->_indexes = array();
        
    }

    /**
     * Set multiple fields
     *
     * Setup as an alternate to update.  This should avoid potential conflict if
     * and update is followed by a read or set on the existing da row data.
     *
     * @param  array  $data  hash of field and value
     * @param  integer  $primaryKey  The primary key in table
     * @param  array $tags any tags
     * @return void
     */
    public function setFields( $data, $primaryKeys, $tags = false )
    {
        foreach ( $data as $field => $value ) {
            $this->setField( $field, $primaryKeys, $value, $tags );
        }
    }

    /**
     * Get the table
     * 
     * @return string
     */
    public function getTable()
    {
        return $this->_table;
    }
    
    /**
     * Get the internal data array
     *
     * IMPORTANT: This is a debug only function.  All reads should use getField.
     * This function should be protected in production.
     *
     * @return hash
     */
    public function getData()
    {
        return $this->_data;
    }
    
    /**
     * Populate the row using the primary keys
     *
     * @param hash $primaryKeys
     * @return hash
     */
    protected function getRowData( $primaryKeys )
    {
        if ( $this->_preloadEnabled && ! $this->_preloaded ) {
            // get the database key to reset after the preload
            $databaseKey = $this->getDatabaseKey();
            $this->preload( $primaryKeys );
            $this->setDatabaseKey( $databaseKey );
        }
        
        $primaryKeysId = $this->getPrimaryKeysId( $primaryKeys );
        
        if ( isset( $this->_data[$primaryKeysId] ) ) {
            return $this->_data[$primaryKeysId];
        }
        
        $data = null;

        if ( $this->_rowCacheEnabled ) {
            $cacheId = $this->getCacheId( $primaryKeys );

            $data = self::$_cache->load( $cacheId, $isHit );

            if ( ! $isHit ) {
                $sql = $this->createSqlStatement( array( '*' ),
                                                  $this->getWhereArrayFromPrimaryKeys( $primaryKeys ) );
                                              
                $data = $this->fetchRow( $sql );
                
                $this->saveCacheKey( $data, $cacheId );
            }
        }
        else {
            $sql = $this->createSqlStatement( array( '*' ),
                                              $this->getWhereArrayFromPrimaryKeys( $primaryKeys ) );
                                              
            $data = $this->fetchRow( $sql );
        }

        return $data;
    }

	/**
	 * Get row data for multiple rows from a single sql statement
	 *
	 * @param string $sql
	 * @param array $tags
	 * @return array The array will be a hash of the primaryKeys for each row 
	 *               returned from the sql.
	 *               []['primaryKey1'] => value,
	 *               []['primaryKey2'] => value, ..
	 */
	public function getRowsData( $sql, $tags = false )
	{
		// run sql
		$rows = $this->fetchRows( $sql, $tags );
		
		return $this->loadRowsFromData( $rows );

	}
	
	/**
	 * Load an array of rows data
	 *
	 * This function loads the _data for the passed data.  It will update any
	 * row based caching. It will return an array of the keyIds for the loaded
	 * rows.
	 *
	 * @param array $rows
	 * @return array The array will be a hash of the primaryKeys for each row 
	 *               returned from the sql.
	 *               []['primaryKey1'] => value,
	 *               []['primaryKey2'] => value, ..
	 */
	public function loadRowsFromData( $rows )
	{
		foreach( $rows as $row ) {
            $primaryKeys = $this->getPrimaryKeysFromData( $row );
            $primaryKeysId = $this->getPrimaryKeysId( $primaryKeys );

            // check if this row has already been modified, if it has, print something
            // to the error log to alert the developer that they needed to have called
            // save before doing another load from sql, so it will get its latest data
            if ( isset( $this->_modifiedRows[$primaryKeysId] ) ) {
                $classname = get_class($this);
                error_log( "$classname::loadRowsFromData the data has been modified, call save() first" );
            }
            
	        /*
	        // checking the cache defeats the point of loading all the rows at once
	        if ( $this->_rowCacheEnabled ) {
	            $cacheId = $this->getCacheId( $primaryKeys );
	
	            $data = self::$_cache->load( $cacheId, $isHit );
	
	            // save to cache if cache is empty or does not match
	            if ( $data !== $row || ! $isHit ) {
	                $this->saveCacheKey( $row, $cacheId );
	            }
	        }
	        */
	        
	        $this->_data[$primaryKeysId] = $row;
		}
        
        return $rows;	    
	}
	
	/**
	 * Load rows for multiple tables and da objects in a single sql statement
	 *
	 * This called DA should be the 'from' part of the query.  All tables to 
	 * load should have a table_name.* in the select query (or just *).  Their 
	 * respective Da objects should also be passed.
	 *
	 * @param string $sql The sql query with join.  Example: 
	 *                    SELECT *
	 *                    FROM league_team
	 *                    JOIN league_team_owner
	 *                        ON league_team.team_id = league_team_owner.team_id
	 *                    WHERE league_team.league = 1
	 * @param array $joinDaOjects Array of the joined Da objects listed in sql. 
	 *                            For the above example:
	 *                    array( Fantasy_Full_League_TeamOwner::getInstance() )
	 * @param array $tags
	 * @return array The array will be a hash of the primaryKeys for each row 
	 *               returned from the sql in the primary table.
	 *               []['primaryKey1'] => value,
	 *               []['primaryKey2'] => value, ..
	 */
	public function getJoinRowsData( $sql, $joinDaOjects, $tags = false )
	{
	    // run sql
		$rows = $this->fetchJoinRows( $sql, $tags );
		
		// load the join table's rows in their da objects	    
		foreach( $joinDaOjects as $joinDaOject ) {
		    $joinDaOject->loadRowsFromData( $rows[$joinDaOject->getTable()] );
		}
		
		// load the primary table's rows
		return $this->loadRowsFromData( $rows[$this->getTable()] );
		
	}
	
	/**
	 * Delete the row from rowCache and _data
	 *
	 * @param array $primaryKeys
	 * @return void
	 */
	protected function deleteRowCache( $primaryKeys )
	{
        // delete the row from cache if enabled
        if ( $this->_rowCacheEnabled ) {
            $cacheId = $this->getCacheId( $primaryKeys );

            self::$_cache->remove( $cacheId );
        }

        // delete the row from the $this->_data
        $primaryKeysId = $this->getPrimaryKeysId( $primaryKeys );
        unset( $this->_data[$primaryKeysId] );
    }
	    
    /**
     * Delete the row using the primary keys
     *
     * @param hash $primaryKeys
     * @return void
     */
    protected function deleteRow( $primaryKeys, $tags = false )
    {
        // delete the row from the database
        $where = $this->getWhereArrayFromPrimaryKeys( $primaryKeys );

        $retVal = $this->delete( join( ' and ', $where ), $tags );
        
        // delete _data and rowCache (if enabled)
        $this->deleteRowCache( $primaryKeys );          
        
        return $retVal;
    }

    /**
     * Get the where clause from the primary keys
     *
     * @return string
     */
    public function getWhereArrayFromPrimaryKeys( $primaryKeys )
    {
        $where = array();
        for( $i = 0; $i < count( $this->_primary ); $i++ ) {

            $column = $this->_primary[$i];

            if ( isset( $this->_dataTypes[$column] ) ) {
                if ( $this->_dataTypes[$column] == 'integer' ) {
                    $where[] = $column . ' = ' . $primaryKeys[$i];
                }
                else {
                    $where[] = $column . ' = \'' . $this->quote( $primaryKeys[$i] ) . "'";
                }
            }
            else {
                if ( is_numeric( $primaryKeys[$i] ) ) {
                    $where[] = $column . ' = ' . $primaryKeys[$i];
                }
                else {
                    $where[] = $column . ' = \'' . $this->quote( $primaryKeys[$i] ) . "'";
                }
            }
        }
        return $where;
    }
    
    /**
     * Get the id for this row
     *
     * @param  int|array  $id  The primary keys in table
     * @return string
     */
    public function getPrimaryKeysId( $primaryKeys )
    {
        return join( '_', $primaryKeys );
    }
    
    /**
     * Get the array of primaryKeys from the primaryKeysId
     *
     * @param  string  $primaryKeysId
     * @return array 
     */
    public function getPrimaryKeysArray( $primaryKeysId )
    {
        return explode( '_', $primaryKeysId );
    }

	/**
	 * Get the primary keys from the array
	 *
	 * @param array $keyArray
	 * @return string
	 */
	public function getPrimaryKeysFromData( $keyArray )
	{
		$primaryArray = array();
		
		foreach( $this->_primary as $field ) {
			$primaryArray[$field] = $keyArray[$field];
		}
		
		return $primaryArray;
	}
	
	/**
	 * Get a hash from the primary keys
	 *
	 * @param array $primaryKeys
	 * @return hash
	 */
	public function getHashFromPrimaryKeys( $primaryKeys )
	{
        $hash = array();  
        for( $i = 0; $i < count( $this->_primary ); $i++ ) {  
            $column = $this->_primary[$i];   
            $hash[$column] = $primaryKeys[$i];	    
        }
        
        return $hash;
    }
    
    /**
     * Get the cache id for this row
     *
     * @param  int|array  $id  The primary keys in table
     * @return string
     */
    public function getCacheId( $primaryKeys )
    {
        return $this->_database.'.'.$this->_table.'.'.join( '_', $primaryKeys );
    }
    
    /**
     * Save the new row to the database
     *
     * @param  int|array  $id  The primary key in table
     * @return void
     */
    public function save()
    {
        foreach( $this->_modifiedRows as $primaryKeysId => $primaryKeysInfo ) {

            // if any fields are timestamp, we should have database
            // automatically update it
            foreach( $this->_dataTypes as $column => $dataType ) {
                if ( $dataType == 'timestamp' ) {
                    unset( $this->_data[$primaryKeysId][$column] );
                }
            }

            // update the database
            //$this->update( $this->_data[$primaryKeysId],
            //               $this->getWhereArrayFromPrimaryKeys( $primaryKeysInfo['keys'] ),
            //               false,
            //               $primaryKeysInfo['tags'] );
            $data = $this->_data[$primaryKeysId];
            for( $i = 0; $i < count( $this->_primary ); $i++ ) {
                $column = $this->_primary[$i];
                $data[$column] = $primaryKeysInfo['keys'][$i];
            }
            
            // insert new rows
            if ( isset( $primaryKeysInfo['new'] ) ) {
                $this->insert( $data, $primaryKeysInfo['tags'], false, false );
            }
            else {
                $this->update2( $data,
                                $this->getHashFromPrimaryKeys( $primaryKeysInfo['keys'] ),
                                false,
                                $primaryKeysInfo['tags'],
                                false  );
            }

            // update the cache
            if ( $this->_rowCacheEnabled ) {
                $cacheId = $this->getCacheId( $primaryKeysInfo['keys'] );
                
                // if this is a new row being inserted, the data/columns that was getting set to memcache was
                // only the data being passed to setFields() which wasn't necessarily everything in the table.
                // then our memcache row cache wasn't complete and there returning bad data.  We want to
                // delete the entire row cache after we inserted, so then we end up having to do a query
                // for the row to get ALL columns from the database.
                if ( isset( $primaryKeysInfo['new'] ) ) {
                    $this->deleteRowCache( $primaryKeysInfo['keys'] );
                }
                else {
                    $this->saveCacheKey( $data, $cacheId );
                }
            }

            // unset that this row is modified
            unset( $this->_modifiedRows[$primaryKeysId] );
        }

    }

    public function fetchOne( $sql, $tags = false )
    {
        //if tags are not set then completely ignore caching
        if ( ! $tags ) {
            return $this->getReadDbAdapter()->fetchOne( $sql );
        }

        $cacheId = self::$_cacheTags->encodeItem($sql);

        $data = self::$_cache->load( $cacheId, $isHit );

        // if no data, then we need to fetch it and save it to cache
        if ( ! $isHit ) {
            $data = $this->getDbAdapter()->fetchOne( $sql );

            //cache the query results
            $this->saveCacheKey( $data, $cacheId, $tags );
        }

        return $data;
    }
    
    /**
     * Fetch the first row for a sql statement
     * 
     * If there are more than one row others will be ignored.
     *
     * @param string $sql
     * @param array $tags
     * @return hash The returned hash will contain:
     *              ['field'] => value
     */
    public function fetchRow( $sql, $tags = false )
    {
        // if tags are not set then completely ignore caching
        if ( ! $tags ) {
            return $this->getReadDbAdapter()->fetchRow( $sql );
        }

        $cacheId = self::$_cacheTags->encodeItem($sql);

        $data = self::$_cache->load( $cacheId, $isHit );

        // if no data, then we need to fetch it and save it to cache
        if ( ! $isHit ) {
            $data = $this->getDbAdapter()->fetchRow( $sql );

            // cache the query results
            $this->saveCacheKey( $data, $cacheId, $tags );
        }

        return $data;
    }

    public function fetchColumns( $sql, $tags = false )
    {
        //if tags are not set then completely ignore caching
        if ( ! $tags ) {
            return $this->getReadDbAdapter()->fetchColumns( $sql );
        }

        $cacheId = self::$_cacheTags->encodeItem($sql);

        $data = self::$_cache->load( $cacheId, $isHit );

        // if no data, then we need to fetch it and save it to cache
        if ( ! $isHit ) {
            $data = $this->getDbAdapter()->fetchColumns( $sql );

            //cache the query results
            $this->saveCacheKey( $data, $cacheId, $tags );
        }

        return $data;
    }

    public function fetchAllColumns( $sql, $tags = false )
    {
        //if tags are not set then completely ignore caching
        if ( ! $tags ) {
            return $this->getReadDbAdapter()->fetchAllColumns( $sql );
        }

        $cacheId = self::$_cacheTags->encodeItem($sql);

        $data = self::$_cache->load( $cacheId, $isHit );

        // if no data, then we need to fetch it and save it to cache
        if ( ! $isHit ) {
            $data = $this->getDbAdapter()->fetchAllColumns( $sql );

            //cache the query results
            $this->saveCacheKey( $data, $cacheId, $tags );
        }

        return $data;
    }

    /**
     * Fetch all the rows for a sql statement
     * 
     * @param string $sql
     * @param array $tags
     * @return array The returned array will contain a hash of the row data:
     *              []['field'] => value
     */
    public function fetchRows( $sql, $tags = false )
    {
        //if tags are not set then completely ignore caching
        if ( ! $tags ) {
            return $this->getReadDbAdapter()->fetchRows( $sql );
        }

        $cacheId = self::$_cacheTags->encodeItem($sql);

        $data = self::$_cache->load( $cacheId, $isHit );

        // if no data, then we need to fetch it and save it to cache
        if ( ! $isHit ) {
            $data = $this->getDbAdapter()->fetchRows( $sql );

            //cache the query results
            $this->saveCacheKey( $data, $cacheId, $tags );
        }

        return $data;
    }

    /**
     * Fetch all the rows for a join statement and break them up by table
     * 
     * @param string $sql
     * @param array $tags
     * @return array The returned array will contain a hash of the data by table:
     *              ['table']['row']['field'] => value
     */
    public function fetchJoinRows( $sql, $tags = false )
    {
        //if tags are not set then completely ignore caching
        if ( ! $tags ) {
            return $this->getReadDbAdapter()->fetchJoinRows( $sql );
        }

        $cacheId = self::$_cacheTags->encodeItem($sql);

        $data = self::$_cache->load( $cacheId, $isHit );

        // if no data, then we need to fetch it and save it to cache
        if ( ! $isHit ) {
            $data = $this->getDbAdapter()->fetchJoinRows( $sql );

            //cache the query results
            $this->saveCacheKey( $data, $cacheId, $tags );
        }

        return $data;
    }

    public function fetchAssoc( $sql, $tags = false )
    {
        //if tags are not set then completely ignore caching
        if ( ! $tags ) {
            return $this->getReadDbAdapter()->fetchAssoc( $sql );
        }

        $cacheId = self::$_cacheTags->encodeItem($sql);

        $data = self::$_cache->load( $cacheId, $isHit );

        // if no data, then we need to fetch it and save it to cache
        if ( ! $isHit ) {
            $data = $this->getDbAdapter()->fetchAssoc( $sql );

            //cache the query results
            $this->saveCacheKey( $data, $cacheId, $tags );
        }

        return $data;
    }
    
    public function fetchCount( $sql, $tags = false )
    {
        //if tags are not set then completely ignore caching
        if ( ! $tags ) {
            $count = $this->getReadDbAdapter()->fetchOne( $sql );
            if ( ! $count ) {
                return 0;
            }
            return $count;
        }
        
        $cacheId = self::$_cacheTags->encodeItem($sql);

        $data = self::$_cache->load( $cacheId, $isHit );
        
        // if no data, then we need to fetch it and save it to cache
        if ( ! $isHit ) {
            // recursive to reuse special processing
            $data = $this->fetchCount( $sql );

            //cache the query results
            $this->saveCacheKey( $data, $cacheId, $tags );
        }
        
        return $data;
    }

    /**
     * Checks if a row exists that matches the data
     *
     * This function should ONLY be used if the data are not the key fields for 
     * the table.  You should use isKeysExist when checking by key id(s).
     *
     * TODO populate _data from the query results
     *
     * @param hash $data The data hash will contain:
     *                       ['field'] => value
     * @param array/boolean $tags The tags to use for caching.
     * @return boolean
     */    
    public function isRowExist( $data, $tags = false )
    {
        $where = $this->createWhereArray( $data );

        $sql = $this->createSqlStatement( array( '*' ), $where );

        $result = $this->fetchOne( $sql, $tags );

        if ( $result !== false && $result !== null ) {
            return true;
        }
        return false;
    }
    
    /**
     * Checks if a row with that key(s) exists
     *
     * The function will look in _data, then attempt to 
     * load the row (from cache if applicable).  
     *
     * @param array $primaryKeys
     * @param array/boolean $tags The tags to use for caching.
     * @return boolean
     */
    public function isKeysExist( $primaryKeys, $tags = false )
    {
    	$primaryKeysId = $this->getPrimaryKeysId( $primaryKeys );
    	
    	// if _data is set to false we have already checked and it isn't set
    	// if _data is set to anything else row exists
    	if ( isset( $this->_data[$primaryKeysId] ) ) {
    	    return ( $this->_data[$primaryKeysId] !== false && $this->_data[$primaryKeysId] !== null );
    	}
    	
    	// attempt to load the row
        $result = $this->getRowData( $primaryKeys );
        $this->_data[$primaryKeysId] = $result;
        
        // if it is false, it means the row doesn't exist
    	if ( $result === false || $result === null ) {
    	    return false;
        }

   		return true;
    }
    
    public function delete( $where, $tags = false )
    {
        // get the database key just in case it gets cleared by the
        // save() call in clearData
        $databaseKey = $this->getDatabaseKey();

        // clear the data which will also save any unsaved _data
        $this->clearData();

        // reset the database key
        $this->setDatabaseKey( $databaseKey );

        // set the sql to delete
        $sql  = 'delete from ' . $this->_database . '.' . $this->_table;
        $sql .= " where $where";

        $retVal = $this->getDbAdapter()->delete( $sql );
        
        if ( $tags ) {
            $this->clearCacheIdsByTags( $tags );
        }

        return $retVal;
    }

    public function truncate( $tags = false )
    {
        // get the database key just in case it gets cleared by the
        // save() call in clearData
        $databaseKey = $this->getDatabaseKey();
        
        // clear the data which will also save any unsaved _data
        $this->clearData();
        
        // reset the database key
        $this->setDatabaseKey( $databaseKey );
        
        // set the sql to truncate
        $sql  = 'truncate table ' . $this->_database . '.' . $this->_table;

        $retVal = $this->getDbAdapter()->query( $sql );
        
        if ( $tags ) {
            $this->clearCacheIdsByTags( $tags );
        }
        
        return $retVal;
    }
    
    public function insert( $data, $tags = false, $ignoreErrors = false, $shouldClearData = true )
    {
        // save current data before you run the update
        if ( $shouldClearData ) {
       
            // get the database key just in case it gets cleared by the
            // save() call in clearData
            $databaseKey = $this->getDatabaseKey();
        
            // clear the data which will also save any unsaved _data
            $this->clearData();

            // reset the database key
            $this->setDatabaseKey( $databaseKey );
        }
        
        // clear indexes in case the shouldClearData wasn't true
        // when updating we always want indexes to be cleared
        $this->_indexes = array();
        
        $ignore = '';
        if ( $ignoreErrors ) {
            $ignore = 'ignore';
        }
        
        $columns = array();
        foreach( $data as $column => $value ) {
            $columns[] = "`$column`";
        }

        $sql  = "insert $ignore into " . $this->_database . '.' . $this->_table;
        $sql .= ' (' . join( ',', $columns ) . ')';
        $sql .= ' VALUES (';
        
        $values = array();
        foreach( $data as $column => $value ) {

            if ( $value === null ) {
                $values[] = 'NULL';
            }
            else {
                if ( isset( $this->_dataTypes[$column] ) ) {
                    if ( $this->_dataTypes[$column] == 'integer' ) {
                        $values[] = $value;
                    }
                    else {
                        $value = $this->quote( $value );
                        $values[] = "'$value'";
                    }
                }
                else {
                    if ( is_numeric( $value ) ) {
                        $values[] = $value;
                    }
                    else {
                        $value = $this->quote( $value );
                        $values[] = "'$value'";
                    }
                }
            }

        }
        
        $sql .= join( ',', $values ) . ')';

        $retVal = $this->getDbAdapter()->insert( $sql );
        
        if ( $tags ) {
            $this->clearCacheIdsByTags( $tags );
        }
        
        return $retVal;
    }
    
    public function update2( $data, $where, $ignoreErrors = false, $tags = false, $shouldClearData = true  )
    {
        $where = $this->createWhereArray( $where );
        
        return $this->update( $data, $where, $ignoreErrors, $tags, $shouldClearData  );
    }
    
    public function update( $data, $where, $ignoreErrors = false, $tags = false, $shouldClearData = true  )
    {
        // save current data before you run the update
        if ( $shouldClearData ) {
       
            // get the database key just in case it gets cleared by the
            // save() call in clearData
            $databaseKey = $this->getDatabaseKey();
        
            // clear the data which will also save any unsaved _data
            $this->clearData();

            // reset the database key
            $this->setDatabaseKey( $databaseKey );
        }
        
        // clear indexes in case the shouldClearData wasn't true
        // when updating we always want indexes to be cleared
        $this->_indexes = array();

        // create the sql statement
        $ignore = '';
        if ( $ignoreErrors ) {
            $ignore = 'ignore';
        }

        $sql = "update $ignore " . $this->_database . '.' . $this->_table;
        $sql .= ' set ' . join(',', $this->createSetArray( $data ));
        $sql .= ' where ' . join( ' and ', $where );

        
        $retVal = $this->getDbAdapter()->update( $sql );
        
        if ( $tags ) {
            $this->clearCacheIdsByTags( $tags );
        }
        
        return $retVal;
    }

    public function replace( $data, $tags = false, $shouldClearData = true )
    {
        // save current data before you run the replace
        if ( $shouldClearData ) {
       
            // get the database key just in case it gets cleared by the
            // save() call in clearData
            $databaseKey = $this->getDatabaseKey();
        
            // clear the data which will also save any unsaved _data
            $this->clearData();

            // reset the database key
            $this->setDatabaseKey( $databaseKey );
        }
        
        // clear indexes in case the shouldClearData wasn't true
        // when updating we always want indexes to be cleared
        $this->_indexes = array();

        // create the sql statement
        $columns = array();
        foreach( $data as $column => $value ) {
            $columns[] = "`$column`";
        }

        $sql  = ' replace into ' . $this->_database . '.' . $this->_table;
        $sql .= '(' . join( ',', $columns ) . ')';
        $sql .= ' VALUES (';
        
        $values = array();
        foreach( $data as $column => $value ) {

            if ( $value === null ) {
                $values[] = 'NULL';
            }
            else {
                if ( isset( $this->_dataTypes[$column] ) ) {
                    if ( $this->_dataTypes[$column] == 'integer' ) {
                        $values[] = $value;
                    }
                    else {
                        $value = $this->quote( $value );
                        $values[] = "'$value'";
                    }
                }
                else {
                    if ( is_numeric( $value ) ) {
                        $values[] = $value;
                    }
                    else {
                        $value = $this->quote( $value );
                        $values[] = "'$value'";
                    }
                }
            }

        }

        $sql .= join( ',', $values ) . ')';
        
        $retVal = $this->getDbAdapter()->replace( $sql );
        
        if ( $tags ) {
            $this->clearCacheIdsByTags( $tags );
        }
        
        return $retVal;
    }

    /**
     * Save then clear all the data for the objects
     *
     * @return void
     */
    public function clearData()
    {
        $this->save();
        $this->_data = array();
        $this->_indexes = array();
        $this->_preloaded = false;
    }

    public function query( $sql, $tags = false )
    {
        if ( $tags ) {
            $this->clearCacheIdsByTags( $tags );
        }

        return $this->getDbAdapter()->query( $sql );
    }

    public function createWhereArray( $data )
    {
        $array = array();
        foreach( $data as $column => $value ) {

            if ( $value === null ) {
                $array[] = "`$column` is NULL";
            }
            else {
                if ( isset( $this->_dataTypes[$column] ) ) {
                    if ( $this->_dataTypes[$column] == 'integer' ) {
                        $array[] = "`$column` = $value";
                    }
                    else {
                        $value = $this->quote( $value );
                        $array[] = "`$column` = '$value'";
                    }
                }
                else {
                    if ( is_numeric( $value ) ) {
                        $array[] = "`$column` = $value";
                    }
                    else {
                        $value = $this->quote( $value );
                        $array[] = "`$column` = '$value'";
                    }
                }
            }
        }

        return $array;
    }

    public function createSetArray( $data )
    {

        $array = array();
        foreach( $data as $column => $value ) {

            if ( $value === null ) {
                $array[] = "`$column` = NULL";
            }
            else {

                if ( isset( $this->_dataTypes[$column] ) ) {
                    if ( $this->_dataTypes[$column] == 'integer' ) {
                        $array[] = "`$column` = $value";
                    }
                    else {
                        $value = $this->quote( $value );
                        $array[] = "`$column` = '$value'";
                    }
                }
                else {
                    if ( is_numeric( $value ) ) {
                        $array[] = "`$column` = $value";
                    }
                    else {
                        $value = $this->quote( $value );
                        $array[] = "`$column` = '$value'";
                    }
                }
            }
        }
        return $array;
    }
    
    public function createSqlStatement( $columns,
                                        $where = null, 
                                        $orderBy = null, 
                                        $groupBy = null, 
                                        $leftJoin = null, 
                                        $limit = null, 
                                        $offset = null )
    {
        $sql  = 'select ' . join( ',', $columns );
        $sql .= ' from ' . $this->_database . '.' . $this->_table;

        if ( $leftJoin ) {
            $sql .= ' ' . join( ' ', $leftJoin );
        }

        if ( $where ) {
            $sql .= ' where ' . join( ' and ', $where );
        }

        if ( $groupBy ) {
            $sql .= ' group by ' . join( ',', $groupBy );
        }

        if ( $orderBy ) {
            $sql .= ' order by ' . join( ',', $orderBy );
        }

        if ( $limit ) {
            $sql .= " limit $limit";
        }
        
        if ( $offset ) {
            $sql .= " offset $offset";
        }

        return $sql;
    }

    /**
     * Create a tag so formatting is consistent
     *
     * @var array of $rawTags as array $values hash of $field => $value
     *                    Empty array for whole table tag
     * @var string $prefix (Null = current table)
     * @return string $tag
     */
    public function createTags( $rawTags, $addDefaults = false, $prefix = NULL )
    {
        if ( $prefix === NULL ) {
            $prefix = $this->_database.".".$this->_table;
        }
        
        $tags = array();
        
        if ( $addDefaults ) {
            //$tags[] = self::$_cacheTags->encodeItem( $this->_database );
            $tags[] = self::$_cacheTags->encodeItem( $this->_database.".".$this->_table );
        }

        foreach( $rawTags as $values ) {
            $tag = $prefix;

            foreach( $values as $field => $value ) {
                //add seperator if not first
                if ( $tag != "" ) {
                    $tag .= " & ";
                }

                $tag .= $field." = ".$value;
            }

            $tags[] = self::$_cacheTags->encodeItem( $tag );
        }
        
        return $tags;
    }
    
    public function quote( $string )
    {
        //return $this->getDbAdapter()->quote( $string );
        
        // debug
        $dbAdapter = $this->getDbAdapter();
        
        
        if ( ! $dbAdapter ) {
            print get_class($this).": dbAdapter not set\n";
            debug_print_backtrace();
            exit(1);
        }
        
        return $dbAdapter->quote( $string );
    }

    /**
     * Clear the cache ids by tags
     *
     * @return void
     */
    public function clearCacheIdsByTags( $tags )
    {
        // record the tags first if needed
        if ( self::$_isDatabaseTransaction ) {

            self::$_recordedTags = array_merge( self::$_recordedTags, $tags );

        }

        // we need to ALWAYS clear cache ids even if it is a database transaction, because
        // if we do multiple sets and gets during the transaction, we still need the cache
        // to be up to date.  We can't just wait until database transaction is ended to then
        // clear the cache
        self::$_cacheTags->clearCacheIdsByTags( $tags );
    }

    /**
     * Start a database transaction
     *
     * @param integer $databaseKey
     * @return boolean
     */
    public function startDatabaseTransaction()
    {
        self::$_isDatabaseTransaction = true;
        return $this->getDbAdapter()->startTransaction();
    }
    
    /**
     * End a database transaction
     *
     * @param boolean $commit
     * @param integer $databaseKey
     * @return boolean
     */
    public function endDatabaseTransaction( $commit )
    {
        $result = $this->getDbAdapter()->endTransaction( $commit );
        
        self::$_cacheTags->clearCacheIdsByTags( array_unique( self::$_recordedTags ) );

        self::$_isDatabaseTransaction = false;
        
        return $result;
    }

    /**
     * Get the offset of a specific element in a larger query
     *
     * NOTE: targetQuery should not use count or offset to
     *
     * @param string $targetQuery
     * @param string $keyField
     * @param mixed $keyValue
     * @param array|null $tags
     * @return int
     */
    public function getKeyValueOffsetInQuery( $targetQuery, $keyField, $keyValue, $tags = null )
    {
        $sql = "SELECT z.rank
            FROM ( SELECT @rank:=@rank+1 AS rank, y.*
                FROM ( $targetQuery ) y, ( SELECT @rank := 0 ) x ) z";

        if ( gettype( $keyValue ) == 'string' ) {
            $sql .= " WHERE z.$keyField = '$keyValue';";
        } else {
            $sql .= " WHERE z.$keyField = $keyValue;";
        }

        return $this->fetchOne( $sql, $tags );
    }

    /**
     * Combine results
     *
     * Helper function for multi database queries where the sql cannot do all of
     * the grouping.
     *
     * @param hash $results The results will contain:
     *                      [][field] => value
     * @param array $groupByFields
     * @param hash $orderByFields orderByFields will contain:
     *                            [field] => sort type (asc or desc)
     * @param array $countFields
     * @param array $maxFields 
     * @return hash The grouped results
     */
    public function combineResults( $results, $groupByFields = null, $orderByFields = null, $countFields = null, $maxFields = null ) 
    {
        $data = array();
        
        foreach( $results as $result ) {
            // get row key
            if ( $groupByFields ) {
                $rowKey = '';
                foreach( $groupByFields as $groupByField ) {
                    $rowKey .= '_' . $result[$groupByField];
                }
                   
            }
            else {
                $rowKey = 0;
            }
            
            // get any current data for row
            if ( isset( $data[$rowKey] ) ) {
                $row = $data[$rowKey];
            }
            else {
                $row = array();
            }
            
            // set the row's fields
            
            // group by
            if ( $groupByFields ) {
                foreach( $groupByFields as $groupByField ) {
                    $row[$groupByField] = $result[$groupByField];
                }
            }
                
            // count
            if ( $countFields ) {
                foreach( $countFields as $countField ) {
                    if ( isset( $row[$countField] ) ) {
                        $row[$countField] += $result[$countField];
                    }
                    else {
                        $row[$countField] = $result[$countField];
                    }
                }
            }
            
            // max
            if ( $maxFields ) {
                foreach( $maxFields as $maxField ) {
                    if ( isset( $row[$maxField] ) ) {
                        $row[$maxField] = ( $row[$maxField] > $result[$maxField] ) ? $row[$maxField] : $result[$maxField];
                    }
                    else {
                        $row[$maxField] = $result[$maxField];
                    }
                }
            }
            
            $data[$rowKey] = $row;
        }
        
        // order by
        if ( $orderByFields ) {
            $data = $this->orderResults( $data, $orderByFields );
        }
        
        // strip out keys and return
        return array_values( $data );
    }
    
    /**
     * Order results by field(s)
     *
     * @param hash $results
     * @param hash $orderByFields orderByFields will contain:
     *                            [field] => sort type ('asc' or 'desc')
     * @return hash
     */
    public function orderResults( $results, $orderByFields ) 
    {
        $sortColumns = array();
        $sortDirections = array();
        $multiSortArgs = array();

        if ( !$results ) {
            return array();
        }
        
        // get the data by column
        foreach( $results as $key => $row ) {
            foreach( $orderByFields as $field => $direction ) {
                $sortColumns[$field][$key] = $row[$field];
            }
        }
         
        // add to args
        foreach( $orderByFields as $field => $direction ) {
            $multiSortArgs[] = &$sortColumns[$field];
            $sortDirections[$field] = ( $direction == 'asc' ) ? SORT_ASC : SORT_DESC;
            $multiSortArgs[] = &$sortDirections[$field];
        }

        //add the main results to the sort
        $multiSortArgs[] = &$results;
                    
        call_user_func_array( 'array_multisort', $multiSortArgs );
        
        return $results;
    }        

    /**
     * Magic method calling
     *
     * @param  $functionName, $arguments 
     * @return void
     */
    public function __call($functionName, $arguments) {
        $type = substr($functionName, 0, 3);
        $function = substr($functionName, 3);

        if ( ! isset( $this->_functions[$functionName] ) ) {
            $classname = get_class($this);
            throw new Zend_Exception( "$classname::__call function doesn't exist: $functionName" );
        }

        $column = $this->_functions[$functionName];

        return $this->$type( $column, $arguments );
    }

    /**
     * Magic getter methods
     *
     * @param  string $column
     * @param  Array $arguments 
     * @return String
     */
    protected function get( $column, $argument )
    {
        return $this->getField( $column, $argument );
    }

    /**
     * Setter magic methods
     *
     * @param string $column
     * @param Array $arguments
     * @return void
     */
    protected function set( $column, $arguments )
    {
        $value = array_pop( $arguments );

        return $this->setField( $column, $arguments, $value, $this->getTags( $arguments ) );
    }

    /**
     * Get the tags
     *
     * This is the default method but it can be overriden if children classes
     * need to use different tags for magic set functions
     *
     * @param array $primaryKeys
     * @return array
     */
    public function getTags( $primaryKeys ) {
        return $this->_tags;
    }

    public function setDatabaseName( $name ) {
        $this->_database = $name;
    }
    
    public function getDatabaseName() {
        return $this->_database;
    }
}

?>
