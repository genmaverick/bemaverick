<?php
require_once( ZEND_ROOT_DIR . '/lib/Zend/Date.php' );

class Sly_Date
{

    public static function getIsoDate( $inputDate,
                                       $inputTime = null,
                                       $inputTimeAmPm = null,
                                       $inputTimezone = null,
                                       $format = 'Y-m-d' )
    {
        if ( ! $inputDate ) {
            return null;
        }

        $date = self::_getDate( $inputDate,
                                $inputTime,
                                $inputTimeAmPm,
                                $inputTimezone );

        return self::formatDate( $date, $format );
    }

    public static function getIsoTime( $inputDate,
                                       $inputTime,
                                       $inputTimeAmPm = null,
                                       $inputTimezone = null )
    {
        if ( ! $inputDate || ! $inputTime ) {
            return null;
        }

        $date = self::_getDate( $inputDate,
                                $inputTime,
                                $inputTimeAmPm,
                                $inputTimezone );

        return self::formatDate( $date, 'H:i:s' );
    }

    public static function _getDate( $inputDate,
                                     $inputTime,
                                     $inputTimeAmPm,
                                     $inputTimezone )
    {
        // add on the am/pm and timezone only if there is a time
        if ( $inputTime ) {
            $inputTime .= $inputTimeAmPm;
        }

        // if there is a time given, then we can do the timezone check
        // otherwise we don't change the timezone
        if ( $inputTime && $inputTimezone != null ) {
            $oldTimezone = date_default_timezone_get();
            date_default_timezone_set( $inputTimezone );
        }

        $dateString = "$inputDate $inputTime";

        $time = strtotime( $dateString );

        if ( $inputTime && $inputTimezone != null ) {
            date_default_timezone_set( $oldTimezone );
        }

        return $time;
    }

    /**
     * Convert a string to time
     *
     * @param string $dateTimeString
     * @param string $timezone
     * @return string
     */
    public static function strtotime( $dateTimeString, $timezone )
    {
        $oldTimezone = date_default_timezone_get();
        date_default_timezone_set( $timezone );
        $timestamp = strtotime( $dateTimeString );
        date_default_timezone_set( $oldTimezone );

        return $timestamp;
    }

    /**
     * Format a date
     *
     * @param string/integer $date String or unix timestamp
     * @param string $format in 'php' format characters
     * @param string $timezone The timezone of the output
     * @return string
     */
    public static function formatDate( $date, $format, $timezone = null )
    {
        if ( ! is_numeric( $date ) ) {
            $timestamp = strtotime( $date );
        }
        else {
            $timestamp = $date;
        }

        if ( $timezone != null ) {
            $oldTimezone = date_default_timezone_get();
            date_default_timezone_set( $timezone );
        }

        $formatString = self::getFormat( $format, 'php' );

        $formattedDate = date( $formatString, $timestamp );

        $formattedDate = str_replace( 'AM', 'am', $formattedDate );
        $formattedDate = str_replace( 'PM', 'pm', $formattedDate );

        if ( $timezone != null ) {
            date_default_timezone_set( $oldTimezone );
        }

        return $formattedDate;
    }

