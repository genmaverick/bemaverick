<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/OAuth/AccessTokenManager.php' );

/**
 * Class for management of a validator
 *
 */
class BeMaverick_Validator
{
    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = false;

    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct( $factory )
    {
        $this->_factory = $factory;
    }

    /**
     * Retrieves the validator instance.
     *
     * @return BeMaverick_Validator
     */
    public static function getInstance( $factory )
    {
        if ( ! self::$_instance ) {
            self::$_instance = new self( $factory );
        }

        return self::$_instance;
    }

    /**
     * Check that the uploaded file is valid
     *
     * @param hash $file
     * @param string $inputName
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkInputUploadedFile( $file, $inputName, $errors )
    {
        if ( ! is_uploaded_file( @$file[$inputName]['tmp_name'] ) || ! file_exists( @$file[$inputName]['tmp_name'] ) ) {
            $errors->setError( $inputName, 'INPUT_INVALID_UPLOAD_FILE' );
        }
    }

    /**
     * Check that the uploaded file size is valid
     *
     * @param hash $file
     * @param string $inputName
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkInputUploadedFileSize( $file, $inputName, $errors, $sizeInMb = 4 )
    {
        $maxFileSize = $sizeInMb * 1024 * 1024;
        if ( ! is_uploaded_file( @$file[$inputName]['tmp_name'] ) || ! file_exists( @$file[$inputName]['tmp_name'] ) || @$file[$inputName]['size'] > $maxFileSize ) {
            $errors->setError( $inputName, 'INPUT_INVALID_FILE_SIZE' );
        }
    }




    /**
     * Check that the app is valid
     *
     * @return void
     */
    public function checkValidApp( $app, $errors )
    {
        if ( ! $app ) {
            $errors->setError( '', 'APP_DOES_NOT_EXIST' );
        }
    }

    /**
     * Check that the user is valid
     *
     * @return void
     */
    public function checkValidUser( $user, $errors )
    {
        if ( ! $user ) {
            $errors->setError( '', 'USER_DOES_NOT_EXIST' );
        }
    }

    /**
     * Check that the badge is valid
     *
     * @return void
     */
    public function checkValidBadge( $badge, $errors )
    {
        if ( ! $badge ) {
            $errors->setError( '', 'BADGE_DOES_NOT_EXIST' );
        }
    }

    /**
     * Check that the challenge is valid
     *
     * @param BeMaverick_Challenge $challenge
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkValidChallenge( $challenge, $errors )
    {
        if ( ! $challenge ) {
            $errors->setError( '', 'CHALLENGE_DOES_NOT_EXIST' );
        }
    }

    /**
     * Check that the response is valid
     *
     * @param BeMaverick_Response $response
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkValidResponse( $response, $errors )
    {
        if ( ! $response ) {
            $errors->setError( '', 'RESPONSE_DOES_NOT_EXIST' );
        }
    }

    /**
     * Check that the response input values are valid
     *
     * @param array $input
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkInputResponse( $input, $errors, $response=null )
    {
        // Check for empty input values
        if ( empty($input) ) {
            $errors->setError( '', 'INVALID_RESPONSE_INPUT_FIELDS' );
            return;
        }

        // Destructure input values
        $responseStatus = $input['responseStatus'];
        $postType = $input['postType'];
        $responseType = $input['responseType'];
        $user = $input['user'];
        $challenge = $input['challenge'];
        $uploadFile = $input['uploadFile'];

        /**
         * All Post Types
         */
        // validate user
        $this->checkValidUser( $user, $errors );
        // validate image (upload or existing)
        $responseHasImage = $this->_fileInputOrObject( $_FILES, 'file', $response, $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ? 'getImage' : 'getVideo');
        if ( ! $responseHasImage ) {
            $errors->setError( 'mainImage', 'INPUT_INVALID_UPLOAD_FILE' );
        }

