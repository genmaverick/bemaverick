<?php

/**
 * Helper for getting table  information including column definitions
 */
class Sly_View_Helper_GetTableInfo
{
    /**
     * The view object that created this helper object.
     * 
     * 
     * @var Zend_View
     */
    public $view;

 
    public function getTableInfo()
    {                       
        return $this;
    }

    public function getColumnInfo($columns = null) 
    {
        $columnInfo = array(            
             'userName' => array(
                'title' => 'User Name',
                'className' => 'userName',
            ),       
            'userName2' => array(
                'title' => 'User Name',
                'className' => 'userName',
            ),                                                     
        );
        
        $columnsToReturn = array();
        if ( $columns ) {
            foreach($columns as $column) {
                if ( isset($columnInfo[$column])){
                    $columnsToReturn[$column] =  $columnInfo[$column];               
                }
	        }                
            return $columnsToReturn;
        } else {       
            return $columnInfo;       
        }
    } 
    
    public function getColumnGroupInfo()
    {
        $groupInfo = array(
            'contact' => array('contact'),            
            'user1' => array('User 1'),             
            'user2' => array('User 2'),                         
        );          
        return $groupInfo;              
    }
    

    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;        
    }
}