    /**
     * Get the converted format string for the passed descriptive string
     *
     * If the descriptive string is not found the string will be passed straight
     * through without any conversion.
     *
     * @param string $format The descriptive format string
     * @param string $type The type of format string to return
     * @return string
     */
    public static function getFormat( $format, $type = 'php' )
    {
        // see http://framework.zend.com/manual/en/zend.date.constants.html#zend.date.constants.selfdefinedformats
        // for a list of constants.

        $formats = array(
            'iso' => array(
                'MONTH_DAY_YEAR' => 'MMMM d, yyyy',
                'MONTH_YEAR' => 'MMMM yyyy',
                'DOW_MONTH_DAY_YEAR' => 'EEEE, MMMM d, yyyy',
                'DOW_MONTH_DAY' => 'EEEE, MMMM d',
                'DOW_SHORT_MONTH_DAY_YEAR' => 'EEEE, MMM d, yyyy',
                'SHORT_DOW_SHORT_MONTH_DAY_YEAR' => 'EEE, MMM d, yyyy',
                'SHORT_DOW_SHORT_MONTH_DAY' => 'EEE, MMM d',
                'SHORT_MONTH_DAY_YEAR' => 'MMM d, yyyy',
                'SHORT_MONTH_DAY_YEAR_TIME_TZ' => 'MMM d, yyyy h:mma z',
                'SHORT_MONTH_DAY' => 'MMM d',
                'SHORT_MONTH_YEAR' => 'MMM yyyy',
                'SHORT_MONTH' => 'MMM',
                'TIME_MONTH_DAY_YEAR' => 'h:mma MMMM d, yyyy',
                'TIME_SHORT_MONTH_DAY' => 'h:mma MMM d',
                'MONTH_DAY_TIME_TZ' => 'MMMM yyyy d, h:mma (z)',
                'TIME_MONTH_DAY_YEAR_TZ' => 'h:mma MMMM d, yyyy z',

                'INPUT_MONTH_DAY_YEAR' => 'M/d/yyyy',
                'RSS_TIMESTAMP' => 'EEE, d MMM yyyy hh:mm:ss z',

                'MONTH_DAY' => 'M/d',
                'DATE_STAMP' => 'MMddyyyy',
                'SHORT_DOW_TIME' => 'EEE h:mma',
                'MESSAGE_DATE' => 'MMM d, yyyy h:mma',
                'DOW' => 'EEEE',
                'SHORT_DOW' => 'EEE',
                'TIME' => 'h:mm a',
                'TIME_24' => 'H:mm',
                'TIME_TIMEZONE' => 'h:mma z',
                'TIMEZONE' => 'z',
                'HOUR' => 'h',
                'MINUTES' => 'mm',
                'AMPM' => 'a',
                'WEEK' => 'w',
                'MONTH' => 'MM',
                'DAY' => 'dd',
                'YEAR' => 'yyyy',
            ),
            'php' => array(
                'ISO_8601' => 'c',
                'MONTH_DAY_YEAR' => 'F j, Y',
                'MONTH_YEAR' => 'F Y',
                'DOW_MONTH_DAY_YEAR' => 'l, F j, Y',
                'DOW_MONTH_DAY' => 'l, F j',
                'DOW_SHORT_MONTH_DAY_YEAR' => 'l, M j, Y',
                'DOW_SHORT_MONTH_DAY_TIME' => 'l, M j \a\t g:ia',
                'DOW_SHORT_MONTH_DAY' => 'l, M j',
                'SHORT_DOW_SHORT_MONTH_DAY_YEAR' => 'D, M j, Y',
                'SHORT_DOW_SHORT_MONTH_DAY' => 'D, M j',
                'SHORT_MONTH_DAY_YEAR' => 'M j, Y',
                'SHORT_MONTH_DAY_YEAR_TIME_TZ' => 'M j, Y g:iA T',
                'SHORT_MONTH_DAY' => 'M j',
                'SHORT_MONTH_YEAR' => 'M Y',
                'SHORT_MONTH' => 'M',
                'TIME_SHORT_MONTH_DAY_TZ'      => 'g:iA M j T',
                'TIME_SHORT_MONTH_DAY_YEAR_TZ' => 'g:iA M j, y T',
                'TIME_MONTH_DAY_YEAR' => 'g:iA F j, Y',
                'TIME_SHORT_MONTH_DAY' => 'g:iA M j',
                'MONTH_DAY_TIME_TZ' => 'F Y j, g:i (T)',
                'TIME_MONTH_DAY_YEAR_TZ' => 'g:iA F j, Y T',
                'SHORT_MONTH_DAY_TIME_TZ' => 'M j, g:iA T',
                'INPUT_MONTH_DAY_YEAR' => 'n/j/Y',
                'RSS_TIMESTAMP' => 'D, j M Y H:i:s T',
                'HTML5_TIMESTAMP' => 'Y-n-j\TH:i:s\ZP',
                'MONTH_DAY' => 'n/j',
                'DATE_STAMP' => 'mdY',
                'SHORT_DOW_TIME' => 'D g:iA',
                'MESSAGE_DATE' => 'M j, Y g:iA',
                'DOW' => 'l',
                'SHORT_DOW' => 'D',
                'TIME' => 'g:i A',
                'TIME_24' => 'G:i',
                'TIME_TIMEZONE' => 'g:iA T',
                'TIMEZONE' => 'T',
                'HOUR' => 'g',
                'MINUTES' => 'i',
                'AMPM' => 'A',
                'WEEK' => 'W',
                'MONTH' => 'm',
                'DAY' => 'd',
                'YEAR' => 'Y',

            ),
        );
        if (isset($formats[$type][$format])) {
            return $formats[$type][$format];
        } else {
            return $format;
        }

    }

