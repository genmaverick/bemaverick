<?php

/**
 * @see Zend_Filter_Interface
 */
require_once 'Zend/Filter/Interface.php';


/**
 * @category   Sly
 * @package    Sly_Filter
 */
class Sly_Filter_ReplaceSmartQuotes implements Zend_Filter_Interface
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
        $search = array(
            "\xe2\x80\x99", 
            "\xe2\x80\x9c",
            "\xe2\x80\x9d",
            "\xe2\x80\x93",
            "\xe2\x80\x94",
        );
 
        $replace = array(
            "'", 
            '"', 
            '"', 
            '-',
            '-',
        );

        return str_replace($search, $replace, $value); 
    }
}
