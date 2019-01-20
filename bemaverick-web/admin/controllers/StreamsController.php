<?php


require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class StreamsController extends BeMaverick_Controller_Base
{

    /**
     * The streams page
     *
     * @return void
     */
    public function indexAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        // set the input params
        $optionalParams = array(
            'status',
            'query',
            'count',
            'offset',
            'sort',
            'sortOrder',
            'contentStatus',
        );

        $this->processInput( null, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'streams' );
    }

    /**
     * The featured responses edit confirm page
     *
     * @return void
     */
    public function streamseditconfirmAction()
    {
        // get the view vars
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */

        $streamIds = @$_REQUEST['streamIds'] ? $_REQUEST['streamIds'] : array();

        $sortOrder = 1;
        foreach ( $streamIds as $streamId ) {

            $stream = $site->getStream( $streamId );

            $stream->setSortOrder( $sortOrder );

            $sortOrder++;
        }

        // redirect to page
        $params = array(
            'confirmPage' => 'streamsEditConfirm',
        );

        return $this->_redirect( $site->getUrl( 'streams', $params ) );
    }

    /**
     * The Stream Ad Block edit page
     *
     * @return void
     */
    public function streamsadblockeditAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        $requiredParams = array(
            'streamId',
        );

        $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'streamsAdBlockEdit' );
    }

    /**
     * The Stream Ad Block edit confirm page
     * 
     * @return void
     */
    public function streamsadblockeditconfirmAction()
    {

        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */

        $requiredParams = array(
            'streamId',
        );
        $optionalParams = array(
            'contentStatus',
            'streamId',
            'label',
            'deeplinkModelType',
            'deeplinkModelId',
            'image',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }


        $streamId = $input->streamId ?? null;
        $modelType = BeMaverick_Site::MODEL_TYPE_RESPONSE;
        $label = $input->label ?? null;
        $contentStatus = $input->contentStatus ?? null;


        /** Update Stream */
        if ($stream = $site->getStream($streamId)) {
            $stream->updateStreamFromInput($input);
        }

        /** Update image */
        // die("\$_FILES <pre>".print_r($_FILES,true));
        if ( @$_FILES['image']['tmp_name'] ) {
            $image = BeMaverick_Image::saveOriginalImage( $site, 'image', $errors );
            $stream->setImage( $image );
        }
        $stream->save();

        // redirect to edit feature stream page
        $params = array(
            'confirmPage' => 'streamsAdBlockEditConfirm',
        );
        if($streamId) {
            $params['streamId'] = $streamId;
        }

        return $this->_redirect( $site->getUrl( 'streamsAdBlockEdit', $params ) );
    }

    /**
     * The Stream Ad Block edit confirm page
     * 
     * @return void
     */
    public function streamsaddstreamconfirmAction()
    {

        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */

        $requiredParams = array(
            'label',
            'streamType',
            'streamType',
        );
        $optionalParams = array(
            'label',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $label = $input->label;
        $streamType = $input->streamType;
        $definition = array();
        $sortOrder = 99;
        $modelType = null;
        $status = 'inactive';

        switch ($streamType) {
            case 'AD_BLOCK':
                $definition = array (
                    "label" => $label,
                    "link" => array(
                        "modelType" => "streams",
                        "modelId" =>"2",
                        "deeplink" => "devmaverick://maverick/streams/2",
                    ),
                );
                $modelType = 'advertisement';
                break;
            case 'FEATURED_CHALLENGES':
                $definition = array (
                    "index" => 0,
                    "label" => $label,
                    "content" => array ( "challenge" ),
                    "responseVersion" => "v1",
                    "streamType" => "FEATURED_CHALLENGES",
                    "sortLogic" => "",
                    "logic" => array (
                        "displayLimit" => "10",
                        "rotateFrequency" => "12",
                        "rotateCount" => "10",
                        "lastRotated" => null
                    )
                );
                $modelType = 'challenge';
                break;
            case 'FEATURED_RESPONSES':
                $definition = array (
                    "index" => 0,
                    "label" => $label,
                    "content" => array ( "responses" ),
                    "responseVersion" => "v1",
                    "streamType" => "FEATURED_RESPONSES",
                    "sortLogic" => "",
                    "logic" => array (
                        "displayLimit" => "10",
                        "rotateFrequency" => "12",
                        "rotateCount" => "10",
                        "lastRotated" => null
                    )
                );
                $modelType = 'response';
                break;
            case 'LATEST_RESPONSES':
                $definition = array (
                    "index" => 0,
                    "label" => $label,
                    "content" => array ( "responses" ),
                    "responseVersion" => "v1",
                    "streamType" => $streamType,
                    "logic" => array (
                        "displayLimit" => "10",
                        "challengeId" => null,
                        "delay" => 0,
                        "backfill" => true,
                        "sort" => "created_ts",
                        "sort_order" => "desc",
                    )
                );
                $modelType = 'response';
                break;
        }

        // Create new stream
        $site->createStream( $label, $definition, $sortOrder, $modelType, $streamType, $status );

        // redirect to edit feature stream page
        $params = array(
            'confirmPage' => 'streamsAddStreamConfirm',
        );

        return $this->_redirect( $site->getUrl( 'streams', $params ) );
    }

    /**
     * The latest responses edit page
     *
     * @return void
     */
    public function latestresponseseditAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        $this->processInput( null, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'streamsLatestResponsesEdit' );
    }

    /**
     * The Stream Latest Responses edit confirm page
     * 
     * @return void
     */
    public function latestresponseseditconfirmAction()
    {

        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */

        $requiredParams = array(
            'streamId',
            'label',
            'contentStatus',
            'displayLimit',
            'delay',
        );
        $optionalParams = array(
            'paginated',
            'challengeId',
        );

        $input = $this->processInput( $requiredParams, $optionalParams, $errors );
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }


        $streamId = $input->streamId ?? null;
        $modelType = BeMaverick_Site::MODEL_TYPE_RESPONSE;
        $label = $input->label ?? null;
        $contentStatus = $input->contentStatus ?? null;
        $displayLimit = $input->displayLimit ?? null;
        $delay = $input->delay ?? null;
        $paginated = $input->paginated ?? null;

        /** Update Stream */
        if ($stream = $site->getStream($streamId)) {
            $stream->updateStreamFromInput($input);
            $stream->save();
        }

        // redirect to edit feature stream page
        $params = array(
            'confirmPage' => 'streamsLatestResponsesEditConfirm',
        );
        if($streamId) {
            $params['streamId'] = $streamId;
        }

        return $this->_redirect( $site->getUrl( 'streamsLatestResponsesEdit', $params ) );
    }

}