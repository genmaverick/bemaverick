<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_UserFollowingUsers extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_UserFollowingUsers
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'user_following_users';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'user_id', 'following_user_id' );

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

    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_UserFollowingUsers
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
     * Check if the user is following the other user
     *
     * @param integer $userId
     * @param integer $followingUserId
     * @return boolean
     */
    public function isUserFollowingUser( $userId, $followingUserId )
    {
        return $this->isKeysExist( array( $userId, $followingUserId ), $this->_tags );
    }

    /**
     * Add a new following user id
     *
     * @param integer $userId
     * @param integer $followingUserId
     * @return void
     */
    public function addUserFollowingUser( $userId, $followingUserId )
    {
        $data = array(
            'user_id' => $userId,
            'following_user_id' => $followingUserId,
        );

        $this->insert( $data, $this->_tags, true );
    }

    /**
     * Delete the user following user
     *
     * @param integer $userId
     * @param integer $followingUserId
     * @return void
     */
    public function deleteUserFollowingUser( $userId, $followingUserId )
    {
        $this->deleteRow( array( $userId, $followingUserId ), $this->_tags );
    }

    /**
     * Delete the user
     *
     * @param integer $userId
     * @return void
     */
    public function deleteUser( $userId )
    {
        $this->delete( "user_id = $userId" );
        $this->delete( "following_user_id = $userId" );
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

            if ( ! $data ) {
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

}

?>
