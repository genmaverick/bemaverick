<?php

/**
 * Helper for creating html attribute string
 */
class Sly_View_Helper_HtmlAttributes
{
    /**
     * The view object that created this helper object.
     * @var Zend_View
     */
    public $view;

 
    public function htmlAttributes( $attribs )
    {
        $xhtml = '';
        ksort( $attribs );
        foreach ((array) $attribs as $key => $val) {
            $key = $this->view->escape($key);
            if (is_array($val)) {
                $val = implode(' ', $val);
            }
            $val = $this->view->escape($val);
            $xhtml .= " $key=\"$val\"";
        }
        return $xhtml;
 
    }

    public function setView(Zend_View_Interface $view)
    {
        $this->view = $view;
    }
}
