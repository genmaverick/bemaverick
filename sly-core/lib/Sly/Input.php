<?php

/**
 * Zend_Filter_Input
 */
require_once( ZEND_ROOT_DIR . '/lib/Zend/Filter/Input.php' );

/**
 * Zend_Filter_HtmlEntities
 */
require_once( ZEND_ROOT_DIR . '/lib/Zend/Filter/HtmlEntities.php' );

/**
 * Class for handling input from the user
 *
 * @category Sly
 * @package Sly_Input
 */
class Sly_Input extends Zend_Filter_Input
{
    /**
     * @var array
     * @access protected
     */
    protected $_requiredParams = array();

    /**
     * @var array
     * @access protected
     */
    protected $_optionalParams = array();

    /**
     * @var array
     * @access protected
     */
    protected $_options = array();

    /**
     * @var array
     * @access protected
     */
    protected $_inputData = array();
    
    /**
     * @var array
     * @access protected
     */
    protected $_paramValues = array();

    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct( $requiredParams = null,
                                 $optionalParams = null,
                                 $options = null,
                                 $inputData = null,
                                 $customParamValues = null )
    {
        if ( ! $requiredParams ) {
            $requiredParams = array();
        }

        if ( ! $optionalParams ) {
            $optionalParams = array();
        }

        if ( ! $options ) {
            $options = array();
        }
        $options[Zend_Filter_Input::INPUT_NAMESPACE] = 'Sly_Filter';

        if ( ! $inputData ) {
            $inputData = $_REQUEST;
        }

        if ( $customParamValues ) {
            foreach( $customParamValues as $param => $values ) {
                $this->_paramValues[$param] = $values;
            }
        }

        $this->_requiredParams = $requiredParams;
        $this->_optionalParams = $optionalParams;
        $this->_options = $options;
        $this->_inputData = $inputData;

        $filters = array();
        $validators = array();

        $params = array_merge( $this->_requiredParams, $this->_optionalParams );

        foreach( $params as $param ) {

            if ( isset( $this->_paramValues[$param]['filters'] ) ) {
                $filters[$param] = $this->_paramValues[$param]['filters'];
            }

            if ( isset( $this->_paramValues[$param]['validators'] ) ) {
                $validators[$param] = $this->_paramValues[$param]['validators'];
            }

            // if the param is optional add allowEmpty flag
            if ( in_array( $param, $optionalParams ) ) {

                $validators[$param]['allowEmpty'] = true;

                // if the request object doesn't have it set, set it to blank
                if ( ! isset( $inputData[$param] ) ) {
                    $inputData[$param] = '';
                }
            }
        }

        parent::__construct( $filters, $validators, $inputData, $options );

    }

    /**
     * Validate all the params given. It will set any errors if any param is invalid
     *
     * @return void
     */
    public function validate( $errors )
    {
        $filter = new Zend_Filter_HtmlEntities();

        $params = array_merge( $this->_requiredParams, $this->_optionalParams );

        foreach( $params as $param ) {

            if ( ! $this->isValid( $param ) ) {
                $errorMessage = $this->_paramValues[$param]['errorStringIds']['message'];
                //$errorDescription = $this->_paramValues[$param]['errorStringIds']['description'];
                $errorDescription = null;
                $value = '';
                if ( isset( $this->_inputData[$param] ) ) {
                    $value = $filter->filter( $this->_inputData[$param] );
                }

                $errors->setError( $param, $errorMessage, $errorDescription, array( $value ) );
            }
        }

    }

}

?>
