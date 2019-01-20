<?php

$EMAIL_ADDRESSES = array(
    'dev@bemaverick.com',
);

$SLACK_TOKEN = 'xoxb-316487704914-Eck49dcHqqjeTRc9gqxKkdGo';
$SLACK_CHANNEL = 'builds';

$CODE_TO_PACKAGE_NAME = array(
    'zend'               => 'zend_:version.tgz',
    'sly'                => 'sly_:version.tgz',
    'common'             => 'common_:version.tgz',
    'database'           => 'database_:version.tgz',
    'api'                => 'api_:version.tgz',
    'admin'              => 'admin_:version.tgz',
    'website'            => 'website_:version.tgz',
    'vendor'             => 'vendor_:version.tgz',
    'scripts'            => 'scripts_:version.tgz',
);

$CODE_TO_SYMLINK_NAME = array(
    'zend'               => 'zend',
    'sly'                => 'sly',
    'common'             => 'bemaverick/common',
    'database'           => 'bemaverick/database',
    'api'                => 'bemaverick/api',
    'admin'              => 'bemaverick/admin',
    'website'            => 'bemaverick/website',
    'vendor'             => 'bemaverick/vendor',
    'scripts'            => 'bemaverick/scripts',
);

$CODE_TO_BUILD_DESTINATION_DIR = array(
    'zend'               => '~/files/builds/zend_:version',
    'sly'                => '~/files/builds/sly_:version',
    'common'             => '~/files/builds/common_:version',
    'database'           => '~/files/builds/database_:version',
    'api'                => '~/files/builds/api_:version',
    'admin'              => '~/files/builds/admin_:version',
    'website'            => '~/files/builds/website_:version',
    'vendor'             => '~/files/builds/vendor_:version',
    'scripts'            => '~/files/builds/scripts_:version',
);

$ENVIRONMENT_TO_USER = array(
    'production' => 'bemaverick',
    'stage'      => 'bemaverick',
    'stage-dev'  => 'bemaverick',
    'dev'        => 'bemaverick',
);

$ENVIRONMENT_TO_HOSTS = array(
    'production' => array(
        'www01.usw1c.prd.bemaverick.com',
        'www02.usw1c.prd.bemaverick.com',
        'api01.usw1c.prd.bemaverick.com',
        'api02.usw1c.prd.bemaverick.com',
    ),
    'stage' => array(
        'www01.usw1c.stg.bemaverick.com',
    ),
    'stage-dev' => array(
        'www01.usw1c.stg.bemaverick.com',
    ),
    'dev' => array(
        '35.227.161.200',
    ),
);

$longOpts = array(
    'code:',
    'version:',
    'host:',
    'environment:',
);

$options = getopt( null, $longOpts );

$code = @$options['code'];
$version = @$options['version'] ? $options['version'] : trim( `git describe --always` );
$environment = @$options['environment'] ? $options['environment'] : 'dev';

print "code: $code\n";
print "version: $version\n";
print "environment: $environment\n";
print "\n";

if ( ! $code || ! $version || ! $environment ) {
    print "\nusage: php install_package.php --code all --version 4200 --environment dev\n\n";
    print "List of codes\n";
    print "----------------\n";
    print implode( "\n", array_keys( $CODE_TO_PACKAGE_NAME ) ) . "\n\n";
    exit( 1 );
}

// make sure code exists
if ( $code != 'all' &&  $code != 'setup' && ! in_array( $code, array_keys( $CODE_TO_PACKAGE_NAME ) ) ) {
    print "error: code does not exist: $code\n";
    exit( 1 );
}

$codes = array();

// if code is set to all, then do the sly, common and the actual site
if ( $code == 'setup' ) {
    $codes = array( 'zend', 'sly', 'common', 'database', 'api', 'admin', 'website', 'vendor', 'scripts');
} else if ( $code == 'all' ) {
    $codes = array( 'sly', 'common', 'database', 'api', 'admin', 'website','vendor', 'scripts');
} else {
    $codes = array( $code );
}

// get the user for this environment
$user = $ENVIRONMENT_TO_USER["$environment"];

// get the hosts
$hosts = $ENVIRONMENT_TO_HOSTS["$environment"];
if ( @$options['host'] ) {
    $hosts = array( $options['host'] );
}

// initialize the symlink commands
$symlinkCommands = array();

