<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class IndexController extends BeMaverick_Controller_Base
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

?>
