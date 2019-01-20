<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Controller/Error.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Input.php' );

class ErrorController extends Sly_Controller_Error
{ 
    /**
     * @var string
     * @access protected
     */
    protected $_inputClassName = 'BeMaverick_Input';
    
}

?>
