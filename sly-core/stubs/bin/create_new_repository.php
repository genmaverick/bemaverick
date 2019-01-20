<?php
include( "config.php" );

$repositoryDir = $config['repositoryDir'];

// make the repo dir
print "mkdir -p $repositoryDir\n";
system( "mkdir -p $repositoryDir" );

// copy the files over to the repo
print "cp -r ../files/* $repositoryDir\n";
system( "cp -r ../files/* $repositoryDir" );
system( "mv $repositoryDir/common/lib/SiteName $repositoryDir/common/lib/{$config['classPrefix']}" );

// go through every directory and do the replacement
$files = `find $repositoryDir -regextype posix-egrep -regex ".*\.*$"`;

$files = explode( "\n", trim( $files ) );

foreach( $files as $file ) {
    
    if ( is_dir( $file ) ) {
        continue;
    }
        
    $fileContents = file_get_contents( $file );
    
    foreach( $config['replace'] as $key => $value ) {
        $fileContents = str_replace( $key, $value, $fileContents );
    }
    
    file_put_contents( $file, $fileContents );
}

// setup the defines
system( "cd $repositoryDir/website/config; ln -s defines_slytrunk_devel.php defines.php" );
system( "cd $repositoryDir/admin/config; ln -s defines_slytrunk_devel.php defines.php" );

$classPrefix = $config['classPrefix'];
$databaseName = $config['databaseName'];
$daDir = "$repositoryDir/common/lib/$classPrefix/Da";
$modelDir = "$repositoryDir/common/lib/$classPrefix";

system( "SITE_HOME=$repositoryDir/website php generate_da.php --class_prefix $classPrefix --database_name $databaseName --output_dir $daDir" );
system( "SITE_HOME=$repositoryDir/website php generate_model.php --class_prefix $classPrefix --database_name $databaseName --output_dir $modelDir" );

?>