    public static function addYears( $date, $numYears, $format = 'Y-m-d' )
    {
        if ( ! $numYears ) {
            return date( $format, strtotime( $date ) );
        }
        return date( $format, strtotime( "+$numYears years", strtotime( $date ) ) );
    }

    public static function addMonths( $date, $numMonths, $format = 'Y-m-d' )
    {
        if ( ! $numMonths ) {
            return date( $format, strtotime( $date ) );
        }
        return date( $format, strtotime( "+$numMonths months", strtotime( $date ) ) );
    }

    public static function addDays( $date, $numDays, $format = 'Y-m-d' )
    {
        if ( ! $numDays ) {
            return date( $format, strtotime( $date ) );
        }
        return date( $format, strtotime( "+$numDays days", strtotime( $date ) ) );
    }

    public static function addMinutes( $dateTime, $numMinutes, $format = 'Y-m-d H:i:s' )
    {
        if ( ! $numMinutes ) {
            return date( $format, strtotime( $dateTime ) );
        }
        return date( $format, strtotime( "+$numMinutes minutes", strtotime( $dateTime ) ) );
    }

    public static function addSeconds( $dateTime, $numSeconds, $format = 'Y-m-d H:i:s' )
    {
        if ( ! $numSeconds ) {
            return date( $format, strtotime( $dateTime ) );
        }
        return date( $format, strtotime( "+$numSeconds seconds", strtotime( $dateTime ) ) );
    }

    public static function subYears( $date, $numYears, $format = 'Y-m-d' )
    {
        if ( ! $numYears ) {
            return date( $format, strtotime( $date ) );
        }
        return date( $format, strtotime( "-$numYears years", strtotime( $date ) ) );
    }

    public static function subDays( $date, $numDays, $format = 'Y-m-d' )
    {
        if ( ! $numDays ) {
            return date( $format, strtotime( $date ) );
        }
        return date( $format, strtotime( "-$numDays days", strtotime( $date ) ) );
    }

    public static function subMinutes( $dateTime, $numMinutes, $format = 'Y-m-d H:i:s' )
    {
        if ( ! $numMinutes ) {
            return date( $format, strtotime( $dateTime ) );
        }
        return date( $format, strtotime( "-$numMinutes minutes", strtotime( $dateTime ) ) );
    }

    public static function subSeconds( $dateTime, $numSeconds, $format = 'Y-m-d H:i:s' )
    {
        if ( ! $numSeconds ) {
            return date( $format, strtotime( $dateTime ) );
        }
        return date( $format, strtotime( "-$numSeconds seconds", strtotime( $dateTime ) ) );
    }

    public static function diffTimes( $time1, $time2 = null )
    {
        if ( ! is_numeric( $time1 ) ) {
            $time1 = strtotime( $time1 );
        }

        if ( ! $time2 ) {
            $time2 = time();
        }
        else if ( ! is_numeric( $time2 ) ) {
            $time2 = strtotime( $time2 );
        }

        $diff = $time2 - $time1;

        return $diff;
    }

