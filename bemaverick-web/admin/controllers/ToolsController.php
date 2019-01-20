<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/S3.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/Transcoder.php' );

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class ToolsController extends BeMaverick_Controller_Base
{

    /**
     * The index page
     *
     * @return void
     */
    public function indexAction()
    {
        return $this->renderPage( 'tools' );
    }

    /**
     * The featured responses edit page
     *
     * @return void
     */
    public function featuredresponseseditAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'featuredResponsesEdit' );
    }

    /**
     * The featured responses edit confirm page
     *
     * @return void
     */
    public function featuredresponseseditconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */

        $requiredParams = array(
            'featuredType',
        );
        $optionalParams = array(
            'streamId',
            'label',
            'contentStatus',
            'sortLogic',
            'displayLimit',
            'rotateFrequency',
            'rotateCount',
            'lastRotated',
            'rotateOnSave',
            'paginated',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $featuredType = $input->featuredType;
        $streamId = $input->streamId ?? null;
        $modelType = BeMaverick_Site::MODEL_TYPE_RESPONSE;
        $rotateOnSave = $input->rotateOnSave ?? false;

        // Update Stream
        if ( $stream = $site->getStream( $streamId ) ) {
            $stream->updateStreamFromInput( $input, $modelType );
        }

        // Apply manual sort changes
        if ( ! $rotateOnSave ) {
            $responseIds = @$_REQUEST['responseIds'] ? $_REQUEST['responseIds'] : array();

            $site->updateFeaturedModels( $featuredType, $modelType, $responseIds );
        }

        // redirect to edit feature stream page
        $params = array(
            'featuredType' => $featuredType,
            'confirmPage' => 'featuredResponsesEditConfirm',
        );

        if ( $streamId ) {
            $params['streamId'] = $streamId;
        }

        return $this->_redirect( $site->getUrl( 'featuredResponsesEdit', $params ) );
    }

    /**
     * The featured challenges edit page
     *
     * @return void
     */
    public function featuredchallengeseditAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        $optionalParams = array(
            'featuredType',
            'streamId',
        );

        $this->processInput( null, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'featuredChallengesEdit' );
    }

    /**
     * The featured challenges edit confirm page
     *
     * @return void
     */
    public function featuredchallengeseditconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */

        $requiredParams = array(
            'featuredType',
        );

        $optionalParams = array(
            'streamId',
            'label',
            'contentStatus',
            'sortLogic',
            'displayLimit',
            'rotateFrequency',
            'rotateCount',
            'lastRotated',
            'rotateOnSave',
            'paginated',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $featuredType = $input->featuredType;
        $modelType = BeMaverick_Site::MODEL_TYPE_CHALLENGE;
        $streamId = $input->streamId ?? null;
        $stream = isset( $streamId ) ? $site->getStream( $streamId ) : null;
        $rotateOnSave = $input->rotateOnSave ?? false;

        // Update Stream
        if ( $stream ) {
            $stream->updateStreamFromInput( $input, $modelType );
        }

        // Manual reorder stream
        if ( ! $rotateOnSave ) {

            $challengeIds = @$_REQUEST['challengeIds'] ? $_REQUEST['challengeIds'] : array();

            $site->updateFeaturedModels( $featuredType, $modelType, $challengeIds );
        }

        // redirect to page
        $params = array(
            'featuredType' => $featuredType,
            'confirmPage' => 'featuredChallengesEditConfirm',
        );

        if ( $streamId ) {
            $params['streamId'] = $streamId;
        }

        return $this->_redirect( $site->getUrl( 'featuredChallengesEdit', $params ) );
    }

    /**
     * The featured users edit page
     *
     * @return void
     */
    public function featureduserseditAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'featuredUsersEdit' );
    }

    /**
     * The featured users edit confirm page
     *
     * @return void
     */
    public function featureduserseditconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */

        $requiredParams = array(
            'featuredType',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $featuredType = $input->featuredType;
        $modelType = BeMaverick_Site::MODEL_TYPE_USER;
        $userIds = @$_REQUEST['userIds'] ? $_REQUEST['userIds'] : array();

        $site->updateFeaturedModels( $featuredType, $modelType, $userIds );

        // redirect to page
        $params = array(
            'featuredType' => $featuredType,
            'confirmPage' => 'featuredUsersEditConfirm',
        );

        return $this->_redirect( $site->getUrl( 'featuredUsersEdit', $params ) );
    }

    /**
     * The profile cover preset images edit page
     *
     * @return void
     */
    public function profilecoverpresetimageseditAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'profileCoverPresetImagesEdit' );
    }

    /**
     * The profile cover preset images edit confirm page
     *
     * @return void
     */
    public function profilecoverpresetimageseditconfirmAction()
    {
        // get the view vars
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */
        $systemConfig = $this->view->systemConfig;
        $errors = $this->view->errors;

        // go through all input
        $maxProfileCoverPresetImages = $systemConfig->getSetting( 'SYSTEM_ADMIN_MAX_PROFILE_COVER_PRESET_IMAGES' );

        for ( $i = 1; $i <= $maxProfileCoverPresetImages; $i++ ) {

            if ( @$_FILES["image-$i"]['tmp_name'] ) {

                $profileCoverImage = BeMaverick_Image::saveOriginalImage( $site, "image-$i", $errors );

                if ( $errors->hasErrors() ) {
                    return $this->renderPage( 'errors' );
                }

                $site->setProfileCoverPresetImage( $i, $profileCoverImage );
            }
        }

        // redirect to page
        $params = array(
            'confirmPage' => 'profileCoverPresetImagesEditConfirm',
        );

        return $this->_redirect( $site->getUrl( 'profileCoverPresetImagesEdit', $params ) );
    }

    /**
     * The favorite responses edit page
     *
     * @return void
     */
    public function favoriteresponseseditAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        // set the input params
        $optionalParams = array(
            'responseType',
            'challengeId',
            'mentorId',
            'username',
            'count',
            'offset',
            'sort',
            'sortOrder',
        );

        $this->processInput( null, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'favoriteResponsesEdit' );
    }

    /**
     * The favorite responses edit confirm page
     *
     * @return void
     */
    public function favoriteresponseseditconfirmAction()
    {
        // get the view vars
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */

        $responseIds = @$_REQUEST['responseIds'] ? $_REQUEST['responseIds'] : array();

        foreach ( $responseIds as $responseId ) {

            $response = $site->getResponse( $responseId );

            if ( @$_REQUEST["responseFavorite-$responseId"] == 1 ) {
                $response->setFavorited( true );
            } else {
                $response->setFavorited( false );
            }
        }

        // redirect to page
        $params = array(
            'confirmPage' => 'favoriteResponsesEditConfirm',
        );

        return $this->_redirect( $site->getUrl( 'favoriteResponsesEdit', $params ) );
    }

    /**
     * The posts badges edit page
     *
     * @return void
     */
    public function postsbadgeseditAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        // set the input params
        $optionalParams = array(
            'responseStatus',
            'responseType',
            'postType',
            'challengeId',
            'mentorId',
            'username',
            'count',
            'offset',
            'sort',
            'sortOrder',
            'badgeAsUserId'
        );

        $this->processInput( null, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'postsBadgesEdit' );
    }

    /**
     * The posts badges edit confirm page
     *
     * @return void
     */
    public function postbadgeeditconfirmAction()
    {
        // get the view vars
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */
        $errors = $this->view->errors;

        $requiredParams = array(
            'responseId',
            'userId',
        );

        $optionalParams = array(
            'badgeId',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $response = $site->getResponse( $input->responseId );
        $badge = $site->getBadge( $input->badgeId );
        $user = $site->getUser( $input->userId );

        // delete all current badges for this user
        $givenBadgeIds = $user->getGivenResponseBadgeIds( $response );
        foreach ( $givenBadgeIds as $givenBadgeId ) {
            $givenBadge = $site->getBadge( $givenBadgeId );
            $response->deleteBadge( $givenBadge, $user );
        }

        // add the badge
        if ( $badge ) {
            $response->addBadge( $badge, $user );
            BeMaverick_Util::sendNotificationForBadgeGiven( $site, $response, $badge, $user, $response->getUser() );
        }

        // send success to as the response
        $res = $this->getResponse();
        $res->setHeader( 'Content-Type', 'application/json' );
        $res->setHeader( 'Cache-Control', 'private, no-store, no-cache' );
        $res->setHeader( 'Pragma', 'no-cache' );
        $res->setHeader( 'Expires', 'Sat, 01 Jan 2000 00:00:00 GMT' );

        $res->setBody(
            json_encode(
                array(
                    'success' => true
                )
            )
        );
    }

}

?>
