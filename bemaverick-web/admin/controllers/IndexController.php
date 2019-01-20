<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/S3.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Service/Amazon/Transcoder.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Util.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class IndexController extends BeMaverick_Controller_Base
{

    /**
     * The home page
     *
     * @return void
     */
    public function indexAction()
    {
        return $this->renderPage( 'home' );
    }

    /**
     * The challenges page
     *
     * @return void
     */
    public function challengesAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        // set the input params
        $optionalParams = array(
            'challengeStatus',
            'query',
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

        return $this->renderPage( 'challenges' );
    }

    /**
     * The challenge add page
     *
     * @return void
     */
    public function challengeaddAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        // set the input params
        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'challengeAdd' );
    }

    /**
     * The challenge add confirm page
     *
     * @return void
     */
    public function challengeaddconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;

        // set the input params
        $requiredParams = array(
            'challengeStatus',
            'startTime',
            'endTime',
        );

        $optionalParams = array(
            'username',
            'mentorId',
            'challengeTitle',
            'challengeType',
            'challengeDescription',
            'challengeLinkUrl',
            'tagNames',
            'hideFromStreams',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $input->challengeStatus == 'published' ) {
            $validator->checkChallengeCanBePublished( $input, $_FILES, null, $errors );
        }

        // Limit image filetypes to JPEG
        if ( @$_FILES['image']['tmp_name'] ) {
            $validator->checkJpegOnly('image', $errors);
        }
        if ( @$_FILES['cardImage']['tmp_name'] ) {
            $validator->checkJpegOnly('cardImage', $errors);
        }
        if ( @$_FILES['mainImage']['tmp_name'] ) {
            $validator->checkJpegOnly('mainImage', $errors);
        }

        // Display Errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $mentorId = $input->mentorId;
        $username = $input->username;
        $challengeStatus = $input->challengeStatus;
        $challengeType = $input->challengeType ? $input->challengeType : BeMaverick_Challenge::CHALLENGE_TYPE_VIDEO;
        $challengeTitle = $input->getUnescaped( 'challengeTitle' );
        $challengeTitle = $challengeTitle ?: '';
        $challengeDescription = $input->challengeDescription ? $input->getUnescaped( 'challengeDescription' ) : null;
        $challengeLinkUrl = $input->challengeLinkUrl ? $input->getUnescaped( 'challengeLinkUrl' ) : null;
        $startTime = $input->startTime;
        $endTime = $input->endTime;
        $tagNames = $input->tagNames ? explode( ',', $input->getUnescaped( 'tagNames' ) ) : array();
        $isHideFromStreams = $input->hideFromStreams == 1 ? true : false;

        $mainImage = null;
        if ( @$_FILES['mainImage']['tmp_name'] ) {
            $mainImage = BeMaverick_Image::saveOriginalImage( $site, 'mainImage', $errors );
        }

        $cardImage = null;
        if ( @$_FILES['cardImage']['tmp_name'] ) {
            $cardImage = BeMaverick_Image::saveOriginalImage( $site, 'cardImage', $errors );
        }

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $user = $mentorId ? $site->getUser( $mentorId ) : $site->getUserByUsername($username);

        $challenge = $site->createChallenge( $user, $challengeTitle, $challengeDescription );

        $challenge->setLinkUrl( $challengeLinkUrl );
        $challenge->setStartTime( $startTime );
        $challenge->setEndTime( $endTime );
        $challenge->setStatus( $challengeStatus );
        $challenge->setTagNames( $tagNames );
        $challenge->setChallengeType( $challengeType );
        $challenge->setHideFromStreams( $isHideFromStreams );

        if ( $challengeDescription ) {
            // set challenge hashtags by parsing description
            $challenge->setHashtags( $challengeDescription );
        }

        $video = $this->_createVideoFromUploadedFile( $site, $challenge->getId(), 'challenge' );

        $image = null;
        if ( @$_FILES['image']['tmp_name'] ) {
            $image = BeMaverick_Image::saveOriginalImage( $site, 'image', $errors );
        }

        if ( $video ) {
            $challenge->setVideo( $video );
        }

        if ( $image ) {
            $challenge->setImage( $image );
        }

        if ( $mainImage ) {
            $challenge->setMainImage( $mainImage );
        }

        if ( $cardImage ) {
            $challenge->setCardImage( $cardImage );
        }

        // send response data to sns publish
        $challenge->publishChange( $site, 'CREATE' );
        
        // redirect to page
        $params = array(
            'confirmPage' => 'challengeAddConfirm',
        );

        return $this->_redirect( $site->getUrl( 'challenges', $params ) );
    }

    /**
     * The challenge edit page
     *
     * @return void
     */
    public function challengeeditAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;

        // set the input params
        $requiredParams = array(
            'challengeId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $challenge = $site->getChallenge( $input->challengeId );

        $this->view->challenge = $challenge;

        return $this->renderPage( 'challengeEdit' );
    }

    /**
     * The challenge edit confirm page
     *
     * @return void
     */
    public function challengeeditconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */

        // set the input params
        $requiredParams = array(
            'challengeId',
            'challengeStatus',
            'startTime',
            'endTime',
        );

        $optionalParams = array(
            'username',
            'mentorId',
            'challengeTitle',
            'challengeDescription',
            'challengeLinkUrl',
            'tagNames',
            'challengeType',
            'hideFromStreams',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        $challengeId = $input->challengeId;
        $challenge = $site->getChallenge( $challengeId );

        if ( $input->challengeStatus == 'published' ) {
            $validator->checkChallengeCanBePublished( $input, $_FILES, $challenge, $errors );
        }

        // Limit image filetypes to JPEG
        if ( @$_FILES['image']['tmp_name'] ) {
            $validator->checkJpegOnly('image', $errors);
        }
        if ( @$_FILES['cardImage']['tmp_name'] ) {
            $validator->checkJpegOnly('cardImage', $errors);
        }
        if ( @$_FILES['mainImage']['tmp_name'] ) {
            $validator->checkJpegOnly('mainImage', $errors);
        }

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $mentorId = $input->mentorId;
        $username = $input->username;

        if ( $username ) {
            $user = $site->getUserByUsername($username);
            $userId = $user->getId();
        }

        $challengeTitle = $input->getUnescaped( 'challengeTitle' );
        $challengeType = $input->challengeType ? $input->challengeType : BeMaverick_Challenge::CHALLENGE_TYPE_VIDEO;
        $challengeDescription = $input->challengeDescription ? $input->getUnescaped( 'challengeDescription' ) : null;
        $challengeLinkUrl = $input->challengeLinkUrl ? $input->getUnescaped( 'challengeLinkUrl' ) : null;
        $challengeStatus = $input->challengeStatus;
        $startTime = $input->startTime;
        $endTime = $input->endTime;
        $tagNames = $input->tagNames ? explode( ',', $input->getUnescaped( 'tagNames' ) ) : array();
        $isHideFromStreams = $input->hideFromStreams == 1 ? true : false;

        $mainImage = null;
        if ( @$_FILES['mainImage']['tmp_name'] ) {
            $mainImage = BeMaverick_Image::saveOriginalImage( $site, 'mainImage', $errors );
        }

        $cardImage = null;
        if ( @$_FILES['cardImage']['tmp_name'] ) {
            $cardImage = BeMaverick_Image::saveOriginalImage( $site, 'cardImage', $errors );
        }

        $video = $this->_createVideoFromUploadedFile( $site, $challenge->getId(), 'challenge' );

        $image = null;
        if ( @$_FILES['image']['tmp_name'] ) {
            $image = BeMaverick_Image::saveOriginalImage( $site, 'image', $errors );
        }

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $challenge->setTitle( $challengeTitle );
        $challenge->setChallengeType( $challengeType );
        $challenge->setDescription( $challengeDescription );
        $challenge->setLinkUrl( $challengeLinkUrl );
        $challenge->setUserId( $mentorId );
        $challenge->setStatus( $challengeStatus );
        $challenge->setStartTime( $startTime );
        $challenge->setEndTime( $endTime );
        $challenge->setTagNames( $tagNames );
        $challenge->setHideFromStreams( $isHideFromStreams );

        if ( $challengeDescription ) {
            // set challenge hashtags by parsing description
            $challenge->setHashtags( $challengeDescription );
        } else {
            $challenge->setHashtags( null );
        }

        if ( $mentorId ) {
            $challenge->setUserId( $mentorId );
        } else if ( $userId ) {
            $challenge->setUserId( $userId );
        }

        if ( $video ) {
            $challenge->setVideo( $video );
        }

        if ( $image ) {
            $challenge->setImage( $image );
        }

        if ( $mainImage ) {
            $challenge->setMainImage( $mainImage );
        }

        if ( $cardImage ) {
            $challenge->setCardImage( $cardImage );
        }

        // send response data to sns publish
        if ( in_array( $challengeStatus, ['hidden', 'draft', 'deleted'] ) ) {
            $challenge->publishChange( $site, 'DELETE' );
        } else {
            $challenge->publishChange( $site, 'UPDATE' );
        }

        // redirect to page
        $params = array(
            'confirmPage' => 'challengeEditConfirm',
        );

        return $this->_redirect( $site->getUrl( 'challenges', $params ) );
    }

    /**
     * The contents page
     *
     * @return void
     */
    public function contentsAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        // set the input params
        $optionalParams = array(
            'contentType',
            'contentStatus',
            'username',
            'query',
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

        return $this->renderPage( 'contents' );
    }

    /**
     * The content add page
     *
     * @return void
     */
    public function contentaddAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        // set the input params
        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'contentAdd' );
    }

    /**
     * The content add confirm page
     *
     * @return void
     */
    public function contentaddconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;      /* @var BeMaverick_Site $site */

        // set the input params
        $requiredParams = array(
            'contentType',
            'mentorId',
            'contentTitle',
            'contentStatus',
        );

        $optionalParams = array(
            'contentDescription',
            'tagNames',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $contentType = $input->contentType;
        $contentStatus = $input->contentStatus;
        $contentTitle = $input->getUnescaped( 'contentTitle' );
        $contentDescription = $input->contentDescription ? $input->getUnescaped( 'contentDescription' ) : null;
        $mentorId = $input->mentorId;
        $tagNames = $input->tagNames ? explode( ',', $input->getUnescaped( 'tagNames' ) ) : array();



        $video = null;
        $image = null;

        if ( $contentType == BeMaverick_Content::CONTENT_TYPE_VIDEO ) {

            $video = $this->_createVideoFromUploadedFile( $site, BeMaverick_Util::generateUUID(), 'content', "file" );

        } else if ( $contentType == BeMaverick_Content::CONTENT_TYPE_IMAGE ) {

            $image = BeMaverick_Image::saveOriginalImage( $site, "file", $errors );
        }

        $file = null;
        if ( @$_FILES['coverImage']['tmp_name'] ) {
            $coverImage = BeMaverick_Image::saveOriginalImage( $site, 'coverImage', $errors );
        }

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $user = $site->getUser( $mentorId );

        $content = $site->createContent( $contentType, $user, $video, $image,   $contentTitle, $contentDescription, false );

        $content->setStatus( $contentStatus );
        $content->setTagNames( $tagNames );

        if ( $coverImage ) {
            $content->setCoverImage( $coverImage );
        }

        // redirect to page
        $params = array(
            'confirmPage' => 'contentAddConfirm',
        );

        return $this->_redirect( $site->getUrl( 'contents', $params ) );
    }

    /**
     * The content edit page
     *
     * @return void
     */
    public function contenteditAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;

        // set the input params
        $requiredParams = array(
            'contentId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $content = $site->getContent( $input->contentId );

        $this->view->content = $content;

        return $this->renderPage( 'contentEdit' );
    }

    /**
     * The content edit confirm page
     *
     * @return void
     */
    public function contenteditconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */

        // set the input params
        $requiredParams = array(
            'contentId',
            'contentType',
            'contentTitle',
            'mentorId',
            'contentStatus',
        );

        $optionalParams = array(
            'contentDescription',
            'tagNames',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }
        $content = $site->getContent( $input->contentId );

        $contentType = $input->contentType;
        $contentTitle = $input->getUnescaped( 'contentTitle' );
        $contentDescription = $input->contentDescription ? $input->getUnescaped( 'contentDescription' ) : null;
        $mentorId = $input->mentorId;
        $contentStatus = $input->contentStatus;
        $tagNames = $input->tagNames ? explode( ',', $input->getUnescaped( 'tagNames' ) ) : array();

        $video = null;
        $image = null;

        if ( $contentType == BeMaverick_Content::CONTENT_TYPE_VIDEO ) {

            $video = $this->_createVideoFromUploadedFile( $site, BeMaverick_Util::generateUUID(), 'content', "file" );

        } else if ( $contentType == BeMaverick_Content::CONTENT_TYPE_IMAGE ) {

            $image = BeMaverick_Image::saveOriginalImage( $site, "file", $errors );
        }

        $file = null;
        if ( @$_FILES['coverImage']['tmp_name'] ) {
            $coverImage = BeMaverick_Image::saveOriginalImage( $site, 'coverImage', $errors );
        }

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $content->setContentType( $contentType );
        $content->setTitle( $contentTitle );
        $content->setDescription( $contentDescription );
        $content->setUserId( $mentorId );
        $content->setStatus( $contentStatus );
        $content->setTagNames( $tagNames );

        if ( $video ) {
            $content->setVideo( $video );
        }

        if ( $image ) {
            $content->setImage( $image );
        }

        if ( $coverImage ) {
            $content->setCoverImage( $coverImage );
        }

        // redirect to page
        $params = array(
            'confirmPage' => 'contentEditConfirm',
        );

        return $this->_redirect( $site->getUrl( 'contents', $params ) );
    }

    /**
     * The users page
     *
     * @return void
     */
    public function usersAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        // set the input params
        $optionalParams = array(
            'userType',
            'userStatus',
            'query',
            'startAge',
            'endAge',
            'startRegisteredDate',
            'endRegisteredDate',
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

        return $this->renderPage( 'users' );
    }

    /**
     * The user add page
     *
     * @return void
     */
    public function useraddAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'userAdd' );
    }

    /**
     * The user add confirm page
     *
     * @return void
     */
    public function useraddconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;               /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;     /* @var BeMaverick_Validator $validator */

        // set the input params
        $requiredParams = array(
            'username',
            'userType',
            'password',
        );

        $optionalParams = array(
            'emailAddress',
            'parentEmailAddress',
            'birthdate',
            'firstName',
            'lastName',
            'bio',
            'isVerified',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $profileImage = null;
        if ( @$_FILES['profileImage']['tmp_name'] ) {
            $profileImage = BeMaverick_Image::saveOriginalImage( $site, 'profileImage', $errors );
        }

        // get the variables
        $username = $input->username;
        $userType = $input->userType;
        $password = $input->getUnescaped( 'password' );
        $birthdate = $input->birthdate;
        $emailAddress = $input->emailAddress ? $input->emailAddress : null;
        $parentEmailAddress = $input->parentEmailAddress ? $input->parentEmailAddress : null;
        $firstName = $input->firstName ? $input->getUnescaped( 'firstName' ) : null;
        $lastName = $input->lastName ? $input->getUnescaped( 'lastName' ) : null;
        $bio = $input->bio ? $input->getUnescaped( 'bio' ) : null;
        $isVerified = $input->isVerified;

        // perform the checks
        $validator->checkUsernameAvailable( $site, $username, $errors );
        if ( $emailAddress ) {
            $validator->checkEmailAddressAvailable( $site, $emailAddress, $errors );
        }
        if ( $parentEmailAddress ) {
            $validator->checkEmailAddressAvailable( $site, $parentEmailAddress, $errors );
        }
        if ( $userType == 'kid' ) {
            $validator->checkInputBirthdateAndEmailAddressType( $input->birthdate, $input->emailAddress, $input->parentEmailAddress, $errors );
        } else {
            $validator->checkEmailAddressProvided( $site, $emailAddress, $parentEmailAddress, $errors );
        }

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        if ( $userType == 'kid' ) {
            $user = $site->createKid( $username, $password, $birthdate, $emailAddress, $parentEmailAddress );
        } else {
            $user = $site->createMentor( $username, $password, $firstName, $lastName );
        }

        if ( $firstName ) {
            $user->setFirstName( $firstName );
        }

        $user->setLastName( $lastName );
        $user->setBio( $bio );
        $user->setEmailVerified(true); // default verified when the user is added from admin
        $user->setVerified( $isVerified );

        if ( $profileImage ) {
            $user->setProfileImage( $profileImage );
        }

        if ($bio) {
            $user->setHashtags( $bio );
        }

        // send response data to sns publish
        $user->publishChange( 'CREATE' );

        // redirect to page
        $params = array(
            'userId'      => $user->getId(),
            'confirmPage' => 'userAddConfirm',
        );

        return $this->_redirect( $site->getUrl( 'users', $params ) );
    }

    /**
     * The kid edit page
     *
     * @return void
     */
    public function usereditAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $user = $site->getUser( $input->userId );

        $this->view->user = $user;

        return $this->renderPage( 'userEdit' );
    }

    /**
     * The kid edit confirm page
     *
     * @return void
     */
    public function usereditconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;               /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;     /* @var BeMaverick_Validator $validator */

        // set the input params
        $requiredParams = array(
            'userId',
            'userType',
            'userStatus',
            'userRevokedReason',
        );

        $optionalParams = array(
            'username',
            'emailAddress',
            'parentEmailAddress',
            'firstName',
            'lastName',
            'bio',
            'isVerified',
            'birthdate',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $userId = $input->userId;
        $userType = $input->userType;
        $userStatus = $input->userStatus;
        $userRevokedReason = $input->userRevokedReason;
        $username = $input->username;
        $birthdate = $input->birthdate;
        $emailAddress = $input->emailAddress ? $input->emailAddress : null;
        $parentEmailAddress = $input->parentEmailAddress ? $input->parentEmailAddress : null;
        $firstName = $input->firstName ? $input->getUnescaped( 'firstName' ) : null;
        $lastName = $input->lastName ? $input->getUnescaped( 'lastName' ) : null;
        $bio = $input->bio ? $input->getUnescaped( 'bio' ) : null;
        $isVerified = $input->isVerified ? true : false;

        $user = $site->getUser( $userId );

        // check if trying to change non-parent user into parent
        if ( $user->getUserType() != 'parent' && $userType == 'parent' ) {
            $errors->setError( 'userType', 'USERS_CANNOT_BE_CHANGED_TO_PARENT' );
        }

        // check to make sure at least one email address is present
        $validator->checkEmailAddressProvided( $site, $emailAddress, $parentEmailAddress, $errors );

        if ( ( $userType == 'kid' || $userType == 'catalyst' ) && $username != $user->getUsername() ) {
            $validator->checkUsernameAvailable( $site, $username, $errors );
        }

        if ( $emailAddress != $user->getEmailAddress() ) {
            $validator->checkEmailAddressAvailable( $site, $input->emailAddress, $errors );
        }

        // email address is no longer needed since people can sign up via sms or social login without an email
        //$validator->checkInputBirthdateAndEmailAddressType( $input->birthdate, $input->emailAddress, $input->parentEmailAddress, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // if the status of the kid changes, we may need to deactivate or reactive
        $hasStatusChange = false;
        if ( $userStatus != $user->getStatus() ) {
            $hasStatusChange = true;
        }

        if ($userRevokedReason == '') {
            $userRevokedReason = null;
        }

        if ( $userType == 'kid' ) {
            if ( $birthdate ) {
                $user->setBirthdate($birthdate);
            } else {
                $errors->setError( 'birthdate', 'USER_TYPE_KID_MUST_BE_HAVE_BIRTHDATE' );
            }

            if ( $errors->hasErrors() ) {
                return $this->renderPage( 'errors' );
            }
        }

        $user->setRevokedReason( $userRevokedReason );
        $user->setUsername( $username );
        $user->setUserType( $userType );
        $user->setEmailAddress( $emailAddress );
        $user->setParentEmailAddress( $parentEmailAddress );
        $user->setFirstName( $firstName );
        $user->setLastName( $lastName );
        $user->setBio( $bio );
        $user->setVerified( $isVerified );
        
        if ($bio) {
            $user->setHashtags( $bio );
        } else {
            $user->setHashtags( null );
        }

        if ( $userStatus == BeMaverick_User::USER_STATUS_INACTIVE || $userStatus == BeMaverick_User::USER_STATUS_REVOKED || $userStatus == BeMaverick_User::USER_STATUS_DELETED ) {
            $user->deactivateAccount();
        } else if ( $userStatus == BeMaverick_User::USER_STATUS_ACTIVE ) {
            $user->reactivateAccount();
        }
        
        $user->setStatus( $userStatus );
        $user->save();

        // send response data to sns publish
        $publishAction = $userStatus == 'deleted' ? 'DELETE' : 'UPDATE';
        $user->publishChange( $publishAction );

        // redirect to page
        $params = array(
            'confirmPage' => 'kidEditConfirm',
        );

        return $this->_redirect( $site->getUrl( 'users', $params ) );
    }

    /**
     * The kid delete confirm page
     *
     * @return void
     */
    public function userdeleteconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                     /* @var BeMaverick_Site $site */
        $systemConfig = $this->view->systemConfig;

        if ( $systemConfig->getEnvironment() == 'production' ) {
            $errors->setError( '', 'DELETE_KID_NOT_ALLOWED_IN_PRODUCTION' );
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $user = $site->getUser( $input->userId );

        $user->delete();

        // redirect to page
        $params = array(
            'confirmPage' => 'userDeleteConfirm',
        );

        return $this->_redirect( $site->getUrl( 'users', $params ) );
    }

    /**
     * The kid delete confirm page
     *
     * @return void
     */
    public function userremoveimageconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                     /* @var BeMaverick_Site $site */
        $systemConfig = $this->view->systemConfig;

        // set the input params
        $requiredParams = array(
            'userId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $user = $site->getUser( $input->userId );

        $user->setProfileImage(null);

        // redirect to page
        $params = array(
            'confirmPage' => 'userRemoveImageConfirm',
        );

        return $this->_redirect( $site->getUrl( 'users', $params ) );
    }

    /**
     * The parents page
     *
     * @return void
     */
    public function parentsAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        // set the input params
        $optionalParams = array(
            'userStatus',
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

        return $this->renderPage( 'parents' );
    }

    /**
     * The responses page
     *
     * @return void
     */
    public function responsesAction()
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
        );

        $this->processInput( null, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'responses' );
    }

    /**
     * The response add page
     *
     * @return void
     */
    public function responseaddAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'responseAdd' );
    }

    /**
     * The response add confirm page
     *
     * @return void
     */
    public function responseaddconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                       /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;

        $token = $validator->getToken();

        // set the input params
        $requiredParams = array(
            'responseStatus',
            'postType',
            'responseType',
            'username',
        );

        $optionalParams = array(
            'tagNames',
            'challengeId',
            'description',
            'hideFromStreams',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the variables
        $username = $input->username;
        $responseType = $input->responseType;
        $responseStatus = $input->responseStatus;
        $postType = $input->postType;
        $challengeId = (!empty($input->challengeId)) ? $input->challengeId : null;
        $tagNames = $input->tagNames ? explode( ',', $input->getUnescaped( 'tagNames' ) ) : array();
        $description = $input->description ? $input->getUnescaped( 'description' ) : null;
        $skipComments = null;
        $isHideFromStreams = $input->hideFromStreams == 1 ? true : false;


        $user = $site->getUserByUsername( $username );
        $challenge = $site->getChallenge( $challengeId );

        // Perform validation checks
        $validator->checkInputResponse( array(
            'responseStatus' => $responseStatus,
            'postType' => $postType,
            'responseType' => $responseType,
            'user' => $user,
            'challenge' => $challenge,
            'uploadFile' => 'file',
        ), $errors);

        // Limit image filetypes to JPEG
        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE && @$_FILES['file']['tmp_name'] ) {
            $validator->checkJpegOnly('file', $errors);
        }
        if ( @$_FILES['coverImage']['tmp_name'] ) {
            $validator->checkJpegOnly('coverImage', $errors);
        }


        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $video = null;
        $image = null;
        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {
            $video = $this->_createVideoFromUploadedFile( $site, BeMaverick_Util::generateUUID(), 'response', "file" );
        } else if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {
            $image = BeMaverick_Image::saveOriginalImage( $site, "file", $errors );
        }

        // Create the Response object
        $response = $site->createResponse( 
            $responseType, 
            $user, 
            $challenge, 
            $video, 
            $image, 
            $skipComments, 
            $postType, 
            $description, 
            $tagNames,
            $responseStatus
        );
        $response->setHideFromStreams( $isHideFromStreams );

        if( $description ) {
            // set response hashtags by parsing description
            $response->setHashtags( $description );
        }

        // start AWS transcription job if response type = video
        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {
            $site->moderateAudio( $response, $token );
        }

        // asynchronously moderate the response immediately if response type = image
        if( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {
            $site->moderateResponse($response, $token);
        }

        // send response data to sns publish
        $response->publishChange( $site, 'CREATE' );

        // redirect to page
        $params = array(
            'confirmPage' => 'responseAddConfirm',
        );

        return $this->_redirect( $site->getUrl( 'responses', $params ) );
    }

    /**
     * The responses add page
     *
     * @return void
     */
    public function responsesaddAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'responsesAdd' );
    }

    /**
     * The responses add confirm page
     *
     * @return void
     */
    public function responsesaddconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */
        $systemConfig = $this->view->systemConfig;
        $validator = $this->view->validator;

        $token = $validator->getToken();

        // set the input params
        $requiredParams = array(
            'challengeId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the variables
        $challenge = $site->getChallenge( $input->challengeId );

        $validator->checkValidChallenge( $challenge, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // go through all input
        $maxAddResponses = $systemConfig->getSetting( 'SYSTEM_ADMIN_ADD_MAX_RESPONSES_AT_ONE_TIME' );

        for ( $i = 1; $i <= $maxAddResponses; $i++ ) {

            $username = $_REQUEST["username-$i"];
            $tagNames = $_REQUEST["tagNames-$i"] ? explode( ',', $_REQUEST["tagNames-$i"] ) : array();
            $description = $_REQUEST["description-$i"] ? $_REQUEST["description-$i"] : null;
            $responseType = $_REQUEST["responseType-$i"];
            $responseStatus = $_REQUEST["responseStatus-$i"];

            if ( $username && $responseType && $responseStatus && @$_FILES["file-$i"] ) {

                $user = $site->getUserByUsername( $username );

                $validator->checkValidUser( $user, $errors );
                $validator->checkInputUploadedFile( $_FILES, "file-$i", $errors );

                if ( $errors->hasErrors() ) {
                    return $this->renderPage( 'errors' );
                }

                $video = null;
                $image = null;

                if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {

                    $video = $this->_createVideoFromUploadedFile( $site, BeMaverick_Util::generateUUID(), 'response', "file-$i" );

                } else if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {

                    $image = BeMaverick_Image::saveOriginalImage( $site, "file-$i", $errors );
                }

                $response = $challenge->addResponse( $responseType, $user, $video, $image, $tagNames, $description, false );
                $response->setStatus( $responseStatus );

                // start AWS transcription job if response type = video
                if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {
                    $site->moderateAudio( $response, $token );
                }

                // asynchronously moderate the response immediately if response type = image
                if( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {
                    $site->moderateResponse($response, $token);
                }
            }

        }

        // redirect to page
        $params = array(
            'confirmPage' => 'responsesAddConfirm',
        );

        return $this->_redirect( $site->getUrl( 'responses', $params ) );
    }

    /**
     * The response edit page
     *
     * @return void
     */
    public function responseeditAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;

        // set the input params
        $requiredParams = array(
            'responseId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $response = $site->getResponse( $input->responseId );

        $this->view->response = $response;

        return $this->renderPage( 'responseEdit' );
    }

    /**
     * The response edit confirm page
     *
     * @return void
     */
    public function responseeditconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $validator = $this->view->validator;

        // set the input params
        $requiredParams = array(
            'responseId',
            'responseStatus',
            'postType',
            'responseType',
            'username',
        );

        $optionalParams = array(
            'tagNames',
            'challengeId',
            'description',
            'hideFromStreams',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // Limit image filetypes to JPEG
        if ( @$_FILES['image']['tmp_name'] ) {
            $validator->checkJpegOnly('image', $errors);
        }
        if ( @$_FILES['cardImage']['tmp_name'] ) {
            $validator->checkJpegOnly('cardImage', $errors);
        }
        if ( @$_FILES['mainImage']['tmp_name'] ) {
            $validator->checkJpegOnly('mainImage', $errors);
        }

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the variables
        $responseId = $input->responseId;
        $responseStatus = $input->responseStatus;
        $postType = $input->postType;
        $responseType = $input->responseType;
        $username = $input->username;
        $challengeId = $input->challengeId;
        $tagNames = $input->tagNames ? explode( ',', $input->getUnescaped( 'tagNames' ) ) : array();
        $description = $input->description ? $input->getUnescaped( 'description' ) : null;
        $isHideFromStreams = $input->hideFromStreams == 1 ? true : false;

        $user = $site->getUserByUsername( $username );
        $challenge = $site->getChallenge( $challengeId );
        $response = $site->getResponse( $responseId );
        $challengeId = (!empty($challenge)) ? $challenge->getId() : null;

        // Perform validation checks
        $validator->checkInputResponse( array(
            'responseStatus' => $responseStatus,
            'postType' => $postType,
            'responseType' => $responseType,
            'user' => $user,
            'challenge' => $challenge,
            'uploadFile' => 'file',
        ), $errors, $response);

        // Limit image filetypes to JPEG
        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE && @$_FILES['file']['tmp_name'] ) {
            $validator->checkJpegOnly('file', $errors);
        }
        if ( @$_FILES['coverImage']['tmp_name'] ) {
            $validator->checkJpegOnly('coverImage', $errors);
        }

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $video = null;
        $image = null;
        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {
            $video = $this->_createVideoFromUploadedFile( $site, BeMaverick_Util::generateUUID(), 'response', "file" );
        } else if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {
            $image = BeMaverick_Image::saveOriginalImage( $site, "file", $errors );
        }

        $coverImage = null;
        if ( @$_FILES['coverImage']['tmp_name'] ) {
            $coverImage = BeMaverick_Image::saveOriginalImage( $site, 'coverImage', $errors );
        }

        // Update the Response object
        $response->setStatus( $responseStatus );
        $response->setPostType( $postType );
        $response->setResponseType( $responseType );
        $response->setUser( $user );
        $response->setChallenge( $challenge );
        $response->setTags( $tagNames );
        $response->setDescription( $description );
        $response->setHideFromStreams( $isHideFromStreams );

        if ( $description ) {
            // set response hashtags by parsing description
            $response->setHashtags( $description );
        } else {
            $response->setHashtags( null );
        }

        if ( $video ) {
            $response->setVideo( $video );
        }

        if ( $image ) {
            $response->setImage( $image );
        }

        if ( $coverImage ) {
            $response->setCoverImage( $coverImage );
        }

        // send response data to sns publish
        if ( in_array( $responseStatus, ['inactive', 'draft', 'deleted' ] ) ) {
            $response->publishChange( $site, 'DELETE' );
        } else {
            $response->publishChange( $site, 'UPDATE' );
        }

        // redirect to page
        $params = array(
            'confirmPage' => 'responseEditConfirm',
        );

        return $this->_redirect( $site->getUrl( 'responses', $params ) );
    }

}

?>
