<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/GeoData.php' );

/**
 * Class utility for the entire site
 *
 */
class BeMaverick_Util
{

    /**
     * Generate the url for verifying account
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @return string
     */
    public static function getVerifyAccountUrl( $site, $user )
    {
        $systemConfig = $site->getSystemConfig();
        $timestamp = time();
        $salt = $systemConfig->getSetting( 'SYSTEM_VERIFY_ACCOUNT_SALT' );
        $websiteHttpHost = $systemConfig->getSetting( 'SYSTEM_WEBSITE_HTTP_HOST' );

        $username = $user->getUsername();

        $signature = md5( $username . $timestamp . $salt );
        $code = base64_encode( "${username}|${timestamp}|${signature}" );

        $params = array(
            'code' => $code,
        );

        return $site->getUrl( 'authAccountVerifyConfirm', $params, false, $websiteHttpHost );
    }

    /**
     * Generate the url for verifying maverick
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @return string
     */
    public static function getParentVerifyMaverickUrl( $site, $user )
    {
        $systemConfig = $site->getSystemConfig();
        $timestamp = time();
        $salt = $systemConfig->getSetting( 'SYSTEM_VERIFY_ACCOUNT_SALT' );
        $websiteHttpHost = $systemConfig->getSetting( 'SYSTEM_WEBSITE_HTTP_HOST' );

        $username = $user->getUsername();

        $signature = md5( $username . $timestamp . $salt );
        $code = base64_encode( "${username}|${timestamp}|${signature}" );

        $params = array(
            'code' => $code,
        );

        return $site->getUrl( 'authParentVerifyMaverickStep1', $params, false, $websiteHttpHost );
    }

    /**
     * Generate UUID
     *
     * @return string
     */
    public static function generateUUID()
    {
        return sprintf(
            '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            // 32 bits for "time_low"
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            // 16 bits for "time_mid"
            mt_rand(0, 0xffff),
            // 16 bits for "time_hi_and_version",
            // four most significant bits holds version number 4
            mt_rand(0, 0x0fff) | 0x4000,
            // 16 bits, 8 bits for "clk_seq_hi_res",
            // 8 bits for "clk_seq_low",
            // two most significant bits holds zero and one for variant DCE1.1
            mt_rand(0, 0x3fff) | 0x8000,
            // 48 bits for "node"
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
        );
    }

    /**
     * Generate the activities of a kid
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @return array
     */

    public static function getActivities ( $site, $user )
    {
        $systemConfig = $site->getSystemConfig();
        $serviceURL = $systemConfig->getSetting( 'AWS_LAMBDA_SERVICE_URL' );
        $apiKey = $systemConfig->getSetting( 'AWS_LAMBDA_API_KEY' );
        $serviceURL = $serviceURL. 'message/getParentMessages/';

        if ( $user ) {
            $serviceURL = $serviceURL. $user->getId(). '?apiKey='. $apiKey;

            $client = new Zend_Http_Client( $serviceURL );
            $client->setHeaders( array(
                    'Content-Type' => 'application/json',
                )
            );
            $activitiesResponse = null;
            try {
                $activitiesResponse = $client->request( 'GET' );
//                error_log( print_r("Activities response".json_encode( $activitiesResponse->getBody() ), true) );
                $activitiesResponse = json_decode( $activitiesResponse->getBody(), true );
            }
            catch( Zend_Exception $e ) {
                error_log( "BeMaverick_Util::getActivities::Exception found: " . $e->getMessage() );
            }
        }
        return $activitiesResponse;
    }

    /**
     * Generate comments from aws lambda api
     *
     * @param BeMaverick_Site $site
     * @param Object $query
     * @return array
     */
    public static function getComments ( $site, $query = array() )
    {

        $systemConfig = $site->getSystemConfig();
        $serviceURL = $systemConfig->getSetting( 'AWS_LAMBDA_SERVICE_URL' );
        $apiKey = $systemConfig->getSetting( 'AWS_LAMBDA_API_KEY' );

        $serviceURL = $serviceURL. 'comments/';
        $serviceURL = $serviceURL. '?' . http_build_query($query);

        $client = new Zend_Http_Client( $serviceURL );
        $client->setHeaders( array(
                'Content-Type' => 'application/json',
                'Token' => $apiKey, // TODO: load auth token from logged in user
            )
        );
        $response = array();
        try {
            $response = $client->request( 'GET' );
            $response = json_decode( $response->getBody(), true );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Util::getComments::Exception found: " . $e->getMessage() );
        }
        
        return $response;
    }

