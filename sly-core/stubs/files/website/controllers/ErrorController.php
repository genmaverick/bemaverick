<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Controller/Error.php' );
require_once( __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR  . '/lib/__SLY_CLASS_PREFIX__/Input.php' );

class ErrorController extends Sly_Controller_Error
{ 
    /**
     * @var string
     * @access protected
     */
    protected $_inputClassName = '__SLY_CLASS_PREFIX___Input';
    
}

?>
