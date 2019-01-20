<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Controller/Cache.php' );
require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Input.php' );

class CacheController extends Sly_Controller_Cache
{
    /**
     * @var string
     * @access protected
     */
    protected $_inputClassName = 'BeMaverick_Input';


}
