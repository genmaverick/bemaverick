<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_UserLoginProviders extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_UserLoginProviders
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'user_login_providers';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'user_id', 'login_provider' );

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array(
        'getLoginProviderUserId'       => 'login_provider_user_id',
        
        'setLoginProviderUserId'       => 'login_provider_user_id',
    );

    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_UserLoginProviders
     */
    public static function getInstance()
    {
        if (null === self::$_instance) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }

    /**
     * Get a list of login providers
     *
     * @param integer $userId
     * @return array
     */
    public function getLoginProviders( $userId )
    {
        $select = array( 'login_provider' );

        $where = array();

        $where[] = "user_id = $userId";

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchColumns( $sql );
    }

    /**
     * Get the user id
     *
     * @param string $loginProvider
     * @param string $loginProviderUserId
     * @return integer
     */
    public function getUserId( $loginProvider, $loginProviderUserId )
    {
        $select = array( 'user_id' );

        $where = array();

        $where[] = "login_provider = '$loginProvider'";
        $where[] = "login_provider_user_id = '$loginProviderUserId'";

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchOne( $sql );
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
    }

}

?>
