<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class ChallengesController extends BeMaverick_Controller_Base
{
    /**
     * The challenge page
     *
     * @return void
     */
    public function challengeAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;         /* @var BeMaverick_Site $site */
        $loginUser = $this->view->loginUser;

        // set the input params
        $requiredParams = array(
            'challengeId',
        );

        $optionalParams = array(
            'count',
            'offset',
            'startCount'
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );
        $challengeId = $input->challengeId;

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        if ( $loginUser ) {
            $successPage = 'challenge';
            if ( $this->view->ajax && $this->view->ajax != 'dynamicModule' ) {
                $successPage = $this->view->ajax.'Ajax';
            }

            // get the objects
            $challenge = $site->getChallenge( $challengeId );

            // show not found if no challenge
            if ( ! $challenge ) {
                return $this->_forward( 'notfound', 'errors' );
            }

            // show not found if challenge is draft, hidden or deleted
            $challengeStatus = $challenge->getStatus();

            if ( in_array( $challengeStatus, ['draft', 'hidden', 'deleted'] ) ) {
                return $this->_forward( 'notfound', 'errors' );
            }

            // Add meta information
            $this->view->openGraph = $challenge->getOpenGraph();

            // set the view vars
            $this->view->challenge = $challenge;

            return $this->renderPage( $successPage );
        } else {
            $path = 'challenge/' . $challengeId . '/';

            // if coming from the php site, redirect
            if ( $this->view->ajax ) {
                $this->view->redirectUrl = $path;
                return $this->renderPage( 'redirect' );
            }

            // get url
            $systemConfig = $site->getSystemConfig();
            $reactAppUrl = $systemConfig->getSetting( 'REACT_APP_URL' );
            $url = $reactAppUrl . $path;

            // cURL & Render
            $this->renderCurlUrl($url);
        }
    }

    public function addResponseAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;         /* @var BeMaverick_Site $site */

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'challengeId',
        );

        $input = $this->processInput( $requiredParams, array(), $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $challenge = $site->getChallenge( $input->challengeId );

        // show not found
        if ( ! $challenge ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $successPage = 'challenge';
        if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = 'challengeAddResponse';
        } else if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        } else if ( !$this->view->ajax ) {
            $this->view->popupUrl = $challenge->getUrl( 'challengeAddResponse' );
        }

        // set the view vars
        $this->view->challenge = $challenge;

        return $this->renderPage( $successPage );
    }

    public function addResponseConfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $systemConfig = $this->view->systemConfig;  /* @var BeMaverick_Config_System $systemConfig */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */
        $loginUser = $this->view->loginUser;   /* @var BeMaverick_User $loginUser */

        // check that page is viewable by this user
        if ( ! $this->isPageViewable( 'loggedIn' ) ) {
            return $this->renderPage( 'errors' );
        }

        // set the input params
        $requiredParams = array(
            'challengeId',
            'responseType',
        );

        $optionalParams = array(
            'description',
            'tagNames',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        // get the objects
        $challenge = $site->getChallenge( $input->challengeId );

        // show not found
        if ( ! $challenge ) {
            return $this->_forward( 'notfound', 'errors' );
        }

        $validator->checkValidChallenge( $challenge, $errors );
        $validator->checkInputUploadedFile( $_FILES, "file", $errors );
        $uploadFileSizeMax = $systemConfig->getSetting( 'SYSTEM_UPLOAD_FILE_SIZE_MAX_MB' );
        if ( $uploadFileSizeMax ) {
            $validator->checkInputUploadedFileSize( $_FILES, "file", $errors, $uploadFileSizeMax );
        }

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $tagNames = $input->tagNames ? explode( ',', $input->getUnescaped( 'tagNames' ) ) : array();
        $description = $input->description ? $input->getUnescaped( 'description' ) : null;
        $responseType = $input->responseType;

        $video = null;
        $image = null;

        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {

            $video = $this->_createVideoFromUploadedFile( $site, $challenge->getId(), 'response', 'file' );

        } else if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {

            $image = BeMaverick_Image::saveOriginalImage( $site, 'file', $errors );
        }

        $response = $challenge->addResponse( $responseType, $loginUser, $video, $image, $tagNames, $description, false );

        // start AWS transcription job if response type = video
        if ( $responseType == BeMaverick_Response::RESPONSE_TYPE_VIDEO ) {
            $site->moderateAudio( $response, $loginUser->getOAuthAccessToken() );
        }

        // asynchronously moderate the response immediately if response type = image
        if( $responseType == BeMaverick_Response::RESPONSE_TYPE_IMAGE ) {
            $site->moderateResponse($response, $loginUser->getOAuthAccessToken());
        }

        $successPage = 'challenge';
        if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = 'challengeAddResponseConfirm';
        } else if ( $this->view->ajax && $this->view->ajax == 'dynamicModule' ) {
            $successPage = $this->view->ajax.'Ajax';
        } else if ( !$this->view->ajax ) {
            $this->view->popupUrl = $challenge->getUrl( 'challengeAddResponse', array( 'confirm' => true ) );
        }

        // set the view vars
        $this->view->challenge = $challenge;
        $this->view->response = $response;

        return $this->renderPage( $successPage );
    }

    private function renderCurlUrl($url) {
        // curl the remote url
        $curl = curl_init($url);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
        $output = curl_exec($curl);
        curl_close($curl);

        // disable zend rendering
        $this->_helper->viewRenderer->setNoRender(true);
        $this->view->layout()->disableLayout();

        if(trim($output)==='') {
            http_response_code(500);
            echo "Error: Could not load page";
        } else {
            // output the curl request
            echo $output;
        }
        exit();
    }

}
