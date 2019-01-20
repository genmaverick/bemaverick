<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class ModerationController extends BeMaverick_Controller_Base
{
    /**
     * The webhook listener for response updates
     *
     * @return void
     */
    public function responsewebhookAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $input = $this->getRequest()->getRawBody();
        $status = $site->moderateResponseApprovals( $input );

        if ( $status )
        {
            // get the response data object
            $responseData = $site->getFactory()->getResponseData();
            $responseData->addStatus( 'success' );
            $this->view->responseData = $responseData;
            return $this->renderPage( 'responseData' );
        } else {
            $errors->setError( 'approvalsUpdateFailed', 'RESPONSE_APPROVALS_FAILED' );
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }
    }

    /**
     * The webhook listener for user moderation
     *
     * @return void
     */
    public function userwebhookAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        $validator->checkOAuthToken( $site, 'write', false, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $input = $this->getRequest()->getRawBody();
        $status = $site->moderateUserActions( $input );

        if ( $status )
        {
            // get the response data object
            $responseData = $site->getFactory()->getResponseData();
            $responseData->addStatus( 'success' );
            $this->view->responseData = $responseData;
            return $this->renderPage( 'responseData' );
        } else {
            $errors->setError( 'userUpdateFailed', 'UPDATE_FAILED' );
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }
    }

}

?>
