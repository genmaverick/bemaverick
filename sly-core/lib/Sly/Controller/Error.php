<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Controller/Base.php' );

class Sly_Controller_Error extends Sly_Controller_Base
{ 

    public function indexAction()
    {
        if ( $this->view->ajax ) {
            return $this->renderPage( 'genericAjax' );
        }

        return $this->renderPage( 'errors' );
    }

    public function errorAction()
    {
        $error = $this->_getParam( 'error_handler' );

        // set the exceptions if there are any
        $this->view->exceptions = $this->getResponse()->getException();

        // if it is a page not found, then show that page
        if ( $error &&
             ($error->type == 'EXCEPTION_NO_CONTROLLER' ||
             $error->type == 'EXCEPTION_NO_ACTION')  ) {

            $response = $this->getResponse();
            $response->setHttpResponseCode( 404 );

            // if ajax, always return notfoundAjax
            if ( $this->view->ajax ) {
                return $this->renderPage( 'notfoundAjax' );
            }

            return $this->renderPage( 'notfound' );
        }

        $response = $this->getResponse();
        $response->setHttpResponseCode( 500 );

        if ( $this->view->ajax ) {
            return $this->renderPage( 'internalErrorAjax' );
        }

        return $this->renderPage( 'internalError' );
    }

    public function notfoundAction()
    {
        $response = $this->getResponse();
        $response->setHttpResponseCode( 404 );

        if ( $this->view->ajax ) {
            return $this->renderPage( 'notfoundAjax' ); 
        }

        return $this->renderPage( 'notfound' );
    }
    
}

?>
