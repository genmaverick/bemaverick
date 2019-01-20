<?php

$timestamp = time();

$emailAddress = @$argv[1] ? $argv[1] : 'shawn@slytrunk.com';
$password = @$argv[2] ? $argv[2] : 'test';

$appKey = 'test_key';
$appSecret = 'test_secret';

print "/v1/oauth/token?grant_type=password&client_id=$appKey&client_secret=$appSecret&username=$emailAddress&password=$password\n";
