<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Http/Client.php' );

class BeMaverick_Email
{
    /**
     * Send an email to the user
     *
     * @param BeMaverick_Site $site
     * @param string $templateId
     * @param array $toEmailAddresses
     * @param hash $vars
     * @return void
     */
    public static function sendTemplate( $site, $templateId, $toEmailAddresses, $vars )
    {
        $systemConfig = $site->getSystemConfig();

        $environment = $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );

        $sparkpostApiKey = $systemConfig->getSetting( 'SPARKPOST_API_KEY' );

        $client = new Zend_Http_Client( 'https://api.sparkpost.com/api/v1/transmissions' );
        $client->setHeaders( array( 'Content-Type' => 'application/json' ) );
        $client->setHeaders( array( 'Authorization' => $sparkpostApiKey ) );

        $body = array(
            'content' => array(
                'template_id' => $templateId,
            ),
            'substitution_data' => $vars,
            'recipients' => array(),
        );

        if ( $environment != 'production' ) {
            $toEmailAddresses = $systemConfig->getSetting( 'SYSTEM_ADMIN_EMAIL_ADDRESSES' );
        }

        foreach ( $toEmailAddresses as $emailAddress ) {
            $body['recipients'][] = array( 'address' => array( 'email' => $emailAddress ) );
        }

        $client->setRawData( json_encode( $body ) );

        try {
            $response = $client->request( 'POST' );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Email::sendTemplate exception found: " . $e->getMessage() );
            return;
        }

        if ( ! $response || $response->getStatus() != 200 ) {
            error_log( "BeMaverick_Email::sendTemplate response invalid: " . print_r( $response, true ) );
            return;
        }
    }

    /**
     * Send an email to the user
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User[] $users
     * @return string
     */
    public static function getResetPasswordHtml( $site, $users )
    {
        $resetPasswordHtml = '';

        $systemConfig = $site->getSystemConfig();
        $timestamp = time();
        $salt = $systemConfig->getSetting( 'SYSTEM_RESET_PASSWORD_SALT' );
        $websiteHttpHost = $systemConfig->getSetting( 'SYSTEM_WEBSITE_HTTP_HOST' );

        // generate each html table for the reset password links for each user
        if ( count( $users ) > 1 ) {

            $resetPasswordHtml .= '<table border="1" cellpadding="2" cellspacing="2">';
            $resetPasswordHtml .= '<tr><th>Maverick</th><th>Link</th></tr>';

            foreach ( $users as $user ) {

                $email = $user->getEmailAddress();

                $signature = md5( $email. $timestamp . $salt );
                $code = base64_encode( "${email}|${timestamp}|${signature}" );

                $params = array(
                    'code' => $code,
                );

                $resetPasswordUrl = $site->getUrl( 'authPasswordReset', $params, false, $websiteHttpHost );

                $resetPasswordHtml .= '<tr><td>' . $email . '</td><td><a href="' . $resetPasswordUrl . '">Reset Maverick Password</a></td></tr>';
            }

            $resetPasswordHtml .= '</table>';

        } else {

            $email = $users[0]->getEmailAddress();

            $signature = md5( $email . $timestamp . $salt );
            $code = base64_encode( "${email}|${timestamp}|${signature}" );

            $params = array(
                'code' => $code,
            );

            $resetPasswordUrl = $site->getUrl( 'authPasswordReset', $params, false, $websiteHttpHost );

            $resetPasswordHtml .= '<a href="' . $resetPasswordUrl . '">Reset Maverick Password</a>';
        }

        return $resetPasswordHtml;
    }

    /**
     * Get the reset password url for a single user
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @return string
     */
    public static function getResetPasswordUrl( $site, $user )
    {
        $systemConfig = $site->getSystemConfig();
        $timestamp = time();
        $salt = $systemConfig->getSetting( 'SYSTEM_RESET_PASSWORD_SALT' );
        $websiteHttpHost = $systemConfig->getSetting( 'SYSTEM_WEBSITE_HTTP_HOST' );

        // try to set userIdentification by username first
        $userIdentification = $user->getUsername();

        // if no username available, set userIdentification by email
        if ( ! $userIdentification ) {
            $userIdentification = $user->getEmailAddress();
        }

        $signature = md5( $userIdentification . $timestamp . $salt );
        $code = base64_encode( "${userIdentification}|${timestamp}|${signature}" );

        $params = array(
            'code' => $code,
        );

        return $site->getUrl( 'authPasswordReset', $params, false, $websiteHttpHost );
    }

    /**
     * Get the HTML for the forgot username email
     *
     * @param BeMaverick_User[] $users
     * @return string
     */
    public static function getForgotUsernameHtml( $users )
    {
        $forgotUsernameHtml = '';

        // generate a html table with each user's username
        if ( count( $users ) > 1 ) {

            $forgotUsernameHtml .= '<table border="1" cellpadding="2" cellspacing="2">';
            $forgotUsernameHtml .= '<tr><th>Maverick</th></tr>';

            foreach ( $users as $user ) {

                $username = $user->getUsername();

                $forgotUsernameHtml .= '<tr><td>' . $username . '</td></tr>';
            }

            $forgotUsernameHtml .= '</table>';

        } else {

            $username = $users[0]->getUsername();

            $forgotUsernameHtml .= $username;
        }

        return $forgotUsernameHtml;
    }

    /**
     * Send the welcome email to kid that is a teen
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @return void
     */
    public static function sendNewUserEmailToTeenKid( $site, $user )
    {
        $emailAddress = $user->getEmailAddress();

        if ( $emailAddress ) {
            $vars = array(
                'USERNAME' => $user->getUsername(),
                'VERIFY_ACCOUNT_URL' => BeMaverick_Util::getVerifyAccountUrl( $site, $user ),
            );

            BeMaverick_Email::sendTemplate( $site, 'kid-new-user', array( $emailAddress ), $vars );
        }

    }

}
    
?>
