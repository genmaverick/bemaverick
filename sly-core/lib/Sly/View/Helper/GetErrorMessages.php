<?php

/**
 * Helper for creating html attribute string
 */
class Sly_View_Helper_GetErrorMessages
{
    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public $view;


    public function getErrorMessages( $messages = array(), $messagePrefix = '<span class="icon"></span> ', $includeAssociatedErrors = true, $includeUnassociatedErrors = true )
    {
        $xhtml = '';
        $errorMessages = array();

        // used to keep track of all displayed messages, so we can not display
        // the same ones twice (in case there are any).
        $messageMap = array();

        // print out the errors
        $errorMessages = array();

        if ( $this->view->errors->hasErrors() ) {
            foreach ( $this->view->errors->getErrors() as $thisError ) {

                $isAssociated = $thisError->getKey();
                if ( $isAssociated && !$includeAssociatedErrors ) {
                    continue;
                }
                if ( !$isAssociated && !$includeUnassociatedErrors ) {
                    continue;
                }

                $message = $thisError->getMessage();

                if ( in_array( $message, $messageMap ) ) {
                    continue;
                }

                $errorMessages[] = array( 'title' => $message );
                $messageMap[] = $message;
            }
        }

        if ( $messages ) {

            foreach ( $messages as $message ) {

                if ( in_array( $message, $messageMap ) ) {
                    continue;
                }

                $errorMessages[] = array( 'title' => $message );
            }
        }

        $numErrors = count( $errorMessages );

        if ( $numErrors > 1 ) {
            $errorHeading = $messagePrefix.'There were '. $numErrors .' errors.';
        } else {
            $errorHeading = $messagePrefix.'There was an error.';
        }

        if ( $numErrors ) {
            $xhtml .= '<div class="error">';
            $xhtml .= "<p>$errorHeading</p>";
            $xhtml .= $this->view->linkList( $errorMessages );
            $xhtml .= '</div>';
        }

        // print out the warnings
        $warningMessages = array();

        if ( $this->view->errors->hasWarnings() ) {

            foreach ( $this->view->errors->getWarnings() as $thisWarning ) {

                $message = $thisWarning->getMessage();

                if ( in_array( $message, $messageMap ) ) {
                    continue;
                }

                $warningMessages[] = array( 'title' => $message );
                $messageMap[] = $message;
            }
        }

        $numWarnings = count( $warningMessages );

        if ( $numWarnings > 1 ) {
            $warningHeading = $messagePrefix.'There were '. $numWarnings .' warnings.';
        } else {
            $warningHeading = $messagePrefix.'There was a warning.';
        }

        if ( $numWarnings ) {
            $xhtml .= '<div class="error">';
            $xhtml .= "<p>$warningHeading</p>";
            $xhtml .= $this->view->linkList( $warningMessages );
            $xhtml .= '</div>';
        }

        return $xhtml;

    }

    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }
}
