<?php
require_once( SLY_ROOT_DIR . '/lib/Sly/Date.php' );

/**
 * Class for spreadsheets
 *
 * @category Sly
 * @package Sly_Spreadsheet
 */
class Sly_Spreadsheet
{

    /**
     * Create a multi-dimensional array
     *
     * @return array
     */
    public static function getArray( $file, $type )
    {

        $data = array();

        if ( $type == 'csv' ) {

            $handle = fopen( $file, 'r' );

            if ( $handle ) {
                $row = 0;
                while (($line = fgetcsv($handle, 0, ',')) !== FALSE) {
                    $foundValue = false;
                    foreach( $line as $value ) {
                        if ( $value != '' ) {
                            $foundValue = true;
                        }
                    }

                    if ( ! $foundValue ) {
				       continue;
				    }

                    $data[$row] = $line;
                    $row++;
                }
            }

            fclose($handle);
        }
        else if ( $type == 'xls' ) {
            error_log( "Sly_Spreadsheet::getArray xls no longer supported" );
        }
        else if ( $type == 'xlsx' ) {
            error_log( "Sly_Spreadsheet::getArray xlsx no longer supported" );
        }

        return $data;

    }

    /**
     * Create a csv or excel file
     *
     * @return boolean
     */
    public static function createFile( $file, $type, $data )
    {

        if ( $type == 'csv' ) {

            $handle = fopen( $file, 'w' );

            if ( $handle ) {
                foreach( $data as $rowNum => $fields ) {
                    fputcsv( $handle, $fields );
                }
            }

            fclose($handle);
        }
        else if ( $type == 'xls' ) {
            error_log( "Sly_Spreadsheet::createFile xls no longer supported" );

            // not currently supported
            return false;
        }

        return true;
    }

    /**
     * Create a spreadsheet
     *
     * @return string
     */
    public static function getSpreadsheet( $type, $data, $title )
    {

        $contents = false;

        if ( $type == 'csv' ) {

            // write the data to the file
            $tempFile = tempnam( SYSTEM_TEMP_DIR, 'SLY_' );

            self::createFile( $tempFile, $type, $data );

            $contents = file_get_contents( $tempFile );

            unlink( $tempFile );
        }
        else if ( $type == 'xls' ) {
            error_log( "Sly_Spreadsheet::getSpreadsheet xls no longer supported" );
        }

        return $contents;
    }  
}
    
?>
