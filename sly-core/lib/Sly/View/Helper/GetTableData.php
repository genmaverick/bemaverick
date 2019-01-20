<?php

/**
 * Helper for getting table data to populate the table
 */
class Sly_View_Helper_GetTableData
{
    /**
     * The view object that created this helper object.
     * 
     * @var Zend_View
     */
    public $view;

    public function getTableData( $items, $columns, $input )
    {

        $data = array();

        foreach( $items as $item ) {  
        
            if ( ! $item ) {
                continue;
            }
            
            if ( is_array($item) && isset( $item['id'] ) ) {
                $id = $item['id'];
            } else if ( is_scalar( $item ) ) {
                $id = $item;
            } else if ( is_object( $item ) ) {
                $id = $item->getId();
            } else {
                continue;
            }

            foreach( $columns as $column ) {
                $function = "_$column";

                $data[$id][$column] = call_user_func( array( $this, $function ), $item, $input );
            }

        }

        return $data;
    }    

    protected function _userName( $user, $input )
    {
        return $user['name'];
    }                  
               
    protected function _userName2( $user, $input )
    {
        return $user['name'];
    } 
                   
    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }
    
    
}
