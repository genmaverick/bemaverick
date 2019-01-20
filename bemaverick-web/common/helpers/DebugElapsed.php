<?php

class DebugElapsed
{
    private $startTime;
    private $lastElapsedTime;
    private $logPrefix;
    private $clearLines;
    private $quiet;

    public function __construct($logPrefix = 'ELAPSED', $clearLines = 0, $quiet = false) {
        $this->startTime = 0;
        $this->lastElapsedTime = 0;
        $this->logPrefix = $logPrefix;
        $this->clearLines = $clearLines;
        $this->quiet = $quiet;
    }

    public function log($label = "")
    {
        if ($this->quiet) {
            return;
        }

        $now = microtime(true);
        $logPrefix = $this->logPrefix;
        $backtrace = debug_backtrace();
        $cwd = getcwd();
        $file = explode('/', $backtrace[0]['file']);
        $filename = $file[count($file) -1];
        $line = $backtrace[0]['line'];

        if ($this->startTime == 0) {
            for ($i = 0; $i < $this->clearLines; $i++) {
                error_log(" ");
            }
            error_log("$logPrefix | start: ".$now);
            $this->startTime = $now;
        }

        $total_elapsed = round($now - $this->startTime, 6);
        $last_elapsed = ($this->lastElapsedTime > 0) ? round($now - $this->lastElapsedTime, 6) : 0;
        $this->lastElapsedTime = $now;

        $output = "$logPrefix ";
        $output .= "| total: ".str_pad($total_elapsed, 9);
        $output .= "| last: ".str_pad($last_elapsed, 9);
        $output .= "| $filename:$line";
        if ($label) 
            $output .= " ($label)";

        error_log($output);
    }
}