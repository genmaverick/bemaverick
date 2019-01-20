<?php
use Aws\Sns\SnsClient;
require_once( ZEND_ROOT_DIR . '/lib/Zend/Http/Client.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Util.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/helpers/DebugElapsed.php' );


class BeMaverick_Moderation
{
    const MODERATION_STATUS_ALLOW     = 'allow';
    const MODERATION_STATUS_REPLACE   = 'replace';
    const MODERATION_STATUS_REJECT    = 'reject';
    const MODERATION_STATUS_QUEUEDFORAPPROVAL   = 'queuedForApproval';
    const MODERATION_STATUS_DELETED   = 'deleted';
    const MODERATION_STATUS_STARTED   = 'started';
    const MODERATION_STATUS_ERROR   = 'error';

    /**
     * Flag the response
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_Response $response
     * @param BeMaverick_User $user
     * @param String $reason
     * @return void
     */

    public static function flagResponse ( $site, $response, $user, $reason  )
    {
        $moderateURI = 'content/item/flag/';
        $systemConfig = $site->getSystemConfig();
        $environment = $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );
        $apiKey = $systemConfig->getSetting( 'CLEANSPEAK_API_KEY' );
        $applicationId = $systemConfig->getSetting( 'CLEANSPEAK_RESPONSE_APPLICATION_ID' );
        $serviceURL = $systemConfig->getSetting( 'CLEANSPEAK_API_URL' );

        $userUUID = $user->getUUID();
        //if the user doesn't have a uuid, generate one
        if ( !$userUUID )
        {
            $user->setUUID( BeMaverick_Util::generateUUID() );
        }

        $responseUUID = $response->getUUID();
        //if the response doesn't have a uuid, generate one
        if ( !$responseUUID )
        {
            $response->setUUID( BeMaverick_Util::generateUUID() );
            //Add the response to the CleanSpeak system before flagging it.
            self::moderateResponse( $site, $response );
        }
        $serviceURL = $serviceURL . $moderateURI . $response->getUUID();

        $client = new Zend_Http_Client( $serviceURL );
        $client->setHeaders( array(
                'Content-Type' => 'application/json',
                'Authorization'=> $apiKey,
            )
        );

        $body = array(
            'flag'   => array(
                'createInstant'     => round(microtime(true) * 1000),
                'reason'            => $reason,
                'reporterId'        => $user->getUUID()
            )
        );

        $client->setRawData( json_encode( $body ) );
        try {
            $moderationResponse = $client->request( 'POST' );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Moderation::flagResponse::Exception found: " . $e->getMessage() );
        }

