<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class UsersController extends BeMaverick_Controller_Base
{

    /**
     * The user page
     *
     * @return void
     */
    public function userAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;         /* @var BeMaverick_Site $site */
        $loginUser = $this->view->loginUser;

        if ( ! $loginUser ) {
            $redirectUrl = $site->getUrl( 'home' );
            return $this->_redirect( $redirectUrl );
        }

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $optionalParams = array(
            'userProfileDetailsTab',
            'offset',
            'count',
            'startCount'
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );
        $userStatus = $user->getStatus();

        // show not found if user is revoked, deleted or doesn't exist
        if ( ! $user || $userStatus == 'revoked' || $userStatus == 'deleted' ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        // if user is inactive, only allow profile owner to view
        if ( $userStatus == 'inactive' && $loginUser != $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $successPage = 'user';
        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        // set the view vars
        $this->view->user = $user;

        return $this->renderPage( $successPage );
    }

    public function badgedAction()
    {
        $params = array(
            'userProfileDetailsTab' => 'badged'
        );
        return $this->_forward( 'user', 'users', null, $params );
    }

    public function coverAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;         /* @var BeMaverick_Site $site */

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $successPage = 'user';
        if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = 'userCover';
        } else if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        } else if ( !$this->view->ajax ) {
            $this->view->popupUrl = $user->getUrl( 'userFollowing' );
        }

        // set the view vars
        $this->view->user = $user;

        return $this->renderPage( $successPage );
    }

    public function coverConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;         /* @var BeMaverick_Site $site */

        // set the input params
        $requiredParams = array(
            'userId'
        );

        $optionalParams = array(
            'profileCoverPresetImageId'
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $profileCoverPresetImageId = $input->profileCoverPresetImageId ? $input->getUnescaped( 'profileCoverPresetImageId' ) : null;

        if ( array_key_exists( 'profileCoverPresetImageId', $_REQUEST ) ) {
            $user->setProfileCoverImageType( BeMaverick_User::PROFILE_COVER_IMAGE_TYPE_PRESET );
            $user->setProfileCoverPresetImageId( $profileCoverPresetImageId );
        }

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $user->save();

        // set the view vars
        $this->view->user = $user;

        return $this->renderPage( 'user' );
    }

    public function savedAction()
    {
        $params = array(
            'userProfileDetailsTab' => 'saved'
        );
        return $this->_forward( 'user', 'users', null, $params );
    }

    public function responsesAction()
    {
        $params = array(
            'userProfileDetailsTab' => 'responses'
        );
        return $this->_forward( 'user', 'users', null, $params );
    }

    public function activityAction()
    {
        $params = array(
            'userProfileDetailsTab' => 'activity'
        );
        return $this->_forward( 'user', 'users', null, $params );
    }

    public function challengesAction()
    {
        $params = array(
            'userProfileDetailsTab' => 'challenges'
        );
        return $this->_forward( 'user', 'users', null, $params );
    }

    public function followersAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;         /* @var BeMaverick_Site $site */

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $successPage = 'user';
        if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = 'userFollowers';
        } else if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        } else if ( !$this->view->ajax ) {
            $this->view->popupUrl = $user->getUrl( 'userFollowers' );
        }

        // set the view vars
        $this->view->user = $user;

        return $this->renderPage( $successPage );
    }

    public function followingAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;         /* @var BeMaverick_Site $site */

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $successPage = 'user';
        if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = 'userFollowing';
        } else if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        } else if ( !$this->view->ajax ) {
            $this->view->popupUrl = $user->getUrl( 'userFollowing' );
        }

        // set the view vars
        $this->view->user = $user;

        return $this->renderPage( $successPage );
    }

    public function editFollowingConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;         /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;
        $followingUser = $this->view->loginUser;

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'userId',
            'followingAction' // follow, unfollow
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the vars
        $userId = intval($input->userId);
        $user = $site->getUser( $userId );
        $followingAction = $input->followingAction;

        $successPage = 'user';
        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        $validator->checkUserCanFollowThisUser( $user, $followingUser, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        if ( $followingAction == 'follow' ) {
            $user->addFollowingUser( $followingUser);
        } elseif ( $followingAction == 'unfollow' ) {
            $user->deleteFollowingUser( $followingUser);
        }

        // set the view vars
        $this->view->user = $user;


        return $this->renderPage( $successPage );
    }

     /**
     * A generic user page
     *
     * @return void
     */
    public function genericpageAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;         /* @var BeMaverick_Site $site */

        // set the input params
        $requiredParams = array(
            'userId',
            'successPage'
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $successPage = $input->successPage;
        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        // set the view vars
        $this->view->user = $user;

        return $this->renderPage( $successPage );
    }

    /**
     * Parent revoke kid's account
     *
     * @return void
     */
    public function revokeAccessAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;
        $loginUser = $this->view->loginUser;

        // check if user is logged in
        if ( $loginUser ) {

            $requiredParams = array('userId');
            $input = $this->processInput($requiredParams, null, $errors);
            $kid = $site->getUser($input->userId);

            // check to see if kid belongs to logged in user
            if (in_array($kid, $loginUser->getKids())) {

                $kid->deactivateAccount();
                $kid->setStatus( BeMaverick_User::USER_STATUS_REVOKED );
                $kid->setRevokedReason('parental');

                $successPage = 'user';
                if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
                    $successPage = $this->view->ajax.'Ajax';
                }

                // set the view vars
                $this->view->user = $kid;

                return $this->renderPage( $successPage );
            }
        }
        return $this->_forward( 'errors', null, null, null );
    }

    /**
     * Parent reinstate kid's account
     *
     * @return void
     */
    public function reinstateAccessAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;
        $loginUser = $this->view->loginUser;

        // check if user is logged in
        if ( $loginUser ) {

            $requiredParams = array('userId');
            $input = $this->processInput($requiredParams, null, $errors);
            $kid = $site->getUser($input->userId);

            // check to see if kid belongs to logged in user
            if (in_array($kid, $loginUser->getKids())) {

                $kid->reactivateAccount();
                $kid->setRevokedReason(null);

                $successPage = 'user';
                if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
                    $successPage = $this->view->ajax.'Ajax';
                }

                // set the view vars
                $this->view->user = $kid;

                return $this->renderPage( $successPage );
            }
        }
        return $this->_forward( 'errors', null, null, null );
    }

    /**
     * The user settings page
     *
     * @return void
     */
    public function settingsAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $input = $this->processInput( $requiredParams, array(), $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $validator->checkLoginUserCanChangeUserSettings( $loginUser, $user, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $successPage = 'userPasswordEdit';

        return $this->renderPage( $successPage );
    }

    /**
     * The user deactivate edit page
     *
     * @return void
     */
    public function deactivateEditAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $input = $this->processInput( $requiredParams, array(), $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $validator->checkLoginUserCanChangeUserSettings( $loginUser, $user, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $successPage = 'userDeactivateEdit';

        return $this->renderPage( $successPage );
    }

    /**
     * Edit deactivate account confirm
     *
     * @return void
     */
    public function deactivateEditConfirmAction()
    {
        $errors = $this->view->errors;
        $systemConfig = $this->view->systemConfig;  /* @var BeMaverick_Config_System $systemConfig */
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $optionalParams = array(
            'account'
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        // security checks
        $validator->checkCSRFValidation( $systemConfig, $this->_request, $errors );
        $validator->checkCSRFAccessToken( $site, @$_REQUEST['accessToken'], $errors );
        $validator->checkRequestMethodPost( $this->_request, $errors );

        // can this login user edit this user
        $validator->checkLoginUserCanChangeUserSettings( $loginUser, $user, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // set the status
        $account = is_array( $input->account ) ? $input->account : array( $input->account );
        $accountStatus = in_array( 'status', $account ) ? 'active' : 'inactive';

        if ( $accountStatus == 'active' ) {
            $user->reactivateAccount();
        } else {
            $user->deactivateAccount();
        }

        $params = array( 'confirmMessage' => 'deactivateEditConfirm' );

        if ( $this->view->ajax ) {
            $this->view->browserHistoryUrl = $user->getUrl( 'userDeactivateEdit' );
            $this->view->historyReplace = true;
            $this->processInput( null, array( 'confirmMessage' ), $errors, null, $params );
            return $this->renderPage( 'userDeactivateEdit' );
        }

        $redirectUrl = $user->getUrl( 'userDeactivateEdit', $params );

        return $this->_redirect( $redirectUrl );
    }

    /**
     * The user notification settings page
     *
     * @return void
     */
    public function notificationsEditAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $input = $this->processInput( $requiredParams, array(), $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $validator->checkLoginUserCanChangeUserSettings( $loginUser, $user, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // notifications edit is the default page
        $successPage = 'userNotificationsEdit';

        return $this->renderPage( $successPage );
    }

    /**
     * The notifications edit confirm page
     *
     * @return void
     */
    public function notificationsEditConfirmAction()
    {
        $errors = $this->view->errors;
        $systemConfig = $this->view->systemConfig;  /* @var BeMaverick_Config_System $systemConfig */
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $optionalParams = array(
            'notifications'
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        // security checks
        $validator->checkCSRFValidation( $systemConfig, $this->_request, $errors );
        $validator->checkCSRFAccessToken( $site, @$_REQUEST['accessToken'], $errors );
        $validator->checkRequestMethodPost( $this->_request, $errors );

        // can this login user edit this user
        $validator->checkLoginUserCanChangeUserSettings( $loginUser, $user, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // set the status
        $notifications = is_array( $input->notifications ) ? $input->notifications : array( $input->notifications );
        $emailNotificationsEnabled = in_array( 'email', $notifications ) ? true : false;
        $user->setEmailNotificationsEnabled( $emailNotificationsEnabled );

        $params = array( 'confirmMessage' => 'notificationsEditConfirm' );

        if ( $this->view->ajax ) {
            $this->view->browserHistoryUrl = $user->getUrl( 'userSettings' );
            $this->view->historyReplace = true;
            $this->processInput( null, array( 'confirmMessage' ), $errors, null, $params );
            return $this->renderPage( 'userNotificationsEdit' );
        }

        $redirectUrl = $user->getUrl( 'userSettings', $params );

        return $this->_redirect( $redirectUrl );
    }

    /**
     * The user password edit page
     *
     * @return void
     */
    public function passwordEditAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $input = $this->processInput( $requiredParams, array(), $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $validator->checkLoginUserCanChangeUserSettings( $loginUser, $user, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $successPage = 'userPasswordEdit';

        return $this->renderPage( $successPage );
    }

    /**
     * Edit password confirm
     *
     * @return void
     */
    public function passwordEditConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $validator = $this->view->validator;
        $errorFixPage = 'userPasswordEdit';
        $loginUser = $this->view->loginUser;
        $site = $this->view->site;

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'userId',
            'currentPassword',
            'newPassword',
            'confirmPassword',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorFixPage );
        }

        // get the variables
        $currentPassword = $input->getUnescaped( 'currentPassword' );
        $newPassword = $input->getUnescaped( 'newPassword' );
        $confirmPassword = $input->getUnescaped( 'confirmPassword' );
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        // can this login user edit this user
        $validator->checkLoginUserCanChangeUserSettings( $loginUser, $user, $errors );

        // show not found
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // check if current password is correct
        $validator->checkValidUserPassword( $loginUser, $currentPassword, $errors, 'currentPassword' );
        $validator->checkInputPasswordMatch( $newPassword, $confirmPassword, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorFixPage );
        }
        error_log( $newPassword );
        // change the password
        $user->setPassword( $newPassword );

        $params = array( 'confirmMessage' => 'passwordEditConfirm' );
        if ( $this->view->ajax ) {
            $this->view->browserHistoryUrl = $user->getUrl( 'userSettings' );
            $this->view->historyReplace = true;
            $this->processInput( null, array( 'confirmMessage' ), $errors, null, $params );
            return $this->renderPage( 'userPasswordEdit' );
        }

        $redirectUrl = $user->getUrl( 'userPasswordEdit', $params );
        return $this->_redirect( $redirectUrl );
    }

    /**
     * The user profile edit page
     *
     * @return void
     */
    public function profileEditAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $input = $this->processInput( $requiredParams, array(), $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $validator->checkLoginUserCanChangeUserSettings( $loginUser, $user, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $successPage = 'user';
        if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = 'userProfileEdit';
        } else if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        } else if ( !$this->view->ajax ) {
            $this->view->popupUrl = $user->getUrl( 'userProfileEdit' );
        }

        return $this->renderPage( $successPage );
    }

    /**
     * The user profile edit page
     *
     * @return void
     */
    public function profileEditConfirmAction()
    {
        $errors = $this->view->errors;
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $optionalParams = array(
            'firstName',
            'lastName',
            'bio',
            'profileImage'
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $user = $site->getUser( $input->userId );

        // show not found
        if ( ! $user ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $validator->checkLoginUserCanChangeUserSettings( $loginUser, $user, $errors );

        $profileImage = null;
        if ( @$_FILES['profileImage']['tmp_name'] ) {
            $profileImage = BeMaverick_Image::saveOriginalImage( $site, 'profileImage', $errors );
        }

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $firstName = $input->firstName ? $input->getUnescaped( 'firstName' ) : null;
        $lastName = $input->lastName ? $input->getUnescaped( 'lastName' ) : null;
        $bio = $input->bio ? $input->getUnescaped( 'bio' ) : null;

        if ( array_key_exists( 'firstName', $_REQUEST ) ) {
            $user->setFirstName( $firstName );
        }

        if ( array_key_exists( 'lastName', $_REQUEST ) ) {
            $user->setLastName( $lastName );
        }

        if ( array_key_exists( 'bio', $_REQUEST ) ) {
            $user->setBio( $bio );
        }

        if ( $profileImage ) {
            $user->setProfileImage( $profileImage );
        } elseif ( isset( $input->profileImage ) && $input->profileImage == -1 ) {
            $user->setProfileImage( false );
        }

        //moderate user. this will add the user to cleanspeak if the user's isn't already created.
        $site->moderateUser( $user );
        //moderate the firstname, lastname, email, bio, profileImage and profileCoverImage
        $site->moderateUserData( $user );

        $user->save();

        $this->view->user = $user;
        return $this->renderPage( 'user' );
    }


}
