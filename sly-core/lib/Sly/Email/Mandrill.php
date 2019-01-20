<?php

// need to do the require_once for Mandrill in client code

class Sly_Email_Mandrill
{
    /**
     * The system config
     *
     * @var object
     * @access protected
     */
    protected $_systemConfig;

    /**
     * The mandrill messages
     *
     * @var object
     * @access protected
     */
    protected $_mandrillMessages;

    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct( $systemConfig )
    {
        $this->_systemConfig = $systemConfig;
        
        $mandrillApiKey = $systemConfig->getSetting( 'MANDRILL_API_KEY' );
        
        $mandrill = new Mandrill( $mandrillApiKey );
        
        $this->_mandrillMessages = new Mandrill_Messages( $mandrill );
    }

    /**
     * Send an email to the user
     *
     * @return void
     */
    public function sendTemplate( $templateSlug, $toEmailAddresses, $vars, $errors )
    {
        $environment = $this->_systemConfig->getSetting( 'SYSTEM_ENVIRONMENT' );
        $errorEmailAddress = $this->_systemConfig->getSetting( 'SYSTEM_ERROR_EMAIL_ADDRESS' );
        
        $message = array(
            'to' => array(),
            'global_merge_vars' => array(),
        );
        
        if ( isset( $vars['REPLY_TO_EMAIL_ADDRESS'] ) ) {
            $message['headers'] = array('Reply-To' => $vars['REPLY_TO_EMAIL_ADDRESS']);
        }

        // add the global vars        
        foreach( $vars as $key => $value ) {
            $message['global_merge_vars'][] = array( 'name' => $key, 'content' => $value );
        }
        
        // add the recipients
        foreach( $toEmailAddresses as $emailAddress ) {
            
            if ( $errorEmailAddress && $environment != 'production' ) {
                $emailAddress = $errorEmailAddress;
            }
            
            $message['to'][] = array( 'email' => $emailAddress );
        }

        $result = $this->_mandrillMessages->sendTemplate( $templateSlug, array(), $message );

        //error_log( print_r( $result, true ) );
        return $result;
    }

}
    
?>
