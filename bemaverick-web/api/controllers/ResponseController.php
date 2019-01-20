<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/Transcoder.php' );

class ResponseController extends BeMaverick_Controller_Base
{


    /**
     * Add a response
     *
     * @return void
     */
    public function addAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;                    /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;          /* @var BeMaverick_Validator $validator */
        $systemConfig = $this->view->systemConfig;

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
            'filename',
        );

        $optionalParams = array(
            'challengeId',
            'responseType',
            'coverImageFileName',
            'width',
            'height',
            'tags',
            'title',
            'description',
            'skipComments',
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
        $responseType = $input->responseType ? $input->responseType : 'video';
        $filename = $input->filename;
        $width = $input->width ? $input->width : null;
        $height = $input->height ? $input->height : null;
        $coverImageFileName = $input->coverImageFileName;
        $tagNames = $input->tags ? explode( ',', $input->getUnescaped( 'tags' ) ) : array();
        $title = $input->title ? $input->getUnescaped( 'title' ) : null;
        $description = $input->description ? $input->getUnescaped( 'description' ) : null;
        $skipComments = $input->skipComments;

        $coverImage = null;
        if ( @$_FILES['coverImage']['tmp_name'] ) {
            $coverImage = BeMaverick_Image::saveOriginalImage( $site, 'coverImage', $errors );
        }

        if ( $coverImageFileName ) {

            $coverImage = $site->createImageFromAmazonImage( $coverImageFileName, $width, $height );
        }

        $video = null;
        $image = null;

        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {

            $video = $site->createVideo( $filename, $width, $height );

        } else if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {

            $image = $site->createImageFromAmazonImage( $filename, $width, $height );
        }

        $response = $site->createResponse( $responseType, $user, $challengeId, $video, $image, $skipComments );

        if( $title ) {
            $response->setTitle( $title );
        }

        if( $description ) {
            $response->setDescription( $description );

            // set response hashtags by parsing description
            $response->setHashtags( $description );
        } else {
            $response->setHashtags( null );
        }

        if ( $coverImage ) {
            $response->setCoverImage( $coverImage );
        }

        if ( $tagNames ) {
            $response->setTags( $tagNames );
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addResponseLimited( $response );
        $this->view->responseData = $responseData;

        /** 
         * Suppress async event errors
         * Send custom error alert to New Relic
         */
        try {
            $transcoderEnabled = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_ENABLED' );
            if ( $transcoderEnabled && $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {
                $site->startAmazonTranscoderJob( $video, BeMaverick_Site::MODEL_TYPE_RESPONSE );
                // start AWS transcription job if response type = video
                $site->moderateAudio( $response, $token );
            }            

            // asynchronously moderate the response immediately if response type = image
            if( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {
                $site->moderateResponse($response, $token);
            }

            // send response data to sns publish
            $response->publishChange( $site, 'CREATE' );
        
            // publish events
            $response->publishEvent( $site, 'CREATE_RESPONSE', $response->getUserId() );
            $response->publishEvent( $site, 'CREATE_VIDEO_RESPONSE', $response->getUserId() );

        } catch(Exception $error) {
            error_log( 'ERROR::ASYNC:: => ' . json_encode ( $error ) );
            $message = "Error while creating a response";
            if (extension_loaded('newrelic')) {
                newrelic_notice_error($message, $error );
            }
        }

        return $this->renderPage( 'responseData' );
    }


    /**
     * The badge users page
     *
     * @return void
     */
    public function badgeusersAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'read', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'responseId',
        );

        $optionalParams = array(
            'badgeId',
            'count',
            'offset',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $responseId = $input->responseId;
        $badgeId = $input->badgeId ? $input->badgeId : null;
        $count = $input->count ? $input->count : 25;
        $offset = $input->offset ? $input->offset : 0;

        // perform the action
        $response = $site->getResponse( $responseId );
        $badge = $site->getBadge( $badgeId );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addResponseBadgeUsers( $response, $badge, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The add badge page
     *
     * @return void
     */
    public function addbadgeAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'responseId',
            'badgeId',
        );
        
        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // Load input variables
        $responseId = $input->responseId;
        $badgeId = $input->badgeId;

        // Get the user
        $user = $tokenInfo['user'];
        
        // Get the response
        $response = $site->getResponse( $responseId );

        // Add the badge
        $badge = $site->getBadge( $badgeId );
        $response->addBadge( $badge, $user );

        /** 
         * Suppress async event errors
         * Send custom error alert to New Relic
         */
        try {
            // publish events
            $response->publishEvent( $site, 'BADGE_RESPONSE', $user->getId() );

        } catch(Exception $error) {
            error_log( 'ERROR::ASYNC:: => ' . json_encode ( $error ) );
            $message = "Error while adding a badge";
            if (extension_loaded('newrelic')) {
                newrelic_notice_error($message, $error );
            }
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();  
        $responseData->addResponseDetails( $response );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' ); 
    }

    /**
     * The delete badge page
     *
     * @return void
     */
    public function deletebadgeAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'responseId',
            'badgeId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];

        $responseId = $input->responseId;
        $badgeId = $input->badgeId;

        // perform the action
        $response = $site->getResponse( $responseId );
        $badge = $site->getBadge( $badgeId );

        $response->deleteBadge( $badge, $user );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addResponseDetails( $response );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The delete page
     *
     * @return void
     */
    public function deleteAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'responseId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];
        $response = $site->getResponse( $input->responseId );

        $validator->checkValidResponse( $response, $errors );
        $validator->checkUserCanDeleteResponse( $user, $response, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // perform the action
        $response->delete();

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        // send response data to sns publish
        $response->publishChange( $site, 'DELETE' );

        return $this->renderPage( 'responseData' );
    }

    /**
     * The share page
     *
     * @return void
     */
    public function shareAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'responseId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];
        $response = $site->getResponse( $input->responseId );

        $validator->checkValidResponse( $response, $errors );
        $validator->checkUserCanShareResponse( $user, $response, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // perform the action
        $response->setPublic( true );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $responseData->addResponseBasic( $response );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The report the response
     *
     * @return void
     */
    public function flagAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'responseId'
        );

        $optionalParams = array(
            'reason'
        );


        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];
        $response = $site->getResponse( $input->responseId );
        $reason = $input->reason;

        $validator->checkValidResponse( $response, $errors );
        $validator->checkUserCanReportResponse( $user, $response, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $site->flagResponse( $response, $user, $reason );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $responseData->addResponseBasic( $response );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }
    /**
     * The responses page
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
            'responseId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the responseId
        $responseId = $input->responseId;
        $response = $site->getResponse( $responseId );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $allowPeekCache = false;
        $responseData->addResponseBasic( $response, $allowPeekCache );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Favorite a response
     *
     * @return void
     */
    public function favoriteAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'responseId',
            'favoriteAction'
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];
        $response = $site->getResponse( $input->responseId );
        $action = $input->favoriteAction;
        $challenge = $response->getChallenge();

        $validator->checkValidResponse( $response, $errors );
        $validator->checkUserCanFavoriteResponse( $user, $challenge, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }
        if ( $action == 'favorite' ) {
            $response->setFavorited(true);
            $response->setUpdatedTimestamp( date( 'Y-m-d H:i:s' ) );
        } else if ( $action == 'unfavorite' ) {
            $response->setFavorited(false);
            $response->setUpdatedTimestamp( date( 'Y-m-d H:i:s' ) );
        }
        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $responseData->addResponseBasic( $response );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The update status of the response
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
            'responseId',
            'moderationStatus'
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $responseId = $input->responseId;
        $moderationStatus = $input->moderationStatus;

        $site->updateResponseStatus( $responseId, $moderationStatus );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Update transcription text of the response
     *
     * @return void
     */
    public function updatetranscriptionAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $validator = $this->view->validator;

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'write', false, $errors );
        $token = $validator->getToken();

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'responseId',
            'transcriptionText'
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the vars from input
        $responseId = $input->responseId;
        $transcriptionText = $input->transcriptionText;
        $response = $site->getResponse($responseId);

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();

        // update response transcription and start moderation only if response exists
        if ( $response ) {
            $response->setTranscriptionText( $transcriptionText );

            $site->moderateResponse( $response, $token );
            
            $responseData->addStatus( 'success' );
        } else {
            $responseData->addStatus( 'failure' );
        }

        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

}

?>
