<?php

/**
 * Class for strings
 *
 * @category Sly
 * @package Sly_Strings
 */
class Sly_Strings
{

    /**
     * @static
     * @var Sly_Strings
     * @access protected
     */
    protected static $_instance = NULL;

    /**
     * @var string
     * @access protected
     */
    protected static $_stringsFile = null;
    
    /**
     * @var Xml
     * @access protected
     */
    protected $_xml = NULL;

    /**
     * Sets the strings config file
     *
     * @param  $stringsFile
     * @return void
     */
    public static final function setStringsFile( $file )
    {
        self::$_stringsFile = $file;
    }
    
    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct()
    {
        if ( self::$_stringsFile ) {
            $stringsFile = self::$_stringsFile;
        }
        else {
            $stringsFile = SLY_ROOT_DIR . '/config/strings.xml';
        }

        $this->_xml = simplexml_load_file( $stringsFile );
    }

    /**
     * Retrieves the strings instance.
     *
     * @return Sly_Strings
     */
    public static function getInstance()
    {
        if ( ! self::$_instance ) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }
    
    /**
     * Get the value of the string id
     *
     * @param string $stringId
     * @return string The text of the string
     */
    public function getText( $stringId )
    {
        if ( $this->_xml->$stringId && ! (string)$this->_xml->$stringId == '' ) {
            return (string)$this->_xml->$stringId;
        }

        return $stringId;
    }

}
    
?>
