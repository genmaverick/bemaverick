<?php

require_once( ZEND_ROOT_DIR . '/lib/Zend/Mail.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Mail/Transport/Smtp.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Registry.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/FileFinder.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Emogrifier.php' );

/**
 * Class for management of an email
 *
 * @category Sly
 * @package Sly_Email
 */
abstract class Sly_Email
{
    /**
     * @var hash
     * @access protected
     */
    protected $_emailTypes = array();
    
    /**
     * @var string
     * @access protected
     */
    protected $_transport = null;
    
    /**
     * Get all the email types
     *
     * @return array
     */
    public function getEmailTypes()
    {
        return array_keys( $this->_emailTypes );
    }

    /**
     * Set the transport
     *
     */
    public function setTransport( $transport )
    {
    	$this->_transport = $transport;
    }

    /**
     * Sends emails
     *
     * @param string $emailType One of the email types in the _emailTypes hash
     * @param Fantasy_Full_User $fromUser The user sending the email
     * @param array $toEmailAddress
     * @param hash $vars A hash of varibles used in the email modules
     * @return void
     */
    public function sendEmails( $emailType, $fromUser, $toEmailAddresses, $vars )
    {
        // if there are no email addresses to send, just skip
        if ( ! $toEmailAddresses ) {
            return;
        }
         
        $systemConfig = Zend_Registry::get( 'systemConfig' );
        
        // if $emailType is empty we're expecting emailHeader, emailBody and emailFooter vars to be set since we'll be creating the email in the calling script
        if ( !empty( $emailType ) ) {
            $file = $this->_emailTypes[$emailType]['file'];
        }

        $subject = ( isset( $vars['subject'] ) ) ?
                   $vars['subject'] :
                   $this->_emailTypes[$emailType]['subject'];
        
        $moduleDirs = array_reverse( $systemConfig->getModuleDirs( $systemConfig->getSite() ) );

        //
        // Allow the caller to specify the header and footer. This allows
        // sites to have more than one.
        //
        $emailHeaderFilename = @$this->_emailTypes[$emailType]['emailHeaderFilename'];
        if ( empty( $emailHeaderFilename ) ) {
            $emailHeaderFilename = 'emailHeader.phtml';
        }

        $emailFooterFilename = @$this->_emailTypes[$emailType]['emailFooterFilename'];
        if ( empty( $emailFooterFilename ) ) {
            $emailFooterFilename = 'emailFooter.phtml';
        }        
        
        $emailHeaderFile = Sly_FileFinder::findFile( $emailHeaderFilename, $moduleDirs );
        $emailFooterFile = Sly_FileFinder::findFile( $emailFooterFilename, $moduleDirs );

        
        if ( !empty( $emailType ) ) {
            $emailFile = Sly_FileFinder::findFile( $file, $moduleDirs );
        }
        
        $emailCSSFile = Sly_FileFinder::findFile( 'emailCSS.phtml', $moduleDirs );
        
        $vars['moduleDirs'] = $moduleDirs;
        $vars['url'] = Sly_Url::getInstance();
        $vars['fromUser'] = $fromUser;
        $vars['emailType'] = $emailType;
        $vars['systemConfig'] = $systemConfig;

        if ( $fromUser ) {
            $fromUserEmailAddress = $fromUser->getEmailAddress();
            $fromUserName = $fromUser->getName();
        }
        else if ( isset( $vars['fromUserEmailAddress'] ) ) {
            $fromUserEmailAddress = $vars['fromUserEmailAddress'];
            $fromUserName = $systemConfig->getFromUserEmailName();
        }
        else {
            $fromUserEmailAddress = $systemConfig->getFromUserEmailAddress();
            $fromUserName = $systemConfig->getFromUserEmailName();
        }
        
        // check if we have a specific SMTP server to send to
        //if ( $this->_transport == 'smtp' ) {
        //	$tr = new Zend_Mail_Transport_Smtp( $this->_smtpServer );
        //	Zend_Mail::setDefaultTransport($tr);
        //}

        foreach( $toEmailAddresses as $toEmailAddress ) {

            // for testing
            if ( $systemConfig->getEnvironment() != 'production' ) {
                $toEmailAddress = $systemConfig->getErrorEmailAddress();
            }

            $vars['toEmailAddress'] = $toEmailAddress;

            ob_start();
            if ( isset( $vars['emailHeader'] ) ) {
                print $vars['emailHeader'];
            }
            else { 
                include( $emailHeaderFile );
            }
            
            if ( isset( $vars['emailBody'] ) ) {
                print $vars['emailBody'];
            }
            else {
                if ( isset( $emailFile ) ) {
                    include( $emailFile );
                }
            }
            
            if ( isset( $vars['emailFooter'] ) ) {
                print $vars['emailFooter'];
            }
            else { 
                include( $emailFooterFile );
            }
            
            $emailBody = ob_get_clean();

            if ( $emailCSSFile ) {
                ob_start();
                include( $emailCSSFile );
                $emailCSS = ob_get_clean();
                $emogrifier = new Emogrifier( $emailBody, $emailCSS );
                $emailBody = @$emogrifier->emogrify();
            }
            
            $mail = new Zend_Mail();
            $mail->setBodyHtml( $emailBody );
            $mail->setFrom( $fromUserEmailAddress, $fromUserName );
            $mail->addTo( $toEmailAddress, null );
            $mail->setSubject( $subject );

            // add attachments if needed
            if ( isset( $vars['attachments'] ) ) {
                foreach( $vars['attachments'] as $attachment ) {
                    $mail->addAttachment( $attachment );
                }
            }

            try {
                $mail->send( $this->_transport );
            }
            catch( Exception $e ) {
                error_log( "Sly_Email::sendEmails unable to send email to $toEmailAddress: " . $e->getMessage() );
            }
			
            unset( $vars['toEmailAddress'] );
        }
    }
    
}
    
?>
