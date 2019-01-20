<?php

class Sly_DataObject
{

    var $_data;

    public function __construct( $data )
    {
        $this->_data = $data;
    }

    /**
     * Magic method calling
     *
     * @param  $functionName, $arguments 
     * @return void
     */
    public function __call($functionName, $arguments) {
        
        // functionName will look like:  getContentType
        // or isEditable, in which case we will thake that as the key
        // remove the get part and lowercase the first character
        $get = strpos( strtolower($functionName), 'get' ) === 0 ? true : false;        
        $is = strpos( strtolower($functionName), 'is' ) === 0 ? true : false;
        $has = strpos( strtolower($functionName), 'has' ) === 0 ? true : false;

        if ( !$is && !$has ) {
            $field = strtolower( substr($functionName,3, 1) ) . substr($functionName, 4); 
        } else {
            $field = $functionName;
        }

        if ( $get || $is || $has ) {
                       
            if ( isset( $this->_data[$field] ) ) {
                return $this->_data[$field];
            }

            if ( isset($arguments[0]) )  {
                return $arguments[0];
            }

            return false;
        } else if ( isset($arguments[0]) ) {
            $this->_data[$field] = $arguments[0];
        }
    }
    
    public function __toString()
    {
        return serialize( $this->_data );
    }
}

?>