foreach ( $codes as $code ) {

    $packageName = $CODE_TO_PACKAGE_NAME[$code];

    // fix up the package name
    $packageName = str_replace( ':version', $version, $packageName );

    // make sure package exists before continueing
    if ( ! file_exists( "builds/$packageName" ) ) {
        print "error: package does not exist: 'builds/$packageName'\n";
        exit( 1 );
    }
    
    $buildDestinationDir = $CODE_TO_BUILD_DESTINATION_DIR[$code];
    $symlinkName = $CODE_TO_SYMLINK_NAME[$code];

    // fix up the build destination dir
    $buildDestinationDir = str_replace( ':version', $version, $buildDestinationDir );

    foreach ( $hosts as $index => $host ) {

        // Code for database package is only needed to be available on 1 host.
        if ( $code == 'database' && $index > 0 ) {
            continue;
        }

        // scp the package to the host
        print "scp -p builds/$packageName $user@$host:files/packages\n";
        system( "scp -p builds/$packageName $user@$host:files/packages" );
    }

    foreach ( $hosts as $index => $host ) {

        // Code for database package is only needed to be available on 1 host.
        if ( $code == 'database' && $index > 0 ) {
            continue;
        }

        $commands = array();

        $commands[] = "mkdir -p $buildDestinationDir";
        $commands[] = "tar xvf files/packages/$packageName -C $buildDestinationDir";

        // add symlink the defines.php file
        if ( $code == 'api' ) {
            $commands[] = "cd $buildDestinationDir/config";
            $commands[] = "ln -s defines_$environment.php defines.php";
            $commands[] = "cd ../htdocs";
            $commands[] = "mkdir -p cache";
            $commands[] = "chmod -R 777 cache";
        } else if ( $code == 'admin' ) {
            $commands[] = "cd $buildDestinationDir/config";
            $commands[] = "ln -s defines_$environment.php defines.php";
            $commands[] = "cd ../htdocs";
            $commands[] = "mkdir -p cache";
            $commands[] = "chmod -R 777 cache";
        } else if ( $code == 'common' ) {
            $commands[] = "cd $buildDestinationDir/config";
            $commands[] = "ln -s databases_$environment.php databases.php";
            $commands[] = "ln -s paths_$environment.php paths.php";
            $commands[] = "ln -s settings_$environment.php settings.php";
        } else if ( $code == 'website' ) {
            $commands[] = "cd $buildDestinationDir/config";
            $commands[] = "ln -s defines_$environment.php defines.php";
            $commands[] = "cd ../htdocs";
            $commands[] = "mkdir -p cache";
            $commands[] = "chmod -R 777 cache";
        } else if ( $code == 'scripts' ) {
            $commands[] = "cd $buildDestinationDir/config";
            $commands[] = "ln -s defines_$environment.php defines.php";
            $commands[] = "cd ../htdocs";
            $commands[] = "mkdir -p cache";
            $commands[] = "chmod -R 777 cache";
        } else if ( $code == 'database' ) {
            // Database package commands is needed to run from only 1 machine
            $commands[] = "cd $buildDestinationDir/config";
            $commands[] = "ln -s defines_$environment.php defines.php";
            $commands[] = "cd ..";
            $commands[] = "php ~/files/bemaverick/vendor/bin/phinx migrate -c bemaverick/phinx.php";
        }

        // go to the host and run the commands
        print "ssh $user@$host '" . join( '; ', $commands ) . "'\n";
        system( "ssh $user@$host '" . join( '; ', $commands ) . "'" );
    }

    foreach( $hosts as $host ) {

        // mv the symlink to the new version
        $symlinkCommands[$host][] = "rm -rf $symlinkName";
        $symlinkCommands[$host][] = "ln -s $buildDestinationDir $symlinkName";
    }
}

// do the symlink and apache restart commands on each host
foreach ( $symlinkCommands as $host => $commands ) {

    array_unshift( $commands, 'cd files' );

    $commands[] = 'sudo /etc/init.d/apache2 reload';

    print "ssh $user@$host '" . join( '; ', $commands ) . "'\n";
    system( "ssh $user@$host '" . join( '; ', $commands ) . "'" );
}

$previousVersionFilename = "/tmp/bemaverick-$environment-git-rev.txt";
$previousVersion = @file_get_contents( $previousVersionFilename );
@file_put_contents( $previousVersionFilename, $version );

if ( $previousVersion ) {
    $commits = `git log --oneline $version...$previousVersion`;
} else {
    $commits = `git log --oneline $version -n 1`;
}

$commits = trim( $commits );

$message = "Build: Maverick - $environment - $version - " . date( 'M j' ) . ' at ' . date( 'g:iA' );
$message .= " ```$commits```";
$message = urlencode( $message );

// send to slack channel
$slackApiUrl = "https://slack.com/api/chat.postMessage?text=$message&pretty=1&token=$SLACK_TOKEN&channel=$SLACK_CHANNEL";
@file_get_contents( $slackApiUrl );

exit( 0 );
