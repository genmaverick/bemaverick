<?php
$start = microtime(true);

try {

    // set the environment
    require_once( '../config/setup_environment.php' );

    // set the application to 'main'
    $systemConfig = Zend_Registry::get( 'systemConfig' );

    require_once( ZEND_ROOT_DIR   . '/lib/Zend/Controller/Front.php' );
    require_once( ZEND_ROOT_DIR   . '/lib/Zend/Controller/Router/Route/Static.php' );
    require_once( ZEND_ROOT_DIR   . '/lib/Zend/Controller/Router/Route/Regex.php' );
    require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Plugin/AuthUser.php' );
    require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Redirect.php' );

    // setup a logger if debug mode
    if ( $systemConfig->isDebug() && ! $systemConfig->isProduction() ) {
        require_once( ZEND_ROOT_DIR . '/lib/Zend/Log/Writer/Firebug.php' );
        $writer = new Zend_Log_Writer_Firebug();
        $logger = new Zend_Log( $writer );
        Zend_Registry::set( 'debugLogger', $logger );
    }

    // get the front controller
    $front = Zend_Controller_Front::getInstance();


    $front->setControllerDirectory( array(
        'default' => $systemConfig->getRootDir() . '/controllers',
    ));

    // set the plugins
    $front->registerPlugin( new BeMaverick_Controller_Plugin_AuthUser() );

    // allow for output at anytime
    $front->setParam( 'disableOutputBuffering', true );

    $viewRenderer = Zend_Controller_Action_HelperBroker::getStaticHelper('viewRenderer');
    $viewRenderer->setNeverRender();

    // add the routes
    $router = $front->getRouter();


    $indexRoute = new Zend_Controller_Router_Route(
        '/:action',
        array( 'controller' => 'index',
               'action' => 'index' )
    );
    $router->addRoute( 'index', $indexRoute );

    $usersRoute = new Zend_Controller_Router_Route(
        '/users/:userId/:action',
        array(
            'controller' => 'users',
            'action' => 'user'
        )
    );
    $router->addRoute( 'users', $usersRoute );

    $challengesRoute = new Zend_Controller_Router_Route(
        '/challenges/:challengeId/:action',
        array(
            'controller' => 'challenges',
            'action' => 'challenge'
        )
    );
    $router->addRoute( 'challenges', $challengesRoute );

    $responsesRoute = new Zend_Controller_Router_Route(
        '/responses/:responseId/:action',
        array(
            'controller' => 'responses',
            'action' => 'response'
        )
    );
    $router->addRoute( 'responses', $responsesRoute );

//    $postsRoute = new Zend_Controller_Router_Route(
//        '/posts/:postId/:action',
//        array(
//            'controller' => 'posts',
//            'action' => 'post'
//        )
//    );
//    $router->addRoute( 'posts', $postsRoute );

    $cacheFilesRoute = new Zend_Controller_Router_Route_Regex(
        '^cache/(css|js)/([^\/]+)/([^\/]+).(css|js)$',
        array( 'controller' => 'cache',
               'action' => 'mergefiles'),
        array( 1 => 'type',
               2 => 'maxModTime',
               3 => 'files')
    );
    $router->addRoute( 'cacheFiles', $cacheFilesRoute );

/*
 * This redirect code can be removed as we aren't using the old urls anymore.
 */
    $redirectMap = array(
        array (
            'from' => 'parenthome',
            'toController' => 'family-home',
            'toAction' => null
        ),
        array (
            'from' => 'maverickhome',
            'toController' => 'maverick-home',
            'toAction' => null
        ),
        array (
            'from' => 'temphome',
            'toController' => 'temp-home',
            'toAction' => null
        ),
        array (
            'from' => 'contactus',
            'toController' => 'contact-us',
            'toAction' => null
        ),
        array (
            'from' => 'supportresources',
            'toController' => 'support-resources',
            'toAction' => null
        ),
        array (
            'from' => 'termsofservice',
            'toController' => 'terms-of-service',
            'toAction' => null
        ),
        array (
            'from' => 'privacy',
            'toController' => 'privacy-policy',
            'toAction' => null
        ),
        array (
            'from' => 'auth/parentverifymaverickstep1',
            'toController' => 'auth',
            'toAction' => 'family-verify-maverick-step-1'
        ),
        array (
            'from' => 'auth/passwordreset/',
            'toController' => 'auth',
            'toAction' => 'password-reset/'
        ),
    );

    foreach ( $redirectMap as $pathArray  ) {
        $testRoute = new Zend_Controller_Router_Route_Redirect( $pathArray['from'], array('controller'=>$pathArray['toController'], 'action' => $pathArray['toAction']) );
        $router->addRoute( '/' . $pathArray['from'], $testRoute );
    }

    // routing for the React App pages
    $reactAppPaths = array(
        '^_next.*$',
        '^challenge/.*$',
        '^pages/.*$',
        '^posts/.*$',
        'get-started',
        'other',
        'sign-in',
        'sign-up',
    );

    foreach ( $reactAppPaths as $path  ) {
        $route = new Zend_Controller_Router_Route_Regex(
            $path,
            array( 'controller' => 'index',
                'action' => 'react-app' )
        );
        $router->addRoute( $path , $route );
    }

    // routing for the Wordpress pages
    $wordpressPaths = array(
        'about',
        'blog',
        '^blog/.*$',
        'community-guidelines',
        'careers',
        'contact',
        'copyright',
        'faq',
        'faq-families',
        'homepage',
        '^page/.*$',
        'privacy-policy',
        'support-resources',
        'team',
        'terms-of-service',
        'third-party-operators',
    );

    foreach ( $wordpressPaths as $path  ) {
        $route = new Zend_Controller_Router_Route_Regex(
            $path,
            array( 'controller' => 'index',
                'action' => 'wordpress' )
        );
        $router->addRoute( $path , $route );
    }

    // Handle inbound share links
    $postsRoute = new Zend_Controller_Router_Route(
        '/share/:objectType/:objectId',
        array(
            'controller' => 'share',
            'action' => 'inbound'
        )
    );
    $router->addRoute( 'posts', $postsRoute );

    // throwing of exceptions is turned off, which means in zend code, any
    // exception thrown will be caught somewhere internal and set in the
    // response. Typically, if throwExceptions was turned on, then the
    // internal code will continue to throw it and then be able to get
    // caught here and do something with it. we can't catch them, but we
    // can get them here and displaying something if we want.
    $front->returnResponse( true );
}
catch( Exception $e ) {
    error_log( $e );
    include( 'errors/internalProcessError.php' );
    exit( 0 );
}

try {

    $response = $front->dispatch();

    if ( $response->isException() &&
         $response->getHttpResponseCode() != '404' ) {
        $exceptions = $response->getException();
        foreach( $exceptions as $exception ) {
            error_log( '[remote ip: ' . @$_SERVER['HTTP_X_FORWARDED_FOR'] . '] [current url: ' . $systemConfig->getCurrentUrl() . '] ' . $exception );
        }
    }

    $response->sendResponse();
}
catch( Zend_Exception $exception ) {

    // The Zend's dispatch() code catches any exceptions when rendering the
    // initial page and will get sent to the ErrorHandler.  If while in the
    // process of handling the error through the ErrorHandler another
    // exception is thrown, then it gets caught here.  Try to make your
    // internalError and notFound pages be simple.
    error_log( '[remote ip: ' . @$_SERVER['HTTP_X_FORWARDED_FOR'] . '] [current url: ' . $systemConfig->getCurrentUrl() . '] ' . $exception );

    include( 'errors/internalProcessError.php' );

    // dump the exception
    if ( ! $systemConfig->isProduction() ) {
        print "<p><pre>$exception</pre></p>";
    }

    exit( 0 );
}

$end = microtime(true);
//error_log( ($end-$start) );

?>
