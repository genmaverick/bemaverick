<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_Notification extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_Notification
     * @access protected
     */
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'notification';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'notification_id' );

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
        'getUserId'            => 'user_id',
        'getAction'            => 'action',
        'getObjectId'          => 'object_id',
        'getObjectType'        => 'object_type',
        'getCreatedTimestamp'  => 'created_ts',

        'setUserId'            => 'user_id',
        'setAction'            => 'action',
        'setObjectId'          => 'object_id',
        'setObjectType'        => 'object_type',
        'setCreatedTimestamp'  => 'created_ts',
    );

    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_Notification
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
     * Create a new notification
     *
     * @param integer $userId
     * @param string $action
     * @param integer $objectId
     * @param string $objectType
     * @return integer
     */
    public function createNotification( $userId, $action, $objectId, $objectType )
    {
        $data = array(
            'user_id' => $userId,
            'action' => $action,
            'object_id' => $objectId,
            'object_model' => $objectType,
            'created_ts' => date( 'Y-m-d H:i:s' ),
        );

        return $this->insert( $data, $this->_tags );
    }

    /**
     * Get a list of notification ids
     *
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return integer[]
     */
    public function getNotificationIds( $filterBy, $sortBy, $count, $offset )
    {
        $select = array( 'notification_id' );

        $where = array();

        if ( @$filterBy['userId'] ) {
            $where[] = "user_id = " . $filterBy['userId'];
        }

        $orderBy = array( 'created_ts desc' );

        if ( @$sortBy['sort'] ) {
            $sort = $sortBy['sort'];
            $sortOrder = $sortBy['sortOrder'];

            if ( $sort == 'id' ) {
                $orderBy = array( "notification_id $sortOrder" );
            } else if ( $sort == 'createdTimestamp' ) {
                $orderBy = array( "created_ts $sortOrder" );
            }
        }

        $sql = $this->createSqlStatement( $select, $where, $orderBy, null, null, $count, $offset );

        return $this->fetchColumns( $sql );
    }

    /**
     * Get the count of notifications
     *
     * @param hash $filterBy
     * @return integer
     */
    public function getNotificationCount( $filterBy )
    {
        $select = array( 'count(notification_id)' );

        $where = array();

        if ( @$filterBy['userId'] ) {
            $where[] = "user_id = " . $filterBy['userId'];
        }

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchCount( $sql );
    }

    /**
     * Delete the notification
     *
     * @param integer $notificationId
     * @return void
     */
    public function deleteNotification( $notificationId )
    {
        $this->deleteRow( array( $notificationId ) );
    }

}

?>