    /**
     * Delete a user's comments from aws lambda api
     *
     * @param BeMaverick_Site $site
     * @param Object $query
     * @return array
     */
    public static function deleteComments ( $site, $query )
    {
        $systemConfig = $site->getSystemConfig();
        $serviceURL = $systemConfig->getSetting( 'AWS_LAMBDA_SERVICE_URL' );
        $apiKey = $systemConfig->getSetting( 'AWS_LAMBDA_API_KEY' );

        $serviceURL = $serviceURL. 'comments/';
        $serviceURL = $serviceURL. '?' . http_build_query($query);

        $client = new Zend_Http_Client( $serviceURL );
        $client->setHeaders( array(
                'Content-Type' => 'application/json',
                'Token' => $apiKey, // TODO: load auth token from logged in user
            )
        );
        $response = array();
        try {
            $response = $client->request( 'DELETE' );
            $response = json_decode( $response->getBody(), true );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Util::deleteComments::Exception found: " . $e->getMessage() );
        }

        return $response;
    }

    /**
     * Delete the comment mentions the user is included in from aws lambda api
     *
     * @param BeMaverick_Site $site
     * @param Object $query
     * @return array
     */
    public static function deleteMentions ( $site, $query )
    {
        $systemConfig = $site->getSystemConfig();
        $serviceURL = $systemConfig->getSetting( 'AWS_LAMBDA_SERVICE_URL' );
        $apiKey = $systemConfig->getSetting( 'AWS_LAMBDA_API_KEY' );

        $serviceURL = $serviceURL. 'comments/mentions';
        $serviceURL = $serviceURL. '?' . http_build_query($query);

        $client = new Zend_Http_Client( $serviceURL );
        $client->setHeaders( array(
                'Content-Type' => 'application/json',
                'Token' => $apiKey, // TODO: load auth token from logged in user
            )
        );
        $response = array();
        try {
            $response = $client->request( 'DELETE' );
            $response = json_decode( $response->getBody(), true );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Util::deleteMentions::Exception found: " . $e->getMessage() );
        }

        return $response;
    }

    /**
     * Generate user level from aws lambda api
     *
     * @param BeMaverick_Site $site
     * @param number $userId
     * @return array
     */
    public static function getUserCurrentLevelNumber ( $site, $userId )
    {

        $systemConfig = $site->getSystemConfig();
        $serviceURL = $systemConfig->getSetting( 'AWS_LAMBDA_SERVICE_URL' );
        $apiKey = $systemConfig->getSetting( 'AWS_LAMBDA_API_KEY' );

        $serviceURL = $serviceURL. 'progression/users';
        $serviceURL = $serviceURL . '/' . $userId;

        $client = new Zend_Http_Client( $serviceURL );
        $client->setHeaders( array(
                'Content-Type' => 'application/json',
                'Token' => $apiKey, // TODO: load auth token from logged in user
            )
        );
        $response = array();
        try {
            $response = $client->request( 'GET' );
            $response = json_decode( $response->getBody(), true );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Util::getComments::Exception found: " . $e->getMessage() );
        }

        if ( $response["progression"] && $response["progression"]["currentLevelNumber"] ) {
            $currentLevelNumber = $response["progression"]["currentLevelNumber"];
        } else {
            $currentLevelNumber = 1;
        }

        return $currentLevelNumber;
    }

    /**
     * Send notification to aws lambda api
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_Response $response
     * @param BeMaverick_Badge $badge
     * @param BeMaverick_User $givenBadgeUser
     * @param BeMaverick_User $receivedBadgeUser
     * @return void
     */
    public static function sendNotificationForBadgeGiven( $site, $response, $badge, $givenBadgeUser, $receivedBadgeUser )
    {

        $systemConfig = $site->getSystemConfig();
        $notificationUrl = $systemConfig->getSetting( 'AWS_LAMBDA_NOTIFICATION_URL' );
        $apiKey = $systemConfig->getSetting( 'AWS_LAMBDA_API_KEY' );
        $deepLinkProtocol = $systemConfig->getSetting( 'AWS_LAMBDA_DEEP_LINK_PROTOCOL' );

        $badgeName = $badge->getName();

        $client = new Zend_Http_Client( $notificationUrl );

        $client->setHeaders(
            array(
                'Content-Type' => 'application/json',
                'Token' => $apiKey,
            )
        );

        $body = array(
            "requestType" => "badged",
            "sourceUserId" => $givenBadgeUser->getId(),
            "targetUserId" => "apiLookUp",
            "subjectId" => $response->getId(),
            "subjectType" => "response",
            "notificationCopyNoChallenge" => "%s has given you a $badgeName Badge for your post",
            "sourceDeepLinkUrl" => "$deepLinkProtocol://maverick/user/" . $givenBadgeUser->getId(),
            "targetDeepLinkUrl" => "$deepLinkProtocol://maverick/response/" . $receivedBadgeUser->getId(),
            "notificationCopy" => "%s has given you a $badgeName Badge for your response to %s",
        );

        $jsonBody = json_encode( $body );

        $client->setRawData( $jsonBody, null );

        try {
            $client->request( 'POST' );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Util::sendNotificationForBadgeGiven::Exception found: " . $e->getMessage() );
        }

    }

