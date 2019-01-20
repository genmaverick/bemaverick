<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class ResponsesController extends BeMaverick_Controller_Base
{

    /**
     * The response page
     *
     * @return void
     */
    public function responseAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        // set the input params
        $requiredParams = array(
            'responseId',
        );

        $optionalParams = array(
            'count',
            'offset',
            'startCount'
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $successPage = 'response';
        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        // get the objects
        $response = $site->getResponse( $input->responseId );

        // show not found if no response
        if ( ! $response ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        // show not found if response is revoked, deleted or inactive
        $responseStatus = $response->getStatus();

        if ( in_array( $responseStatus, ['revoked', 'deleted', 'inactive'] ) ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        // check user can view this response (not logged in && response = private returns error)
        $validator->checkUserCanViewResponse( $loginUser, $response, $errors );

        // if checkUserCanViewResponse comes back with error/not-pass, redirect to react shared-signin
        if ( $errors->hasErrors() ) {
            $site = $this->view->site;

            if ( $this->view->ajax ) {
                $this->view->redirectUrl = 'shared-signin';
                return $this->renderPage( 'redirect' );
            }

            // get url
            $systemConfig = $site->getSystemConfig();
            $reactAppUrl = $systemConfig->getSetting( 'REACT_APP_URL' );
            $url = $reactAppUrl . 'shared-signin';

            // curl the remote url
            $curl = curl_init($url);
            curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
            $output = curl_exec($curl);
            curl_close($curl);

            // disable zend rendering
            $this->_helper->viewRenderer->setNoRender(true);
            $this->view->layout()->disableLayout();

            // output the curl request
            echo $output;
            exit();
        }

        // Add OpenGraph meta information
        $this->view->openGraph = $response->getOpenGraph();

        // set the view vars
        $this->view->response = $response;

        return $this->renderPage( $successPage );
    }

    /**
     * The edit status  page
     *
     * @return void
     */
    public function statusEditAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $systemConfig = $this->view->systemConfig;  /* @var BeMaverick_Config_System $systemConfig */
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        $successPage = 'responseStatusEdit';
        $errorPage = 'errors';

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'responseId'
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        // get the objects
        $response = $site->getResponse( $input->responseId );

        // show not found
        if ( ! $response ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        // perform the checks
        $validator->checkUserCanEditResponseStatus( $loginUser, $response, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        } else if ( ! $this->view->ajax ) {
            $this->view->popupUrl = $response->getUrl( 'responseStatusEdit' );
            $successPage = 'response';
        }


        // set the view vars
        $this->view->response = $response;

        return $this->renderPage( $successPage );
    }

    /**
     * The edit status confirm page
     *
     * @return void
     */
    public function statusEditConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $systemConfig = $this->view->systemConfig;  /* @var BeMaverick_Config_System $systemConfig */
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        $successPage = 'response';
        $errorPage = 'errors';

        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // security checks
        $validator->checkCSRFValidation( $systemConfig, $this->_request, $errors );
        $validator->checkCSRFAccessToken( $site, @$_REQUEST['accessToken'], $errors );
        $validator->checkRequestMethodPost( $this->_request, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        // set the input params
        $requiredParams = array(
            'responseId',
            'responseStatus',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        // get the objects
        $response = $site->getResponse( $input->responseId );

        // show not found
        if ( ! $response ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $responseStatus = $input->responseStatus;

        // perform the checks
        $validator->checkUserCanEditResponseStatus( $loginUser, $response, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        // perform the action
        $response->setStatus( $responseStatus );
        $response->save();

        // set the view vars
        $this->view->response = $response;

        return $this->renderPage( $successPage );
    }

    /**
     * The flag response action
     *
     * @return void
     */
    public function flagAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $systemConfig = $this->view->systemConfig;  /* @var BeMaverick_Config_System $systemConfig */
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        $successPage = 'responseFlag';
        $errorPage = 'errors';

        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'responseId'
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        // get the objects
        $response = $site->getResponse( $input->responseId );

        // show not found
        if ( ! $response ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        // set the view vars
        $this->view->response = $response;

        return $this->renderPage( $successPage );
    }

    /**
     * The flag response confirm page
     *
     * @return void
     */
    public function flagConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $systemConfig = $this->view->systemConfig;  /* @var BeMaverick_Config_System $systemConfig */
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        $successPage = 'responseFlagConfirm';
        $errorPage = 'errors';

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // security checks
        $validator->checkCSRFValidation( $systemConfig, $this->_request, $errors );
        $validator->checkCSRFAccessToken( $site, @$_REQUEST['accessToken'], $errors );
        $validator->checkRequestMethodPost( $this->_request, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        // set the input params
        $requiredParams = array(
            'responseId',
        );

        $optionalParams = array(
            'reason',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        // get the objects
        $response = $site->getResponse( $input->responseId );

        // show not found
        if ( ! $response ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $reason = $input->reason;

        // perform the checks
        $validator->checkUserCanReportResponse( $loginUser, $response, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        // perform the action
        $site->flagResponse( $response, $loginUser, $reason );

        // set the view vars
        $this->view->response = $response;

        if ( ! $this->view->ajax ) {
            $successPage = 'response';
        }

        return $this->renderPage( $successPage );
    }

    /**
     * The edit badge confirm page
     *
     * @return void
     */
    public function editBadgeConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $systemConfig = $this->view->systemConfig;  /* @var BeMaverick_Config_System $systemConfig */
        $site = $this->view->site;                  /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;        /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;        /* @var BeMaverick_User $loginUser */

        $successPage = 'response';
        $errorPage = 'errors';

        if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        }

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // security checks
        $validator->checkCSRFValidation( $systemConfig, $this->_request, $errors );
        // $validator->checkCSRFAccessToken( $site, @$_REQUEST['accessToken'], $errors );
        $validator->checkRequestMethodPost( $this->_request, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        // set the input params
        $requiredParams = array(
            'responseId',
            'badgeId',
        );

        $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        // get the objects
        $response = $site->getResponse( $input->responseId );

        // show not found
        if ( ! $response ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $badge = $site->getBadge( $input->badgeId );


        // perform the checks
        $validator->checkValidResponse( $response, $errors );
        $validator->checkValidBadge( $badge, $errors );
        $validator->checkUserCanBadgeResponse( $loginUser, $response, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( $errorPage );
        }

        $givenBadgeIds = $loginUser->getGivenResponseBadgeIds( $response );
        $addBadge = true;
        if ( in_array( $badge->getId(), $givenBadgeIds ) ) {
            $addBadge = false;
        }

        // perform the actions
        foreach( $givenBadgeIds as $givenBadgeId ) {
            $givenBadge = $site->getBadge( $givenBadgeId );
            $response->deleteBadge( $givenBadge, $loginUser );
        }
        if ( $addBadge ) {
            $response->addBadge( $badge, $loginUser );
        }


        // set the view vars
        $this->view->response = $response;

        return $this->renderPage( $successPage );
    }
}
