<?php

/**
 * Class for specialize array manipulation functions
 *
 * @description This class has Array functions
 * @category Sly
 * @package Sly
 * @subpackage Sly_Array
 */
class Sly_Array
{
    /**
     * Split a two demensional array by keys
     *
     * The combined array is a array of rows.  Each row will be split into new
     * nows according to the keys in the setDefinitions
     *
     * @param array $combinedArray An array of rows with keys in each row
     * @param hash $setDefinitions A hash of the sets and the keys to include.
     *                             Exp: array( 'set1' => array( 'a', 'b', 'c' ),
     *                                         'set2' => array( 'd', 'e'), 
     *                                       )
     * @return hash The returned hash will be split into sets with each set's
     *              new array.  From the above setDefinitions it might be:
     *              array( 'set1' => array( array( 'a' => 1, 'b' => 2, 'c' => 3 ),
     *                                      array( 'a' => 6, 'b' => 7, 'c' => 8 ),
     *                                    ),
     *                     'set2' => array( array( 'd' => 4, 'e' => 5 ),
     *                                      array( 'd' => 9, 'e' => 10 ),
     *                                    ),
     *                   )
     */
    public static function splitArrayByKeys( $combinedArray, $setDefinitions )
    {
        $resultArray = array();
        
        foreach( $combinedArray as $row ) {
            foreach( $setDefinitions as $setName => $set ) {
                
                $newRow = array();
                
                foreach( $set as $item ) {
                    $newRow[$item] = $row[$item];
                }
                
                $resultArray[$setName][] = $newRow;
            }
        }
        
        return $resultArray;                                              
    }
}

?>
