<?php

/**
 * Sly_Error
 */
require_once( SLY_ROOT_DIR . '/lib/Sly/Error.php' );

/**
 * Class for management of errors
 *
 * @category Sly
 * @package Sly_Errors
 */
class Sly_Errors
{
    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = NULL;

    /**
     * @var array
     * @access protected
     */
    protected $_errors = array();

    /**
     * @var array
     * @access protected
     */
    protected $_warnings = array();
    
    /**
     * Retrieves the errors instance.
     *
     * @return Sly_Errors
     */
    public static function getInstance()
    {
        if ( ! self::$_instance ) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }

    /**
     * Clear all errors
     *
     * @return void
     */
    public function clearErrors()
    {
        $this->_errors = array();
    }
    
    /**
     * Set an error 
     *
     * @param string $key The key of the error
     * @param string $messageStringId The message string id for the error
     * @param string $descriptionStringId The description string id for the error
     * @param array $params An array of params for the error message
     * @return void
     */
    public function setError( $key, 
                              $messageStringId,
                              $descriptionStringId = NULL,
                              $params = array() )
    {
        if ( ! isset( $this->_errors[$key] ) ) {
            $this->_errors[$key] = array();
        }

        // don't add a new error if it is already in there
        $found = false;
        foreach( $this->_errors[$key] as $error ) {
            if ( $error->getMessageStringId() == $messageStringId ) {
                $found = true;
            }
        }

        if ( ! $found ) {
            $this->_errors[$key][] = new Sly_Error( $key, $messageStringId, $descriptionStringId, $params );
        }
    }

    /**
     * Add a set of errors
     *
     * @param array A list of error objects
     * @return void
     */
    public function addError( $error )
    {
        $key = $error->getKey();

        if ( ! isset( $this->_errors[$key] ) ) {
            $this->_errors[$key] = array();
        }

        $this->_errors[$key][] = $error;
    }

    /**
     * Add a set of errors
     *
     * @param array A list of error objects
     * @return void
     */
    public function addErrors( $errors )
    {
        foreach( $errors as $error ) {
            $this->addError( $error );
        }
    }
    
    /**
     * Check if any errors have been set
     *
     * @return boolean True if errors have been set; false otherwise
     */
    public function hasErrors( $key = NULL )
    {
        if ( $key ) {
            if ( isset( $this->_errors[$key] ) && count( $this->_errors[$key] ) > 0 ) {
                return true;
            }
            return false;
        }
        else {
            if ( count( $this->_errors ) > 0 ) {
                return true;
            }
        }

        return false;
    }
    
    /**
     * Get a list of errors for a given key
     *
     * @param string $key Optional; The key for the errors
     * @return array A list of errors
     */
    public function getErrors( $key = NULL )
    {
        $errors = array();
        if ( ! $key ) {
            foreach( $this->_errors as $key => $thisErrors ) {
                $errors = array_merge( $errors, $thisErrors );
            }
        }
        else {
            $errors = $this->_errors[$key];
        }

        return $errors;
    }

    /**
     * Print the list of errors (used for command-line)
     *
     * @return void
     */
    public function printErrors()
    {
        $errors = $this->getErrors();

        foreach( $errors as $error ) {
            print $error->getMessage() . "\n";
        }
    }

    /**
     * Get list of error messages
     *
     * @return void
     */
    public function getMessages()
    {
        $errors = $this->getErrors();

        $messages = array();
        foreach( $errors as $error ) {
            $messages[] = $error->getMessage();
        }

        return $messages;
    }

    /**
     * Set a wanring
     *
     * @param string $key The key of the warning
     * @param string $messageStringId The message string id for the warning
     * @param string $descriptionStringId The description string id for the warning
     * @param array $params An array of params for the warning message
     * @return void
     */
    public function setWarning( $key, 
                                $messageStringId,
                                $descriptionStringId = null,
                                $params = array() )
    {
        if ( ! isset( $this->_warnings[$key] ) ) {
            $this->_warnings[$key] = array();
        }

        // don't add a new warning if it is already in there
        $found = false;
        foreach( $this->_warnings[$key] as $error ) {
            if ( $error->getMessageStringId() == $messageStringId ) {
                $found = true;
            }
        }

        if ( ! $found ) {
            $this->_warnings[$key][] = new Sly_Error( $key, $messageStringId, $descriptionStringId, $params );
        }
    }

    /**
     * Get a list of warnings for a given key
     *
     * @param string $key Optional; The key for the warnings
     * @return array A list of Sly_Error objects
     */
    public function getWarnings( $key = NULL )
    {
        $warnings = array();
        if ( ! $key ) {
            foreach( $this->_warnings as $key => $thisWarnings ) {
                $warnings = array_merge( $warnings, $thisWarnings );
            }
        }
        else {
            $warnings = $this->_warnings[$key];
        }

        return $warnings;
    }

    /**
     * Check if any warnings have been set
     *
     * @return boolean True if warnings have been set; false otherwise
     */
    public function hasWarnings( $key = NULL )
    {
        if ( $key ) {
            if ( isset( $this->_warnings[$key] ) &&
                 count( $this->_warnings[$key] ) > 0 ) {
                return true;
            }
            return false;
        }
        else {
            if ( count( $this->_warnings ) > 0 ) {
                return true;
            }
        }

        return false;
    }
    
}

?>
