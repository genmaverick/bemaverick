<?php

class Sly_Util
{
    public static function getOrdinal( $num )
    {
        return $num.self::getJustOrdinal( $num );
    }

    public static function getJustOrdinal( $num )
    {
        $numLast = $num % 100;
        if (($numLast > 10 && $numLast < 14) || $num == 0){
            return "th";
        }
        
        switch(substr($num, -1)) {
            case '1':    return "st";
            case '2':    return "nd";
            case '3':    return "rd";
            default:     return "th";
        }        
    }

    /**
     * Filter a string to be used for part of a url
     *
     * @return string
     */
    public static function filterString( $string )
    {
        $string = strtolower( $string );
        $string = str_replace( ' ', '-', $string );
        $string = preg_replace( '/[^a-z0-9\-_]/', '', $string );
        $string = preg_replace( '/\-+/', '-', $string );

        return $string;
    }

    /**
     * Tell facebook to re-scrape the url
     *
     * @return string
     */
    public static function triggerFacebookToRescrapeUrl( $url )
    {
        // we don't really care if this works or not as it isn't a big deal, so no catch
        // try block with error handling

        $result = @file_get_contents( 'http://graph.facebook.com/?scrape=true&id='.urlencode($url) );
        //error_log( print_r( $result, true ) );
    }

    public static function convertSmartQuotes( $string, $escapeQuotes = false ) 
    {

        $quote = $escapeQuotes ? '\"' : '"';
        $search = array(
            "“",
            "”",
            "’",
            "‘",
            "–",
            "•"
        );
        $replace = array(
            $quote,
            $quote,
            "'",
            "'",
            "-",
            "-",
        );

        return str_replace( $search, $replace, $string );

    }

    /**
    * Format the passed amount as currency with the passed format and locale
    *
    *  @param float $amount
    *  @param string $format
    *  @param string $locale
    *  @return string
    */
    public function formatCurrency( $amount, $format = null, $locale = null )
    {
        $currentLocale = setlocale( LC_MONETARY, 0 );

        if ( ! $locale ) {
            $locale = 'en_US.UTF-8';
        }

        if ( ! $format ) {
            $format = '%.2n';
        }

        try {
            setlocale( LC_MONETARY, $locale );
            return money_format( $format, $amount );
        } finally {
            setlocale( LC_MONETARY, $currentLocale );
        }
    }

}

?>
