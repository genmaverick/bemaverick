<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/GridRow.php' );

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
class Sly_Grid
{

    private $id;
    private $type;
    private $rows;
    private $attributes;

    /**
     * Class constructor
     *
     * @return void
     */
    public function __construct( $id, $type, $rows = array(), $attributes = array() )
    {
        $this->id = $id;
        $this->type = $type;
        $this->rows = $rows;
        $this->attributes = $attributes;
    }

    public function getId()
    {
        return $this->id;
    }

    public function getType()
    {
        return $this->type;
    }

    public function addRow( $row )
    {
        if ( !$row ) {
            return false;
        }
        if ( is_array($row) ) {
            $row = new Sly_GridRow($row);
        }
        $this->rows[] = $row;
        return true;
    }

    public function getRows()
    {
        return $this->rows;
    }

    public function getAttributes()
    {
        return $this->attributes;
    }

}
    
?>
