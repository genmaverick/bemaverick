<?php

/**
 * Helper for creating HTML markup that can easily be enlivened with some JS
 */
class Sly_View_Helper_FormatCountdown
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

    const DAYS    = 'days';
    const HOURS   = 'hours';
    const MINUTES = 'minutes';
    const SECONDS = 'seconds';

    protected static $minute = 60;
    protected static $hour   = 3600;
    protected static $day    = 86400;

    public $defaultLabels = array(self::DAYS    => array('day',
                                                         'days'),
                                  self::HOURS   => array('hour',
                                                         'hours'),
                                  self::MINUTES => array('minute',
                                                         'minutes'),
                                  self::SECONDS => array('second',
                                                         'seconds'),
                                  );

    /*
     * Meh, can't do $obj::CONST pre PHP 5.3...
     * http://php.net/manual/en/language.oop5.constants.php
     */
    public function getDaysKeyConst() {
        return self::DAYS;
    }
    public function getHoursKeyConst() {
        return self::HOURS;
    }
    public function getMinutesKeyConst() {
        return self::MINUTES;
    }
    public function getSecondsKeyConst() {
        return self::SECONDS;
    }

    public function formatCountdown()
    {
        return $this;
    }

    public function getWholeUnits ($x) {
        if ($x < 0) {
            return ceil($x);
        }
        return floor($x);
    }

    /*
     *
     * @param (string) Unixtime representing 'now'
     * @param (string) Unixtime representing the target date
     * @param (array)  Custom labels, can also be used to specify which time
     *                 chunks to render. Need to be in decreasing size order i.e. 
     *                 years, weeks, seconds etc.
     *                 (add support for other time chunks as needed)
     *
     * return (string) markup representing the countdown
     */
    public function getCountdown( $currentDate, $targetDate, $labels = null, $numLength = 2, $labelGlue = ' ' )
    {

        $markup = '';

        if (!$labels) {
            $labels = $this->defaultLabels;
        }
        $timeToTarget    = $targetDate - $currentDate;

        $timeRemaining = $timeToTarget;

        $countdownData = array();
        foreach ($labels as $labelKey => $label) {
            $data = array('label'     => $label,
                          'remaining' => null,
                          'duration'  => null);
            switch ($labelKey) {
            case self::DAYS :
                $remaining    = $this->getWholeUnits($timeRemaining / self::$day) ;
                $duration     = $remaining * self::$day;
                break;
            case self::HOURS :
                $remaining    = $this->getWholeUnits($timeRemaining / self::$hour);
                $duration     = $remaining * self::$hour;
                break;
            case self::MINUTES :
                $remaining    = $this->getWholeUnits($timeRemaining / self::$minute);
                $duration     = $remaining * self::$minute;
                break;
            case self::SECONDS :
                $remaining    = $timeRemaining;
                $duration     = $remaining;
                break;
            default :
                error_log(get_class($this) . ": Unknown label type " . $labelKey);
                break;
            }
            $data['remaining'] = $remaining;
            $data['duration']  = $duration;
            $timeRemaining -= $data['duration']; // Update time left
            $countdownData[$labelKey] = $data;
        }

        $isFirst = true;
        foreach ($countdownData as $key => $data) {
            $label = $this->getLabel($data, $labelGlue);
            $time  = $this->getTimeValue($data, $numLength);
            if ($isFirst && $time == 0) {
                continue;
            }
            $isFirst = false;
            $markup .= <<<HTML
<span class="timePeriod"><span class="timeValue {$key}">{$time}</span><span class="timeLabel">{$label}</span></span>
HTML;
        }

        // Prefix with sign
        $sign = ($timeToTarget >= 0) ? '' : '-';
        $markup = <<<HTML
                <div class="countdown cdTargetTime-{$targetDate} cdLoadTime-{$currentDate}">
                    <span class="timePeriod timePeriod-sign"><span class="timeValue sign">{$sign}</span><span class="timeLabel"></span></span>
                    {$markup}
                </div>
HTML;

        return $markup;
    }

    protected function getLabel ($data, $labelGlue = ' ') {
        if (!is_array($data['label'])) {
            // plurarity not an issue, perhaps a ':' delim?
            return $data['label'];
        }
        if ($data['remaining'] != 1) {
            return $labelGlue . $data['label'][1]; // plural
        }
        return $labelGlue . $data['label'][0];     // singular, e.g. 'day'
    }

    protected function getTimeValue ($data, $numLength) {
        return $this->padNumberWithZerosUpFront($numLength, $data['remaining']);
    }

    protected function padNumberWithZerosUpFront ($desiredDigitLength, $number) {
        $number = strval(abs($number));
        if (strlen($number) < $desiredDigitLength) {
            return '0' . $number; //$this->padNumberWithZerosUpFront($desiredDigitLength, '0' . $number); // Add a '0', recurse...
        }
        return $number;
    }

    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

}

?>
