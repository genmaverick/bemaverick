<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Email.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Util.php' );

class UserController extends BeMaverick_Controller_Base
{

    /**
     * Gets user me
     *
     * @return void
     */
    public function meAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'read', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $optionalParams = array(
            'basic',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $basic = $input->basic??true;
        if ( !$basic) {
            $basic = false;
        }

        // get the variables and validate token
        $loginUser = $tokenInfo['user'];

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();

        $responseData->addLoginUser( $site, $loginUser, $basic );

        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Gets user details
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

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $optionalParams = array(
            'userId',
            'userIds',
            'username',
            'basic',

        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $basic = $input->basic ?? true;
        if ( ! $basic ) {
            $basic = false;
        }

        $users = array();

        if ( $input->userId ) {
            $users[] = $site->getUser( $input->userId );
        } else if ( $input->username ) {
            $users[] = $site->getUserByUsername( $input->username );
        } else if ( $input->userIds ) {
            $userIds = explode( ',', $input->userIds );

            $users = array();
            foreach ( $userIds as $userId ) {
                $users[] = $site->getUser( $userId );
            }
        } else {
            $errors->setError( '', 'INVALID_INPUT_USER_ID' );
        }

        foreach ( $users as $user ) {
            $validator->checkValidUser( $user, $errors );
        }

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();

        foreach ( $users as $user ) {
            if ( $basic ) {
                $responseData->addUserBasic( $site, $user, false, true );
            } else {
                $responseData->addUserDetails( $site, $user );
            }
        }

        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Gets user response feed
     *
     * @return void
     */
    public function responsefeedAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'read', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $optionalParams = array(
            'count',
            'offset',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $user = $tokenInfo['user'];
        $count = $input->count ? $input->count : 10;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserResponseFeed( $site, $user, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Gets user my feed
     *
     * @return void
     */
    public function myfeedAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'read', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $optionalParams = array(
            'count',
            'offset',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $user = $tokenInfo['user'];
        $count = $input->count ? $input->count : 10;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserMyFeed( $site, $user, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Gets the created responses by user
     *
     * @return void
     */
    public function responsesAction()
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
            'userId',
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
        $userId = $input->userId;
        $badgeId = $input->badgeId ? $input->badgeId : null;
        $count = $input->count ? $input->count : 10;
        $offset= $input->offset ? $input->offset : 0;

        // perform the action
        $user = $site->getUser( $userId );

        $validator->checkValidUser( $user, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserResponses( $user, $badgeId, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }


    /**
     * Gets user badged responses
     *
     * @return void
     */
    public function badgedresponsesAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'read', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'userId',
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

        // get the variables and validate token
        $user = $site->getUser( $input->userId );
        $validator->checkValidUser( $user, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $badgeId = $input->badgeId ? $input->badgeId : null;
        $count = $input->count ? $input->count : 10;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserBadgedResponses( $site, $user, $badgeId, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Get the user's saved challenges
     *
     * @return void
     */
    public function savedchallengesAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'read', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $user = $tokenInfo['user'];

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserSavedChallenges( $site, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Edit user saved challenge
     *
     * @return void
     */
    public function editsavedchallengeAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'challengeId',
            'saveAction',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $user = $tokenInfo['user'];
        $challenge = $site->getChallenge( $input->challengeId );
        $saveAction = $input->saveAction;

        if ( $saveAction == 'add' ) {
            $user->addSavedChallenge( $challenge );
        } else if ( $saveAction == 'remove' ) {
            $user->deleteSavedChallenge( $challenge );
        }

        $user->save();

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserSavedChallenges( $site, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Gets the created content by user
     *
     * @return void
     */
    public function contentsAction()
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
            'userId',
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
        $userId = $input->userId;
        $count = $input->count ? $input->count : 10;
        $offset= $input->offset ? $input->offset : 0;

        // perform the action
        $user = $site->getUser( $userId );

        $validator->checkValidUser( $user, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserContents( $user, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }


    /**
     * Get the user's saved contents
     *
     * @return void
     */
    public function savedcontentsAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'read', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $user = $tokenInfo['user'];

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserSavedContents( $site, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Edit user saved content
     *
     * @return void
     */
    public function editsavedcontentAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'contentId',
            'saveAction',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $user = $tokenInfo['user'];  /* @var BeMaverick_User $user */
        $content = $site->getContent( $input->contentId );
        $saveAction = $input->saveAction;

        if ( $saveAction == 'add' ) {
            $user->addSavedContent( $content );
        } else if ( $saveAction == 'remove' ) {
            $user->deleteSavedContent( $content );
        }

        $user->save();

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserSavedContents( $site, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Gets user badged responses and contents
     *
     * @return void
     */
    public function badgedAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'read', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'userId',
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

        // get the variables and validate token
        $user = $site->getUser( $input->userId );
        $validator->checkValidUser( $user, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $badgeId = $input->badgeId ? $input->badgeId : null;
        $count = $input->count ? $input->count : 10;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserBadged( $site, $user, $badgeId, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }


    /**
     * Gets user followers
     *
     * @return void
     */
    public function followersAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'read', false, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'userId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $user = $site->getUser( $input->userId );

        $validator->checkValidUser( $user, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }


        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserFollowers( $site, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Edit user following
     *
     * @return void
     */
    public function editfollowingAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'followingUserId',
            'followingAction',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $user = $tokenInfo['user'];

        $followingUser = $site->getUser( $input->followingUserId );
        $validator->checkValidUser( $followingUser, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $followingAction = $input->followingAction;

        $validator->checkUserCanFollowThisUser( $user, $followingUser, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        if ( $followingAction == 'follow' ) {
            $user->addFollowingUser( $followingUser );

            /** 
             * Suppress async event errors
             * Send custom error alert to New Relic
             */
            try {
                // publish events
                $followingUser->publishEvent( $site, 'FOLLOW_USER', $user->getId() );

            } catch(Exception $error) {
                error_log( 'ERROR::ASYNC:: => ' . json_encode ( $error ) );
                $message = "Error while adding followers";
                if (extension_loaded('newrelic')) {
                    newrelic_notice_error($message, $error );
                }
            }

        } else if ( $followingAction == 'unfollow' ) {
            $user->deleteFollowingUser( $followingUser );
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserFollowers( $site, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Delete user follower
     *
     * @return void
     */
    public function deletefollowerAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'followerUserId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $user = $tokenInfo['user'];

        $followerUser = $site->getUser( $input->followerUserId );

        $user->deleteFollowerUser( $followerUser );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserFollowers( $site, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The edit password page
     *
     * @return void
     */
    public function editpasswordAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'newPassword',
            'currentPassword',
        );
        
        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $user = $tokenInfo['user'];
        $currentPassword = $input->getUnescaped( 'currentPassword' );
        $newPassword = $input->getUnescaped( 'newPassword' );

        // perform the checks
        $validator->checkValidUserPassword( $user, $currentPassword, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }        

        // perform the action
        $user->setPassword( $newPassword );
        $user->save();

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();  
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' ); 
    }

    /**
     * The edit profile page
     *
     * @return void
     */
    public function editprofileAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $optionalParams = array(
            'firstName',
            'lastName',
            'bio',
            'profileCoverPresetImageId',
            'profileCoverTint',
            'profileImage',
            'preferences',
            'username',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $profileImage = null;
        if ( @$_FILES['profileImage']['tmp_name'] ) {
            $profileImage = BeMaverick_Image::saveOriginalImage( $site, 'profileImage', $errors );
        }

        $profileCoverImage = null;
        if ( @$_FILES['profileCoverImage']['tmp_name'] ) {
            $profileCoverImage = BeMaverick_Image::saveOriginalImage( $site, 'profileCoverImage', $errors );
        }

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $username = $input->username ? $input->getUnescaped( 'username' ) : null;
        $firstName = $input->firstName ? $input->getUnescaped( 'firstName' ) : null;
        $lastName = $input->lastName ? $input->getUnescaped( 'lastName' ) : null;
        $bio = $input->bio ? $input->getUnescaped( 'bio' ) : null;
        $profileCoverPresetImageId = $input->profileCoverPresetImageId ? $input->profileCoverPresetImageId : null;
        $profileCoverTint = $input->profileCoverTint ? $input->profileCoverTint : null;
        $preferences = $input->preferences ? $input->preferences : array();


        // get the variables
        $user = $tokenInfo['user'];

        // perform the action only if the request contained the parameter.  This allows them to send
        // an empty firstName for example and we will set it to null in the database.
        if ( array_key_exists( 'username', $_REQUEST ) && $username != $user->getUsername()) {
            // Validate if the username is available
            $validator->checkUsernameAvailable( $site, $username, $errors );
            if ( $errors->hasErrors() ) {
                return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
            }
            $user->setUsername( $username );
        }

        if ( array_key_exists( 'firstName', $_REQUEST ) ) {
            $user->setFirstName( $firstName );
        }

        if ( array_key_exists( 'lastName', $_REQUEST ) ) {
            $user->setLastName( $lastName );
        }

        if ( array_key_exists( 'bio', $_REQUEST ) ) {
            $user->setBio( $bio );
            $user->setHashtags( $bio );
        } else {
            $user->setHashtags( null );
        }

        if ( array_key_exists( 'profileCoverPresetImageId', $_REQUEST ) ) {
            $user->setProfileCoverPresetImageId( $profileCoverPresetImageId );
            $user->setProfileCoverImageType( BeMaverick_User::PROFILE_COVER_IMAGE_TYPE_PRESET );
        }

        if ( array_key_exists( 'profileCoverTint', $_REQUEST ) ) {
            $user->setProfileCoverTint( $profileCoverTint );
        }

        if ( $profileImage ) {
            $user->setProfileImage( $profileImage );
        } elseif ( isset($input->profileImage) && $input->profileImage==-1) {
            // error_log('UNSET PROFILE IMAGE');
            $user->setProfileImage( false );
        }

        if ( $profileCoverImage ) {
            $user->setProfileCoverImage( $profileCoverImage );
            $user->setProfileCoverImageType( BeMaverick_User::PROFILE_COVER_IMAGE_TYPE_CUSTOM );
        }

        // update user preferences
        $user->updatePreferences($preferences);

        $user->save();

        /** 
         * Suppress async event errors
         * Send custom error alert to New Relic
         */
        try {
            //moderate user. this will add the user to cleanspeak if the user's isn't already created.
            $site->moderateUser( $user );
            //moderate the firstname, lastname, email, bio, profileImage and profileCoverImage
            $site->moderateUserData( $user );

            // Publish change to SNS for microservices
            $user->publishChange( 'UPDATE' );

            // publish events
            $user->publishEvent( $site, 'COMPLETE_PROFILE', $user->getId() );
            
        } catch(Exception $error) {
            error_log( 'ERROR::ASYNC:: => ' . json_encode ( $error ) );
            $message = "Error while editing uer profile";
            if (extension_loaded('newrelic')) {
                newrelic_notice_error($message, $error );
            }
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $responseData->addUserBasic( $site, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Deactivate the user's account
     *
     * @return void
     */
    public function deactivateaccountAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', true, $errors );

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $optionalParams = array(
            'deactivateAction',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        //Ignore the user status is inactive as they can reset their status
        if ( $errors->hasErrors() && !$errors->hasErrors( "userInactive" ) )   {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $deactivateAction = $input->deactivateAction??true;
        $user = $tokenInfo['user'];  /* @var BeMaverick_User $user */

        if ( $deactivateAction ) {
            $user->deactivateAccount();
        }else {
            $user->reactivateAccount();
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Prints to STDOUT the actual image blob for the user's avatar
     *
     * @return void
     */
    public function avatarAction()
    {
        // get the view variables
        $errors = $this->view->errors;
        $validator = $this->view->validator;     /* @var BeMaverick_Validator $validator */
        $site = $this->view->site;       /* @var BeMaverick_Site $site */

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $optionalParams = array(
            'x',
            'y',
        );

        // process the input and validate
        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check for errors
        if ( $errors->hasErrors() ) {
            return $this->_forward( 'notfound', 'error' );
        }

        $user = $site->getUser( $input->userId );
        $validator->checkValidUser( $user, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }


        $profileImage = $user->getProfileImage();

        if ( ! $profileImage ) {
            return $this->renderPage( 'notfound' );
        }

        $width = $input->x ? $input->x : 200;
        $height = $input->y ? $input->y : 200;

        $profileImageUrl = $profileImage->getUrl( $width, $height );

        // get the contents from the real url and just return it
        $imageBlob = file_get_contents( $profileImageUrl );

        if ( $imageBlob ) {

            $now = time();
            $ttl = 600;

            $expires = Sly_Date::formatDate( $now+$ttl, 'D, d M Y H:i:s', 'UTC' ) . ' GMT';
            $lastModified = Sly_Date::formatDate( $now, 'D, d M Y H:i:s', 'UTC' ) . ' GMT';

            // lets add the last modified
            $lastModified = Sly_Date::formatDate( time(), 'D, d M Y H:i:s', 'UTC' ) . ' GMT';

            header( 'Content-Type: ' . $profileImage->getContentType() );
            header( 'Content-Length: ' . strlen( $imageBlob ) );
            header( "Expires: $expires" );
            header( "Cache-Control: max-age=$ttl" );
            header( "Last-Modified: $lastModified" );
            header( "Pragma: " );

            print $imageBlob;
            return;
        }

        return $this->renderPage( 'notfound' );
    }

    /**
     * Get the notifications
     *
     * @return void
     */
    public function notificationsAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'read', true, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $optionalParams = array(
            'count',
            'offset',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables and validate token
        $user = $tokenInfo['user'];
        $count = $input->count ? $input->count : 10;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserNotifications( $user, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }


    /**
     * The report the user
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
            'userId'
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
        $flaggedUser = $site->getUser( $input->userId );
        $reason = $input->reason;

        $validator->checkValidUser( $flaggedUser, $errors );
        $validator->checkUserCanReportUser( $user, $flaggedUser, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $site->flagUser( $user, $flaggedUser, $reason );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $responseData->addUserBasic( $site, $flaggedUser );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Find My Friends
     *
     * @return void
     */
    public function findmyfriendsAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'read', false, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $optionalParams = array(
            'count',
            'offset',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );
        $body = $this->getRequest()->getRawBody();
        $validator->checkValidJson( $body, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $requestJson = json_decode( $body, true );

        $emailAddresses = isset( $requestJson['emailAddresses'] ) ? explode( ',', $requestJson['emailAddresses'] ) : null;
        $phoneNumbers = isset( $requestJson['phoneNumbers'] ) ? explode( ',', $requestJson['phoneNumbers'] ) : null;
        $loginProvider = isset( $requestJson['loginProvider'] ) ? $requestJson['loginProvider'] : null;
        $loginProviderUserIds = isset( $requestJson['loginProviderUserIds'] ) ? explode( ',', $requestJson['loginProviderUserIds'] ) : null;

        $count = $input->count ? $input->count : null;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addFindMyFriends( $site, $emailAddresses, $phoneNumbers, $loginProvider, $loginProviderUserIds, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Email My Friends
     *
     * @return void
     */
    public function invitemyfriendsAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'read', false, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        //check the input params
        $input = $this->processInput( $requiredParams, null, $errors );
        $body = $this->getRequest()->getRawBody();
        $validator->checkValidJson( $body, $errors );
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        //check the valid app key
        $systemConfig = $site->getSystemConfig();
        $environment = $systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );

        if ( $environment == 'production' ) {

            $app = $site->getApp( $input->appKey );
            if( !$app || $app->getId() != 'bemaverick_ios') {
                $errors->setError( 'INVALID_APPKEY', 'This request can be made only through iOS.' );
                return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
            }
        }

        $user = $tokenInfo['user']; /* @var BeMaverick_User $user */
        $validator->checkValidUser( $user, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $username = $user->getUsername();
        $name = $user->getFirstName();

        if ( !$name ) {
            $name = $username;
        }

        // get the variables
        $requestJson = json_decode( $body, true );
        $emailAddresses = $requestJson['emailAddresses'];
        $deepLinkURL = $requestJson['deepLinkURL'];
        $subject = $requestJson['subject'];
        $body = $requestJson['body'];

        if ( !$emailAddresses ) {
            $errors->setError( 'INPUT_INVALID_EMAILADDRESSES', 'EmailAddresses is resquired.' );
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        if( !$deepLinkURL ) {
            $deepLinkURL = $systemConfig->getSetting( 'APP_DEEPLINK' );
        }

        // send the email to verify account for normal user
        $vars = array(
            'NAME'     => $name,
            'USERNAME' => $username,
            'APP_URL'  => $deepLinkURL,
        );

        if ( $subject ) {
            $vars['SUBJECT'] = $subject;
        }

        if( $body ) {
            $vars['BODY'] = $body;
        }

        $toEmailAddreses = explode(',', $emailAddresses);
        BeMaverick_Email::sendTemplate( $site, 'maverick-invite-email', $toEmailAddreses , $vars );


        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        // set the results
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Autocomplete user query
     *
     * @return void
     */
    public function autocompleteAction() {
        
        $site = $this->view->site;

        // Uses the $_GET and SQL query for speed optimization
        $query = $_GET['query'];
        if (strlen($query) < 2) {
            header('Content-Type: application/json');
            http_response_code(400);
            echo json_encode(array(
                "error" => "`query` must be at least 2 characters"
            ));
            exit();
        }
        

        $result = BeMaverick_User::getAutocomplete($site, $query);
        
        header('Content-Type: application/json');
        http_response_code(200);
        echo json_encode($result);
        exit();
    }
}

?>
