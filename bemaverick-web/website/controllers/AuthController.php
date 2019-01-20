<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Url.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Email.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class AuthController extends BeMaverick_Controller_Base
{

    /**
     * The Parent login page
     *
     * @return void
     */
    public function loginAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $loginUser = $this->view->loginUser;

        if ( $loginUser ) {
            $homeUrl = $site->getUrl( 'home' );
            return $this->_redirect( $homeUrl );
        }

        // set the input params
        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'authLogin' );
    }

    /**
     * The Parent login confirm page
     *
     * @return void
     */
    public function loginConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $validator = $this->view->validator;

        // set the input params
        $requiredParams = array(
            'emailAddress',
            'password',
        );

        $customInputParams = array(
            'password' => array(
                'filters' => array( 'StringTrim', 'StripTags' ),
                'validators' => array( array( 'StringLength', 6, 255 ) ),
                'errorStringIds' => array(
                    'message' => 'USER_PASSWORD_INVALID',
                ),
            )
        );

        $input = $this->processInput( $requiredParams, null, $errors, null, null, $customInputParams );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'authLogin' );
        }

        // get the variables
        $emailAddress = $input->emailAddress;
        $password = $input->getUnescaped( 'password' );

        $user = $site->getUserByEmailAddress( $emailAddress );

        $validator->checkValidUserPassword( $user, $password, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'authLogin' );
        }

        // if user is kid and trying to log in from parent login, redirect them to temp tempHome.phtml
        if ( $user->getUserType() == BeMaverick_User::USER_TYPE_KID ) {
            $page = 'tempHome';

            $redirectUrl = $site->getUrl( $page );
            if ( $this->view->ajax ) {
                $this->view->redirectUrl = $redirectUrl;
                return $this->renderPage( 'redirect' );
            }

            return $this->_redirect( $redirectUrl );
        }

        // set the cookie
        BeMaverick_Cookie::updateUserCookie( $user );

        $page = 'home';
        if ( $user->getUserType() == BeMaverick_User::USER_TYPE_PARENT ) {
            $page = 'parentHome';
        }

        $redirectUrl = $site->getUrl( $page );

        if ( $this->view->ajax ) {
            $this->view->redirectUrl = $redirectUrl;
            return $this->renderPage( 'redirect' );
        }

        return $this->_redirect( $redirectUrl );
    }

    /**
     * The Maverick login page
     *
     * @return void
     */
    public function maverickLoginAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $loginUser = $this->view->loginUser;

        if ( $loginUser ) {
            $homeUrl = $site->getUrl( 'home' );
            return $this->_redirect( $homeUrl );
        }

        // set the input params
        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'authMaverickLogin' );
    }

    /**
     * The Maverick login confirm page
     *
     * @return void
     */
    public function maverickLoginConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $validator = $this->view->validator;

        // set the input params
        $requiredParams = array(
            'username',
            'password',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'authMaverickLogin' );
        }

        // get the variables
        $username = $input->username;
        $password = $input->getUnescaped( 'password' );

        $user = $site->getUserByUsername( $username );

        $validator->checkValidUserPassword( $user, $password, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'authMaverickLogin' );
        }

        // set the cookie
        BeMaverick_Cookie::updateUserCookie( $user );

        $page = 'maverickHome';
        $redirectUrl = $site->getUrl( $page );

        if ( $this->view->ajax ) {
            $this->view->redirectUrl = $redirectUrl;
            return $this->renderPage( 'redirect' );
        }

        return $this->_redirect( $redirectUrl );
    }

    /**
     * The logout confirm page
     *
     * @return void
     */
    public function logoutConfirmAction()
    {
        // get the vars from the view
        $site = $this->view->site;

        // delete the cookie
        BeMaverick_Cookie::deleteUserCookie();

        // setup the params for redirecting to page
        $params = array(
            'confirmPage' => 'authLogout',
        );

        $redirectUrl = $site->getUrl( 'home', $params );

        if ( $this->view->ajax ) {
            $this->view->redirectUrl = $redirectUrl;
            return $this->renderPage( 'redirect' );
        }

        return $this->_redirect( $redirectUrl );
    }

    /**
     * The register parent page
     *
     * @return void
     */
    public function registerFamilyAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'authRegisterParent' );
    }

    /**
     * The register parent confirm page
     *
     * @return void
     */
    public function registerFamilyConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                       /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;             /* @var BeMaverick_Validator $validator */

        // set the input params
        $requiredParams = array(
            'emailAddress',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'authRegisterParent' );
        }

        // get the variables
        $emailAddress = $input->emailAddress;

        // perform the checks
        $validator->checkParentEmailAddressAssociatedWithAKid( $site, $emailAddress, $errors );

        $errorPopupCode = null;
        if ( $errors->hasErrors() ) {
            $errorPopupCode = 'EMAIL_NOT_ASSOCIATED';
        }

        if ( $errorPopupCode && $this->view->ajax ) {
            $input->errorCode = $errorPopupCode;
            return $this->renderPage( 'authError' );
        } else if ( $errorPopupCode ) {
            $this->view->popupUrl = $site->getUrl( 'authError', array( 'errorCode' => $errorPopupCode ) );
            return $this->renderPage( 'authRegisterParent' );
        }

        // parent is registering, so send them to verify the first kid. they had to have at least
        // one kid to get to this point
        $kids = $site->getKidsByParentEmailAddress( $emailAddress );

        if( $kids[0] && !($kids[0]->getVPCStatus()) ) {
            $redirectUrl = BeMaverick_Util::getParentVerifyMaverickUrl( $site, $kids[0] );
            if ( $this->view->ajax ) {
                $this->view->redirectUrl = $redirectUrl;
                return $this->renderPage( 'redirect' );
            }

            return $this->_redirect( $redirectUrl );
        } else {
            //if one of the kid is verified, send the parent to set their email.
            $parent = $site->getUserByEmailAddress( $emailAddress );
            BeMaverick_Cookie::updateUserCookie( $parent );
            $successPage = 'authParentVerifyMaverickStep3';
            if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
                $successPage = $this->view->ajax.'Ajax';
            }
            return $this->renderPage( $successPage );
        }
    }

    /**
     * The forgot password page
     *
     * @return void
     */
    public function passwordForgotAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'authPasswordForgot' );
    }

    /**
     * The forgot password confirm page
     *
     * @return void
     */
    public function passwordForgotConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $validator = $this->view->validator;

        // set the input params
        $requiredParams = array(
            'emailAddress',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'authPasswordForgot' );
        }

        $inputEmail = $input->emailAddress;

        $user = $site->getUserByEmailAddress( $inputEmail );

        $validator->checkValidUser( $user, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'authPasswordForgot' );
        }

        if ( $user->getUserType() == BeMaverick_User::USER_TYPE_KID ) {
            $emailAddress = $user->getParentEmailAddress();
        } else {
            $emailAddress = $user->getEmailAddress();
        }

        $resetPasswordUrl = BeMaverick_Email::getResetPasswordUrl( $site, $user );

        // send mail to recover your password
        $vars = array(
            'RESET_PASSWORD_URL' => $resetPasswordUrl,
        );

        BeMaverick_Email::sendTemplate( $site, 'user-forgot-password', array( $emailAddress ), $vars );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'authPasswordForgot' );
        }

        return $this->renderPage( 'authPasswordForgotConfirm' );
    }

    /**
     * The reset password page
     *
     * @return void
     */
    public function passwordResetAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $validator = $this->view->validator;

        // set the input params
        $requiredParams = array(
            'code',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // decode the hash and gets its parts, confirm all good and allow user to change password
        list( $userIdentification, $timestamp, $signature ) = explode( '|', base64_decode( urldecode( $input->code ) ) );

        // first assume userIdentification is a username
        $user = $site->getUserByUsername( $userIdentification );

        // if userIdentification is not a username, use userIdentification as an email address
        if ( ! $user ) {
            $user = $site->getUserByEmailAddress( $userIdentification );
        }

        $validator->checkValidUser( $user, $errors );
        $validator->checkValidResetPasswordCode( $site, $userIdentification, $timestamp, $signature, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'authPasswordReset' );
    }

    /**
     * The reset password confirm page
     *
     * @return void
     */
    public function passwordResetConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $validator = $this->view->validator;

        // set the input params
        $requiredParams = array(
            'code',
            'password',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $password = $input->getUnescaped( 'password' );

        // decode the hash and gets its parts, confirm all good and allow user to change password
        list( $userIdentification, $timestamp, $signature ) = explode( '|', base64_decode( urldecode( $input->code ) ) );

        // first assume userIdentification is a username
        $user = $site->getUserByUsername( $userIdentification );

        // if userIdentification is not a username, use userIdentification as an email address
        if ( ! $user ) {
            $user = $site->getUserByEmailAddress( $userIdentification );
        }

        $validator->checkValidUser( $user, $errors );
        $validator->checkValidResetPasswordCode( $site, $userIdentification, $timestamp, $signature, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // all passed, so lets change this user's password and log in
        $user->setPassword( $password );
        $user->save();

        // set the cookie/log the user in if they are a parent
//        if ( $user->getUserType() == BeMaverick_User::USER_TYPE_PARENT ) {
//            BeMaverick_Cookie::updateUserCookie( $user );
//        }

        if ( $user->getUserType() == BeMaverick_User::USER_TYPE_KID ) {
            $toEmailAddress = $user->getParentEmailAddress();
        } else {
            $toEmailAddress = $user->getEmailAddress();
        }

        // send mail to recover your password
        $vars = array(
            'USERNAME' => $user->getUsername(),
        );

        BeMaverick_Email::sendTemplate( $site, 'user-reset-password', array( $toEmailAddress ), $vars );

        return $this->renderPage( 'authPasswordResetConfirm' );
    }

    /**
     * The account verify confirm page
     *
     * @return void
     */
    public function accountVerifyConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        // set the input params
        $requiredParams = array(
            'code',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // decode the hash and gets its parts, confirm all good and account is valid
        list( $username, $timestamp, $signature ) = explode( '|', base64_decode( urldecode( $input->code ) ) );

        $user = $site->getUserByUsername( $username );

        $validator->checkValidUser( $user, $errors );
        $validator->checkValidVerifyAccountCode( $site, $username, $timestamp, $signature, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $user->setEmailVerified( true );
        $user->save();

        // set the cookie
        BeMaverick_Cookie::updateUserCookie( $user );

        return $this->renderPage( 'authAccountVerifyConfirm' );
    }

    /**
     * The parent verify maverick step 1 page
     *
     * @return void
     */
    public function familyVerifyMaverickStep1Action()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        // set the input params
        $requiredParams = array(
            'code',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // decode the hash and gets its parts, confirm all good and account is valid
        list( $username, $timestamp, $signature ) = explode( '|', base64_decode( urldecode( $input->code ) ) );

        $user = $site->getUserByUsername( $username );

        $validator->checkValidUser( $user, $errors );
        $validator->checkValidVerifyAccountCode( $site, $username, $timestamp, $signature, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // per MVP-2507, we want to go directly to step2 if request IP address is not from US
        // or if user's vpc status is already set
        $ipAddress = BeMaverick_Util::getRequestIpAddress();
        $country = BeMaverick_Util::getCountryFromIPAddress( $ipAddress );

        if ( $user->getVPCStatus() || $country != 'US' ) {

            $this->_verifyParent( $site, $user, 'PASS' );

            return $this->renderPage( 'authParentVerifyMaverickStep2' );
        }

        return $this->renderPage( 'authParentVerifyMaverickStep1' );
    }

    /**
     * The parent verify maverick step 2 page
     *
     * @return void
     */
    public function familyVerifyMaverickStep2Action()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        // set the input params
        $requiredParams = array(
            'code',
            'firstName',
            'lastName',
            'address',
            'zipCode',
            'lastFourSSN',
        );

        $optionalParams = array(
            'testKey',
            'retry'
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // decode the hash and gets its parts, confirm all good and account is valid
        list( $username, $timestamp, $signature ) = explode( '|', base64_decode( urldecode( $input->code ) ) );

        $kid = $site->getUserByUsername( $username );

        $validator->checkValidUser( $kid, $errors );
        $validator->checkValidVerifyAccountCode( $site, $username, $timestamp, $signature, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $firstName = $input->getUnescaped( 'firstName' );
        $lastName = $input->getUnescaped( 'lastName' );
        $address = $input->getUnescaped( 'address' );
        $zipCode = $input->zipCode;
        $lastFourSSN = $input->lastFourSSN;
        $testKey = $input->testKey ? $input->testKey : 'general';

        // make a call to third party check
        $idVerificationResponse = $site->verifyParentIdentity( $kid->getId(), $firstName, $lastName, $address, $zipCode, $lastFourSSN, $testKey );

        $result = $idVerificationResponse['result']['action'];

        $parent = $this->_verifyParent( $site, $kid, $result );

        if ( $result == 'PASS' ) {
            BeMaverick_Cookie::updateUserCookie( $parent );

        } else if ( $result == 'FAIL' ) {

            $this->view->retry = true;

            return $this->renderPage( 'authParentVerifyMaverickStep1' );

        } else if ( $result == 'REJECT' ) {
            $errors->setError( '', 'please contact customer support' );

            return $this->renderPage( 'errors' );
        }

        $successPage = 'authParentVerifyMaverickStep2';
        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        return $this->renderPage( $successPage );
    }

    /**
     * The parent verify maverick step 3 page
     *
     * @return void
     */
    public function familyVerifyMaverickStep3Action()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        // set the input params
        $requiredParams = array(
            'code',
            'consentCollect',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // decode the hash and gets its parts, confirm all good and account is valid
        list( $username, $timestamp, $signature ) = explode( '|', base64_decode( urldecode( $input->code ) ) );

        $kid = $site->getUserByUsername( $username );

        $validator->checkValidUser( $kid, $errors );
        $validator->checkValidVerifyAccountCode( $site, $username, $timestamp, $signature, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // verify the account for the kid
        $kid->setEmailVerified( true );
        $kid->setVPCStatus( 1 );
        $kid->save();

        $successPage = 'authParentVerifyMaverickStep3';
        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        return $this->renderPage( $successPage );
    }

    /**
     * The parent verify maverick confirm page
     *
     * @return void
     */
    public function familyVerifyMaverickConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $loginUser = $this->view->loginUser;       /* @var BeMaverick_User $loginUser */

        // set the input params
        $requiredParams = array(
            'password',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $loginUser->setPassword( $input->getUnescaped( 'password' ) );

        $emailAddress = $loginUser->getEmailAddress();
        $kids = $site->getKidsByParentEmailAddress( $emailAddress );
        $systemConfig = $site->getSystemConfig();

        if ( $kids[0] ) {
            // send the email
            $vars = array(
                'EMAIL_ADDRESS' => $emailAddress,
                'USERNAME' => $kids[0]->getUsername(),
                'APP_URL' => $systemConfig->getSetting( 'APP_DEEPLINK' ),
            );
            BeMaverick_Email::sendTemplate( $site, 'parent-new-user', array( $emailAddress ), $vars );

        }


        $successPage = 'authParentVerifyMaverickConfirm';
        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        return $this->renderPage( $successPage );
    }

    /**
     * The parent verify maverick confirm page
     *
     * @return void
     */
    public function errorAction()
    {
        // get the view vars
        $site = $this->view->site;
        $errors = $this->view->errors;
        $loginUser = $this->view->loginUser;

        // set the input params
        $optionalParams = array(
            'errorCode',
        );

        $input = $this->processInput( null, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        if ( !$this->view->ajax ) {
            $homeUrl = $site->getUrl( 'home' );
            return $this->_redirect( $homeUrl );
        }

        return $this->renderPage( 'authError' );
    }

    /**
     * Authenticate the user from react app -
     * Read the token from the Authorization header and
     * sets the PHP user cookie if appropriate.
     * 
     * @return void
     */
    public function tokenAction() {
        // load global variables
        $validator = $this->view->validator;
        $site = $this->view->site;
        $errors = $this->view->errors;

        // read the token info from `headers: { Authorization }`
        $tokenInfo = $validator->checkOAuthToken( $site, 'read', true, $errors, false);
        $user = $tokenInfo['user'];

        // echo '$tokenInfo[user] => <pre>'.print_r($tokenInfo['user'], true).'</pre>';

        header('Content-Type: application/json');
        if ($user) {
            http_response_code(200);
            BeMaverick_Cookie::updateUserCookie( $user );
            echo json_encode(array(
                'status' => 'success',
                'message' => 'User authenticated successfully',
            ));
            exit();
        } else {
            http_response_code(401);
            echo json_encode(array(
                'status' => 'error',
                'message' => 'User not authenticated',
            ));
            exit();
        }
    }

    /**
     * Get the logged in user
     *
     * @return void
     */
    public function userAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $loginUser = $this->view->loginUser;

        if ($loginUser) {
            header('Content-Type: application/json');
            http_response_code(200);
            echo json_encode(array(
                'userId' => $loginUser->getId(),
                'username' => $loginUser->getUsername(),
                'authenticated' => true,
                'userType' => $loginUser->getUserType(),
                'emailAddress' => $loginUser->getEmailAddress(),
                'firstName' => $loginUser->getFirstName(),
                'lastName' => $loginUser->getLastName(),
                'birthdate' => $loginUser->getBirthdate(),
                'isVerified' => method_exists(($loginUser), 'isVerified') ? $loginUser->isVerified() : null,
                'isEmailVerified' => method_exists(($loginUser), 'isEmailVerified') ? $loginUser->isEmailVerified() : null,
                'status' => $loginUser->getStatus(),
                'uuid' => $loginUser->getUUID(),
                // 'imageId' => $loginUser->getProfileImageId(),
                // 'coverImageType' => $loginUser->getProfileCoverImageType(),
                // 'coverImageId' => $loginUser->getProfileCoverImageId(),
                // 'coverPresetImageId' => $loginUser->getProfileCoverPresetImageId(),
                // 'coverTing' => $loginUser->getProfileCoverTint(),
            ));
            exit();
        } else {
            header('Content-Type: application/json');
            http_response_code(200);
            echo json_encode(array(
                'authenticated' => false,
            ));
            exit();
        }
    }


    /**
     * Get the logged in user
     *
     * @param BeMaverick_Site $site
     * @param BeMaverick_User_Kid $kid
     * @param string $result
     * @return void
     */
    private function _verifyParent( $site, $kid, $result )
    {
        // check to see if this parent already has an account, if not, then lets create one
        $parentEmailAddress = $kid->getParentEmailAddress();
        $parent = $site->getUserByEmailAddress( $parentEmailAddress );

        if ( ! $parent ) {
            $parent = $site->createParent( null, null, $parentEmailAddress );
        }

        // if they got this far, they must have a valid email since they clicked on the code,
        // so lets verify the parent's account
        $parent->setEmailVerified( true );
        $parent->setIdVerificationTimestamp( date( 'Y-m-d H:i:s' ) );

        if ( $result == 'PASS' ) {

            $parent->setIdVerificationStatus( BeMaverick_User_Parent::ID_VERIFICATION_STATUS_VERIFIED );

            BeMaverick_Cookie::updateUserCookie( $parent );

        } else if ( $result == 'FAIL' ) {
            $parent->setIdVerificationStatus( BeMaverick_User_Parent::ID_VERIFICATION_STATUS_PENDING );

        } else if ( $result == 'REJECT' ) {
            $parent->setIdVerificationStatus( BeMaverick_User_Parent::ID_VERIFICATION_STATUS_REJECTED );
        }

        return $parent;
    }

}