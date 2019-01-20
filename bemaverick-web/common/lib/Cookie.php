<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Cookie.php' );

/**
 * Class for managing cookies
 *
 */
class BeMaverick_Cookie extends Sly_Cookie
{

    /**
     * Get the user id from the cookie
     *
     * @return string
     */
    public static function getUserId()
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        $data = self::decodeString( @$_COOKIE['bu'] );

        // check that cookie is valid
        if ( ! $data ) {
            return false;
        }

        // get the salt
        $cookieSalt = $systemConfig->getCookieSalt();

        // validate the cookie
        $md5Hash = md5( $data['u'] . '.' . $data['ts'] . '.' . $cookieSalt );

        if ( $md5Hash != $data['h'] ) {
            return false;
        }

        return $data['u'];
    }

    /**
     * Update the user cookie
     *
     * @param BeMaverick_User $user
     * @return void
     */
    public static function updateUserCookie( $user )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        // get the cookie salt and domain
        $cookieSalt = $systemConfig->getCookieSalt();
        $cookieDomain = $systemConfig->getCookieDomain();

        $data = array();
        
        // update the latest data
        $data['u'] = $user->getId();
        $data['ts'] = time();

        // create the hash
        $md5Hash = md5( $data['u'] . '.' . $data['ts'] . '.' . $cookieSalt );

        // add the md5 values
        $data['h'] = $md5Hash;

        $cookieString = self::encodeData( $data );

        // set the cookie
        $expire = time()+60*60*24*300;

        setcookie( 'bu', $cookieString, $expire, '/', $cookieDomain );
    }

    /**
     * Delete the user cookie
     *
     * @return void
     */
    public static function deleteUserCookie()
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );
        $cookieDomain = $systemConfig->getCookieDomain();
        setcookie( 'bu', '', time()-3600, '/', $cookieDomain );
    }

}

?>
