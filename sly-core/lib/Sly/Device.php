<?php

class Sly_Device
{

    static function getDeviceFromUserAgent( $userAgent )
    {
        $device = 'pc';
        
        if ( stripos( $userAgent, 'ipad' ) !== false ) {
            $device = 'tablet-ipad';
        }
        else if ( stripos( $userAgent, 'iphone' ) !== false ||
                  stripos( $userAgent, 'ipod' ) !== false ) {
            $device = 'mobile-iphone';
        }
        else if ( preg_match( '/android.*(mobile|mini)/i', $userAgent ) ) {
            $device = 'mobile-android';
        }
        else if ( stripos( $userAgent, 'android' ) !== false ) {
            $device = 'tablet-android';
        }

        return $device;        
    }
}

?>
