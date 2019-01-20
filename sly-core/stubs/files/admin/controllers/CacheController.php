<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Controller/Cache.php' );
require_once( __SLY_REPOSITORY_UPPERCASE_NAME___ROOT_DIR  . '/common/lib/__SLY_CLASS_PREFIX__/Input.php' );

class CacheController extends Sly_Controller_Cache
{
    /**
     * @var string
     * @access protected
     */
    protected $_inputClassName = '__SLY_CLASS_PREFIX___Input';


}
