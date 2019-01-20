<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/Date.php' );

/**
 * Helper for creating html attribute string
 */
class Sly_View_Helper_FormatDate
{
    /**
     * The view object that created this helper object.
     *
     * possible types:
     * 		name			- group name linked to profile - default
     *
     * @var Zend_View
     */
    public $view;


    public function formatDate()
    {
        return $this;
    }

    public function getDate( $timestamp, $format = 'MONTH_DAY_TIME_TZ', $timezone = null )
    {

        if ( !$timestamp ) {
            return '';
        }

        return Sly_Date::formatDate( $timestamp, $format, $timezone );
    }

    public function isYesterday( $timestamp, $now = false ) {

        if (!$now) {
            $now = mktime();
        }
        $yesterday  = mktime(0, 0, 0, date("m", $now)  , date("d", $now)-1, date("Y", $now));
        if ( date( "Y-m-d", $yesterday ) == date( "Y-m-d", $timestamp ) ) {
            return true;
        }

        return false;

    }

    public function isToday( $timestamp, $now = false ) {

        if (!$now) {
            $now = mktime();
        }
        $today  = mktime(0, 0, 0, date("m", $now)  , date("d", $now), date("Y", $now));
        if ( date( "Y-m-d", $today ) == date( "Y-m-d", $timestamp ) ) {
            return true;
        }

        return false;

    }

    public function isTomorrow( $timestamp, $now = false ) {

        if (!$now) {
            $now = mktime();
        }
        $tomorrow  = mktime(0, 0, 0, date("m", $now)  , date("d", $now)+1, date("Y", $now));
        if ( date( "Y-m-d", $tomorrow ) == date( "Y-m-d", $timestamp ) ) {
            return true;
        }

        return false;

    }

    public function isThisWeek( $timestamp, $now = false ) {

        if (!$now) {
            $now = mktime();
        }
        $thisWeek = date( "W", $now );
        $timestampWeek = date( "W", $timestamp );
        if( $timestampWeek == $thisWeek ) {
            return true;

        }
        return false;
    }


    public function getSinceTime( $timestamp, $includeAt = false, $useYesterday = true, $defaultFormat = 'TIME_SHORT_MONTH_DAY', $useDays = false )
    {
        $now = time();

        $diff = floor(( $now - $timestamp )/60);
        $at = '';
        if ( $includeAt ) {
            $at = 'at ';
        }
        $timeString = '';

        if ( $diff < 2 ) {
            $timeString = 'just now';
        } else if ( $diff < 60 ) {
            $timeString = $diff.' minutes ago';
        } else if ( $diff < 60*24 ) {
            $str = 'hour';
            $hours = floor($diff/60);
            if ( $hours > 1 ) {
                $str = $str.'s';
            } else {
                $hours = '1';
            }
            $timeString =  "$hours $str ago";
        } else if ( $useDays ) {


            $str = 'hour';
            $days = floor( $diff/(60*24) );
            $daysStr = 'day';
            if ( $days > 1 ) {
                $daysStr = 'days';
            }
            $hoursDiff = $diff - ( 60*24 )*$days;
            $hours = floor($hoursDiff/60);
            if ( $hours > 1 ) {
                $str = $str.'s';
            } else {
                $hours = '1';
            }

            if ( $hours ) {
                $timeString =  "$days $daysStr $hours $str ago";
            } else {
                $timeString =  "$days $daysStr ago";
            }

        } else if ( $useYesterday && $this->isYesterday( $timestamp, $now ) ) {
            $timeString = 'Yesterday at '.date("g:i a",$timestamp);
        } else {
            if ( $defaultFormat == 'FACEBOOK_EVENT') {
                $timeString = $this->getDate($timestamp, 'SHORT_MONTH_DAY' ). ' at '. $this->getDate($timestamp, 'TIME' ) ;
            } else{
                $timeString = $this->getDate($timestamp, $defaultFormat );
            }
        }

        return $timeString;
    }

    // this was written by someone in the php.net comments
    public function timeDiff($t1, $t2 = null, $format='yfwdhms' ) {
        $t2 = $t2 === null ? time() : $t2;
        $s = abs($t2 - $t1);
        $sign = $t2 > $t1 ? 1 : -1;
        $out = array();
        $left = $s;
        $format = array_unique(str_split(preg_replace('`[^yfwdhms]`', '', strtolower($format))));
        $format_count = count($format);
        $a = array('y'=>31556926, 'f'=>2629744, 'w'=>604800, 'd'=>86400, 'h'=>3600, 'm'=>60, 's'=>1);
        $i = 0;
        foreach( $a as $k => $v ) {
            if ( in_array( $k, $format ) ) {
                ++$i;
                if ( $i != $format_count ) {
                    $out[$k] = $sign * (int)($left / $v);
                    $left = $left % $v;
                }
                else {
                    $out[$k] = $sign * ($left / $v);
                }
            }
            else {
                $out[$k] = 0;
            }
        }
        return $out;
    }

    public function isRecent( $timestamp1, $timestamp2, $timeAmount )
    {
        if ( !$timestamp1 || !$timestamp2 || !$timeAmount ) {
            return '';
        }
        $diff = Sly_Date::diffTimes( $timestamp1, $timestamp2 );
        return $diff < $timeAmount;
    }

    /**
     * Will return the time difference when given 2 timestamps of the format 'Y-m-d H:i:s'
     *
     * @method timeDiffISO
     * @param null $time1
     * @param null $time2
     * @param string $format
     * @return string
     */
    public function timeDiffISO( $time1 = null, $time2 = null, $format = '%d:%h:%i:%s' )
    {
        if ( ! $time1 || ! $time2 ) {
            return '';
        }

        $timeFormat = 'Y-m-d H:i:s';
        $date1 = DateTime::createFromFormat($timeFormat, $time1);
        $date2 = DateTime::createFromFormat($timeFormat, $time2);

        $interval = $date2->diff($date1);

        return $interval->format( $format );
    }



    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }
}

