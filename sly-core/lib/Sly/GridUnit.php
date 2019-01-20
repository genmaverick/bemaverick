<?php

/**
 * Class for encapsulating grid configurations
 *
 * Grid => structure
 *  - Rows
 *     - Units
 *        - Files
 *
 * Grid = Id + Type + collection of rows
 * Row  = collection of units
 * Unit = width + collection of files
 *
 */
class Sly_GridUnit
{

    private $id;
    private $width;
    private $files;
    private $content;
    private $attributes;
    private $isContentWrapped;

    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct( $id, $width, $files = array(), $content = '', $attributes = array(), $isContentWrapped = false )
    {
        $this->id = $id;
        $this->width = $width;
        $this->files = $files;
        $this->content = $content;
        $this->attributes = $attributes;
        $this->isContentWrapped = $isContentWrapped;
    }

    public function getId()
    {
        return $this->id;
    }

    public function getWidth()
    {
        return $this->width;
    }

    public function getWidths()
    {
        $widths = explode(' ', $this->getWidth());
        return $widths;
    }

    public function hasId()
    {
        return (bool) $this->id;
    }

    public function getUnitIdTag()
    {
        if ($this->hasId()) {
            return $this->id;
        }
    }

    public function setFiles( $files )
    {
        if ( !$files || 
             !is_array($files) ) {
            return false;
        }
        $this->files = $files;
        return true;
    }

    public function getFiles()
    {
        return $this->files;
    }

    public function getContent()
    {
        return $this->content;
    }

    public function getAttributes()
    {
        return $this->attributes;
    }

    public function setIsContentWrapped( $isWrapped )
    {
        $this->isContentWrapped = $isWrapped;
    }

    public function isContentWrapped()
    {
        return $this->isContentWrapped;
    }

}
    
?>
