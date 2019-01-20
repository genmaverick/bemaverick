<?php
require_once( ZEND_ROOT_DIR . '/lib/Zend/Controller/Plugin/Abstract.php' );

class Sly_Controller_Plugin_SiteDown extends Zend_Controller_Plugin_Abstract
{

    public function dispatchLoopStartup( Zend_Controller_Request_Abstract $request )
    {
        $systemConfig = Zend_Registry::get( 'systemConfig' );

        if ( $systemConfig->isSiteDown() ) {
            $request->setControllerName( 'index' );
            $request->setActionName( 'siteDown' );
        }

    }

}

?>
