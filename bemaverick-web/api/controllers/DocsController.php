<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/controllers/Base.php' );

class DocsController extends BeMaverick_Controller_Base
{ 
    /**
     * The docs home page
     *
     * @return void
     */
    public function homeAction()
    {
        // get the view vars
        $errors = $this->view->errors;

        // process the input and validate
        $this->processInput( null, null, $errors );

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'docsErrors', self::HTTP_RC_BAD_REQUEST );
        }

        return $this->renderPage( 'docsHome' );
    }

    /**
     * The docs for a service
     *
     * @return void
     */
    public function serviceAction()
    {
        // get the view vars
        $errors = $this->view->errors;
        $systemConfig = $this->view->systemConfig;

        // set the input params
        $requiredParams = array(
            'serviceName',
        );

        // process the input and validate
        $input = $this->processInput( $requiredParams, null, $errors );

        $serviceName = $input->serviceName;

        $serviceDocsXmlDir = $systemConfig->getSetting( 'SYSTEM_SERVICE_DOCS_XML_DIR' );

        $serviceDocXmlFile = "$serviceDocsXmlDir/$serviceName.xml";

        if ( ! file_exists( $serviceDocXmlFile ) ) {
            $errors->setError( 'serviceName', 'INPUT_INVALID_SERVICE_NAME' );
        }

        if ( $errors->hasErrors() ) {
            return $this->renderPage( 'docsErrors' );
        }

        $this->view->serviceDocXml = simplexml_load_file( $serviceDocXmlFile );

        return $this->renderPage( 'docsService' );
    }
}

?>
