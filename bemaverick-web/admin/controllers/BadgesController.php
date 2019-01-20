<?php


require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class BadgesController extends BeMaverick_Controller_Base
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

        return $this->renderPage( 'badges' );
    }


    /**
     * The badges edit confirm page
     *
     * @return void
     */
    public function badgeseditconfirmAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $site = $this->view->site;                   /* @var BeMaverick_Site $site */

        // $input = $this->processInput( $requiredParams, null, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        $badgeIds = @$_REQUEST['badgeIds'] ? $_REQUEST['badgeIds'] : array();

        $sortOrder = 1;
        // print("<pre>\$responseIds => ".print_r($responseIds,true)."</pre>");
        // print("<pre>\$_REQUEST => ".print_r($_REQUEST,true)."</pre>");
        // exit();
        foreach ( $badgeIds as $badgeId ) {

            $badge = $site->getBadge( $badgeId );

            error_log("setStortOrder : ".$badgeId." = ".$sortOrder);
            $badge->setSortOrder($sortOrder);

            $sortOrder++;
        }

        // // redirect to page
        $params = array(
            'confirmPage' => 'badgesEditConfirm',
        );

        return $this->_redirect( $site->getUrl( 'badges', $params ) );
    }


}