        if ( $moderationResponse && $moderationResponse->getStatus() == 200 ) {
            error_log("BeMaverick_Moderation::flagResponse::Moderation flagged response successfull " );
        } else {
            self:handleErrorResponses( $moderationResponse );
        }
        //Make the response inactive
        $response->setModerationStatus( 'queuedForApproval' );
        $response->setStatus( BeMaverick_Response::RESPONSE_STATUS_INACTIVE );
    }

    /**
     * Moderate the user.
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @return void
     */
    public static function moderateUser ( $site, $user )
    {

        $moderateURI = 'content/user/';
        $systemConfig = $site->getSystemConfig();
        $apiKey = $systemConfig->getSetting( 'CLEANSPEAK_API_KEY' );
        $userApplicationId = $systemConfig->getSetting( 'CLEANSPEAK_USERDATA_APPLICATION_ID' );
        $responseApplicationId = $systemConfig->getSetting( 'CLEANSPEAK_RESPONSE_APPLICATION_ID' );
        $serviceURL = $systemConfig->getSetting( 'CLEANSPEAK_API_URL' );

        $userUUID = $user->getUUID();
        //if the user doesn't have a uuid, generate one
        if ( !$userUUID )
        {
            $user->setUUID( BeMaverick_Util::generateUUID() );
        }
        $serviceURL = $serviceURL . $moderateURI . $user->getUUID();

        $client = new Zend_Http_Client( $serviceURL );
        $headers = array(
            'Authorization'=> $apiKey,
        );

        $applicationIds = array();
        $applicationIds[] = $userApplicationId;
        $applicationIds[] = $responseApplicationId;

        $displayNames   = array( $user ->getUsername() );
        $profileImage = $user->getProfileImage();
        $profileImageUrl = $profileImage ? $profileImage->getUrl() : null;
        $email = $user->isTeen() ? $user->getEmailAddress() : $user->getParentEmailAddress();

        $body = array(
            'user'   => array(
                'applicationId'     => $applicationIds,
                'createInstant'     => round(microtime(true) * 1000),
                'email'             => $email,
                'name'              => $user->getFirstName().' '.$user->getLastName(),
                'imageURL'          => $profileImageUrl,
                'displayNames'      => $displayNames,
                'birthDate'         => $user->getBirthdate()
            )
        );

        try {
            $client->setHeaders( $headers );
            $userResponse = $client->request( 'GET' );
            if (! $userResponse || $userResponse->getStatus() == 404 ) {
                $headers['Content-Type'] = 'application/json';
                $client->setHeaders( $headers );
                $client->setRawData( json_encode( $body ) );
                $moderationResponse = $client->request( 'POST' );
            }else {
                $headers['Content-Type'] = 'application/json';
                $client->setHeaders( $headers );
                $client->setRawData( json_encode( $body ) );
                $moderationResponse = $client->request( 'PUT' );
            }
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Moderation::moderateUser exception found: " . $e->getMessage() );
        }
        if ( $moderationResponse && $moderationResponse->getStatus() == 200 ) {
            error_log("BeMaverick_Moderation::moderateUser::User created/updated successfully " );
        } else {
            self::handleErrorResponses( $moderationResponse );
        }
    }


    /**
     * Flag the response
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     * @param BeMaverick_User $flaggedUser
     * @param String $reason
     * @return void
     */

    public static function flagUser ( $site, $user, $flaggedUser, $reason  )
    {
        $moderateURI = 'content/user/flag/';
        $systemConfig = $site->getSystemConfig();
        $environment = $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );
        $apiKey = $systemConfig->getSetting( 'CLEANSPEAK_API_KEY' );
        $applicationId = $systemConfig->getSetting( 'CLEANSPEAK_USERDATA_APPLICATION_ID' );
        $serviceURL = $systemConfig->getSetting( 'CLEANSPEAK_API_URL' );

        $userUUID = $flaggedUser->getUUID();
        //if the user doesn't have a uuid, generate one
        if ( !$userUUID )
        {
            $flaggedUser->setUUID( BeMaverick_Util::generateUUID() );
        }

        $userUUID = $user->getUUID();
        //if the user doesn't have a uuid, generate one
        if ( !$userUUID )
        {
            $user->setUUID( BeMaverick_Util::generateUUID() );
        }

        $serviceURL = $serviceURL . $moderateURI . $flaggedUser->getUUID();

        $client = new Zend_Http_Client( $serviceURL );
        $client->setHeaders( array(
                'Content-Type' => 'application/json',
                'Authorization'=> $apiKey,
            )
        );

        $body = array(
            'flag'   => array(
                'applicationId'     => $applicationId,
                'createInstant'     => round(microtime(true) * 1000),
                'reason'            => $reason,
                'reporterId'        => $user->getUUID()
            )
        );

        $client->setRawData( json_encode( $body ) );
        try {
            $moderationResponse = $client->request( 'POST' );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Moderation::flagUser::Exception found: " . $e->getMessage() );
        }
        if ( $moderationResponse && $moderationResponse->getStatus() == 200 ) {
            error_log("BeMaverick_Moderation::flagUser::Moderation flagged user successfully " );
        } else {
            self::handleErrorResponses( $moderationResponse );
        }

        //Make the user inactive
        $user->setStatus( BeMaverick_User::USER_STATUS_REVOKED );
        $user->setRevokedReason( BeMaverick_User::USER_REVOKED_OTHER );
        $user->save();
    }


    /**
     * Moderate bio, profileImage and coverImage
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User $user
     */

    public static function moderateUserData ( $site, $user )
    {
        $moderateURI = 'content/item/moderate';
        $systemConfig = $site->getSystemConfig();
        $environment = $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );
        $apiKey = $systemConfig->getSetting( 'CLEANSPEAK_API_KEY' );
        $applicationId = $systemConfig->getSetting( 'CLEANSPEAK_USERDATA_APPLICATION_ID' );
        $serviceURL = $systemConfig->getSetting( 'CLEANSPEAK_API_URL' );

        $userUUID = $user->getUUID();
        $serviceURL = $serviceURL . $moderateURI;

        $client = new Zend_Http_Client( $serviceURL );
        $client->setHeaders( array(
                'Content-Type' => 'application/json',
                'Authorization'=> $apiKey,
            )
        );

        $bio = $user->getBio();
        $firsName = $user->getFirstName();
        $lastName = $user->getLastName();
        $profileImage = $user->getProfileImage();
        $profileCoverImage = $user->getProfileCoverImage();

        if ( $bio ) {
            $moderatedText = BeMaverick_Moderation::moderateTransientText( $client, $applicationId, $bio, 'bio', $userUUID );
            if( $moderatedText ) {
                $user->setBio( $moderatedText );
            }
        }
        if ( $firsName ) {
            $moderatedText = BeMaverick_Moderation::moderateTransientText( $client, $applicationId, $firsName, 'firstName', $userUUID );
            if( $moderatedText ) {
                $user->setFirstName( $moderatedText );
            }
        }
        if ( $lastName ) {
            $moderatedText = BeMaverick_Moderation::moderateTransientText( $client, $applicationId, $lastName, 'lastName', $userUUID );
            if( $moderatedText ) {
                $user->setLastName( $moderatedText );
            }
        }

        if( $profileImage ) {
            $moderatedImage = BeMaverick_Moderation::moderateTransientImage( $client, $applicationId, $environment, $profileImage, 'profileImage', $userUUID );
            if( !$moderatedImage ) {
                $user->setProfileImage( null );
            }
        }

        if( $profileCoverImage ) {
            $moderatedImage = BeMaverick_Moderation::moderateTransientImage( $client, $applicationId, $environment, $profileCoverImage, 'profileImage', $userUUID );
            if( !$moderatedImage ) {
                $user->setProfileCoverImage( null );
            }
        }
    }


    /**
     * Moderate the username
     *
     * @param BeMaverick_Site $site
     * @param String $username
     * @return boolean
     */

    public static function moderateUserName ( $site, $username )
    {
        $moderateURI = 'content/item/moderate';
        $systemConfig = $site->getSystemConfig();
        $apiKey = $systemConfig->getSetting( 'CLEANSPEAK_API_KEY' );
        $applicationId = $systemConfig->getSetting( 'CLEANSPEAK_USERNAME_APPLICATION_ID' );
        $serviceURL = $systemConfig->getSetting( 'CLEANSPEAK_API_URL' );
        $serviceURL = $serviceURL . $moderateURI ;

        $client = new Zend_Http_Client( $serviceURL );
        $client->setHeaders( array(
                'Content-Type' => 'application/json',
                'Authorization'=> $apiKey,
            )
        );
        $body = array(
            'content'   => array(
                'applicationId'     => $applicationId,
                'createInstant'     => round(microtime(true) * 1000),
                'parts'             => array( array(
                    'content'   => $username,
                    'name'      => 'username',
                    'type'      => 'text') ),
                'senderId'          => BeMaverick_Util::generateUUID(),
            )
        );

        $client->setRawData( json_encode( $body ) );
        $moderationStatus = '';
        try {
            $moderationResponse = $client->request( 'POST' );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Moderation::moderateUserName::Moderation exception found: " . $e->getMessage() );
        }
        if ( !$moderationResponse || $moderationResponse->getStatus() == 200 ) {
            $responseResult = json_decode( $moderationResponse->getBody(), true );
            $moderationStatus = $responseResult['contentAction'] ? $responseResult['contentAction'] : '';
            if( $moderationStatus == 'allow' ) {
                return true;
            }
        } else {
            self::handleErrorResponses( $moderationResponse );
        }
        return false;
    }

    /**
     * Handle the response approvals from the moderation tool.
     *
     * @param BeMaverick_Site $site
     * @param String $input
     * @return boolean
     */

    public static function moderateResponseApprovals ( $site, $input )
    {
        $requestJson = json_decode( $input, true );
        $type = $requestJson['type'];
        error_log( print_r("BeMaverick_Moderation::moderateResponseApprovals::Response body".json_encode( $requestJson ), true) );

        if( $type == 'contentApproval' )
        {
            $approvals = $requestJson['approvals'];
            foreach ( $approvals as $key => $value ) {
                $filterBy = array(
                    'uuid' => $key,
                );
                $response = BeMaverick_Response::getResponse( $site, $filterBy );
                if( $value == 'approved' ) {
                    $response->setStatus( BeMaverick_Response::RESPONSE_STATUS_ACTIVE );
                    $response->setModerationStatus( BeMaverick_Moderation::MODERATION_STATUS_ALLOW );
                    $response->setUpdatedTimestamp( date( 'Y-m-d H:i:s' ) );
                    $message = "False alarm! Your content is totally fine and it’s back online. Thanks for your patience!";
                    BeMaverick_Util::sendNotificationForModeration( $site, $response, $message, 'response' );
                }elseif ( $value == 'rejected' ) {
                    $response->setStatus( BeMaverick_Response::RESPONSE_STATUS_INACTIVE );
                    $response->setModerationStatus( BeMaverick_Moderation::MODERATION_STATUS_REJECT );
                    $response->setUpdatedTimestamp( date( 'Y-m-d H:i:s' ) );
                    $message = "Sorry, but we had to remove your content because it violates our community guidelines.";
                    BeMaverick_Util::sendNotificationForModeration( $site, $response, $message, 'response' );
                }
            }
        }else if ( $type == 'contentDelete' ) {
            $uuid = $requestJson['id'];
            $filterBy = array(
                'uuid' => $uuid,
            );
            $response = BeMaverick_Response::getResponse( $site, $filterBy );
            $response->setStatus( BeMaverick_Response::RESPONSE_STATUS_DELETED );
            $response->setModerationStatus( BeMaverick_Moderation::MODERATION_STATUS_DELETED );
            $response->setUpdatedTimestamp( date( 'Y-m-d H:i:s' ) );
        }
        return true;
    }

    /**
     * Handle the user action from the moderation tool.
     *
     * @param BeMaverick_Site $site
     * @param String $input
     * @return boolean
     */

    public static function moderateUserActions ( $site, $input )
    {
        $requestJson = json_decode( $input, true );
        $userUUID = $requestJson['userId'];
        $action = $requestJson['action'];
        $type = $requestJson['type'];

        if( $type == 'userAction'  )
        {
            if( $action == 'ban' || $action == 'mute' )
            {
                $filterBy = array(
                    'uuid' => $userUUID,
                );
                $user = BeMaverick_User::getUser( $site, $filterBy );
                //Make the user inactive
                $user->setStatus( BeMaverick_User::USER_STATUS_INACTIVE );
                $user->save();
            }
        }
        return true;
    }

    /**
     * Handle the error from the http response.
     *
     * @param HttpResponse $response
     */

    private static function handleErrorResponses ( $response )
    {
        if ( $response ) {
            if ( $response->getStatus() == 400 ) {
                $responseResult = json_decode( $response->getBody(), true );
                $moderationGeneralErrors = $responseResult['generalErrors']?$responseResult['generalErrors']:'';
                $moderationFieldErrors = $responseResult['fieldErrors']?$responseResult['fieldErrors']:'';
                error_log( print_r("BeMaverick_Moderation::Moderation general errors found: " . json_encode( $moderationGeneralErrors ), true ) );
                error_log( print_r("BeMaverick_Moderation::Moderation field errors found: " . json_encode( $moderationFieldErrors ), true ) );
            } else if ( $response->getStatus() == 401 ) {
                error_log( "BeMaverick_Moderation::Moderation Error: You did not supply a valid Authorization header. The header was omitted or your API key was not valid." );
            } else if ( $response->getStatus() == 402 ) {
                error_log( "BeMaverick_Moderation::Moderation Error: Your license has expired. " );
            } else if ( $response->getStatus() == 500 ) {
                error_log( "BeMaverick_Moderation::Moderation Error: CleanSpeak internal server error." );
            }else if ( $response->getStatus() != 200 ){
                error_log( "BeMaverick_Moderation::Moderation Error: other error." );
            }
        }else {
            error_log( "BeMaverick_Moderation::Moderation Error: Invalid Response" );
        }
    }

    /**
     * Moderate a text without id
     *
     * @param Zend_Http_Client $client
     * @param String $applicationId
     * @param String $text
     * @param String $name
     * @param String $userUUID
     * @return string
     */
    private static function moderateTransientText ( $client, $applicationId, $text, $name, $userUUID )
    {
        $body = array(
            'content' => array(
                'applicationId' => $applicationId,
                'createInstant' => round(microtime( true ) * 1000 ),
                'parts' => array(array(
                    'content' => $text,
                    'name' => $name,
                    'type' => 'text' )),
                'senderId' => $userUUID,
            )
        );

        $client->setRawData( json_encode( $body ));
        try {
            $moderationResponse = $client->request( 'POST' );
        } catch ( Zend_Exception $e ) {
            error_log("BeMaverick_Moderation::moderateTransientText::Moderation exception found: " . $e->getMessage());
        }
        if ( !$moderationResponse || $moderationResponse->getStatus() == 200 ) {
            $responseResult = json_decode( $moderationResponse->getBody(), true );
            $moderationStatus = $responseResult['contentAction'] ? $responseResult['contentAction'] : '';
            if ($moderationStatus == 'replace') {
                return $responseResult['content']['parts'][0]['replacement'] ;
            } else if ( $moderationStatus == 'reject' ) {
                return "*****";
            }
        } else {
            self::handleErrorResponses( $moderationResponse );
        }
        return ;
    }

    /**
     * Moderate a image without id
     *
     * @param Zend_Http_Client $client
     * @param String $applicationId
     * @param String $environment
     * @param BeMaverick_Image $image
     * @param String $userUUID
     * @return string
     */
    private static function moderateTransientImage ( $client, $applicationId, $environment, $image, $name, $userUUID )
    {

        if( $environment == 'devel' ) {
            $imageURL = 'https://s3.amazonaws.com/dev-bemaverick-images/' . $image->getFilename();
        }else {
            $imageURL = $image->getUrl();
        }

        $body = array(
            'content' => array(
                'applicationId' => $applicationId,
                'createInstant' => round(microtime( true ) * 1000 ),
                'parts' => array(array(
                    'content' => $imageURL,
                    'name' => $name,
                    'type' => 'image' )),
                'senderId' => $userUUID,
            )
        );

        $client->setRawData( json_encode( $body ));
        try {
            $moderationResponse = $client->request( 'POST' );
        } catch ( Zend_Exception $e ) {
            error_log("BeMaverick_Moderation::moderateTransientImage::Moderation exception found: " . $e->getMessage());
        }
        if ( !$moderationResponse || $moderationResponse->getStatus() == 200 ) {
            $responseResult = json_decode( $moderationResponse->getBody(), true );
            $moderationStatus = $responseResult['contentAction'] ? $responseResult['contentAction'] : '';
            if( $moderationStatus != 'allow' ) {
                return false;
            }
        } else {
            self::handleErrorResponses( $moderationResponse );
        }
        return true;
    }

    /**
     * Moderate audio for responses/challenges
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_Response $response
     * @param $token
     */

    public static function moderateAudio ( $site, $response, $token )
    {
        $systemConfig = $site->getSystemConfig();
        $awsRegion = $systemConfig->getSetting( 'AWS_REGION');
        $serviceURL = $systemConfig->getSetting( 'AWS_LAMBDA_SERVICE_URL' );
        $apiKey = $systemConfig->getSetting( 'AWS_LAMBDA_API_KEY' );
        $serviceURL = $serviceURL. 'transcriptions/' . $response->getUUID();
        $type = $response->getResponseType();
        $user = $response->getUser();
        $userUUID = $user->getUUID();
        $username = $user->getUsername();

        if ( $response && $type == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {
            $serviceURL = $serviceURL;
            $video = $response->getVideo();
            $filename = $video->getFilename();
            $bucketName = $systemConfig->getSetting( 'AWS_S3_VIDEO_INPUT_BUCKET_NAME' );
            $videoUrl = 'https://s3.amazonaws.com/' . $bucketName . '/' . $filename;
            $pathInfo = pathinfo( $filename );
            $videoFormat = $pathInfo['extension'];
            $body = array(
                'id'    =>  $response->getId(),
                'videoUrl'  => $videoUrl,
                'videoFormat'=> $videoFormat,
                'contentType' => BeMaverick_Site::MODEL_TYPE_RESPONSE,
                'env' => $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' ),
                'userUuid' => $userUUID,
                'username' => $username,
            );
            $client = new Zend_Http_Client( $serviceURL );
            $client->setHeaders( array(
                    'Content-Type' => 'application/json',
                )
            );
            $client->setHeaders( array( 'Authorization' => $token ) );
            $lambdaResponse = null;
            $client->setRawData( json_encode( $body ));
            try {
                error_log( print_r("lambda request for moderate audio".json_encode( $serviceURL  ), true) );
                error_log( print_r("lambda request for moderate audio".json_encode( $body  ), true) );
                $lambdaResponse = $client->request( 'POST' );
                error_log( print_r("lambda response for moderate audio".json_encode( $lambdaResponse->getBody() ), true) );
            }
            catch( Zend_Exception $e ) {
                error_log( "BeMaverick_Moderation::audio::Exception found: " . $e->getMessage() );
            }
        }
    }


    /**
     * Moderate response
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_Response $response
     * @param String $token
     */

    public static function moderateResponse ( $site, $response, $token )
    {
        $elapsed = new DebugElapsed('moderateResponse', 0, true);
        $elapsed->log();

        $systemConfig = $site->getSystemConfig();
        $amazonConfig = $site->getAmazonConfig();
        $environment = $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );
        $imageBucketName = $systemConfig->getSetting( 'AWS_S3_IMAGE_BUCKET_NAME' );
        $videoBucketName = $systemConfig->getSetting( 'AWS_S3_VIDEO_OUTPUT_BUCKET_NAME' );
        $awsRegion = $systemConfig->getSetting( 'AWS_REGION');
        $topicARN = $systemConfig->getSetting( 'AWS_SNS_TOPIC_MODERATION' );

        $user = $response->getUser();
        $userUUID = $user->getUUID();
        $username = $user->getUsername();

        $type = $response->getResponseType();
        $id = $response->getId();
        $responseUUID = $response->getUUID();
        $mainImage = $response->getImage();
        $coverImage = $response->getCoverImage();
        $description = $response->getDescription();
        $transcriptionText = $response->getTranscriptionText();
        $tags = $response->getTagNames();
        $video = $response->getVideo();

        $imageURL = null;
        $videoURL = null;
        $coverImageURL = null;

        if ( $mainImage ) {
            if ($environment == 'devel') {
                $imageURL = 'https://s3.amazonaws.com/' . $imageBucketName . '/' . $mainImage->getFilename();
            } else {
                $imageURL = $mainImage->getUrl();
            }
        }
        $elapsed->log();

        if ( $video ) {
            $videoURL = 'https://s3.' . $awsRegion .  '.amazonaws.com/' . $videoBucketName . '/' . $video->getFilename();
        }

        if ( $coverImage ) {
            if ($environment == 'devel') {
                $coverImageURL = 'https://s3.amazonaws.com/dev-bemaverick-images/' . $coverImage->getFilename();
            } else {
                $coverImageURL = $coverImage->getUrl();
            }
        }
        $elapsed->log();

        $body = array(
            'id'            => $id,
            'contentType'   => 'response',
            'responseUUID'  => $responseUUID,
            'responseType'  => $type,
            'mainImageUrl'  => $imageURL,
            'videoURL'      => $videoURL,
            'coverImageURL'=> $coverImageURL,
            'description'   => $description,
            'transcriptionText' => $transcriptionText,
            'tags'          => $tags,
            'userUUID' => $userUUID,
            'username' => $username,
        );

        try {
            $elapsed->log();
            $response->setModerationStatus( BeMaverick_Moderation::MODERATION_STATUS_STARTED );
            $elapsed->log();
            $response->save();
            $elapsed->log();
            // error_log( print_r("SNS request for moderate response".json_encode( $body, JSON_UNESCAPED_SLASHES   ), true) );
            $client = SnsClient::factory( $amazonConfig );
            $elapsed->log();
            $messageArray =[
                'TopicArn' => $topicARN,
                'Message' => json_encode( $body, JSON_UNESCAPED_SLASHES ),
            ];

            $snsResponse = $client->publish( $messageArray );
            $elapsed->log();
            // error_log( print_r("SNS response for moderate response".json_encode( $snsResponse ), true) );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Moderation::ModerateResponse::Exception found: " . $e->getMessage() );
            $response->setModerationStatus( BeMaverick_Moderation::MODERATION_STATUS_ERROR );
        }
    }

    /**
     * Moderate challenge
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_Response $response
     * @param String $token
     */

    public static function moderateChallenge ( $site, $challenge, $token )
    {
        $systemConfig = $site->getSystemConfig();
        $amazonConfig = $site->getAmazonConfig();
        $environment = $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );
        $imageBucketName = $systemConfig->getSetting( 'AWS_S3_IMAGE_BUCKET_NAME' );
        $videoBucketName = $systemConfig->getSetting( 'AWS_S3_VIDEO_OUTPUT_BUCKET_NAME' );
        $awsRegion = $systemConfig->getSetting( 'AWS_REGION');
        $topicARN = $systemConfig->getSetting( 'AWS_SNS_TOPIC_MODERATION' );


        $user = $challenge->getUser();
        $userUUID = $user->getUUID();
        $username = $user->getUsername();

        $type = $challenge->getChallengeType();
        $id = $challenge->getId();
        $challengeUUID = $challenge->getUUID();
        $image = $challenge->getImage();
        $title = $challenge->getTitle();
        $description = $challenge->getDescription();
        $tags = $challenge->getTagNames();
