<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/Transcoder.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/helpers/DebugElapsed.php' );

class ChallengeController extends BeMaverick_Controller_Base
{


    /**
     * The responses page
     *
     * @return void
     */
    public function responsesAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;
        $validator = $this->view->validator;

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'read', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'challengeId',
        );
        
        $optionalParams = array(
            'count',
            'offset',
        );
        
        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $challengeId = $input->challengeId;
        $count = $input->count ? $input->count : 10;
        $offset= $input->offset ? $input->offset : 0;

        // perform the action
        $challenge = $site->getChallenge( $challengeId );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();  
        $responseData->addChallengeResponses( $challenge, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' ); 
    }

    /**
     * The add response page
     *
     * @return void
     */
    public function addresponseAction()
    {
        $elapsed = new DebugElapsed('addresponseAction', 4, true);
        $elapsed->log();
        $errors = $this->view->errors;
        $site = $this->view->site;                    /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;          /* @var BeMaverick_Validator $validator */
        $systemConfig = $this->view->systemConfig;

        $this->view->format = 'json';
        $elapsed->log();

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );
        $token = $validator->getToken();
        $elapsed->log();

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }
        $elapsed->log();

        // set the input params
        $requiredParams = array(
            'appKey',
            'challengeId',
            'filename',
        );
        $elapsed->log();

        $optionalParams = array(
            'responseType',
            'mimeType',
            'coverImageFileName',
            'coverImageMimeType',
            'width',
            'height',
            'tags',
            'description',
            'skipTwilio',
        );
        $elapsed->log();
        
        $input = $this->processInput( $requiredParams, $optionalParams, $errors );
        $elapsed->log();

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];
        $challengeId = $input->challengeId;
        $responseType = $input->responseType ? $input->responseType : 'video';
        $filename = $input->filename;
        $mimeType = $input->mimeType ?? null;
        $coverImageFileName = $input->coverImageFileName;
        $coverImageMimeType = $input->coverImageMimeType ?? null;
        $width = $input->width ? $input->width : null;
        $height = $input->height ? $input->height : null;
        $tagNames = $input->tags ? explode( ',', $input->getUnescaped( 'tags' ) ) : array();
        $description = $input->description ? $input->getUnescaped( 'description' ) : null;
        $skipComments = $input->skipTwilio;
        $elapsed->log();

        $coverImage = null;
        if ( @$_FILES['coverImage']['tmp_name'] ) {
            $coverImage = BeMaverick_Image::saveOriginalImage( $site, 'coverImage', $errors );
        }
        $elapsed->log();

        if ( $coverImageFileName ) {
            $coverImage = $site->createImageFromAmazonImage( $coverImageFileName, $width, $height );
        }
        $elapsed->log();

        // perform the action
        $challenge = $site->getChallenge( $challengeId );
        $elapsed->log();

        $video = null;
        $image = null;

        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {

            $video = $site->createVideo( $filename, $width, $height );
            $elapsed->log();

        } else if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {
            $image = $site->createImageFromAmazonImage( $filename, $width, $height );
            $elapsed->log("createImageFromAmazonImage .3");
        }

        $response = $challenge->addResponse( $responseType, $user, $video, $image, $tagNames, $description, $skipComments );


        if ( $description ) {
            // set response hashtags by parsing description
            $response->setHashtags( $description );
        }

        $elapsed->log("challenge->addResponse .2");

        if ( $coverImage ) {
            $response->setCoverImage( $coverImage );
            $elapsed->log();
        }

        /** 
         * Suppress async event errors
         * Send custom error alert to New Relic
         */
        try {
            $transcoderEnabled = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_ENABLED' );

            if ( $transcoderEnabled && $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {
                $site->startAmazonTranscoderJob( $video, BeMaverick_Site::MODEL_TYPE_RESPONSE );
                $elapsed->log();
                // start AWS transcription job if response type = video
                $site->moderateAudio( $response, $token );
                $elapsed->log();
            }

            // asynchronously moderate the response immediately if response type = image
            if( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {
                $site->moderateResponse($response, $token);
                $elapsed->log("site->moderateResponse .7");
            }
            // get the response data object
            $responseData = $site->getFactory()->getResponseData();  
            $elapsed->log();
            $responseData->addResponseLimited( $response );
            $elapsed->log("responseData->addResponseLimited .7");
            $this->view->responseData = $responseData;

            // send response data to sns publish
            $response->publishChange( $site, 'CREATE' );

            // publish events
            $response->publishEvent( $site, 'CREATE_RESPONSE', $response->getUserId() );
            $response->publishEvent( $site, 'CREATE_IMAGE_RESPONSE', $response->getUserId() );
            $response->publishEvent( $site, 'CREATE_VIDEO_RESPONSE', $response->getUserId() );
            $response->publishEvent( $site, 'RECEIVE_RESPONSE', $challenge->getUserId() );

        } catch(Exception $error) {
            error_log( 'ERROR::ASYNC:: => ' . json_encode ( $error ) );
            $message = "Error while creating a response";
            if (extension_loaded('newrelic')) {
                newrelic_notice_error($message, $error );
            }
        }
        $output = $this->renderPage( 'responseData' );
        $elapsed->log();

        return $output;
    }

    /**
     * Get a Challenge
     *
     * @return void
     */
    public function detailsAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;
        $validator = $this->view->validator;

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'read', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'challengeId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the challengeId
        $challengeId = $input->challengeId;
        $challenge = $site->getChallenge( $challengeId );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $allowPeekCache = false;
        $responseData->addChallengeBasic( $challenge, $allowPeekCache );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The add challenge page
     *
     * @return void
     */
    public function addAction()
    {
        $elapsed = new DebugElapsed('addAction', 4, true);
        $elapsed->log();
        $errors = $this->view->errors;
        $site = $this->view->site;                    /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;          /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $elapsed->log();
        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );
        $token = $validator->getToken();
        $elapsed->log('getToken');

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'filename',
            'challengeType',
        );

        $optionalParams = array(
            'title',
            'coverImage',
            'description',
            'tags',
            'mentions',
            'width',
            'height',
            'imageText',
            'linkUrl',
        );

        $elapsed->log();
        $input = $this->processInput( $requiredParams, $optionalParams, $errors );
        $elapsed->log('processInput');

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];

        $validator->checkValidUser( $user, $errors );
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $filename = $input->filename;
        $coverImage = $input->coverImage;
        $challengeType = $input->challengeType ? $input->challengeType : 'video';
        $width = $input->width ? $input->width : null;
        $height = $input->height ? $input->height : null;
        $title = $input->title ? $input->getUnescaped( 'title' ) : '';
        $description = $input->description ? $input->getUnescaped( 'description' ) : null;
        $imageText = $input->imageText ? $input->getUnescaped( 'imageText' ) : null;
        $linkUrl = $input->linkUrl ? $input->getUnescaped( 'linkUrl' ) : null;
        $tagNames = $input->tags ? explode( ',', $input->getUnescaped( 'tags' ) ) : array();
        $mentions = $input->mentions ? explode( '@', $input->getUnescaped( 'mentions' ) ) : array();

        $video = null;
        $image = null;

        $elapsed->log();
        if ( $challengeType == BeMaverick_Challenge::CHALLENGE_TYPE_VIDEO && $coverImage) {
            $video = $site->createVideo( $filename, $width, $height );
            $coverImage = $site->createImageFromAmazonImage( $coverImage, $width, $height );
        } else if ( $challengeType == BeMaverick_Challenge::CHALLENGE_TYPE_IMAGE ) {
            $image = $site->createImageFromAmazonImage( $filename, $width, $height );
        }
        $elapsed->log('createImageFromAmazonImage');

        // set challenge properties
        $challenge = $site->createChallenge( $user, $title, $description );
        $elapsed->log('createChallenge');
        $challenge->setChallengeType( $challengeType );
        $challenge->setStatus( 'published' );
        $challenge->setStartTime( date("Y-m-d") );
        $challenge->setEndTime( '2050-01-01' );
        $challenge->setImageText( $imageText );
        $challenge->setlinkUrl( $linkUrl );
        $elapsed->log('setTypeStatusandTimes');

        if ( $description ) {
            // set challenge hashtags by parsing description
            $textString = $title.' '.$description.' '.$imageText;
            error_log('$challenge->setHashtags( $textString ); '.$textString);
            $challenge->setHashtags( $textString );
        }

        if ( $video ) {
            $challenge->setVideo( $video );
        }
        $elapsed->log('setVide');

        if ( $image ) {
            $challenge->setImage( $image );
        }
        $elapsed->log('setImage');

        if ( $coverImage ) {
            $challenge->setMainImage( $coverImage);
        }
        $elapsed->log('setMainImage');

        if ( $tagNames ) {
            $challenge->setTagNames( $tagNames );
        }
        $elapsed->log('setTagNames');

        if ( $mentions ) {
            $mentions = array_filter($mentions);
            $challenge->setMentions( $mentions );
        }
        $elapsed->log('setMentions');

        /** 
         * Suppress async event errors
         * Send custom error alert to New Relic
         */
        try {
            // asynchronously moderate the response immediately if response type = image
            if ( $challengeType == BeMaverick_Challenge::CHALLENGE_TYPE_IMAGE ) {
                $site->moderateChallenge($challenge, $token);
            } elseif ( $challengeType == BeMaverick_Challenge::CHALLENGE_TYPE_VIDEO ) {
                // todo: start AWS transcription job if challenge type = video
            }
            $elapsed->log('moderateChallenge');

            // get the response data object
            $responseData = $site->getFactory()->getResponseData();
            $elapsed->log();
            $responseData->addChallengeLimited( $challenge );
            $elapsed->log('addChallengeLimited');
            $this->view->responseData = $responseData;

            // send response data to sns publish
            $challenge->publishChange( $site, 'CREATE' );

            // publish events
            $challenge->publishEvent( $site, 'CREATE_CHALLENGE', $challenge->getUserId() );

            $elapsed->log();
        } catch(Exception $error) {
            error_log( 'ERROR::ASYNC:: => ' . json_encode ( $error ) );
            $message = "Error while creating a challenge";
            if (extension_loaded('newrelic')) {
                newrelic_notice_error($message, $error );
            }
        }

        return $this->renderPage( 'responseData' );
    }
  
    /**
     * The edit challenge page
     *
     * @return void
     */
    public function editAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;                    /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;          /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );
        $token = $validator->getToken();

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'challengeId',
        );

        $optionalParams = array(
            'filename',
            'title',
            'coverImage',
            'description',
            'tags',
            'mentions',
            'width',
            'height',
            'linkUrl',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];

        $validator->checkValidUser( $user, $errors );
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $challengeId = $input->challengeId;
        $challenge = $site->getChallenge( $challengeId );
        $challengeType = $challenge->getChallengeType();

        $filename = $input->filename;
        $coverImage = $input->coverImage;
        $width = $input->width ? $input->width : null;
        $height = $input->height ? $input->height : null;
        $title = $input->title ? $input->getUnescaped( 'title' ) : null;
        $description = $input->description ? $input->getUnescaped( 'description' ) : null;
        $imageText = $input->imageText ? $input->getUnescaped( 'description' ) : $challenge->getImageText();
        $linkUrl = $input->linkUrl ? $input->getUnescaped( 'linkUrl' ) : null;
        $tagNames = $input->tags ? explode( ',', $input->getUnescaped( 'tags' ) ) : array();
        $mentions = $input->mentions ? explode( '@', $input->getUnescaped( 'mentions' ) ) : array();

        // set the image or video
        if ( $filename ) {
            $video = null;
            $image = null;

            if ($challengeType == BeMaverick_Challenge::CHALLENGE_TYPE_VIDEO && $coverImage) {
                // set new video
                $video = $site->createVideo($filename, $width, $height);
                $challenge->setVideo( $video );
                // set new cover image
                $coverImage = $site->createImageFromAmazonImage($coverImage);
                $challenge->setMainImage( $coverImage);
            } else if ($challengeType == BeMaverick_Challenge::CHALLENGE_TYPE_IMAGE) {
                $image = $site->createImageFromAmazonImage($filename);
                $challenge->setImage( $image );
            }
        }

        // set challenge properties
        if ( $title ) {
            $challenge->setTitle( $title );
        }

        if ( $description ) {
            $challenge->setDescription( $description );

            // set challenge hashtags by parsing description
            $textString = $title.' '.$description.' '.$imageText;
            error_log('$challenge->setHashtags( $textString ); '.$textString);
            $challenge->setHashtags( $textString );
        }

        if ( $linkUrl ) {
            $challenge->setLinkUrl( $linkUrl );
        }

        if ( $tagNames ) {
            $challenge->setTagNames( $tagNames );
        }

        if ( $mentions ) {
            $mentions = array_filter($mentions);
            $challenge->setMentions( $mentions );
        }

        // asynchronously moderate the response immediately if response type = image
        if ( $challengeType == BeMaverick_Challenge::CHALLENGE_TYPE_IMAGE ) {
            $site->moderateChallenge($challenge, $token);
        } elseif ( $challengeType == BeMaverick_Challenge::CHALLENGE_TYPE_VIDEO ) {
            // todo: start AWS transcription job if challenge type = video
        }

        $challenge->save();

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addChallengeBasic( $challenge );
        $this->view->responseData = $responseData;

        // send challenge data to sns publish
        $challenge->publishChange( $site, 'UPDATE' );

        return $this->renderPage( 'responseData' );
    }
  
    /**
     * The delete challenge page
     *
     * @return void
     */
    public function deleteAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;                    /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;          /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'challengeId',
        );

        $input = $this->processInput( $requiredParams, array(), $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];

        $validator->checkValidUser( $user, $errors );
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $challengeId = $input->challengeId;
        $challenge = $site->getChallenge($challengeId);

        // set challenge status
        $challenge->setStatus( 'deleted' );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addChallengeBasic( $challenge );
        $this->view->responseData = $responseData;

        // send challenge data to sns publish
        $challenge->publishChange( $site, 'DELETE' );

        return $this->renderPage( 'responseData' );
    }

    /**
     * The update status of the challenge
     *
     * @return void
     */
    public function updatestatusAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $validator = $this->view->validator;

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'write', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'challengeId',
            'moderationStatus'
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $challengeId = $input->challengeId;
        $moderationStatus = $input->moderationStatus;

        $site->updateChallengeStatus( $challengeId, $moderationStatus );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

}

?>
