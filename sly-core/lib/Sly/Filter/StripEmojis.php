<?php

/**
 * @see Zend_Filter_Interface
 */
require_once 'Zend/Filter/Interface.php';


/**
 * @category   Sly
 * @package    Sly_Filter
 */
class Sly_Filter_StripEmojis implements Zend_Filter_Interface
{

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
        $value = (string) $value;
        
        // Match Emoticons
        $regexEmoticons = '/[\x{1F600}-\x{1F64F}]/u';
        $value = preg_replace($regexEmoticons, '', $value);
    
        // Match Miscellaneous Symbols and Pictographs
        $regexSymbols = '/[\x{1F300}-\x{1F5FF}]/u';
        $value = preg_replace($regexSymbols, '', $value);
    
        // Match Transport And Map Symbols
        $regexTransport = '/[\x{1F680}-\x{1F6FF}]/u';
        $value = preg_replace($regexTransport, '', $value);
    
        // Match Miscellaneous Symbols
        $regexMisc = '/[\x{2600}-\x{26FF}]/u';
        $value = preg_replace($regexMisc, '', $value);
    
        // Match Dingbats
        $regexDingbats = '/[\x{2700}-\x{27BF}]/u';
        $value = preg_replace($regexDingbats, '', $value);
    
        return $value;
    }

}
