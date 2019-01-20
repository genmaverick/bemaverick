<?php
class Sly_View_Helper_FormatApiData
{

    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public $view;

    /**
     * Returns this helper
     *
     * @return Sly_View_Helper_FormatApiData
     */
    public function formatApiData()
    {
        return $this;
    }

    /**
     * Convert the php data hash to xml
     *
     * @param hash $apiData
     * @return string
     */
    public function toXml( $apiData, $nodeIndent = 4, $level = 0 )
    {
    $xml = '';

    if ( $level == 0 ) {
        $xml .= '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
    }

    foreach ( $apiData as $key => $value ) {
        //$key = strtolower( $key );
        if ( is_array( $value ) ) {
            if ( is_int( $key ) ) {
                // no key so do not indent or build node
                $xml .= $this->toXml( $value, $nodeIndent, $level );
            }
            else {
                // use key as node and generate subnode
                $xml .= str_repeat( " ", $level * $nodeIndent ) . "<$key>\n";
                $xml .= $this->toXml( $value, $nodeIndent, $level + 1 );
                $xml .= str_repeat( " ", $level * $nodeIndent ) . "</$key>\n";
            }
        }
        else {
            if ( trim($value) != '' ) {
                if ( htmlspecialchars( $value )!= $value ) {
                    $xml .= str_repeat( " " , $level * $nodeIndent ) . "<$key>" .
                            "<![CDATA[$value]]></$key>\n";
                }
                else {
                    $xml .= str_repeat( " ", $level * $nodeIndent ) .
                            "<$key>$value</$key>\n";
                }
            }
        }
    }

    return $xml;
    }
                /*
                $multi_tags = false;
                foreach($value as $key2=>$value2) {
                    if (is_array($value2)) {
                        $xml .= str_repeat("\t",$level)."<$key>\n";
                        $xml .= $this->toXml($value2, $level+1);
                        $xml .= str_repeat("\t",$level)."</$key>\n";
                        $multi_tags = true;
                    }
                    else {
                        if (trim($value2)!='') {
                            if (htmlspecialchars($value2)!=$value2) {
                                $xml .= str_repeat("\t",$level).
                                        "<$key><![CDATA[$value2]]>".
                                        "</$key>\n";
                            }
                            else {
                                $xml .= str_repeat("\t",$level).
                                        "<$key>$value2</$key>\n";
                            }
                        }
                        $multi_tags = true;
                    }
                }
                */

    /**
     * Convert the php data hash to php. The data will be serialized
     *
     * @param hash $apiData
     * @return string
     */
    public function toPhp( $apiData )
    {
        return serialize( $apiData );
    }

    /**
     * Convert the php data hash to json.
     *
     * @param hash $apiData
     * @return string
     */
    public function toJson( $apiData )
    {
        return json_encode( $apiData );
    }

    /**
     * Indents a flat JSON string to make it more human-readable.
     *
     * @param string $json The original JSON string to process.
     *
     * @return string Indented version of the original JSON string.
     */
    function indent($json)
    {
    
        $result      = '';
        $pos         = 0;
        $strLen      = strlen($json);
        $indentStr   = '  ';
        $newLine     = "\n";
        $prevChar    = '';
        $outOfQuotes = true;
    
        for ($i=0; $i<=$strLen; $i++) {
    
            // Grab the next character in the string.
            $char = substr($json, $i, 1);
    
            // Are we inside a quoted string?
            if ($char == '"' && $prevChar != '\\') {
                $outOfQuotes = !$outOfQuotes;
    
            // If this character is the end of an element,
            // output a new line and indent the next line.
            } else if(($char == '}' || $char == ']') && $outOfQuotes) {
                $result .= $newLine;
                $pos --;
                for ($j=0; $j<$pos; $j++) {
                    $result .= $indentStr;
                }
            }
    
            // Add the character to the result string.
            $result .= $char;
    
            // If the last character was the beginning of an element,
            // output a new line and indent the next line.
            if (($char == ',' || $char == '{' || $char == '[') && $outOfQuotes) {
                $result .= $newLine;
                if ($char == '{' || $char == '[') {
                    $pos ++;
                }
    
                for ($j = 0; $j < $pos; $j++) {
                    $result .= $indentStr;
                }
            }
    
            $prevChar = $char;
        }
    
        return $result;
    }

    /**
     * Set the view to this object
     *
     * @param Zend_View_Interface $view
     * @return void
     */
    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

}
