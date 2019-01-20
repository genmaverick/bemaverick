<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Url.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/AccessTokenManager.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Email.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/SMSUtil.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Util.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );
require_once( BEMAVERICK_ROOT_DIR . '/vendor/autoload.php' );

use Abraham\TwitterOAuth\TwitterOAuth;

class AuthController extends BeMaverick_Controller_Base
{ 

    /**
     * The register kid page
     *
     * @return void
     */
    public function registerkidAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'username',
            'password',
            'birthdate',
        );

        $optionalParams = array(
            'emailAddress',
            'parentEmailAddress',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $app = $tokenInfo['app'];
        $username = $input->username;
        $password = $input->getUnescaped( 'password' );
        $birthdate = $input->birthdate;
        $emailAddress = $input->emailAddress ? $input->emailAddress : null;
        $parentEmailAddress = $input->parentEmailAddress ? $input->parentEmailAddress : null;

        // perform the checks
        $validator->checkUsernameAvailable( $site, $username, $errors );
        $validator->checkInputBirthdateAndEmailAddressType( $birthdate, $emailAddress, $parentEmailAddress, $errors );

        if ( $parentEmailAddress ) {
            $validator->checkUnusedOrValidParentEmail( $site, $parentEmailAddress, $errors );
        } else {
            $validator->checkEmailAddressAvailable( $site, $emailAddress, $errors );
        }

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $user = $site->createKid( $username, $password, $birthdate, $emailAddress, $parentEmailAddress );

        if ( $user->isTeen() ) {

            // send the email to verify account for normal user
            BeMaverick_Email::sendNewUserEmailToTeenKid( $site, $user );

        } else {

            // the kid is less than 13, so need to send mail to the parent to verify the account and create parent account
            
            // create a new parent account if the email address is not already in use
            if ( ! $site->isEmailAddressTaken( $parentEmailAddress ) ) {
                $site->createParent( null, null, $parentEmailAddress );
            }
            
            $vars = array(
                'USERNAME' => $username,
                'VERIFY_MAVERICK_URL' => BeMaverick_Util::getParentVerifyMaverickUrl( $site, $user ),
            );

            BeMaverick_Email::sendTemplate( $site, 'parent-verify-maverick', array( $parentEmailAddress ), $vars );

        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserAccessToken( $site, $app, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The register parent page
     *
     * @return void
     */
    public function registerparentAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'username',
            'password',
            'emailAddress',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // perform the checks
        $validator->checkUsernameAvailable( $site, $input->username, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the variables
        $app = $tokenInfo['app'];
        $username = $input->username;
        $password = $input->getUnescaped( 'password' );
        $emailAddress = $input->emailAddress;

        $user = $site->createParent( $username, $password, $emailAddress );
        $systemConfig = $site->getSystemConfig();

        // send the email
        $vars = array(
            'USERNAME' => $username,
            'VERIFY_ACCOUNT_URL' => BeMaverick_Util::getVerifyAccountUrl( $site, $user ),
            'APP_URL' => $systemConfig->getSetting( 'APP_DEEPLINK' ),
        );

        BeMaverick_Email::sendTemplate( $site, 'parent-new-user', array( $emailAddress ), $vars );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserAccessToken( $site, $app, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The forgot username page
     *
     * @return void
     */
    public function forgotusernameAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'read', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $optionalParams = array(
            'emailAddress',
            'parentEmailAddress',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $emailAddress = $input->emailAddress;
        $parentEmailAddress = $input->parentEmailAddress;

        if ( ! $emailAddress && ! $parentEmailAddress ) {
            $errors->setError( '', 'EMAIL_ADDRESS_OR_PARENT_EMAIL_ADDRESS_IS_REQUIRED' );
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        if ( $emailAddress ) {
            $user = $site->getUserByEmailAddress( $emailAddress );

            if( !$user ) {
                //check if the user doesn't exist. This could be a parent email address.
                $filterBy = array(
                    'parentEmailAddress' => $emailAddress,
                );
                $users = $site->getUsers( $filterBy );

                if ( count( $users ) == 0 ) {
                    $errors->setError( 'parentEmailAddress', 'USER_DOES_NOT_EXIST' );
                }

                foreach ( $users as $user ) {
                    $validator->checkValidUser( $user, $errors );
                }

            }else {
                //if the user exists for the emailAddress
                $users[] = $user;
                $validator->checkValidUser( $user, $errors );
            }

            if ( $errors->hasErrors() ) {
                return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
            }

            $toEmailAddress = $emailAddress;

        } else {
            //todo Remove this code. this api will not be called with parentEmailAddress param.
            $filterBy = array(
                'parentEmailAddress' => $parentEmailAddress,
            );

            $users = $site->getUsers( $filterBy );

            foreach ( $users as $user ) {
                $validator->checkValidUser( $user, $errors );
            }

            if ( count( $users ) == 0 ) {
                $errors->setError( 'parentEmailAddress', 'PARENT_EMAIL_ADDRESS_DOES_NOT_EXIST' );
            }

            $toEmailAddress = $parentEmailAddress;
        }

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $forgotUsernameHtml = BeMaverick_Email::getForgotUsernameHtml( $users );

        // send mail to show the user's username
        $vars = array(
            'USERNAME' => $forgotUsernameHtml,
        );

        BeMaverick_Email::sendTemplate( $site, 'user-forgot-username', array( $toEmailAddress ), $vars );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();

        // set the results
        $responseData->addStatus( 'success' );

        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The forgot password page
     *
     * @return void
     */
    public function forgotpasswordAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'read', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'username',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $user = $site->getUserByUsername( $input->username );

        $validator->checkValidUser( $user, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $toEmailAddress = $user->getEmailAddress();

        // if the user doesn't have an email address then check to see if they have a parent
        // that has an email address
        if ( ! $toEmailAddress && $user->getUserType() == BeMaverick_User::USER_TYPE_KID ) {
            $toEmailAddress = $user->getParentEmailAddress();
        }

        $resetPasswordUrl = BeMaverick_Email::getResetPasswordUrl( $site, $user );

        // send mail to recover your password 
        $vars = array(
            'RESET_PASSWORD_URL' => $resetPasswordUrl,
        );

        BeMaverick_Email::sendTemplate( $site, 'user-forgot-password', array( $toEmailAddress ), $vars );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();  

        // set the results
        $responseData->addStatus( 'success' );

        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' ); 
    }

    /**
     * The reset password page
     *
     * @return void
     */
    public function resetpasswordAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        // check the oauth token
        $tokenInfo = $validator->checkOAuthToken( $site, 'write', false, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'code',
            'newPassword',
        );        

        $input = $this->processInput( $requiredParams, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // decode the hash and gets its parts, confirm all good and allow user to change password
        list( $email, $timestamp, $signature ) = explode( '|', base64_decode( $input->code ) );

        $user = $site->getUserByEmailAddress( $email );

        $validator->checkValidUser( $user, $errors );        
        $validator->checkValidResetPasswordCode( $site, $email, $timestamp, $signature, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }
        
        // all passed, so lets change this user's password and log in
        $user->setPassword( $input->newPassword );
        $user->save();

        if ( $user->getUserType() == BeMaverick_User::USER_TYPE_KID ) {
            $toEmailAddress = $user->getParentEmailAddress();
            $emailUsername = $user->getUsername();
        } else {
            $toEmailAddress = $user->getEmailAddress();
            $emailUsername = $user->getEmailAddress();
        }

        // send mail to recover your password
        $vars = array(
            'USERNAME' => $emailUsername,
        );

        BeMaverick_Email::sendTemplate( $site, 'user-reset-password', array( $toEmailAddress ), $vars );

        $app = $tokenInfo['app'];

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserAccessToken( $site, $app, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The validate username
     *
     * @return void
     */
    public function validateusernameAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'username',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // perform the checks
        $validator->checkUsernameAvailable( $site, $input->username, $errors );
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The facebook login action
     *
     * @return void
     */
    public function facebookloginAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */
        $systemConfig = $this->view->systemConfig; /* @var BeMaverick_Config_System $systemConfig */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'fbAccessToken',
        );

        $optionalParams = array(
            'username',
            'birthdate',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get some variables
        $app = $tokenInfo['app'];

        try {

            $fb = new \Facebook\Facebook(
                array(
                    'app_id' => $systemConfig->getSetting( 'FACEBOOK_APP_ID' ),
                    'app_secret' => $systemConfig->getSetting( 'FACEBOOK_APP_SECRET' ),
                )
            );

            $response = $fb->get( '/me?fields=id,name,email', $input->fbAccessToken );

            $facebookUser = $response->getGraphUser();

            $facebookUserId = $facebookUser->getId();
            $emailAddress = $facebookUser->getEmail();

            if ( ! $facebookUserId ) {
                throw new Exception( 'Unable to obtain user id from Facebook.' );
            }

            // Look up for facebook user ID first, if not found, try by email
            $user = $site->getUserByLoginProvider( BeMaverick_User::USER_LOGIN_PROVIDER_FACEBOOK, $facebookUserId );

            if ( ! $user ) {

                // see if this user is in our database by email address
                if ( $emailAddress ) {
                    $user = $site->getUserByEmailAddress( $emailAddress, null );
                }
            }

            // create a user if there isn't one yet
            if ( ! $user ) {

                $username = $input->username;
                $birthdate = $input->birthdate;

                // perform the checks
                $validator->checkUsernameAvailable( $site, $username, $errors );
                $validator->checkInputBirthdateIsTeen( $birthdate, $errors );

                if ( $errors->hasErrors() ) {
                    return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
                }

                $user = $site->createKid( $username, null, $birthdate, $emailAddress, null );

                // send the email to verify account for normal user
                BeMaverick_Email::sendNewUserEmailToTeenKid( $site, $user );

            } else {

                $validator->checkUserCanUseSocialLogin( $user, $errors );

                if ( $errors->hasErrors() ) {
                    return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
                }
            }

            // always make sure the social login provider is set
            $user->addSocialLoginProvider( BeMaverick_User::USER_LOGIN_PROVIDER_FACEBOOK, $facebookUserId );

            // get the response data object
            $responseData = $site->getFactory()->getResponseData();
            $responseData->addUserAccessToken( $site, $app, $user );
            $this->view->responseData = $responseData;

            return $this->renderPage( 'responseData' );


        } catch ( Exception $e ) {
            $errors->setError( 'facebookInvalidLogin', 'FACEBOOK_INVALID_LOGIN' );
            $errors->setError( 'facebookInvalidResponse', $e->getMessage() );

            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }
    }

    /**
     * The twitter login action
     *
     * @return void
     */
    public function twitterloginAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */
        $systemConfig = $this->view->systemConfig; /* @var BeMaverick_Config_System $systemConfig */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'twitterAccessToken',
            'twitterAccessTokenSecret',
        );

        $optionalParams = array(
            'username',
            'birthdate',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get some variables
        $app = $tokenInfo['app'];

        try {

            $connection = new TwitterOAuth(
                $systemConfig->getSetting( 'TWITTER_API_CONSUMER_KEY' ),
                $systemConfig->getSetting( 'TWITTER_API_CONSUMER_SECRET' ),
                $input->twitterAccessToken,
                $input->twitterAccessTokenSecret
            );

            $params = array(
                'include_email' => 'true',
            );

            $twitterUser = $connection->get( "account/verify_credentials", $params );

            $twitterUserId = $twitterUser->{'id'};
            $emailAddress = isset( $twitterUser->{'email'} ) ? $twitterUser->{'email'} : null;

            if ( ! $twitterUserId ) {
                throw new Exception( 'Unable to obtain user id from Twitter.' );
            }

            // Look up for facebook user ID first, if not found, try by email
            $user = $site->getUserByLoginProvider( BeMaverick_User::USER_LOGIN_PROVIDER_TWITTER, $twitterUserId );

            if ( ! $user ) {

                // see if this user is in our database by email address
                if ( $emailAddress ) {
                    $user = $site->getUserByEmailAddress( $emailAddress, null );
                }
            }

            // create a user if there isn't one yet
            if ( ! $user ) {

                $username = $input->username;
                $birthdate = $input->birthdate;

                // perform the checks
                $validator->checkUsernameAvailable( $site, $username, $errors );
                $validator->checkInputBirthdateIsTeen( $birthdate, $errors );

                if ( $errors->hasErrors() ) {
                    return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
                }

                $user = $site->createKid( $username, null, $birthdate, $emailAddress, null );

                // send the email to verify account for normal user
                BeMaverick_Email::sendNewUserEmailToTeenKid( $site, $user );

            } else {

                $validator->checkUserCanUseSocialLogin( $user, $errors );

                if ( $errors->hasErrors() ) {
                    return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
                }
            }

            // always make sure the social login provider is set
            $user->addSocialLoginProvider( BeMaverick_User::USER_LOGIN_PROVIDER_TWITTER, $twitterUserId );

            // get the response data object
            $responseData = $site->getFactory()->getResponseData();
            $responseData->addUserAccessToken( $site, $app, $user );
            $this->view->responseData = $responseData;

            return $this->renderPage( 'responseData' );

        } catch ( Exception $e ) {
            $errors->setError( 'twitterInvalidLogin', 'TWITTER_INVALID_LOGIN' );
            $errors->setError( 'twitterInvalidResponse', $e->getMessage() );

            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }
    }

    /**
     * The sms login request action
     *
     * @return void
     */
    public function smsloginrequestAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'write', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'phoneNumber',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get some variables
        $phoneNumber = $input->phoneNumber;

        $validator->checkValidPhoneNumber( $site, $phoneNumber, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // generate a code for the phone number
        $code = BeMaverick_SMSUtil::generateSmsCode();

        // add the phone number and code to the database
        BeMaverick_SMSUtil::setSmsCode( $phoneNumber, $code );

        // send the code to the phone number
        BeMaverick_SMSUtil::sendSMSMessage( $site, $phoneNumber, "Here is your code: $code" );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The sms login confirm action
     *
     * @return void
     */
    public function smsloginconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'write', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'phoneNumber',
            'code',
        );

        $optionalParams = array(
            'username',
            'birthdate',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get some variables
        $app = $tokenInfo['app'];
        $phoneNumber = $input->phoneNumber;
        $code = $input->code;

        // perform the checks
        $validator->checkValidSMSLoginCode( $site, $phoneNumber, $code, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // look up the user by phone number
        $user = $site->getUserByPhoneNumber( $phoneNumber, null );

        // create a user if there isn't one yet
        if ( ! $user ) {

            $username = $input->username;
            $birthdate = $input->birthdate;

            // perform the checks
            $validator->checkUsernameAvailable( $site, $username, $errors );
            $validator->checkInputBirthdateIsTeen( $birthdate, $errors );

            if ( $errors->hasErrors() ) {
                return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
            }

            $user = $site->createKid( $username, null, $birthdate, null, null );

            $user->setPhoneNumber( $phoneNumber );
        }

        BeMaverick_SMSUtil::deleteSmsCode( $phoneNumber );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addUserAccessToken( $site, $app, $user );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );

    }

    /**
     * The sms verify code action
     *
     * @return void
     */
    public function smsverifycodeAction()
    {
        // get the view vars
        $errors = $this->view->errors;             /* @var Sly_Errors $errors */
        $site = $this->view->site;                 /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;       /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'write', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'phoneNumber',
            'code',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get some variables
        $phoneNumber = $input->phoneNumber;
        $code = $input->code;

        // perform the checks
        $validator->checkValidSMSLoginCode( $site, $phoneNumber, $code, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

}

?>