    /**
     * Get the list of timezones and their descriptions
     *
     * @return hash
     */
    public static function getTimezones()
    {
        static $timezones = null;

        if ( $timezones !== null ) {
            return $timezones;
        }

        //$timezones = DateTimeZone::listIdentifiers();

        /*
        $timezones = array(
            'Etc/GMT+12'             => 'GMT -12:00  Dateline',
            'Pacific/Apia'           => 'GMT -11:00  Samoa',
            'Pacific/Tahiti'         => 'GMT -10:00  Tahiti',
            'US/Hawaii'              => 'GMT -10:00  U.S. Hawaiian Time',
            'Pacific/Marquesas'      => 'GMT -09:30  Marquesas',
            'US/Alaska'              => 'GMT -09:00  U.S. Alaska Time',
            'Pacific/Pitcairn'       => 'GMT -08:30  Pitcairn',
            'US/Pacific'             => 'GMT -08:00  Pacific Time',
            'US/Mountain'            => 'GMT -07:00  U.S. Mountain Time',
            'US/Arizona'             => 'GMT -07:00  U.S. Mountain Time (Arizona)',
            'US/Central'             => 'GMT -06:00  U.S. Central Time',
            'Mexico/General'         => 'GMT -06:00  Mexico',
            'US/Eastern'             => 'GMT -05:00  U.S. Eastern Time',
            'US/East-Indiana'        => 'GMT -05:00  U.S. Eastern Time (Indiana)',
            'America/Lima'           => 'GMT -05:00  Columbia, Peru, South America',
            'America/Halifax'        => 'GMT -04:00  Atlantic Time',
            'America/St_Johns'       => 'GMT -03:30  Newfoundland, Canada',
            'America/Buenos_Aires'   => 'GMT -03:00  Argentina',
            'America/Sao_Paulo'      => 'GMT -03:00  Brazil',
            'Atlantic/South_Georgia' => 'GMT -02:00  Mid-Atlantic',
            'Atlantic/Azores'        => 'GMT -01:00  Azores',
            'Europe/London'          => 'GMT +00:00  U.K.',
            'WET'                    => 'GMT +00:00  Western Europe',
            'Europe/Paris'           => 'GMT +01:00  Western Europe, Spain',
            'Europe/Bucharest'       => 'GMT +02:00  Eastern Europe',
            'Africa/Cairo'           => 'GMT +02:00  Egypt',
            'Africa/Johannesburg'    => 'GMT +02:00  South Africa',
            'Asia/Jerusalem'         => 'GMT +02:00  Israel',
            'Europe/Moscow'          => 'GMT +03:00  Russia',
            'Asia/Riyadh'            => 'GMT +03:00  Saudi Arabia',
            'Asia/Tehran'            => 'GMT +03:30  Iran',
            'Asia/Dubai'             => 'GMT +04:00  Arabian',
            'Asia/Kabul'             => 'GMT +04:30  Afghanistan',
            'Asia/Karachi'           => 'GMT +05:00  Pakistan, West Asia',
            'Asia/Calcutta'          => 'GMT +05:30  India',
            'Asia/Dhaka'             => 'GMT +06:00  Bangladesh, Central Asia',
            'Asia/Rangoon'           => 'GMT +06:30  Burma',
            'Asia/Bangkok'           => 'GMT +07:00  Bangkok, Hanoi, Jakarta',
            'Asia/Shanghai'          => 'GMT +08:00  China, Taiwan',
            'Asia/Singapore'         => 'GMT +08:00  Singapore',
            'Australia/Perth'        => 'GMT +08:00  Australia (WT)',
            'Asia/Tokyo'             => 'GMT +09:00  Japan',
            'Asia/Seoul'             => 'GMT +09:00  Korea',
            'Australia/Adelaide'     => 'GMT +09:30  Australia (CT)',
            'Australia/Sydney'       => 'GMT +10:00  Australia (ET)',
            'Australia/Brisbane'     => 'GMT +10:00  Australia/Brisbane (ET)',
            'Australia/Lord_Howe'    => 'GMT +10:30  Australia (Lord Howe)',
            'Pacific/Guadalcanal'    => 'GMT +11:00  Central Pacific',
            'Pacific/Fiji'           => 'GMT +12:00  Fiji, New Zealand',
        );
        */

        $timezones = array(
            'Etc/GMT+12'             => 'Dateline',
            'Pacific/Apia'           => 'Samoa',
            'Pacific/Tahiti'         => 'Tahiti',
            'America/Adak'           => 'U.S. Hawaiian Time',
            'Pacific/Honolulu'       => 'U.S. Hawaiian Time (no DST)',
            'Pacific/Marquesas'      => 'Marquesas',
            'America/Anchorage'      => 'U.S. Alaska Time',
            'Pacific/Pitcairn'       => 'Pitcairn',
            'America/Los_Angeles'    => 'Pacific Time',
            'America/Denver'         => 'U.S. Mountain Time',
            'America/Phoenix'        => 'U.S. Mountain Time (Arizona)',
            'America/Chicago'        => 'U.S. Central Time',
            'Mexico/General'         => 'Mexico',
            'America/Barbados'       => 'Barbados',
            'America/New_York'       => 'U.S. Eastern Time',
            'America/Indiana/Indianapolis' => 'U.S. Eastern Time (Indiana)',
            'America/Lima'           => 'Columbia, Peru, South America',
            'America/Halifax'        => 'Atlantic Time',
            'America/St_Johns'       => 'Newfoundland, Canada',
            'America/Buenos_Aires'   => 'Argentina',
            'America/Sao_Paulo'      => 'Brazil',
            'Atlantic/South_Georgia' => 'Mid-Atlantic',
            'Atlantic/Azores'        => 'Azores',
            'Europe/London'          => 'U.K.',
            'WET'                    => 'Western Europe',
            'Europe/Paris'           => 'Western Europe, Spain',
            'Europe/Bucharest'       => 'Eastern Europe',
            'Africa/Cairo'           => 'Egypt',
            'Africa/Johannesburg'    => 'South Africa',
            'Asia/Jerusalem'         => 'Israel',
            'Europe/Moscow'          => 'Russia',
            'Asia/Riyadh'            => 'Saudi Arabia',
            'Asia/Tehran'            => 'Iran',
            'Asia/Dubai'             => 'Arabian',
            'Asia/Kabul'             => 'Afghanistan',
            'Asia/Karachi'           => 'Pakistan, West Asia',
            'Asia/Calcutta'          => 'India',
            'Asia/Dhaka'             => 'Bangladesh, Central Asia',
            'Asia/Rangoon'           => 'Burma',
            'Asia/Bangkok'           => 'Bangkok, Hanoi, Jakarta',
            'Asia/Shanghai'          => 'China, Taiwan',
            'Asia/Singapore'         => 'Singapore',
            'Australia/Perth'        => 'Australia (WT)',
            'Asia/Tokyo'             => 'Japan',
            'Asia/Seoul'             => 'Korea',
            'Australia/Adelaide'     => 'Australia (CT)',
            'Australia/Sydney'       => 'Australia (ET)',
            'Australia/Brisbane'     => 'Australia/Brisbane (ET)',
            'Australia/Lord_Howe'    => 'Australia (Lord Howe)',
            'Pacific/Guadalcanal'    => 'Central Pacific',
            'Pacific/Fiji'           => 'Fiji, New Zealand',
        );

        // figure out the offset for each timezone based as of now and add that to description
        foreach ( $timezones as $timezone => $description ) {
            $dateTimeZone = new DateTimeZone( $timezone );
            $dateTime = new DateTime( 'now', $dateTimeZone );

            $offset = $dateTimeZone->getOffset( $dateTime );

            $posNeg = $offset >= 0 ? '+' : '-';

            $timezones[$timezone] = "GMT $posNeg" . gmdate( 'H:i', abs( $offset ) ) . ' ' . $timezones[$timezone];
        }

        return $timezones;
    }

    public static function isWeekend( $dateTime )
    {
        return ( date( 'N', strtotime( $dateTime ) ) >= 6 );
    }
}

?>
