<?php

$longOpts = array(
    'code:'
);

$options = getopt( null, $longOpts );

$code = $options['code'];

$packageExcludeDirs = array(
    '.git',
    'config/defines.php',
    'config/databases.php',
    'config/paths.php',
    'config/settings.php',
);

$packageIncludeDirs = array(
    'zend' => array(
        'lib',
    ),
    'sly' => array(
        'bin',
        'css',
        'js',
        'lib',
        'modules',
        'pages',
    ),
    'common' => array(
        '*',
    ),
    'api' => array(
        '*',
    ),
    'admin' => array(
        '*',
    ),
    'website' => array(
        '*',
    ),
    'database' => array(
        '*',
    ),
    'vendor' => array(
        '*',
    ),
    'scripts' => array(
        '*',
    ),
);

$rootDir = str_replace( '/packages', '', getcwd() );

// create the software_version.xml file
$packageBaseDir = $code;
if ( $code == 'sly' ) {
    $packageBaseDir = "$rootDir/../sly-core";
} else if ( $code == 'zend' ) {
    $packageBaseDir = "$rootDir/../zend";
} else {
    $packageBaseDir = "$rootDir/$code";
}

// create the software_version.xml file
print "$code: creating the software version file\n";
$versionTextFile = "$packageBaseDir/package_build_version.txt";

$revision = trim( `git describe --always` );

file_put_contents( $versionTextFile, $revision );

// set the package name
$packageName = "${code}_${revision}.tgz";

// remove the current tar.gz file
@unlink( $packageName );

// create the excludeDirsParam
$excludeDirsParam = '';
foreach ( $packageExcludeDirs as $dir ) {
    $excludeDirsParam .= "--exclude \"$dir\" ";
}

// create the includeDirsParam
$includeDirsParam = join( ' ', $packageIncludeDirs[$code] );
$includeDirsParam .= ' package_build_version.txt';

// tar up the package
print "$code: taring up the files\n";
if ( ! file_exists( 'builds' ) ) {
    mkdir( 'builds', 0755, true );
}

print "cd $packageBaseDir; tar -czf $rootDir/packages/builds/$packageName $excludeDirsParam $includeDirsParam\n";
system( "cd $packageBaseDir; tar -czf $rootDir/packages/builds/$packageName $excludeDirsParam $includeDirsParam" );

// remove the software_version.xml file
unlink( $versionTextFile );

exit( 0 );
?>
