<?php

/**
 * @see Zend_Filter_Interface
 */
require_once 'Zend/Filter/Interface.php';


/**
 * @category   Sly
 * @package    Sly_Filter
 */
class Sly_Filter_StringLTrim implements Zend_Filter_Interface
{
    /**
     * List of characters provided to the trim() function
     *
     * If this is null, then trim() is called with no specific character list,
     * and its default behavior will be invoked, trimming whitespace.
     *
     * @var string|null
     */
    protected $_charList;

    /**
     * Sets filter options
     *
     * @param  string $charList
     * @return void
     */
    public function __construct($charList = null)
    {
        $this->_charList = $charList;
    }

    /**
     * Defined by Zend_Filter_Interface
     *
     * Returns the string $value with characters stripped from the beginning
     *
     * @param  string $value
     * @return string
     */
    public function filter($value)
    {
        if (null === $this->_charList) {
            return ltrim((string) $value);
        } else {
            return ltrim((string) $value, $this->_charList);
        }
    }
}
