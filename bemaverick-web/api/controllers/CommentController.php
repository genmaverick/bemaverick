<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class CommentController extends BeMaverick_Controller_Base
{

    /**
     * Generates the access token for accessing the comments third party provider
     *
     * @return void
     */
    public function tokenAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */
        $this->view->format = 'json';

        $tokenInfo = $validator->checkOAuthToken( $site, 'read', true, $errors );
        $user = $tokenInfo['user'];
        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        // set the input params
        $requiredParams = array(
            'appKey',
            'deviceId',
        );

        $input = $this->processInput( $requiredParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }
        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addCommentUserToken( $site,  $user,  $input->deviceId );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }

    /**
     * The webhook listener for comment updates
     *
     * @return void
     */
    public function messageupdatewebhookAction()
    {
        $errors = $this->view->errors;         /* @var Sly_Errors $errors */
        $site = $this->view->site;             /* @var BeMaverick_Site $site */
        $validator = $this->view->validator;   /* @var BeMaverick_Validator $validator */

        $this->view->format = 'json';

        // set the input params
        $requiredParams = array(
            'EventType',
            'MessageSid',
            'ChannelSid',
            'Body',
            'Attributes',
            'From',
            'ModifiedBy',
            'DateCreated',
            'DateUpdated'
        );

        $input = $this->processInput( $requiredParams, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors', 0, self::HTTP_RC_BAD_REQUEST );
        }

        $messageId = $input->MessageSid;
        $channelId = $input->ChannelSid;
        $message = $input->Body;
        $attributes = $input->Attributes;
        $from = $input->From;
        $updatedBy = $input->ModifiedBy;
        $createdAt = $input->DateCreated;
        $updatedAt = $input->DateUpdated;

        $comment = $site->createComment($site, $messageId, $channelId, $message, $attributes, $from, $updatedBy, $createdAt, $updatedAt);
        // get the response data object
        $responseData = $site->getFactory()->getResponseData();
        $responseData->addStatus( 'success' );
        $this->view->responseData = $responseData;

        return $this->renderPage( 'responseData' );
    }
}

?>
