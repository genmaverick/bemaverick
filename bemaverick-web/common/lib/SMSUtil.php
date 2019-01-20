<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/SmsCode.php' );

use Twilio\Rest\Client;

/**
 * Class utility for dealing sms codes
 *
 */
class BeMaverick_SMSUtil
{

    /**
     * Get the twilio client object
     *
     * @param BeMaverick_Site $site
     * @return Twilio\Jwt\Client
     */
    public static function getTwilioClient( $site )
    {
        $systemConfig = $site->getSystemConfig();

        $accountSid = $systemConfig->getSetting( 'TWILIO_ACCOUNT_SID' );
        $token = $systemConfig->getSetting( 'TWILIO_ACCESSTOKEN' );

        return new Client( $accountSid, $token );
    }

    /**
     * Send SMS message to phone number
     *
     * @param BeMaverick_Site $site
     * @param string $toPhoneNumber
     * @param string $body
     * @return void
     */
    public static function sendSMSMessage( $site, $toPhoneNumber, $body )
    {
        $systemConfig = $site->getSystemConfig();

        $fromPhoneNumber = $systemConfig->getSetting( 'TWILIO_SMS_PHONE_NUMBER' );

        $twilioClient = self::getTwilioClient( $site );

        $params = array(
            'body' => $body,
            'from' => $fromPhoneNumber,
        );

        try {
            $twilioClient->messages->create( $toPhoneNumber, $params );
        }
        catch( Exception $e ) {
            error_log( "SiteUtil::sendSMSMessage::Exception found: " . $e->getMessage() );
        }
    }

    /**
     * Generate a random sms code - 4 digits
     *
     * @return string
     */
    public static function generateSmsCode()
    {
        return rand( 1000, 9999 );
    }

    /**
     * Get the code for the phone number
     *
     * @param string $phoneNumber
     * @return string
     */
    public static function getSmsCode( $phoneNumber )
    {
        $daSmsCode = BeMaverick_Da_SmsCode::getInstance();

        return $daSmsCode->getCode( $phoneNumber );
    }

    /**
     * Set the code for the phone number
     *
     * @param string $phoneNumber
     * @param string $code
     * @return void
     */
    public static function setSmsCode( $phoneNumber, $code )
    {
        $daSmsCode = BeMaverick_Da_SmsCode::getInstance();

        $daSmsCode->setCode( $phoneNumber, $code );
    }

    /**
     * Delete the sms code for the phone number
     *
     * @param string $phoneNumber
     * @return void
     */
    public static function deleteSmsCode( $phoneNumber )
    {
        $daSmsCode = BeMaverick_Da_SmsCode::getInstance();

        $daSmsCode->deletePhoneNumber( $phoneNumber );
    }

    /**
     * Validate phone number
     *
     * @param BeMaverick_Site $site
     * @param string $phoneNumber
     * @return boolean
     */
    public static function isValidPhoneNumber( $site, $phoneNumber )
    {
        $twilioClient = self::getTwilioClient( $site );

        $response = null;

        try {
            $response = $twilioClient->lookups->v1->phoneNumbers( $phoneNumber )->fetch();
        }
        catch( Exception $e ) {
            error_log( "SiteUtil::isValidPhoneNumber::Exception found: " . $e->getMessage() );
        }

        if ( $response ) {
            return true;
        }

        return false;
    }

}

?>
