<?php
/**
 * Sly
 *
 * @category   Sly
 * @package    Sly_Cookie
 */

/**
 * Class for managing cookies
 *
 * @category Sly
 * @package Sly_Cookie
 */
class Sly_Cookie
{

    const LEVEL1_LIST_SEPARATOR = '&';
    const LEVEL1_KEY_SEPARATOR = '=';

    /**
     * Encode the cookie array hash into a string
     *
     * @param hash $data
     * @return string
     */
    public static function encodeData( $data )
    {
        $parts = array();

        foreach( $data as $key => $value ) {

            $parts[] = $key.self::LEVEL1_KEY_SEPARATOR.$value;
        }

        return join( self::LEVEL1_LIST_SEPARATOR, $parts );
    }

    /**
     * Decode the cookie string into an array hash
     *
     * @param string $string
     * @return hash
     */
    public static function decodeString( $string )
    {
        if ( ! $string ) {
            return array();
        }

        $data = array();

        $parts = explode( self::LEVEL1_LIST_SEPARATOR, $string );

        foreach( $parts as $part ) {
            list( $key, $value ) = explode( self::LEVEL1_KEY_SEPARATOR, $part );

            $data[$key] = $value;
        }

        return $data;
    }

}

?>
