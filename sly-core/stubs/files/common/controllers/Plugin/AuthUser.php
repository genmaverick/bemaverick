<?php
require_once( ZEND_ROOT_DIR     . '/lib/Zend/Controller/Plugin/Abstract.php' );
require_once( ZEND_ROOT_DIR     . '/lib/Zend/Http/Client.php' );
require_once( ZEND_ROOT_DIR     . '/lib/Zend/Validate/Digits.php' );
require_once( ZEND_ROOT_DIR     . '/lib/Zend/Translate.php' );
require_once( SLY_ROOT_DIR      . '/lib/Sly/Errors.php' );

class __SLY_CLASS_PREFIX___Controller_Plugin_AuthUser extends Zend_Controller_Plugin_Abstract
{

    public function dispatchLoopStartup( Zend_Controller_Request_Abstract $request )
    {
        $viewRenderer = Zend_Controller_Action_HelperBroker::getStaticHelper( 'viewRenderer' );
        $viewRenderer->initView();
        
        // add the errors instance to the view
        $errors = Sly_Errors::getInstance();
        $viewRenderer->view->errors = $errors;

        
        // add if ajax request to the view
        $ajax = $this->_request->getHeader('Ajax-Request');
        $viewRenderer->view->ajax = $ajax;

        // add the system config to the view
        $systemConfig = Zend_Registry::get( 'systemConfig' );
        $viewRenderer->view->systemConfig = $systemConfig;

        // add the validator instance to the view
        $validator = Zend_Registry::get( 'validator' );
        $viewRenderer->view->validator = $validator;

        // if this is the cache controller, then don't do any user auth
        if ( $request->getControllerName() == 'cache' ) {
            return;
        }

        // add the site to the view
        $site = Zend_Registry::get( 'site' );
        $viewRenderer->view->site = $site;
    }

}

?>
