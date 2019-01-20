<?php

use Twilio\Jwt\AccessToken;
use Twilio\Jwt\Grants\ChatGrant;
use Twilio\Rest\Client;

require_once( ZEND_ROOT_DIR    . '/lib/Zend/Registry.php' );
require_once( ZEND_ROOT_DIR    . '/lib/Zend/Cache.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Util.php' );

class BeMaverick_Comment
{

    const DEFAULT_TTL = 60 * 60; // 60 minutes
    const DEFAULT_ALLOW_CACHE = true;

    /**
     * Loads the API Key for accessing comments lambda microservice
     *
     * @param BeMaverick_User $user
     * @param String $deviceId
     * @return String
     */
    public function getLambdaApiKey( $site, $user )
    {
        // TODO: Generate OAuth Token based on authenticated user
        $systemConfig = $site->getSystemConfig();
        $apiKey = $systemConfig->getSetting( 'AWS_LAMBDA_API_KEY' );

        return $apiKey;
    }

    /**
     * Get the comments using lambda microservice
     *
     * @param BeMaverick_Site $site
     * @param String $parentType        e.g. challenge, response
     * @param String $parentId          e.g. 1, 900
     * @param Array $query              query object
     * @return Object
     */
    public static function getComments(
        $site,
        $parentType,
        $parentId,
        $query,
        $allowCache = self::DEFAULT_ALLOW_CACHE,
        $ttl = self::DEFAULT_TTL
    ) {
        /** Build the comments query */
        $query = array_merge(
            array(
                'sort' => '-created',
                'skip' => 0,
                'limit' => 99
            ),
            $query,
            array(
                'parentType' => $parentType,
                'parentId' => $parentId,
            )
        );

        /** Check for cached data, first */
        $zendCache = Zend_Registry::get( 'cache' );
        $queryMd5 = md5(json_encode($query));
        $cacheKey = 'bemaverick_comments_' . $queryMd5;
        if ( $zendCache && $allowCache ) {
            $data = $zendCache->load( $cacheKey, $found );
            // error_log('cache : load : ' . $cacheKey . ' : ' . var_export($found));
            if ( $found ) {
                return json_decode($data, true);
            }
        }

        /** Load comments from the microservice, */
        $comments = BeMaverick_Util::getComments($site, $query);

        /** Create uesrId tag array */
        $tags = array();
        if($comments) {
            $commentsArr = $comments['data'];
            foreach ($commentsArr as $comment) {
                $tags[] = 'user:'.$comment['userId'];
                if ($comment['meta'] && $comment['meta']['mentions']) {
                    foreach ($comment['meta']['mentions'] as $mention) {
                        $tags[] = 'mention:'.$mention['userId'];
                    }

                }

            }
        }

        /** Save comments to redis cache */
        if ( $zendCache ) {
            // error_log('cache : save : ' . $cacheKey);
            $zendCache->save( json_encode($comments), $cacheKey, $tags, $ttl );
        }
        return $comments;
    }

    /**
     * Delete a user's comments using lambda microservice
     *
     * @param BeMaverick_Site $site
     * @param String $parentType        e.g. challenge, response
     * @param String $parentId          e.g. 1, 900
     * @param Array $query              query object
     * @return Object
     */
    public static function deleteComments(
        $site,
        $userId,
        $active,
        $ttl = self::DEFAULT_TTL
    ) {

        /** Build the comments query */
        $query = array(
            'userId' => $userId,
            'active' => $active,
        );

        /** Check for cached data, first */
        $zendCache = Zend_Registry::get( 'cache' );
        $queryMd5 = md5(json_encode($query));
        $cacheKey = 'bemaverick_comments_' . $queryMd5;

        /** Clean records with matching tags from redis cache */
        $tag = 'user:' . $userId;
        if ( $zendCache ) {
            $zendCache->clean(
                Zend_Cache::CLEANING_MODE_MATCHING_TAG,
                array($tag)
            );
        }

        /** Load comments from the microservice, */
        $deletedComments = BeMaverick_Util::deleteComments($site, $query);

        return $deletedComments;
    }

    /**
     * Delete the comment mentions the user is included in using lambda microservice
     *
     * @param BeMaverick_Site $site
     * @param String $parentType        e.g. challenge, response
     * @param String $parentId          e.g. 1, 900
     * @param Array $query              query object
     * @return Object
     */
    public static function deleteMentions(
        $site,
        $userId,
        $active,
        $ttl = self::DEFAULT_TTL
    ) {
        /** Build the comments query */
        $query = array(
            'userId' => $userId,
            'active' => $active,
        );

        /** Check for cached data, first */
        $zendCache = Zend_Registry::get( 'cache' );
        $queryMd5 = md5(json_encode($query));
        $cacheKey = 'bemaverick_comments_' . $queryMd5;

        /** Clean records with matching tags from redis cache */
        $tag = 'mention:' . $userId;
        if ( $zendCache ) {
            $zendCache->clean(
                Zend_Cache::CLEANING_MODE_MATCHING_TAG,
                array($tag)
            );
        }

        /** Load comments from the microservice, */
        $updatedComments = BeMaverick_Util::deleteMentions($site, $query);

        return $updatedComments;
    }

    /**
     * Update a comment with inappropriate flag
     *
     * @param BeMaverick_Response $response
     * @param string $messageId
     * @param boolean $inappropriate
     * @return string
     */
    public static function NOT_USED_updateComment( $response, $messageId, $inappropriate )
    {
        return $messageId;
    }

    /**
     * Get the twilio client object
     * Generates the access token for accessing comments lambda microservice
     *
     * @param BeMaverick_Site $site
     * @return Twilio\Jwt\Client
     */
    public static function getTwilioClient( $site )
    {
        $systemConfig = $site->getSystemConfig();

        $accountSid = $systemConfig->getSetting( 'TWILIO_ACCOUNT_SID' );
        $token = $systemConfig->getSetting( 'TWILIO_ACCESSTOKEN' );

        return new Client( $accountSid, $token );
    }

    /**
     * Generates the access token for accessing the comments third party provider
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @param String $deviceId
     * @return String
     */
    public static function createAccessToken( $site, $user, $deviceId )
    {
        $systemConfig = $site->getSystemConfig();

        $accountSid = $systemConfig->getSetting( 'TWILIO_ACCOUNT_SID' );
        $apiKey = $systemConfig->getSetting( 'TWILIO_API_KEY' );
        $apiSecret = $systemConfig->getSetting( 'TWILIO_API_SECRET' );
        $serviceSid = $systemConfig->getSetting( 'TWILIO_SERVICE_SID' );
        $appName = $systemConfig->getSetting( 'TWILIO_APPNAME' );

        $identity = $user->getUsername();
        $endpointId = $appName . ':' . $identity . ':' . $deviceId;

        // Create access token, which we will serialize and send to the client
        $token = new AccessToken( $accountSid, $apiKey, $apiSecret, 3600, $identity );

        // Create Chat grant
        $chatGrant = new ChatGrant();
        $chatGrant->setServiceSid( $serviceSid );
        $chatGrant->setEndpointId( $endpointId );

        // Add grant to token
        $token->addGrant( $chatGrant );

        return $token->toJWT();
    }

}

?>