        if($postType == BeMaverick_Response::POST_TYPE_RESPONSE) {
            // Respones Post Type
            $this->checkValidChallenge( $challenge, $errors );
        } elseif($postType == BeMaverick_Response::POST_TYPE_CONTENT) {
            // Content Post Type
            $this->checkUserIsTypeMentor($user, 'username', $errors );
        } else {
            $errors->setError( '', 'INVALID_INPUT_POST_TYPE' );
        }
    }

    /**
     * Check that the content is valid
     *
     * @param BeMaverick_Content $content
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkValidContent( $content, $errors )
    {
        if ( ! $content ) {
            $errors->setError( '', 'CONTENT_DOES_NOT_EXIST' );
        }
    }

    /**
     * Check the user can favorite a response
     *
     * @param BeMaverick_User $user
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanCreateContent( $user, $errors )
    {
        if (  $user->getUserType() != BeMaverick_User::USER_TYPE_MENTOR ) {
            $errors->setError( 'userId', 'USER_DOES_NOT_HAVE_PERMISSIONS_TO_CREATE_CONTENT' );
        }
    }

    /**
     * Check the user is a mentor/catalyst
     *
     * @param BeMaverick_User $user
     * @param string $field
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserIsTypeMentor( $user, $field='userId', $errors )
    {
        if (is_null($user)) {
            $errors->setError( $field, 'USER_DOES_NOT_EXIST' );
            return;
        }

        if (  $user->getUserType() != BeMaverick_User::USER_TYPE_MENTOR ) {
            $errors->setError( $field, 'USER_TYPE_MENTOR_REQUIRED' );
        }
    }

    /**
     * Check the user can delete content
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_Content $content
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanDeleteContent( $user, $content, $errors )
    {
        if ( ! $content || $content->getUser() != $user ) {
            $errors->setError( 'contentId', 'USER_DOES_NOT_HAVE_PERMISSIONS_TO_DELETE_CONTENT' );
        }
    }

    /**
     * Check that the app key has permission
     *
     * @param BeMaverick_App $app
     * @param string $accessType Type can be 'read' or 'write'
     * @param Sly_Errors $errors
     * @return integer - app_id
     */
    public function checkAppAccess( $app, $accessType, $errors )
    {
        if ( is_bool($app) ) {
            return $app;
        }
        if ( ! $app->hasAccess( $accessType ) ) {
            $errors->setError( 'appKeyNoAccess', 'APP_KEY_NO_ACCESS' );
        }
    }

    /**
     * Check that the password is correct
     *
     * @return void
     */
    public function checkValidUserPassword( $user, $password, $errors, $inputName = 'password' )
    {
        if ( ! $user ) {
            $errors->setError( '', 'USER_DOES_NOT_EXIST' );
            return;
        }

        if ( $user->getPassword() != md5( $password ) ) {
            $errors->setError( $inputName, 'USER_PASSWORD_INVALID' );
        }
    }

    /**
     * Check that the new password matches confirmation new password
     *
     * @return void
     */
    public function checkInputPasswordMatch( $newPassword, $confirmPassword, $errors )
    {
        if ( $newPassword != $confirmPassword ) {
            $errors->setError( '', 'NEW_PASSWORDS_DO_NOT_MATCH' );
        }
    }

    /**
     * Check the username is available
     *
     * @param BeMaverick_Site $site
     * @param string $username
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUsernameAvailable( $site, $username, $errors )
    {
        if ( $site->isUsernameTaken( $username ) ) {
            $errors->setError( 'username', 'USERNAME_IS_NOT_AVAILABLE' );
        }

        // moderate username
        if ( ! $site->moderateUserName( $username ) ) {
            $errors->setError( 'username', 'USERNAME_IS_INAPPROPRIATE' );
        };
    }

    /**
     * Check the email address is available
     *
     * @param BeMaverick_Site $site
     * @param string $emailAddress
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkEmailAddressAvailable( $site, $emailAddress, $errors, $user = null )
    {
        // do not check if the address is not changing
        if (!is_null($user)) {
            $oldEmailAddress = $user->getEmailAddress();
            if ($oldEmailAddress === $emailAddress) {
                return;
            }
        }

        // check that the email address is available
        if ( $site->isEmailAddressTaken( $emailAddress ) ) {
            $errors->setError( 'emailAddress', 'EMAIL_ADDRESS_IS_NOT_AVAILABLE' );
        }
    }

    /**
     * Check if at least one email address is provided
     *
     * @param BeMaverick_Site $site
     * @param string $emailAddress
     * @param string $parentEmailAddress
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkEmailAddressProvided( $site, $emailAddress, $parentEmailAddress, $errors )
    {
        if ( !$emailAddress && !$parentEmailAddress ) {
            $errors->setError( '', 'EMAIL_ADDRESS_REQUIRED' );
        }
    }

    /**
     * Check the parent email address exists
     *
     * @param BeMaverick_Site $site
     * @param string $emailAddress
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkParentEmailAddressAssociatedWithAKid( $site, $emailAddress, $errors )
    {
        $kids = $site->getKidsByParentEmailAddress( $emailAddress );

        if ( count( $kids ) == 0 ) {
            $errors->setError( 'emailAddress', 'PARENT_EMAIL_ADDRESS_IS_NOT_ASSOCIATED_WITH_KID' );
        }
    }

    /**
     * Check the the proper email address was given depending on age of user
     *
     * @param string $birthdate
     * @param string $emailAddress
     * @param string $parentEmailAddress
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkInputBirthdateAndEmailAddressType( $birthdate, $emailAddress, $parentEmailAddress, $errors )
    {
        $from = new DateTime( $birthdate );
        $to   = new DateTime( 'today' );
        $age = $from->diff( $to )->y;

        if ( $age < 13 && ! $parentEmailAddress ) {
            $errors->setError( 'parentEmailAddress', 'PARENT_EMAIL_ADDRESS_MUST_BE_GIVEN' );
        } else if ( $age >= 13 && ! $emailAddress ) {
            $errors->setError( 'emailAddress', 'EMAIL_ADDRESS_MUST_BE_GIVEN' );
        }
    }

    /**
     * Check the the birthdate is at least a teen (used in social login)
     *
     * @param string $birthdate
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkInputBirthdateIsTeen( $birthdate, $errors )
    {
        $from = new DateTime( $birthdate );
        $to   = new DateTime( 'today' );
        $age = $from->diff( $to )->y;

        if ( $age < 13 ) {
            $errors->setError( 'birthdate', 'USER_MUST_BE_TEEN_TO_USE_SOCIAL_LOGIN' );
        }
    }

    /**
     * Check the user can login with social
     *
     * @param BeMaverick_User $user
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanUseSocialLogin( $user, $errors )
    {
        if ( $user->isParent() ) {
            $errors->setError( '', 'PARENT_NOT_ALLOWED_TO_USE_SOCIAL_LOGIN' );
        }
    }

    /**
     * Check the user can delete response
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_Response $response
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanDeleteResponse( $user, $response, $errors )
    {
        if ( ! $response || $response->getUser() != $user ) {
            $errors->setError( 'responseId', 'USER_DOES_NOT_HAVE_PERMISSIONS_TO_DELETE_RESPONSE' );
        }
    }

    /**
     * Check the user can favorite a response
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_Challenge $challenge
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanFavoriteResponse( $user, $challenge, $errors )
    {
        if (  ( $challenge && $challenge->getUserId() != $user->getId() )) {
            $errors->setError( 'responseId', 'USER_DOES_NOT_HAVE_PERMISSIONS_TO_FAVORITE_RESPONSE' );
        }
    }

    /**
     * Check that reset password code is valid
     *
     * @param BeMaverick_Site $site
     * @param string $userIdentification
     * @param string $timestamp
     * @param string $signature
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkValidResetPasswordCode( $site, $userIdentification, $timestamp, $signature, $errors )
    {
        $systemConfig = $site->getFactory()->getSystemConfig();

        $salt = $systemConfig->getSetting( 'SYSTEM_RESET_PASSWORD_SALT' );

        if ( md5( $userIdentification . $timestamp . $salt ) != $signature ) {
            $errors->setError( '', 'RESET_PASSWORD_CODE_IS_INVALID' );
        }

        if ( $timestamp < time() - 60*60*7 ) {
            $errors->setError( '', 'RESET_PASSWORD_CODE_IS_EXPIRED' );
        }
    }

    /**
     * Check that verify account code is valid
     *
     * @param BeMaverick_Site $site
     * @param string $username
     * @param string $timestamp
     * @param string $signature
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkValidVerifyAccountCode( $site, $username, $timestamp, $signature, $errors )
    {
        $systemConfig = $site->getFactory()->getSystemConfig();

        $salt = $systemConfig->getSetting( 'SYSTEM_VERIFY_ACCOUNT_SALT' );

        if ( md5( $username . $timestamp . $salt ) != $signature ) {
            $errors->setError( '', 'VERIFY_ACCOUNT_CODE_IS_INVALID' );
        }

        if ( $timestamp < time() - 60*60*24*30 ) {
            $errors->setError( '', 'VERIFY_ACCOUNT_CODE_IS_EXPIRED' );
        }
    }

    private function _fileInputOrObject($files, $field, $object, $method) {
        // check input
        if ( !empty($files[$field]['tmp_name'] ) ) {
            return true;
        }

        // check if the object is populated
        if ( empty($object) ) {
            return false;
        }

        // check if method exists
        if ( ! method_exists( $object, $method ) ) {
            return false;
        }

        // check if the method can be called
        $return = call_user_func_array(array($object, $method), array()) ? true : false;
        return $return;
    }

    /**
     * Check the challenge can be published
     *
     * @param BeMaverick_Input $input
     * @param array $files
     * @param BeMaverick_Challenge $challenge
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkChallengeCanBePublished( $input, $files, $challenge, $errors )
    {
        $isImageChallenge = $input->challengeType == BeMaverick_Challenge::CHALLENGE_TYPE_IMAGE;

        // All challenges
        if (!$input->mentorId && !$input->username) {
            $errors->setError( 'userId', 'CHALLENGE_OWNER_REQUIRED' );
        }

        if ($isImageChallenge) { // Image Challenge Type
            // Image Field
            if ( ! $this->_fileInputOrObject($files, 'image', $challenge, 'getImage') ) {
                $errors->setError( 'image', 'CHALLENGE_IMAGE_REQUIRED' );
            }
        } else { // Video Challenge Type
            // Video Field
            if ( ! $this->_fileInputOrObject($files, 'video', $challenge, 'getVideo') ) {
                $errors->setError( 'video', 'CHALLENGE_VIDEO_REQUIRED' );
            }
            // Main Image Field
            if ( ! $this->_fileInputOrObject($files, 'mainImage', $challenge, 'getMainImage') ) {
                $errors->setError( 'mainImage', 'CHALLENGE_MAIN_IMAGE_REQUIRED' );
            }
        }

    }

    /**
     * Check if the user can follow this other user
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_User $followingUser
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanFollowThisUser( $user, $followingUser, $errors )
    {
        if ( $user == $followingUser ) {
            $errors->setError( 'followingUserId', 'USER_CANNOT_FOLLOW_THIS_USER' );
        }
    }

    /**
     * Check if the user can edit the status of response
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_Response $response
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanEditResponseStatus( $user, $response, $errors )
    {
        // if user is the owner of the response OR the parent of the owner of the response, then all good
        $responseUser = $response->getUser();

        if ( $responseUser != $user && ! $user->isParentOfKid( $responseUser ) ) {
            $errors->setError( '', 'USER_CANNOT_EDIT_STATUS_OF_RESPONSE' );
        }
    }

    /**
     * Check if the user can share the response
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_Response $response
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanShareResponse( $user, $response, $errors )
    {
        // if user is the owner of the response OR the parent of the owner of the response, then all good
        $responseUser = $response->getUser();

        if ( $responseUser != $user && ! $user->isParentOfKid( $responseUser ) ) {
            $errors->setError( '', 'USER_CANNOT_SHARE_RESPONSE' );
        }
    }


    /**
     * Check if the user can report a response
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_Response $response
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanReportResponse( $user, $response, $errors )
    {
        //todo Need to check if the user is eligible to flag content
    }

    /**
     * Check if the user can report a response
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_User $flaggedUser
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanReportUser( $user, $flaggedUser, $errors )
    {
        //todo Need to check if the user is eligible to flag another user
    }

    /**
     * Check if the user can view the response
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_Response $response
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanViewResponse( $user, $response, $errors )
    {
        // if the user is not logged in (i.e. this user is null) and response is not public,
        // then they can't view the response
        if ( ! $user && ! $response->isPublic() ) {
            $errors->setError( '', 'USER_CANNOT_VIEW_RESPONSE' );
        }
    }

    /**
     * Check the request came from same origin
     *
     * @param Asp_Config_System $systemConfig
     * @param Zend_Http_Request $request
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkCSRFValidation( $systemConfig, $request, $errors )
    {
        $csrfHost = $systemConfig->getSetting( 'SYSTEM_CSRF_HOST' );

        // first try to get the host from the origin header
        $refererUrl = $request->getServer( 'HTTP_ORIGIN' );

        // if not found, then try the referer header
        if ( ! $refererUrl ) {
            $refererUrl = $request->getServer( 'HTTP_REFERER' );
        }

        $refererHost = null;

        // if we have a referer url, then get just the host
        if ( $refererUrl ) {
            if ( $parts = parse_url( $refererUrl ) ) {
                $refererHost = $parts['host'];
            }
        }

        // if there is no refererHost OR the csrf host isn't in the referer host
        if ( ! $refererHost || strpos( $refererHost, $csrfHost ) === false ) {
            $errors->setError( '', 'REQUEST_FAILED_CSRF_CHECK' );
        }
    }

    /**
     * Check the request came from same origin
     *
     * @param Asp_Site $site
     * @param string $accessToken
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkCSRFAccessToken( $site, $accessToken, $errors )
    {
        // check the access token if valid
        if ( ! $accessToken ) {
            $errors->setError( 'accessTokenInvalid', 'ACCESS_TOKEN_NOT_FOUND' );
            return;
        }

        // we don't need the token info, but instead just care if the errors will be populated
        $this->_getTokenInfoFromOAuthToken( $site, $accessToken, true, $errors );
    }

    /**
     * Check the request method is post
     *
     * @param Zend_Http_Request $request
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkRequestMethodPost( $request, $errors )
    {
        if ( $request->getServer( 'REQUEST_METHOD' ) != 'POST' ) {
            $errors->setError( '', 'REQUEST_METHOD_NOT_POST' );
        }
    }


    /**
     * Check the loginuser can edit the current user
     *
     * @param Zend_Http_Request $request
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkLoginUserCanChangeUserSettings( $loginUser, $user, $errors )
    {
        if ( $loginUser != $user ) {
            $errors->setError( '', 'NO_PERMISSION_TO_VIEW_PAGE' );
        }
    }

    /**
     * Check the oauth header access token is valid and return appropriate info
     *
     * @param BeMaverick_Site $site
     * @param string $accessType - read, write, null
     * @param bool $requireUser - If we are required to extract the user out of the JWT Authorization header.
     * @param Sly_Errors $errors
     * @return array|null
     */
    public function checkOAuthToken( $site, $accessType, $requireUser, $errors, $allowDevel=true )
    {
        $accessToken = $this->_getOAuthAccessTokenFromRequest();

        // make it easier for testing on devel environment
        if ( ! $accessToken && $site->getSystemConfig()->getEnvironment() == 'devel' && $allowDevel) {
            return array(
                'app' => $site->getApp( 'test_key' ),
                'user' => $site->getUser( 1 ),
            );
        }

        if ( ! $accessToken ) {
            $errors->setError( 'accessTokenInvalid', 'ACCESS_TOKEN_NOT_FOUND' );
            return;
        }

        $tokenInfo = $this->_getTokenInfoFromOAuthToken( $site, $accessToken, $requireUser, $errors );

        // do an extra check to make sure this app has proper access type
        if ( isset( $tokenInfo['app'] ) ) {
            $this->checkAppAccess( $tokenInfo['app'], $accessType, $errors );

            if ( $errors->hasErrors() ) {
                return null;
            }
        }

        // check if user's account is revoked, deleted, draft
        if ( isset( $tokenInfo['user'] ) ) {
            if ( $tokenInfo['user']->getStatus() == BeMaverick_User::USER_STATUS_REVOKED ) {
                if ($tokenInfo['user']->getRevokedReason() == 'parental') {
                    $errors->setError( 'userRevoked', 'parental' );
                } else {
                    $errors->setError( 'userRevoked', 'admin' );
                }

                return $tokenInfo;

            } else if ( $tokenInfo['user']->getStatus() == BeMaverick_User::USER_STATUS_INACTIVE ) {
                $errors->setError( 'userInactive', 'User account is inactive.' );
                return $tokenInfo;

            } else if ( $tokenInfo['user']->getStatus() == BeMaverick_User::USER_STATUS_DELETED ) {
                $errors->setError( 'userDeleted', 'User account is deleted.' );
                return $tokenInfo;

            } else if ( $tokenInfo['user']->getStatus() == BeMaverick_User::USER_STATUS_DRAFT ) {
                $errors->setError( 'userInDraft', 'User account is in draft mode.' );
                return $tokenInfo;
            }
        }

        return $tokenInfo;
    }

    /**
     * Get the token information from the original oauth token
     *
     * @param BeMaverick_Site $site
     * @param string $accessToken
     * @param boolean $requireUser
     * @param Sly_Errors $errors
     *
     * @return hash
     */
    private function _getTokenInfoFromOAuthToken( $site, $accessToken, $requireUser, $errors )
    {
        // Load the OAuth dependencies on demand now.
        require_once( BEMAVERICK_COMMON_ROOT_DIR . '/config/autoload_oauth_dependencies.php' );

        $userId = null;

        // Decoding token now.
        try {
            $accessTokenManger = new Sly_OAuth_AccessTokenManager();
            $accessTokenManger->setAccessTokenSigningSecret( $site->getSystemConfig()->getAccessTokenSigningSecret() );
            $payload = (array) $accessTokenManger->decodeToken( $accessToken );

            // 'iss' field with the app key **must** be there.
            $appKey = $payload['iss'];

            if ( $requireUser && !isset( $payload['sub'] ) ) {
                throw new LogicException( 'User required. User not found in the token.' );
            }

            // Gets the user id out of the token,
            // if we are required to obtain a user or there's one
            if ( isset( $payload['sub'] ) ) {
                $userId = $payload['sub'];
            }
        }
        catch (\Firebase\JWT\ExpiredException $ex ) {
            $errors->setError( 'accessTokenExpired', 'ACCESS_TOKEN_EXPIRED' );
        }
        catch (Exception $ex ) {
            $errors->setError( 'accessTokenInvalid', 'ACCESS_TOKEN_INVALID' );
            $errors->setError( 'accessTokenInvalidReason', $ex->getMessage() );
        }

        if ( $errors->hasErrors() ) {
            return null;
        }

        // check the app key access type
        $tokenInfo = array(
            'app' => $site->getApp( $appKey ),
        );

        if ( $userId ) {
            $tokenInfo['user'] = $site->getUser( $userId );
        }

        return $tokenInfo;
    }

    /**
     * Get the oauth access token from the request
     *
     * @return string|null
     */
    private function _getOAuthAccessTokenFromRequest()
    {
        $front = Zend_Controller_Front::getInstance();

        $request = $front->getRequest();

        // lets allow clients to send the access token via a request param instead of through the
        // authorization header
        $accessToken = $request ? $request->getParam( 'accessToken' ) : null;

        if ( $accessToken ) {
            return $accessToken;
        }

        $authorizationHeader = $request ? $request->getHeader( 'Authorization' ) : null;

        // There's a bug in android webview client for example where authorization header label
        // is lower-cased. Postman's curl code has a similar bug too. We will check one more time.
        if ( ! $authorizationHeader ) {
            $authorizationHeader = $request ? $request->getHeader( 'authorization' ) : null;
        }

        if ( $authorizationHeader ) {

            // we don't need the Bearer part for the access token
            return str_replace( 'Bearer ', '', trim( $authorizationHeader ) );
        }

        return null;
    }

    /**
     * Public wrapper for _getOAuthAccessTokenFromRequest
     *
     * @return string|null
     */
    public function getToken() {
        return self::_getOAuthAccessTokenFromRequest();
    }

    /**
     * Check the user can favorite a response
     *
     * @param BeMaverick_User $user
     * @param BeMaverick_Response $response
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUserCanBadgeResponse( $user, $response, $errors )
    {
        if ( $user->getUserType() != BeMaverick_User::USER_TYPE_KID ) {
            $errors->setError( 'responseId', 'USER_DOES_NOT_HAVE_PERMISSIONS_TO_BADGE_RESPONSE' );
        }
    }

    /**
     * Check if the response can be made public
     *
     * @param String $moderationStatus
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkModerationStatus(  $moderationStatus, $errors )
    {
        // if the response is rejected or queuedforapproval from the moderation, return an error.
        if ( $moderationStatus != 'allow' ) {
            $errors->setError( 'inAppropriateResponse', 'RESPONSE_FAILED_MODERATION_CHECK' );
        }
    }

    /**
     * Check if the email address can be used for a parent
     *
     * @param BeMaverick_Site $site
     * @param string $emailAddress
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkUnusedOrValidParentEmail( $site, $emailAddress, $errors )
    {
        // check if the email address is unused
        $emailAddressAvailable = !$site->isEmailAddressTaken( $emailAddress );
        if ( $emailAddressAvailable ) {
            return;
        }

        // check if the email address belongs to a parent
        $user = $site->getUserByEmailAddress( $emailAddress );
        $userType = $user->getUserType();
        if (  $userType !== BeMaverick_User::USER_TYPE_PARENT ) {
            $errors->setError( 'parentEmailAddress', 'EMAIL_ADDRESS_IS_NOT_AVAILABLE_PARENT' );
        }

    }

    /**
     * Check that the SMS login code is valid
     *
     * @param BeMaverick_Site $site
     * @param string $phoneNumber
     * @param string $code
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkValidSMSLoginCode( $site, $phoneNumber, $code, $errors )
    {
        if ( BeMaverick_SMSUtil::getSmsCode( $phoneNumber ) != $code ) {
            $errors->setError( 'code', 'SMS_CODE_IS_INVALID' );
        }
    }

    /**
     * Check that the input is a valid json
     *
     * @param hash $json
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkValidJson( $json, $errors )
    {
        if ( !json_decode( $json, true ))  {
            $errors->setError( "INVALID_JSON", 'Syntax Error. Invalid JSON' );
        }
    }

    /**
     * Check if the phone number is valid
     *
     * @param BeMaverick_Site $site
     * @param string $phoneNumber
     * @param Sly_Errors $errors
     * @return void
     */
    public function checkValidPhoneNumber( $site, $phoneNumber, $errors )
    {
        if ( ! BeMaverick_SMSUtil::isValidPhoneNumber( $site, $phoneNumber ) ) {
            $errors->setError( "INPUT_INVALID_PHONE_NUMBER", 'INPUT_INVALID_PHONE_NUMBER' );
        }
    }

    public function checkJpegOnly($fieldname, $errors) {
        $isValid = false;
        $validTypes = [ 'image/jpeg', 'image/jpg', 'image/pjpeg' ];
        if ( $_FILES[$fieldname] ) {
            $type = $_FILES[$fieldname]['type'];
            $isValid = in_array($type, $validTypes);
        }

        if (!$isValid) {
            $errors->setError( $fieldname, 'INPUT_INVALID_JPEG_ONLY' );
        } 
    }

}

?>
