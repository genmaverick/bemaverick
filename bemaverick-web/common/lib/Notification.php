<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Notification.php' );

class BeMaverick_Notification
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
    protected $_notificationId = null;

    /**
     * @var BeMaverick_Da_Notification
     * @access protected
     */
    protected $_daNotification;

    /**
     * Class constructor
     *
     * @param BeMaverick_Site $site
     * @param integer $notificationId
     * @return void
     */
    public function __construct( $site, $notificationId )
    {
        $this->_site = $site;
        $this->_notificationId = $notificationId;
        $this->_daNotification = BeMaverick_Da_Notification::getInstance();
    }

    /**
     * Retrieves the notification instance.
     *
     * @param BeMaverick_Site $site
     * @param integer $notificationId
     * @return BeMaverick_Notification
     */
    public static function getInstance( $site, $notificationId )
    {
        if ( ! $notificationId ) {
            return null;
        }
        
        if ( ! isset( self::$_instance[$notificationId] ) ) {

            $daNotification = BeMaverick_Da_Notification::getInstance();

            // make sure notification exists
            if ( ! $daNotification->isKeysExist( array( $notificationId ) ) ) {
                self::$_instance[$notificationId] = null;
            } else {
                self::$_instance[$notificationId] = new self( $site, $notificationId );
            }
        }

        return self::$_instance[$notificationId];

    }

    /**
     * Create a notification
     *
     * @param BeMaverick_Site $site
     * @param integer $userId
     * @param string $action
     * @param integer $objectId
     * @param string $objectType
     * @return BeMaverick_Notification
     */
    public static function createNotification( $site, $userId, $action, $objectId, $objectType )
    {
        $daNotification = BeMaverick_Da_Notification::getInstance();

        $notificationId = $daNotification->createNotification( $userId, $action, $objectId, $objectType );
        
        // we might have already tried to get this notification for some reason, so update
        // the self instance here and return it
        self::$_instance[$notificationId] = new self( $site, $notificationId );
        
        return self::$_instance[$notificationId];
    }

    /**
     * Get a list of notifications
     *
     * @param BeMaverick_Site $site
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Video[]
     */
    public static function getNotifications( $site, $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $daNotification = BeMaverick_Da_Notification::getInstance();

        $notificationIds = $daNotification->getNotificationIds( $filterBy, $sortBy, $count, $offset );

        $notifications = array();
        foreach ( $notificationIds as $notificationId ) {
            $notifications[] = self::getInstance( $site, $notificationId );
        }

        return $notifications;
    }

    /**
     * Get a count of notifications
     *
     * @param hash $filterBy
     * @return integer
     */
    public static function getNotificationCount( $filterBy = null )
    {
        $daNotification = BeMaverick_Da_Notification::getInstance();

        return $daNotification->getNotificationCount( $filterBy );
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
        return $this->_notificationId;
    }

    /**
     * Get the user
     *
     * @return string
     */
    public function getUser()
    {
        $userId = $this->_daNotification->getUserId( $this->getId() );
        return $this->_site->getUser( $userId );
    }

    /**
     * Get the action
     *
     * @return string
     */
    public function getAction()
    {
        return $this->_daNotification->getAction( $this->getId() );
    }

    /**
     * Get the object
     *
     * @return object
     */
    public function getObject()
    {
        $objectId = $this->_daNotification->getObjectId( $this->getId() );

        $objectType = $this->getObjectType();

        if ( $objectType == BeMaverick_Site::MODEL_TYPE_CHALLENGE ) {
            return $this->_site->getChallenge( $objectId );
        } else if ( $objectType == BeMaverick_Site::MODEL_TYPE_RESPONSE ) {
            return $this->_site->getResponse( $objectId );
        } else if ( $objectType == BeMaverick_Site::MODEL_TYPE_CONTENT ) {
            return $this->_site->getContent( $objectId );
        } else if ( $objectType == BeMaverick_Site::MODEL_TYPE_USER ) {
            return $this->_site->getUser( $objectId );
        }

        return null;
    }

    /**
     * Get the object type
     *
     * @return string
     */
    public function getObjectType()
    {
        return $this->_daNotification->getObjectType( $this->getId() );
    }

}

?>
