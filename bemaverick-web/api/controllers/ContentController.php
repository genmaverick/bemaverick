<?php
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/Transcoder.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class ContentController extends BeMaverick_Controller_Base
{

    /**
     * Add a content
     *
     * @return void
     */
    public function addAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;                    /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;
        $systemConfig = $this->view->systemConfig;

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

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
            'contentType',
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

        $validator->checkUserCanCreateContent( $user, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $contentType = $input->contentType ? $input->contentType : 'video';
        $filename = $input->filename;
        $width = $input->width ? $input->width : null;
        $height = $input->height ? $input->height : null;
        $tagNames = $input->tags ? explode( ',', $input->getUnescaped( 'tags' ) ) : array();
        $title = $input->title ? $input->getUnescaped( 'title' ) : null;
        $description = $input->description ? $input->getUnescaped( 'description' ) : null;
        $skipComments = $input->skipComments;

        $coverImage = null;
        if ( @$_FILES['coverImage']['tmp_name'] ) {
            $coverImage = BeMaverick_Image::saveOriginalImage( $site, 'coverImage', $errors );
        }


        $video = null;
        $image = null;

        if ( $contentType == BeMaverick_Content::CONTENT_TYPE_VIDEO ) {

            $video = $site->createVideo( $filename, $width, $height );

        } else if ( $contentType == BeMaverick_Content::CONTENT_TYPE_IMAGE ) {

            $image = $site->createImageFromAmazonImage( $filename );
        }

        $content = $site->createContent( $contentType, $user, $video, $image, $title, $description, $skipComments );

        if ( $coverImage ) {
            $content->setCoverImage( $coverImage );
        }

        if ( $tagNames ) {
            $content->setTagNames( $tagNames );
        }

        $transcoderEnabled = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_ENABLED' );
        if ( $transcoderEnabled && $contentType == BeMaverick_Content::CONTENT_TYPE_VIDEO ) {
            $site->startAmazonTranscoderJob( $video, BeMaverick_Site::MODEL_TYPE_CONTENT, false );
        }

//        $amazonConfig = $site->getAmazonConfig();
//        $pipelineId = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_PIPELINE_ID' );
//        $presetId = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_RESPONSE_PRESET_ID' );
//        $transcoderEnabled = $systemConfig->getSetting( 'AWS_VIDEO_TRANSCODER_ENABLED' );
//
//        if ( $transcoderEnabled && $contentType == BeMaverick_Content::CONTENT_TYPE_VIDEO) {
//            BeMaverick_AWSTranscoder::startJob( $filename, $pipelineId, $presetId, $amazonConfig );
//        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addContentBasic( $content );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }


    /**
     * Get a list of users and badges for a content
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
            'contentId',
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
        $contentId = $input->contentId;
        $badgeId = $input->badgeId ? $input->badgeId : null;
        $count = $input->count ? $input->count : 25;
        $offset = $input->offset ? $input->offset : 0;

        // perform the action
        $content = $site->getContent( $contentId );
        $badge = $site->getBadge( $badgeId );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addContentBadgeUsers( $content, $badge, $count, $offset );
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
            'contentId',
            'badgeId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];

        $contentId = $input->contentId;
        $badgeId = $input->badgeId;

        // perform the action
        $content = $site->getContent( $contentId );
        $badge = $site->getBadge( $badgeId );

        $validator->checkValidContent( $content, $errors );
        $validator->checkValidBadge( $badge, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $content->addBadge( $badge, $user );

        //Follow user of the response creator
        $followingUser = $content->getUser();
        $validator->checkUserCanFollowThisUser( $user, $followingUser, $errors );

        if ( !$errors->hasErrors() ) {
            $user->addFollowingUser( $followingUser );
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addContentBasic( $content );
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
            'contentId',
            'badgeId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];

        $contentId = $input->contentId;
        $badgeId = $input->badgeId;

        // perform the action
        $content = $site->getContent( $contentId );
        $badge = $site->getBadge( $badgeId );

        $validator->checkValidContent( $content, $errors );
        $validator->checkValidBadge( $badge, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $content->deleteBadge( $badge, $user );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addContentBasic( $content );
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
            'contentId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];
        $content = $site->getContent( $input->contentId );

        $validator->checkValidContent( $content, $errors );
        $validator->checkUserCanDeleteContent( $user, $content, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // perform the action
        $content->delete();

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The content details page
     *
     * @return void
     */
    public function detailsAction()
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
            'contentId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the responseId
        $contentId = $input->contentId;
        $content = $site->getContent( $contentId );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addContentBasic( $content );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

}

?>
