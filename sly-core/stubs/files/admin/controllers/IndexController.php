<?php

require_once( __SLY_REPOSITORY_UPPERCASE_NAME___ROOT_DIR . '/common/lib/__SLY_CLASS_PREFIX__/Input.php' );
require_once( __SLY_REPOSITORY_UPPERCASE_NAME___ROOT_DIR . '/common/controllers/Base.php' );

class IndexController extends __SLY_CLASS_PREFIX___Controller_Base
{ 

    /**
     * @var string
     * @access protected
     */
    protected $_inputClassName = '__SLY_CLASS_PREFIX___Input';

    public function indexAction()
    {
        return $this->renderPage( 'home' );
    }

}

?>
