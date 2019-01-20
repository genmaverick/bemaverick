<?php

/**
 * @see Zend_Filter_Interface
 */
require_once 'Zend/Filter/Interface.php';


/**
 * @category   Sly
 * @package    Sly_Filter
 */
class Sly_Filter_StripChars implements Zend_Filter_Interface
{
    /**
     * The chars to strip
     *
     * @var string
     **/
    protected static $_chars;

    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct( $chars = '' )
    {
        self::$_chars = $chars;
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
        return preg_replace( "/[" . self::$_chars . "]/", '', (string) $value );
    }
}
