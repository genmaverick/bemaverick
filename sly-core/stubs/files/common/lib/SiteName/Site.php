<?php

require_once( SLY_ROOT_DIR      . '/lib/Sly/Url.php' );

/**
 * Class for management of the entire site
 *
 */
class __SLY_CLASS_PREFIX___Site
{
    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = null;

    /**
     * Retrieves the site instance.
     *
     * @return __SLY_CLASS_PREFIX___Site
     */
    public static function getInstance()
    {
        if ( ! self::$_instance ) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }

}

?>
