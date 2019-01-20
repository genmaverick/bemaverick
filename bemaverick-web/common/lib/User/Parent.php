<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/UserParent.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/User.php' );

class BeMaverick_User_Parent extends BeMaverick_User
{
    const ID_VERIFICATION_STATUS_PENDING   = 'pending';
    const ID_VERIFICATION_STATUS_VERIFIED  = 'verified';
    const ID_VERIFICATION_STATUS_REJECTED  = 'rejected';

    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = array();

    /**
     * @var BeMaverick_Da_UserParent
     * @access protected
     */
    protected $_daUserParent;

    /**
     * Class constructor
     *
     * @param BeMaverick_Site $site
     * @param integer $userId
     * @return void
     */
    public function __construct( $site, $userId )
    {
        parent::__construct( $site, $userId );

        $this->_daUserParent = BeMaverick_Da_UserParent::getInstance();
    }

    /**
     * Retrieves the user instance.
     *
     * @param BeMaverick_Site $site
     * @param integer $userId
     * @return BeMaverick_User_Parent
     */
    public static function getInstance( $site, $userId )
    {
        if ( ! $userId ) {
            return null;
        }
        
        if ( ! isset( self::$_instance[$userId] ) ) {

            $daUserParent = BeMaverick_Da_UserParent::getInstance();

            // make sure kid exists
            if ( ! $daUserParent->isKeysExist( array( $userId ) ) ) {
                self::$_instance[$userId] = null;
            } else {
                self::$_instance[$userId] = new self( $site, $userId );
            }
        }

        return self::$_instance[$userId];
    }

    /**
     * Create a parent
     *
     * @param BeMaverick_Site $site
     * @param string $username
     * @param string $password
     * @param string $emailAddress
     * @return BeMaverick_User_Parent
     */
    public static function createParent( $site, $username, $password, $emailAddress )
    {
        $userType = BeMaverick_User::USER_TYPE_PARENT;

        $user = self::createUser( $site, $userType, $username, $password, $emailAddress );
        $userId = $user->getId();

        $daUserParent = BeMaverick_Da_UserParent::getInstance();
        $daUserParent->createParent( $userId );

        // we might have already tried to get this user for some reason, so update
        // the self instance here and return it
        self::$_instance[$userId] = new self( $site, $userId );
        
        return self::$_instance[$userId];
    }

    /**
     * Get a list of kids
     *
     * @return BeMaverick_User_Kid[]
     */
    public function getKids()
    {
        $filterBy = array(
            'parentEmailAddress' => $this->getEmailAddress(),
        );

        return $this->_site->getUsers( $filterBy );
    }

    /**
     * Get the id verification status
     *
     * @return string
     */
    public function getIdVerificationStatus()
    {
        return $this->_daUserParent->getIdVerificationStatus( $this->getId() );
    }

    /**
     * Set the id verification status
     *
     * @param string $idVerificationStatus
     * @return void
     */
    public function setIdVerificationStatus( $idVerificationStatus )
    {
        $this->_daUserParent->setIdVerificationStatus( $this->getId(), $idVerificationStatus );
    }

    /**
     * Get the id verification timestamp
     *
     * @return string
     */
    public function getIdVerificationTimestamp()
    {
        return $this->_daUserParent->getIdVerificationTimestamp( $this->getId() );
    }

    /**
     * Set the id verification timestamp
     *
     * @param string $idVerificationTimestamp
     * @return void
     */
    public function setIdVerificationTimestamp( $idVerificationTimestamp )
    {
        $this->_daUserParent->setIdVerificationTimestamp( $this->getId(), $idVerificationTimestamp );
    }

    /**
     * Save the parent
     *
     * @return void
     */
    public function save()
    {
        $this->_daUserParent->save();

        parent::save();
    }

    /**
     * Delete the parent
     *
     * @return void
     */
    public function delete()
    {
        $this->_daUserParent->deleteParent( $this->getId() );

        parent::delete();
    }

        /**
     * Get the email notification status
     *
     * @return boolean
     */
    public function isEmailNotificationsEnabled( )
    {
        $value = $this->_daUserParent->getEmailNotificationsEnabled( $this->getId() );
        return ( $value == 1 ) ? true : false;
    }

    /**
     * Set the email notification status
     *
     * @param boolean $getEmailStatus
     * @return void
     */
    public function setEmailNotificationsEnabled( $isEmailNotificationsEnabled )
    {
        $value = $isEmailNotificationsEnabled ? 1 : 0;
        $this->_daUserParent->setEmailNotificationsEnabled( $this->getId(), $value );
    }
}

?>
