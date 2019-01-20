<?php

$USER = preg_match('/^\/home\/([^\/]+)\//', getcwd(), $matches) ? $matches[1] : false;

// include all the defines paths
require_once( "/home/$USER/dev/bemaverick-web/common/config/paths.php" );

?>

