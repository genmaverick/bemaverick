<?php

/**
 * Helper for declaring default values of template variables
 *
 * @package    Zend_View
 * @subpackage Helpers
 * @copyright  Copyright (c) 2005-2007 Zend Technologies USA Inc. (http://www.zend.com)
 * @license    http://framework.zend.com/license/new-bsd     New BSD License
 */
class Sly_View_Helper_GetItem
{
    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public $view;


    public function getItem( $itemKey, $objectKey = null )
    {
        if ( !$objectKey ) {
            if ( !isset( $this->view->items ) || !isset( $this->view->items[$itemKey] )) {
                return null;
            } else {
                return   $this->view->items[$itemKey];
            }
        } else {
            if ( !isset( $this->view->items ) || !isset( $this->view->items[$itemKey] ) || !isset( $this->view->items[$itemKey][$objectKey] ) ) {
                return null;
            } else {
                return   $this->view->items[$itemKey][$objectKey];
            }
        }

    }


    public function setView(Zend_View_Interface $view)
    {
        $this->view = $view;
    }
}
