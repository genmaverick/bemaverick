#! /usr/bin/php
<?php

/**
 * Created by: Chris Fitkin
 * Created on: 7/25/2018
 * 
 * Example usage
 * ./migrate_hashtags.php -c 1000 # processes the last 1000 challenges
 */

require_once( '../../config/setup_environment.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
            // 'file=s'  => '[Required] The config file to load for the streams',
            'challenges|c=i'     => '[Optional] Maximum number of challenges to process',
            'responses|r=i'      => '[Optional] Maximum number of responses to process',
            'users|u=i'          => '[Optional] Maximum number of users to process',
        )
    );

    $options->parse();
}
catch( Zend_Console_Getopt_Exception $e ) {
    print $e->getUsageMessage();
    exit( 1 );
}

$logger = new Sly_Log( $options );

try {

    $logger->start();

    $site = Zend_Registry::get( 'site' );               /* @var BeMaverick_Site $site */
    $logger->info('$site => '.var_export(!empty($site),true));

    /**
     * Config
     */
    $maxChallenges = $options->challenges ?? 0;
    $maxResponses = $options->responses ?? 0;
    $maxUsers = $options->users ?? 0;
    $logger->info();
    $logger->info('***** CONFIG *****');
    $logger->info('$maxChallenges = '.$maxChallenges);
    $logger->info('$maxResponses = '.$maxResponses);
    $logger->info('$maxUsers = '.$maxUsers);

    /**
     * Publish Challenges to SNS changeContent
     */
    $logger->info();
    $logger->info('***** CHALLENGES *****');
    $logger->info('$site->getChallenges()');
    $challenges = $site->getChallenges();
    $countChallenges = count($challenges);
    $logger->info('count($challenges) => ' . $countChallenges);
    $i = 0;
    foreach ( $challenges as $challenge ) {
        $i++;
        if ($i > $maxChallenges)
            break;
        $id = $challenge->getID();
        $title = $challenge->getTitle();
        $description = $challenge->getDescription();
        $challenge->setHashtags( $description );
        $challenge->save();
        $result = $challenge->publishChange( $site, 'UPDATE' );
        $logger->info("challenge #$i/$countChallenges :: id:$id :: $title :: SNS $result");
    }

    /**
     * Publish Responses to SNS changeContent
     */
    $logger->info();
    $logger->info('***** RESPONSES *****');
    $logger->info('$site->getResponses()');
    $responses = $site->getResponses();
    $countResponses = count($responses);
    $logger->info('count($responses) => ' . $countResponses);
    $i = 0;
    foreach ( $responses as $response ) {
        $i++;
        if ($i > $maxResponses)
            break;
        $id = $response->getID();
        $title = $response->getTitle();
        $description = $response->getDescription();
        $response->setHashtags( $description );
        $response->save();
        $result = $response->publishChange( $site, 'UPDATE' );
        $logger->info("response #$i/$countResponses :: id:$id :: $title :: SNS $result");
    }

    /**
     * Publish User to SNS changeContent
     */
    $logger->info();
    $logger->info('***** USERS *****');
    $logger->info('$site->getUsers()');
    $users = $site->getUsers();
    $countUsers = count($users);
    $logger->info('count($users) => ' . $countUsers);
    $i = 0;
    foreach ( $users as $user ) {
        $i++;
        if ($i > $maxUsers)
            break;
        if (!$user) {
            $logger->info("user #$i/$countUsers :: id:$id :: ERROR: invalid user object");
            continue;
        }
        $id = $user->getID();
        $title = $user->getUsername();
        if(method_exists($user, 'getBio')) {
            $bio = $user->getBio();
            $user->setHashtags( $bio );
            $user->save();
        }
        $result = $user->publishChange( $site, 'UPDATE' );
        $logger->info("user #$i/$countUsers :: id:$id :: $title :: SNS $result");
    }

    $logger->end();
}
catch( Exception $e ) {
    $logger->err( $e->getMessage() );
    print $e->getMessage();
    exit( 1 );
}

exit( 0 );

/**
 * Convert tags table into #description #field #hashtags
 */
/*

update challenge as c
inner join
  (select
     ifnull(concat(
         c.description,
         ' #',
         replace( replace( group_concat(t.name separator ' '), '#', '') , ' ', ' #')
     ), c.description) as description,
     c.challenge_id
   from challenge c
     left join challenge_tags ct on ct.challenge_id = c.challenge_id
     left join tag t on t.tag_id = ct.tag_id
   group by c.challenge_id
) new on new.challenge_id = c.challenge_id
set c.description = new.description;

select c.description, c.* from challenge c where c.description is not null and c.status = 'published' order by c.challenge_id desc;

update response as r
inner join
  (select
     ifnull(concat(
         r.description,
         ' #',
         replace( replace( group_concat(t.name separator ' '), '#', '') , ' ', ' #')
     ), r.description) as description,
     r.response_id
   from response r
     left join response_tags rt on rt.response_id = r.response_id
     left join tag t on t.tag_id = rt.tag_id
   group by r.response_id
) new on new.response_id = r.response_id
set r.description = new.description;

select r.description, r.* from response r;
*/