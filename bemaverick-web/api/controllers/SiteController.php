<?php

use Zendesk\API\HttpClient as ZendeskAPI;

require_once( SLY_ROOT_DIR . '/lib/Sly/Url.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Email.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class SiteController extends BeMaverick_Controller_Base
{

    /**
     * The site config page
     *
     * @return void
     */
    public function configAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
        $validator = $this->view->validator;

        $this->view->format = 'json';

        //$validator->checkOAuthToken( $site, 'read', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addSiteConfig( $site );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData', $systemConfig->getSetting( 'SYSTEM_API_HTTP_CACHE_TTL' ) );
    }

    /**
     * The site challenges page
     *
     * @return void
     */
    public function challengesAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
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
        );

        $optionalParams = array(
            'status',
            'sort',
            'sortOrder',
            'count',
            'offset',
            'featuredType',
            'filter',
            'minimumHours',
            'hasResponse',
            'hasLinkUrl',
            'responseUserId',
            'mentionedUserId',
            'userId',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the values
        $status = $input->status ? $input->status : 'active';
        $count = $input->count ? $input->count : 10;
        $offset = $input->offset ? $input->offset : 0;
        $sort = $input->sort ? $input->sort : 'numBadges';
        $sortOrder = $input->sortOrder ? $input->sortOrder : 'desc';
        $featuredType = $input->featuredType ? $input->featuredType : 'maverick-stream';
        $filter = $input->filter ? $input->filter : array();
        $minimumHours = $input->minimumHours ? $input->minimumHours : 0;
        $hasResponse = $input->hasResponse ? $input->hasResponse : null;
        $hasLinkUrl = $input->hasLinkUrl ? $input->hasLinkUrl : null;
        $responseUserId = $input->responseUserId ? $input->responseUserId : null;
        $mentionedUserId = $input->mentionedUserId ? $input->mentionedUserId : null;
        $userId = $input->userId ? $input->userId : null;

        // Get user data
        $tokenInfo = $validator->checkOAuthToken( $site, 'read', false, $errors );
        $user = @$tokenInfo['user'];

        // Sort Data
        $sortBy = array(
            'sort' => $sort,
            'sortOrder' => $sortOrder,
            'featuredType' => $featuredType,
        );

        // Filter Data
        $filterBy = array();
        if ($minimumHours > 0) {
            $filterBy['minimumHours'] = $minimumHours;
        }
        if (!is_null($hasResponse)) {
            $filterBy['hasResponse'] = $hasResponse;
        }
        if (!is_null($hasLinkUrl)) {
            $filterBy['hasLinkUrl'] = $hasLinkUrl;
        }
        if (!is_null($responseUserId)) {
            if (ctype_digit($responseUserId))
                $filterBy['responseUserId'] = $responseUserId;
            elseif ($responseUserId == 'me' && $user)
                $filterBy['responseUserId'] = $user->getId();
        }
        if (!is_null($userId)) {
            if (ctype_digit($userId))
                $filterBy['userId'] = $userId;
            elseif ($userId == 'me' && $user)
                $filterBy['userId'] = $user->getId();
        }

        if (!is_null($mentionedUserId)) {
            if (ctype_digit($mentionedUserId))
                $filterBy['mentionedUserId'] = $mentionedUserId;
            elseif ($mentionedUserId == 'me' && $user)
                $filterBy['mentionedUserId'] = $user->getId();

            $sortBy = array( 'sort' => 'mentioned', 'sortOrder' => 'desc' );
        }
        // die('$filterBy => '.print_r($filterBy,true));

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        if ( $featuredType === 'challenge-stream' ) {
            $responseData->addSiteChallengeStreamChallenges( $site, $count, $offset /*, $stagger */ );
        } else {
            $responseData->addSiteChallenges( $site, $status, $sortBy, $count, $offset, $filterBy );
        }
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData', $systemConfig->getSetting( 'SYSTEM_API_HTTP_CACHE_TTL' ) );
    }
    /**
     * The site responses page
     *
     * @return void
     */
    public function responsesAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
        $validator = $this->view->validator;

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'read', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
        );

        $optionalParams = array(
            'filter',
            'userId',
            'challengeId',
            'sort',
            'sortOrder',
            'count',
            'offset',
            'featuredType',
            'delay',
            'hideFromStreams',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the values
        $filter = $input->filter ? $input->filter : null;
        $userId = $input->userId ? $input->userId : null;
        $challengeId = $input->challengeId ? $input->challengeId : null;
        $sort = $input->sort ? $input->sort : 'createdTimestamp';
        $sortOrder = $input->sortOrder ? $input->sortOrder : 'desc';
        $count = $input->count ? $input->count : 25;
        $offset = $input->offset ? $input->offset : 0;
        $featuredType = $input->featuredType ?? null;
        $hideFromStreams = $input->hideFromStreams ?? null;
        $delay = $input->delay ?? null;

        $user = @$tokenInfo['user'];

        if ( ($filter == 'userFollowers' || $filter == 'userFollowing') && ! $user ) {
            $errors->setError( '', 'USER_MUST_BE_IN_TOKEN_FOR_FILTER_GIVEN' );

            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $filterBy = array(
            'responseStatus' => 'active',
        );
        if ($featuredType) {
            $filterBy['featuredType'] = $featuredType;
        }

        if ( $filter == 'featured' ) {
            $filterBy['featured'] = true;

            // if filtering by featured, then force the sort to also be by featured
            $sort = 'featured';
            $sortOrder = 'asc';

        } else if ( $filter == 'userFollowers' ) {
            $filterBy['followingUserId'] = $user->getId();
        } else if ( $filter == 'userFollowing' ) {
            $filterBy['followerUserId'] = $user->getId();
        }

        if ( $userId ) {
            $filterBy['userId'] = $userId;
        }

        if ( $challengeId ) {
            $filterBy['challengeId'] = $challengeId;
        }

        if ( $delay ) {
            $filterBy['delay'] = $delay;
        }

        if ( ! is_null($hideFromStreams) ) {
            $filterBy['hideFromStreams'] = $hideFromStreams;
        }

        $sortBy = array(
            'sort' => $sort,
            'sortOrder' => $sortOrder,
        );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        // error_log('SiteController.php:responsesAction() ... addSiteResponses()');
        $responseData->addSiteResponses( $site, $filterBy, $sortBy, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData', $systemConfig->getSetting( 'SYSTEM_API_HTTP_CACHE_TTL' ) );
    }

    /**
     * The site contents page
     *
     * @return void
     */
    public function contentsAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
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
        );

        $optionalParams = array(
            'userId',
            'sort',
            'sortOrder',
            'count',
            'offset',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the values
        $user = $input->userId ? $site->getUser( $input->userId ) : null;
        $count = $input->count ? $input->count : 25;
        $offset = $input->offset ? $input->offset : 0;
        $sort = $input->sort ? $input->sort : 'createdTimestamp';
        $sortOrder = $input->sortOrder ? $input->sortOrder : 'desc';

        $sortBy = array(
            'sort' => $sort,
            'sortOrder' => $sortOrder,
        );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addSiteContents( $site, $user, $sortBy, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData', $systemConfig->getSetting( 'SYSTEM_API_HTTP_CACHE_TTL' ) );
    }

    /**
     * The site tags page
     *
     * @return void
     */
    public function tagsAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
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
        );

        $optionalParams = array(
            'query',
            'count',
            'offset',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the values
        $query = $input->query ? $input->query : null;
        $count = $input->count ? $input->count : 25;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addSiteTags( $site, $query, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData', $systemConfig->getSetting( 'SYSTEM_API_HTTP_CACHE_TTL' ) );
    }

    /**
     * The site send feedback page
     *
     * @return void
     */
    public function sendfeedbackAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
        $validator = $this->view->validator;

        $validator->checkOAuthToken( $site, 'read', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $this->view->format = 'json';

        // set the input params
        $requiredParams = array(
            'appKey',
            'emailAddress',
            'message',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // send mail to us
        $vars = array(
            'EMAIL_ADDRESS' => $input->getUnescaped( 'emailAddress' ),
            'MESSAGE' => $input->getUnescaped( 'message' ),
            'IP_ADDRESS' => $systemConfig->getRemoteIp(),
        );

        $adminEmailAddresses = $systemConfig->getSetting( 'SYSTEM_ADMIN_EMAIL_ADDRESSES' );

        BeMaverick_Email::sendTemplate( $site, 'admin-contact-us', $adminEmailAddresses, $vars );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The site users page
     *
     * @return void
     */
    public function usersAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
        $validator = $this->view->validator;

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'read', false, $errors );

        // check if there were any errors
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

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the values
        $user = @$tokenInfo['user'];
        $count = $input->count ? $input->count : 25;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addSiteUsers( $site, $user, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData', $systemConfig->getSetting( 'SYSTEM_API_HTTP_CACHE_TTL' ) );
    }

    /**
     * The site maverick stream page
     *
     * @return void
     */
    public function maverickstreamAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
        $validator = $this->view->validator;

        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'read', false, $errors );

        // check if there were any errors
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

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $user = $tokenInfo['user'];
        $validator->checkValidUser( $user, $errors );
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the values
        $count = $input->count ? $input->count : 25;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addSiteMaverickStream( $site, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData', $systemConfig->getSetting( 'SYSTEM_API_HTTP_CACHE_TTL' ) );
    }

    /**
     * The site challenge stream page
     *
     * @return void
     */
    public function challengestreamAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
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
        );

        $optionalParams = array(
            'count',
            'offset',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the values
        $count = $input->count ? $input->count : 25;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addSiteChallengeStream( $site, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData', $systemConfig->getSetting( 'SYSTEM_API_HTTP_CACHE_TTL' ) );
    }

    /**
     * The video encoding update handler
     *
     * @return void
     */
    public function updatevideostatusAction()
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
            'jobId',
            'jobStatus'
        );

        $optionalParams = array(
            'playlistname',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $jobId = $input->jobId;
        $jobStatus = $input->jobStatus;
        $playlistname = $input->playlistname;

        $site->setVideoEncoderJobStatus( $jobId, $jobStatus, $playlistname );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }


    /**
     * The video encoding update handler
     *
     * @return void
     */
    public function zendeskAction()
    {
        try {
                
            // get the view vars
            $errors = $this->view->errors;
            $site = $this->view->site;
            $validator = $this->view->validator;
            $systemConfig = $this->view->systemConfig;

            $subdomain = $systemConfig->getSetting( 'ZENDESK_SUBDOMAIN' );
            $username = $systemConfig->getSetting( 'ZENDESK_USERNAME' );
            $token = $systemConfig->getSetting( 'ZENDESK_TOKEN' );

            $client = new ZendeskAPI($subdomain);
            $client->setAuth('basic', ['username' => $username, 'token' => $token]);

            $body = "
            name: ".$_POST['name']."\n
            username: ".$_POST['username']."\n
            email: ".$_POST['email']."\n\n
            message: ".$_POST['message']."\n
            ";

            // Create a new ticket
            $ticket = $client->tickets()->create([
                'subject'  => 'Contact form submission on genmaverick.com',
                'comment'  => [
                    'body' => $body
                ],
                'priority' => 'normal',
                'requester' => [
                    'name' => $_POST['name'],
                    'email' => $_POST['email'],
                ] 
            ]);


            header('Content-Type: application/json');
            http_response_code(200);
            echo json_encode(array(
                "status" => "success"
            ));
            exit();

        } catch( Exception $e ) {
            error_log( 'Zendesk exception: '.  $e->getMessage());

            http_response_code(500);
            echo "Error sending ticket";
            exit();
        }
    }

    /**
     * Loads an image object based on an imageId parameter
     *
     * @return void
     */
    public function imageAction()
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
            'imageId',
        );

        $optionalParams = array();

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $imageId = $input->imageId;

        $image = $site->getImage( $imageId );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addImageBasic( $image );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The site streams page
     *
     * @return void
     */
    public function streamsAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
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
        );

        $optionalParams = array(
            'count',
            'offset',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $count = $input->count ? $input->count : 25;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        // error_log('DEBUG::SiteController.php:streamsAction:addSiteStreams()');
        $responseData->addSiteStreams( $site, $count, $offset );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData', $systemConfig->getSetting( 'SYSTEM_API_HTTP_CACHE_TTL' ) );
    }

    /**
     * The site badges page
     *
     * @return void
     */
    public function badgesAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
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
        );

        $optionalParams = array(
            'status',
            'count',
            'offset',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the values
        $status = !empty($input->status) ? $input->status : 'active';
        $count = $input->count ? $input->count : 25;
        $offset = $input->offset ? $input->offset : 0;

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addSiteBadges( $site, $status );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData', $systemConfig->getSetting( 'SYSTEM_API_HTTP_CACHE_TTL' ) );
    }

    /**
     * Publish content changes to SNS
     *
     * @return void
     */
    public function publishchangeAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;
        $systemConfig = $this->view->systemConfig;
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
            'contentType',
            'contentId',
        );
        $optionalParams = array(
            'contentAction'
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // get the values
        $status = !empty($input->status) ? $input->status : 'active';
        $contentType = $input->contentType;
        $contentId = $input->contentId;
        $contentAction = ($input->contentAction && $input->contentAction !== "") ? $input->contentAction : 'UPDATE';

        $allowCache = false;
        if ( $contentType == 'challenge' ) {
            $content = $site->getChallenge( $contentId );
            $publishChange = $content->publishChange( $site, $contentAction, $allowCache);
        } elseif ( $contentType == 'response' ) {
            $content = $site->getResponse( $contentId );
            $publishChange = $content->publishChange( $site, $contentAction, $allowCache);
        } elseif( $contentType == 'user' ) {
            $content = $site->getUser( $contentId );
            $publishChange = $content->publishChange( $site, $contentAction);
        }

        $response = array(
            'contentType' => $contentType,
            'contentId' => $contentId,
            'action' => $contentAction,
            'publishChange' => $publishChange,
            'content' => $content->getDetails(),
        );

        header('Content-Type: application/json');
        http_response_code(200);
        echo json_encode($response);
        exit();
    }

}

?>
