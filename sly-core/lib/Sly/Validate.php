<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Validate/EmailAddress.php' );

class Sly_Validate
{

    /**
     * Checks if value is between min and max inclusive
     *
     * @return integer
     */
    public static function isBetween( $value, $min, $max )
    {
        if ( ($min === null || $value >= $min) && 
             ($max === null || $value <= $max) ) {
            return 1;
        }

        return 0;
    }
    
    /**
     * Check if text has all valid email addresses
     *
     * @param string $emailAddressesText
     * @return boolean
     */
    public static function isEmailAddresses( $emailAddressesText )
    {
        $emailAddressValidate = new Zend_Validate_EmailAddress();

        $emailAddresses = preg_split( "/[\s,;]+/", $emailAddressesText );

        foreach( $emailAddresses as $emailAddress ) {

            $emailAddress = trim( $emailAddress );

            if ( ! $emailAddressValidate->isValid( $emailAddress ) ) {
                return false;
            }
        }
        
        return true;
    }    
}
