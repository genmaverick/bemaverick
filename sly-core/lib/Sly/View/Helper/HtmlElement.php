<?php
/**
 * Helper for creating html elements. Not using the zend stuff, not a fan.
 */
class Sly_View_Helper_HtmlElement
{
    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public $view;


    public function htmlElement()
    {
        return $this;
    }

    public function getCheckbox( $name, $value, $checked = '', $attribs = array() ){
        $attribs['name'] = $name;
        $attribs['value'] = $value;
        $attribs['type'] = 'checkbox';

        if( $checked ) {
            $attribs['checked'] = 'checked';
        }
        return $this->getClosedTag('input', $attribs);
    }

    public function getRadio( $name, $value, $checked = '', $attribs = array() ){
        $attribs['name'] = $name;
        $attribs['value'] = $value;
        $attribs['type'] = 'radio';
        if( $checked ) {
            $attribs['checked'] = 'checked';
        }
        return $this->getClosedTag('input', $attribs);
    }

    public function getTextbox( $name, $value, $attribs = array() ){
        $attribs['name'] = $name;
        $attribs['value'] = $value;
        $attribs['type'] = isset( $attribs['type'] ) ? $attribs['type'] : 'text';
        return $this->getClosedTag('input', $attribs);
    }

    public function getTime( $name, $value, $attribs = array() ){
        $attribs['name'] = $name;
        $attribs['value'] = $value;
        $attribs['type'] = 'time';
        return $this->getClosedTag('input', $attribs);
    }

    public function getPassword( $name, $value, $attribs = array() ){
        $attribs['name'] = $name;
        $attribs['value'] = $value;
        $attribs['type'] = 'password';
        return $this->getClosedTag('input', $attribs);
    }

    public function getInputButton( $name, $value, $attribs = array() ){
        $attribs['name'] = $name;
        $attribs['value'] = $value ? $value : 'Click';
        $attribs['type'] = 'button';
        return $this->getClosedTag('input', $attribs);
    }

    public function getSubmitButton( $name, $value, $attribs = array() ){
        $attribs['name'] = $name;
        $attribs['value'] = $value ? $value : 'Submit';
        $attribs['type'] = 'submit';
        return $this->getClosedTag('input', $attribs);
    }

    public function getFileUpload( $name, $attribs = array() ){
        $attribs['name'] = $name;
        $attribs['type'] = 'file';
        return $this->getClosedTag('input', $attribs);
    }

    public function getHidden( $name, $value, $attribs = array() ){
        $attribs['name'] = $name;
        $attribs['value'] = $value;
        $attribs['type'] = 'hidden';
        return $this->getClosedTag('input', $attribs);
    }


    public function getTextarea( $name, $value, $attribs = array() ){
        $attribs['name'] = $name;
        $attribs['type'] = 'text';
        return $this->getContainingTag('textarea', $value, $attribs);
    }


    public function getSelect( $name, $options, $values = array(), $attribs = array(), $checkStrict = false ){
        $attribs['name'] = $name;

        if (!is_array($values) ) {
            $values = array( $values ) ;
        }

        $pieces = array();
        foreach( $options as $optValue=>$option ) {

            if ( !isset ($option['itemAttributes']) ) {
                $option['itemAttributes'] = array();
            }
            $option['itemAttributes']['value'] = $optValue;


            if ( in_array( $optValue, $values, $checkStrict )){
                $option['itemAttributes']['selected'] = 'selected';
            }
            $pieces[] = $this->getContainingTag('option', $option['text'],  $option['itemAttributes'] );

        }
        return $this->getContainingTag('select', join('',$pieces) , $attribs);
    }


    public function getSelectWithGroups( $name, $groups, $values = array(), $attribs = array(), $checkStrict = false ){
        $attribs['name'] = $name;

        if (!is_array($values) ) {
            $values = array( $values ) ;
        }

        $groupPieces = array();

        foreach( $groups as $group ) {
            $options = $group['options'];
            $pieces = array();

            foreach( $options as $optValue=>$option ) {

                if ( !isset ($option['itemAttributes']) ) {
                    $option['itemAttributes'] = array();
                }
                $option['itemAttributes']['value'] = $optValue;


                if ( in_array( $optValue, $values, $checkStrict )){
                    $option['itemAttributes']['selected'] = 'selected';
                }
                $pieces[] = $this->getContainingTag('option', $option['text'],  $option['itemAttributes'] );

            }
            if ( isset( $group['title']) && $group['title'] ) {
                $groupPieces[] = $this->getContainingTag('optgroup', join('',$pieces),  array( 'label' => $group['title']) );
            } else {
                $groupPieces[] = join('',$pieces);
            }



        }
        return $this->getContainingTag('select', join('',$groupPieces) , $attribs);
    }



    public function getLabel( $content, $for = null, $attribs = array() ){
        if ( $for ) { 
            $attribs['for'] = $for;
        }
        return $this->getContainingTag('label', $content, $attribs);
    }

    public function getClosedTag( $tag, $attribs = array() ){
        $tag = strtolower( $tag );
        if (  $tag == 'input' ) {
            if ( isset( $attribs['class'] ) ) {
                $attribs['class'] .= ' '.$attribs['type'];
            } else {
                $attribs['class'] = $attribs['type'];
            }
        }
        return '<'.$tag.$this->view->htmlAttributes($attribs).'/>';
    }

    public function getContainingTag( $tag,$content, $attribs = array() ){
        $tag = strtolower( $tag );
        return '<'.$tag.$this->view->htmlAttributes($attribs).'>'.$content.'</'.$tag.'>';
    }

    public function tag ($tag, $content, $attribs = array()) {
        return $this->getContainingTag($tag, $content, $attribs);
    }

    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }
}
