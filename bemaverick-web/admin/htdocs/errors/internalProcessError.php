<?php

// set response code
header( 'HTTP/1.1 500 InternalError' );

$dt = new DateTime('+10 seconds', new DateTimeZone('UTC'));
            
header( 'Cache-Control: public, max-age=10' );
header( 'Expires: ' . $dt->format('D, d M Y H:i:s') . ' GMT');

// get internal page
include( 'internal.html' );

?>
