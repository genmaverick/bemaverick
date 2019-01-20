<?php

class Sly_Webservice
{
    // May want to move these to a HTTP type class later.
    
    //  HTTP CONSTANTS
    const HTTP_RC_OK                    = 200;
    const HTTP_RC_BAD_REQUEST           = 400;
    const HTTP_RC_NOT_FOUND             = 404;
    const HTTP_RC_INTERNAL_SERVER_ERROR = 500;

    //  HTTP HEADER NAMES
    const HTTP_HEADER_EXPIRES           = 'Expires';
    const HTTP_HEADER_PRAGMA            = 'Pragma';
    const HTTP_HEADER_CACHE_CONTROL     = 'Cache-Control';
}

?>