<?php

$start = microtime(true);

try {

    // set the environment
    require_once( '../config/setup_environment.php' );

    // set the application to 'main'
    $systemConfig = Zend_Registry::get( 'systemConfig' );

    require_once( ZEND_ROOT_DIR   . '/lib/Zend/Controller/Front.php' );
    require_once( ZEND_ROOT_DIR   . '/lib/Zend/Controller/Router/Route/Regex.php' );
    require_once( __SLY_REPOSITORY_UPPERCASE_NAME___COMMON_ROOT_DIR . '/controllers/Plugin/AuthUser.php' );

    // get the front controller
    $front = Zend_Controller_Front::getInstance();

    $front->setControllerDirectory( array(
        'default' => $systemConfig->getRootDir() . '/controllers',
    ));

    // set the plugins
    $front->registerPlugin( new __SLY_CLASS_PREFIX___Controller_Plugin_AuthUser() );

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

    $cacheFilesRoute = new Zend_Controller_Router_Route_Regex(
        '^cache/(css|js)/([^\/]+)/([^\/]+).(css|js)$',
        array( 'controller' => 'cache',
               'action' => 'mergefiles'),
        array( 1 => 'type',
               2 => 'maxModTime',
               3 => 'files')
    );
    $router->addRoute( 'cacheFiles', $cacheFilesRoute );

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
