<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Url.php' );
require_once( __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR . '/controllers/Base.php' );

class IndexController extends __SLY_CLASS_PREFIX___Controller_Base
{ 

    /**
     * The home page
     *
     * @return void
     */
    public function indexAction()
    {
        return $this->renderPage( 'home' );
    }

}
