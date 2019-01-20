<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class AutocompleteController extends BeMaverick_Controller_Base
{

    /**
     * The challenges
     *
     * @return void
     */
    public function challengesAction()
    {
        // get the view variables
        $errors = $this->view->errors;

        // set the inputs
        $optionalParams = array(
            'query',
        );

        // process the input and validate
        $this->processInput( null, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'autocompleteChallenges' );
    }

    /**
     * The responses
     *
     * @return void
     */
    public function responsesAction()
    {
        // get the view variables
        $errors = $this->view->errors;

        // set the inputs
        $optionalParams = array(
            'query',
        );

        // process the input and validate
        $this->processInput( null, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'autocompleteResponses' );
    }

    /**
     * The users
     *
     * @return void
     */
    public function usersAction()
    {
        // get the view variables
        $errors = $this->view->errors;

        // set the inputs
        $optionalParams = array(
            'query',
        );

        // process the input and validate
        $this->processInput( null, $optionalParams, $errors );

        // check if there were any errors
        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'errors' );
        }

        return $this->renderPage( 'autocompleteUsers' );
    }

}

?>
