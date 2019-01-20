<?php
$args = 'o:s:p:n:';

$options = getopt( $args );

if ( ! @$options['o'] || ! @$options['s'] || ! @$options['p'] || ! @$options['n'] ) {
    print "You must specify the following options:\n";
    print "-o object\n";
    print "-s plural object\n";
    print "-p path to where the files go\n";
    print "-n primary nav\n";
    print "\n";
    exit;
}

// create the pages
$files = split( "\n", trim( `ls ../pages/` ) );

foreach( $files as $file ) {
    $fileContents = file_get_contents( "../pages/$file" );
    
    $fileContents = str_replace( 'objects', $options['s'], $fileContents );
    $fileContents = str_replace( 'Objects', ucfirst($options['s']), $fileContents );
    $fileContents = str_replace( 'object', $options['o'], $fileContents );
    $fileContents = str_replace( '_primary_nav_', $options['n'], $fileContents );
    
    $newFile = $file;
    
    $newFile = str_replace( 'objects', $options['s'], $newFile );
    $newFile = str_replace( 'object', $options['o'], $newFile );
    
    file_put_contents( $options['p']."/pages/$newFile", $fileContents );
}

// create the modules
$files = split( "\n", trim( `ls ../modules/` ) );

foreach( $files as $file ) {
    $fileContents = file_get_contents( "../modules/$file" );
    
    $fileContents = str_replace( 'objects', $options['s'], $fileContents );
    $fileContents = str_replace( 'Objects', ucfirst($options['s']), $fileContents );
    $fileContents = str_replace( 'object', $options['o'], $fileContents );
    $fileContents = str_replace( 'Object', ucfirst($options['o']), $fileContents );
    
    $newFile = $file;
    
    $newFile = str_replace( 'objects', $options['s'], $newFile );
    $newFile = str_replace( 'object', $options['o'], $newFile );
    
    file_put_contents( $options['p']."/modules/$newFile", $fileContents );
}

// create the helper
$files = split( "\n", trim( `ls ../helpers/` ) );

foreach( $files as $file ) {
    $fileContents = file_get_contents( "../helpers/$file" );
    
    $fileContents = str_replace( 'objects', $options['s'], $fileContents );
    $fileContents = str_replace( 'Objects', ucfirst($options['s']), $fileContents );
    $fileContents = str_replace( 'object', $options['o'], $fileContents );
    $fileContents = str_replace( 'Object', ucfirst($options['o']), $fileContents );
    
    $newFile = $file;
    
    $newFile = str_replace( 'objects', $options['s'], $newFile );
    $newFile = str_replace( 'Objects', ucfirst($options['s']), $newFile );
    $newFile = str_replace( 'object', $options['o'], $newFile );
    $newFile = str_replace( 'Object', ucfirst($options['o']), $newFile );
    
    file_put_contents( $options['p']."/helpers/$newFile", $fileContents );
}

// print out the urls
$fileContents = file_get_contents( '../config/urls.xml' );

$fileContents = str_replace( 'objects', $options['s'], $fileContents );
$fileContents = str_replace( 'Objects', ucfirst($options['s']), $fileContents );
$fileContents = str_replace( 'object', $options['o'], $fileContents );
$fileContents = str_replace( 'Object', ucfirst($options['o']), $fileContents );
$fileContents = str_replace( '_primary_nav_', $options['n'], $fileContents );

print "\n---------URLS--------\n$fileContents\n\n";

?>
