<?php

/*!
    Processes a log file, a single line at a time. For each line, it will
    run through the configuration in [callbacks], to check to see if the
    line matches a given regular expression. If it finds a match, it will
    call the callback function associated with that regular expression.
    The callback will receive the regular expression matches for that line.

    $callbacks = array(
        array('regexp' => '<regular expression>', 'callback' => php callback structure),
        ...
        array('regexp' => '<regular expression>', 'callback' => php callback structure),
    );
*/
class Sly_Log_Processor
{

    public function __construct( $file, $callbacks ) {
        $this->file = $file;
        $this->callbacks = $callbacks;
    }
    
    public function process() {

        if (empty($this->file))
            return;

        $fh = fopen( $this->file, 'r' );

        if (!$fh)
            return;

        while (!feof($fh)) {

            $line = fgets($fh);
            
            foreach ($this->callbacks as $cb) {

                if (empty($cb['regexp']))
                    continue;
                
                if (preg_match($cb['regexp'], $line, $matches)) {

                    call_user_func_array($cb['callback'], array($matches, $line));
                
                    break; /* later, could make it so that it tries to apply all regexp's */
                }
            }
        }

        fclose($fh);
    }

    /*  Path string pointing to the file to be processed. */
    private $file;

    /*  Meta-data array specifying processing rules. */
    private $callbacks;
}

?>