<?php

/**
 * Helper for declaring default values of template variables
 *
 */
class Sly_View_Helper_AddItem
{
    /**
     * The view object that created this helper object.
     * @var Zend_View
     */
    public $view;


    /**
     * Add an item to a view array
     *
     * Checks to see if a $key is set in the view object; if not, sets it to $value.
     *
     * @param  string $itemKey
     * @param  string $value Defaults to an empty string
     * @param  string $objectKey  optional
     * @return void
     */
    public function addItem( $itemKey, $value = '', $objectKey = null, $unshift = false )
    {
        if ( !isset( $this->view->items )) {
            $this->view->items = array();
        }

        if ( !isset( $this->view->items[$itemKey] )) {
            $this->view->items[$itemKey] = array();
        }
        if ( ! $objectKey ) {

            if ( $unshift ) {
                array_unshift( $this->view->items[$itemKey], $value );
            } else {
                $this->view->items[$itemKey][] = $value;
            }

        } else {
	        $this->view->items[$itemKey][$objectKey] = $value;
        }

    }


    public function setView(Zend_View_Interface $view)
    {
        $this->view = $view;
    }
}
