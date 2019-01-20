<?php
class Sly_FileFinder
{

    public static function findFile( $file, $dirs )
    {
        foreach( $dirs as $dir ) {
            if ( file_exists( "$dir/$file" ) ) {
                return "$dir/$file";
            }
        }
        
        return false;
    }

    public static function findFileStat( $file, $dirs ) {

        foreach( $dirs as $dir ) {

            if ( ($stat = @stat( "$dir/$file" ) ) != FALSE ) {
                
                return array('path' => "$dir/$file",
                             'mtime' => $stat['mtime']);
            }
        }
        
        return false;        
    }
}

?>