//        $video = $challenge->getVideo();

        $imageURL = null;
//        $videoURL = null;

        if ( $image ) {
            if ($environment == 'devel') {
                $imageURL = 'https://s3.amazonaws.com/' . $imageBucketName . '/' . $image->getFilename();
            } else {
                $imageURL = $image->getUrl();
            }
        }

//        if ( $video ) {
//            $videoURL = 'https://s3.' . $awsRegion .  '.amazonaws.com/' . $videoBucketName . '/' . $video->getFilename();
//        }

        $body = array(
            'id'            => $id,
            'contentType'   => 'challenge',
            'challengeUUID'  => $challengeUUID,
            'challengeType'  => $type,
            'imageUrl'  => $imageURL,
//            'videoURL'      => $videoURL,
            'title'   => $title,
            'description'   => $description,
            'tags'          => $tags,
            'userUUID' => $userUUID,
            'username' => $username,
        );

        try {
            $challenge->setModerationStatus( BeMaverick_Moderation::MODERATION_STATUS_STARTED );
            $challenge->save();
            // error_log( print_r("SNS request for moderate response".json_encode( $body, JSON_UNESCAPED_SLASHES   ), true) );
            $client = SnsClient::factory( $amazonConfig );
            $messageArray =[
                'TopicArn' => $topicARN,
                'Message' => json_encode( $body, JSON_UNESCAPED_SLASHES ),
            ];

            $snsResponse = $client->publish( $messageArray );
            // error_log( print_r("SNS response for moderate response".json_encode( $snsResponse ), true) );
        }
        catch( Zend_Exception $e ) {
            error_log( "BeMaverick_Moderation::ModerateResponse::Exception found: " . $e->getMessage() );
            $challenge->setModerationStatus( BeMaverick_Moderation::MODERATION_STATUS_ERROR );
        }
    }
}
?>
