<?php

class __SLY_CLASS_PREFIX___Validator
{
    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = null;

    /**
     * Retrieves the validator instance.
     *
     * @return __SLY_CLASS_PREFIX___Validator
     */
    public static function getInstance()
    {
        if ( ! isset( self::$_instance ) ) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }

}


?>