    /**
     * Send notification to aws lambda api
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_Response or BeMaverick_Challenge $content
     * @param BeMaverick_User $message
     * @param string $contentType
     * @return void
     */
    public static function sendNotificationForModeration( $site, $content, $message, $contentType = 'response' )
    {

        $systemConfig = $site->getSystemConfig();
        $notificationUrl = $systemConfig->getSetting( 'AWS_LAMBDA_NOTIFICATION_URL' );
        $apiKey = $systemConfig->getSetting( 'AWS_LAMBDA_API_KEY' );
        $deepLinkProtocol = $systemConfig->getSetting( 'AWS_LAMBDA_DEEP_LINK_PROTOCOL' );
        $environment = $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );

        $devMode = true;
        if ($environment == 'production') {
            $devMode = false;
        }

        $client = new Zend_Http_Client( $notificationUrl );

        $client->setHeaders(
            array(
                'Content-Type' => 'application/json',
                'Token' => $apiKey,
            )
        );

        $body = array(
            "requestType" => "moderated",
            "targetUserId" => "apiLookUp",
            "subjectId" => $content->getId(),
            "subjectType" => $contentType,
            "targetDeepLinkUrl" => "$deepLinkProtocol://maverick/$contentType/" . $content->getId(),
            "notificationCopy" => $message,
            "devMode"   => $devMode
        );

        $jsonBody = json_encode( $body );

        $client->setRawData( $jsonBody, null );

        try {
            $client->request( 'POST' );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Util::sendNotificationForModeration::Exception found: " . $e->getMessage() );
        }

    }

    /**
     * Send notification to aws lambda api
     *
     * @param string $string
     * @return array
     */
    public static function getHashtagsFromString( $string )
    {
        $hashtags= null;

        // look for words items with # and return array
        preg_match_all("/(#\w+)/u", $string, $matches);

        if ($matches) {
            $hashtagsArray = array_count_values($matches[0]);
            $hashtags = array_keys($hashtagsArray);
        }

        // remove hashtags
        $removeHashtags = function($tag) {
            return str_replace('#', '', $tag);
        };

        $hashtags = array_map($removeHashtags, $hashtags);

        // return array
        return $hashtags;
    }

    /**
     * Merge arrays recursively
     *
     * Unlike php function array_merge_recursive this will use integer keys
     * as keys.
     *
     * @param array $array1
     * @param array $array2
     * @return array
     */
    public static function mergeArrayRecursive( &$array1, &$array2 )
    {
        foreach ( $array2 as $key => $value ) {
            // if not in $array1 we can just set it
            if ( !isset( $array1[$key] ) ) {
                $array1[$key] = $value;
                continue;
            }

            // if they are not both arrays overwrite the value in $array1
            if ( gettype( $array1[$key] ) != 'array' || gettype( $value ) != 'array' ) {
                $array1[$key] = $value;
                continue;
            }

            // both are arrays so we need to merge those too
            self::mergeArrayRecursive( $array1[$key], $array2[$key] );
        }
    }

    /**
     * Get country from IP Address
     *
     * @param string $ipAddress
     * @return string
     */
    public static function getCountryFromIPAddress( $ipAddress )
    {
        if ( ! $ipAddress ) {
            return null;
        }

        $geoData = Sly_GeoData::getGeolocationFromIPAddress( $ipAddress );

        if ( $geoData ) {
            return $geoData['country'];
        }

        return null;
    }

    /**
     * Get the ip address from the request
     *
     * @return string
     */
    public static function getRequestIpAddress()
    {
        // get the IP Address from the x-forwarded-for header in case it comes from the load balancer
        // or varnish or some other proxy
        $ipAddress = @$_SERVER['HTTP_X_FORWARDED_FOR'];

        // if no ip address, lets get it the standard way
        if ( ! $ipAddress ) {
            $ipAddress = $_SERVER['REMOTE_ADDR'];
        }

        // sometimes the ip addresses are added to each other as they go through proxies, so
        // lets get the first one in the list which should be the original client
        if ( strpos( $ipAddress, ',' ) !== false ) {
            $ipAddresses = explode( ', ', $ipAddress );

            $ipAddress = $ipAddresses[0];
        }

        // if the IP address is not IPv4, then just assume we couldn't get it so return null
        if ( ! filter_var( $ipAddress, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4 ) ) {
            return null;
        }

        return $ipAddress;
    }



}

?>
