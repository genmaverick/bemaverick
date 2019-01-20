<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class CoppaController extends BeMaverick_Controller_Base
{
    /**
     * Verify the identity of the parent through a third party verification service.
     *
     * @return void
     */
    public function verifyparentAction()
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
        // set the input params
        $requiredParams = array(
            'appKey',
            'childUserId',
            'firstName',
            'lastName',
            'address',
            'zipCode',
            'lastFourSSN'
         );

        $optionalParams = array(
            'retry',
            'testKey'
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $kidUserId = $input->childUserId;
        $firstName = $input->firstName;
        $lastName = $input->lastName;
        $address = $input->address;
        $zipCode = $input->zipCode;
        $lastFourSSN = $input->lastFourSSN;
        $retry = $input->retry ? $input->retry : 0;
        $testKey = $input->testKey ? $input->testKey : 'general';

        $idVerificationResponse = $site->verifyParentIdentity( $kidUserId, $firstName, $lastName, $address, $zipCode, $lastFourSSN, $testKey );

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addParentVerificationResponse( $idVerificationResponse, $retry );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * Edit the status of VPC(verifiable parental consent) for the kid
     *
     * @return void
     */
    public function editvpcstatusAction()
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
        // set the input params
        $requiredParams = array(
            'appKey',
            'childUserId',
            'vpc'
        );

        $input = $this->processInput( $requiredParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $vpc = $input->vpc;
        $kidUserId = $input->childUserId;

        $user = $site->getUser( $kidUserId );
        $user->setEmailVerified( true );
        $user->setVPCStatus( $vpc );
        $user->save();

        // check to see if this parent already has an account, if not, then lets create one
        $parentEmailAddress = $user->getParentEmailAddress();

        $parent = $site->getUserByEmailAddress( $parentEmailAddress );

        if ( ! $parent ) {
            $parent = $site->createParent( null, null, $parentEmailAddress );
        }

        if ( $vpc ) {
            // if they got this far, they verified identity
            $parent->setIdVerificationStatus( BeMaverick_User_Parent::ID_VERIFICATION_STATUS_VERIFIED );
        }

        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }
}

?>
