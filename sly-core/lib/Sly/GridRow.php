<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/GridUnit.php' );

/**
 * Class for encapsulating row configurations
 *
 * Row => structure
 *   - Units
 *      - Files
 *
 * Row  = collection of units
 * Unit = width + collection of files
 *
 */
class Sly_GridRow
{

    private $units; /* array */
    private $attributes;

    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct( $units, $attributes = array() )
    {
        $this->units = $units;
        $this->attributes = $attributes;
    }

    public function getUnits()
    {
        return $this->units;
    }

    public function getAttributes()
    {
        return $this->attributes;
    }

}
    
?>
