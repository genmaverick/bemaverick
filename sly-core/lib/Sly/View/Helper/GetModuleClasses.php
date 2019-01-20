<?php

class Sly_View_Helper_GetModuleClasses 
{
    
    /**
     * The view object that created this helper object.
     * @var Zend_View
     */
    public $view;
        
    public function getModuleClasses($moduleName, $existingClasses = array(), $isOwner = false)
    {
        $pageConfig = $this->view->pageConfig;
        
        
        $classes = array();

        
        $isModuleEditableByViewer = $pageConfig->isModuleEditableByViewer($moduleName);
        $isModuleEditableByOwner = $pageConfig->isModuleEditableByOwner($moduleName);
        
        
        if( ($isModuleEditableByOwner && $isOwner ) || $isModuleEditableByViewer) {
        
            $destinations = $pageConfig->getModuleDestinations( $moduleName );
            
            if($destinations){
                $classes[] = 'move';
                $classes[] = 'save';                
                foreach($destinations as $destination){
                    $classes[] = 'dest-'.$destination;
                }
            }
            
        }
        
                    
        $isCollapsible = $pageConfig->isModuleCollapsible( $moduleName );
        $isCollapsed = $pageConfig->isModuleCollapsed( $moduleName );
        
        if($isCollapsible){
            $classes[] = 'toggle';
            if($isCollapsed){
                $classes[] = 'off';                
            }        
        }    

        
        if($existingClasses) {
            $classes=array_merge( $existingClasses, $classes);   
        }
        $moduleClasses ='';
        if(count($classes)){
            $moduleClasses = ' class="'.join(' ', $classes).'"';            
        }
        
        return $moduleClasses;
        
        
    }
    
    public function setView(Zend_View_Interface $view)
    {
        $this->view = $view;
    }    
    
}
?>