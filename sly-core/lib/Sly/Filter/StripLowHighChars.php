<?php

/**
 * @see Zend_Filter_Interface
 */
require_once 'Zend/Filter/Interface.php';


/**
 * @category   Sly
 * @package    Sly_Filter
 */
class Sly_Filter_StripLowHighChars implements Zend_Filter_Interface
{
    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct()
    {
    }

    /**
     * Defined by Zend_Filter_Interface
     *
     * Returns the string $value, stripping the chars
     *
     * @param  string $value
     * @return string
     */
    public function filter($value)
    {
        return filter_var( $value, FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_LOW|FILTER_FLAG_NO_ENCODE_QUOTES|FILTER_FLAG_STRIP_HIGH );
    }
}
