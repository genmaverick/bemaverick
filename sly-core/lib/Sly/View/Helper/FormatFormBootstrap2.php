<?php
require_once( SLY_ROOT_DIR . '/lib/Sly/DataObject.php' );
/**
 *
 */
class Sly_View_Helper_FormatFormBootstrap2
{
    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public $view;

    public function formatFormBootstrap2() {
        return $this;
    }

    public function getTextboxSimple( $name, $text, $value, $defaultValue, $options = array() )
    {
        $inputSettings = array(
            'value' => $value,
            'defaultValue' => $defaultValue,
            'name' => $name,
            'text' => $value,
        );

        $labelSettings = array(
            'text' => $text
        );

        return $this->getTextbox( $inputSettings, $labelSettings, $options );
    }

    public function getTextbox( $input = array(), $label = array(), $options = array() )
    {

        $htmlElement = $this->view->htmlElement();
        $formatForm = $this->view->formatForm();
        $input = new Sly_DataObject( $input );
        $label = new Sly_DataObject( $label );
        $options = new Sly_DataObject( $options );

        $value = $input->getValue();
        $defaultValue = $input->getDefaultValue();
        $name = $input->getName();
        $inputAttributes = $input->getAttributes( array() );
        $isTextarea = $input->getType() == 'textarea' ? true : false;

        $id = isset($inputAttributes['id']) ? $inputAttributes['id'] : $name;

        $rows = $input->getRows();
        if ( $rows && $isTextarea ) {
            $inputAttributes = $this->view->formatUtil()->addItemToAttributes( $inputAttributes , 'rows', $rows );
        }

        $width = $input->getWidth();
        if ( $width ) {
            $inputAttributes = $this->view->formatUtil()->addItemToAttributes( $inputAttributes , 'class', 'span'.$width );
        }

        if ($options->getPlaceholder()) {
            $inputAttributes['placeholder'] = $options->getPlaceholder();
        }

        if ( $input->getIsRequired() ) {
            $inputAttributes = $this->view->formatUtil()->addItemToAttributes( $inputAttributes , 'required', 'true' );
        }


        if ( $input->getType() && $input->getType() != 'textarea' && !isset( $inputAttributes['type'] ) ) {
            $inputAttributes['type'] = $input->getType();
        }

        $inputAttributes['id'] = $id;

        if ( !$value && $defaultValue !== null ) {
            $value = $defaultValue;
        }
        $returnType = $options->getReturnType();
        $controlWrap = $options->getControlWrap( true );

        $pieces = array();
        $pieces[] = $this->wrapContent( $this->_getLabel( $label, $id ), $label );
        if ( $controlWrap ) {
            $controlsAttribs = $this->view->htmlAttributes($options->getControlAttributes(array('class' => 'controls')));
            $pieces[] = '<div ' . $controlsAttribs . '>';
        }
        if ( $isTextarea ) {
            $pieces[] = $this->wrapContent( $htmlElement->getTextarea( $name, $value, $inputAttributes ), $input );
        } else {
            $pieces[] = $this->wrapContent( $htmlElement->getTextbox( $name, $value, $inputAttributes ), $input );
        }
        $pieces[] = $formatForm->getError( $name );

        $pieces[] = $this->_getHelp( $options );
        if ( $controlWrap ) {
            $pieces[]  = '</div>';
        }

        $title = $this->wrapContent(join( $pieces, '' ), $options);


        if ( $returnType == 'title' ) {
            return $title;
        } else {
            if ( $isTextarea ) {
                $itemClass = 'control-group form-group textarea';
            } else {
                $itemClass = 'control-group form-group textbox';
            }
            $classes = $this->getItemClasses( $itemClass, $input->getIsRequired(),  $formatForm->hasError( $name ) );
            $optionAttributes = $options->getAttributes( array() );
            $optionAttributes = $this->view->formatUtil()->addItemToAttributes( $optionAttributes , 'class', $classes );
            return array(
                'title' => $title,
                'itemAttributes' => $optionAttributes
            );
        }
    }

    public function getRadios( $inputs = array(), $label = array(), $options = array() )
    {

        $htmlElement = $this->view->htmlElement();
        $formatForm = $this->view->formatForm();
        $formatUtil = $this->view->formatUtil();
        $inputs = new Sly_DataObject( $inputs );
        $label = new Sly_DataObject( $label );
        $options = new Sly_DataObject( $options );

        $value = $inputs->getValue();
        $defaultValue = $inputs->getDefaultValue();
        $name = $inputs->getName();

        $returnType = $options->getReturnType();
        $controlWrap = $options->getControlWrap( true );
        $defaultWidth = $inputs->getWidth();


        if ( !$value && $defaultValue !== null ) {
            $value = $defaultValue;
        }


        $pieces = array();
        $pieces[] = $this->wrapContent( $this->_getLabel( $label, '' ), $label );
        if ( $controlWrap ) {
            $pieces[] = '<div class="controls">';
        }
        $itemCount = 0;
        foreach( $inputs->getItems() as  $item ) {
            $item = new Sly_DataObject( $item );
            $itemAttributes = $item->getAttributes( array() );
            $id = isset($itemAttributes['id']) ? $itemAttributes['id'] : str_replace( '[]', '', $name ).'-'.$itemCount;

            $itemAttributes = $formatUtil->addItemToAttributes( $itemAttributes, 'id', $id );
            $itemAttributes = $formatUtil->addItemToAttributes( $itemAttributes, 'class', 'radio' );
            $item->setAttributes( $itemAttributes );
            $itemValue = $item->getValue( '' );
            $checked = $itemValue ==  $value ? true : false;
            $item->setText($this->wrapContent( $htmlElement->getRadio( $name, $itemValue, $checked, $itemAttributes ), $item ).$item->getText( '' ));
            $item->setAttributes( array('class' => 'radio') );
            $pieces[] = $this->wrapContent($this->_getLabel( $item ), new Sly_DataObject( $itemAttributes ));
            $itemCount++;
        }
        $pieces[] = $formatForm->getError( $name );

        $pieces[] = $this->_getHelp( $options );
        if ( $controlWrap ) {
            $pieces[]  = '</div>';
        }

        $title = $this->wrapContent(join( $pieces, '' ), $options);


        if ( $returnType == 'title' ) {
            return $title;
        } else {

            $classes = $this->getItemClasses( 'control-group form-group radios', $inputs->getIsRequired(),  $formatForm->hasError( $name ) );
            $optionAttributes = $options->getAttributes( array() );
            $optionAttributes = $this->view->formatUtil()->addItemToAttributes( $optionAttributes , 'class', $classes );
            return array(
                'title' => $title,
                'itemAttributes' => $optionAttributes
            );
        }
    }

    public function getCheckboxSimple( $name, $text, $value, $defaultValue )
    {
        $inputSettings = array(
            'values' => array( $value ),
            'defaultValues' => array( $defaultValue ),
            'name' => $name,
            'items' => array(
                array(
                    'text' => $text,
                    'value' => 1,
                )
            )
        );

        $labelSettings = array(
            'text' => ''
        );

        return $this->getCheckboxes( $inputSettings, $labelSettings );
    }

    public function getCheckboxes( $inputs = array(), $label = array(), $options = array() )
    {

        $htmlElement = $this->view->htmlElement();
        $formatForm = $this->view->formatForm();
        $formatUtil = $this->view->formatUtil();
        $inputs = new Sly_DataObject( $inputs );
        $label = new Sly_DataObject( $label );
        $options = new Sly_DataObject( $options );

        $values = $inputs->getValues(array());
        $defaultValues = $inputs->getDefaultValues(array());
        $name = $inputs->getName();

        $returnType = $options->getReturnType();
        $controlWrap = $options->getControlWrap( true );
        $defaultWidth = $inputs->getWidth();

        if ( !$values && $defaultValues !== null ) {
            $values = $defaultValues;
        }

        $pieces = array();
        $pieces[] = $this->wrapContent( $this->_getLabel( $label, '' ), $label );
        if ( $controlWrap ) {
            $pieces[] = '<div class="controls">';
        }

        foreach( $inputs->getItems() as $itemIndex => $item ) {
            $item = new Sly_DataObject( $item );

            $itemLabel = new Sly_DataObject( $item->getLabel(array()) );

            if ( !$inputs->getIsToggleBox(false)) {

                $itemAttributes = $item->getAttributes( array() );
                $id = isset($itemAttributes['id']) ? $itemAttributes['id'] : str_replace( '[]', '', $name ).'-'.$itemIndex;

                if (!isset($itemAttributes['id'])) {
                    $itemAttributes = $formatUtil->addItemToAttributes( $itemAttributes, 'id', $id );
                }
                //$itemAttributes = $formatUtil->addItemToAttributes( $itemAttributes, 'class', 'checkbox' );
                $item->setAttributes( $itemAttributes );


                $itemValue = $item->getValue( '' );
                $checked = in_array( $itemValue, $values ) ? true : false;
                $item->setText($this->wrapContent( $htmlElement->getCheckbox( $name, $itemValue, $checked, $itemAttributes ), $item ).$item->getText( '' ));

                $item->setAttributes( $itemLabel->getAttributes(array('class' => '')) );

                $pieces[] = '<div class="checkbox">' . $this->_getLabel( $item, $id ) . '</div>';

            } else {
                $itemAttributes = $item->getAttributes( array() );
                $id = isset($itemAttributes['id']) ? $itemAttributes['id'] : str_replace( '[]', '', $name ).'-'.$itemIndex;

                if (!isset($itemAttributes['id'])) {
                    $itemAttributes = $formatUtil->addItemToAttributes( $itemAttributes, 'id', $id );
                }
                //$itemAttributes = $formatUtil->addItemToAttributes( $itemAttributes, 'class', 'checkbox' );
                $item->setAttributes( $itemAttributes );

                $itemValue = $item->getValue( '' );
                $checked = in_array( $itemValue, $values ) ? true : false;
                $item->setText($item->getText( '' ));
                $item->setAttributes( $itemLabel->getAttributes(array('class' => 'checkbox')) );
                $pieces[] = '<div class="togglebox">'.$this->wrapContent( $htmlElement->getCheckbox( $name, $itemValue, $checked, $itemAttributes ), $item ).$this->_getLabel( $item, $id ).'</div>';

            }
        }
        $pieces[] = $formatForm->getError( $name );

        $pieces[] = $this->_getHelp( $options );
        if ( $controlWrap ) {
            $pieces[]  = '</div>';
        }

        $title = $this->wrapContent(join( $pieces, '' ), $options);


        if ( $returnType == 'title' ) {
            return $title;
        } else {
            $classes = $this->getItemClasses( 'control-group form-group checkboxes', $inputs->getIsRequired(),  $formatForm->hasError( $name ) );
            $optionAttributes = $options->getAttributes( array() );
            $optionAttributes = $this->view->formatUtil()->addItemToAttributes( $optionAttributes , 'class', $classes );
            return array(
                'title' => $title,
                'itemAttributes' => $optionAttributes
            );
        }
    }

    public function getButtons( $buttons = array(), $options = array() )
    {

        $htmlElement = $this->view->htmlElement();
        $formatForm = $this->view->formatForm();
        $pieces = array();
        $options = new Sly_DataObject( $options );


        $returnType = $options->getReturnType();
        $classDelimiter = $options->getClassDelimiter( '-' );
        $className = $options->getClassName( 'btn' );

        foreach( $buttons as $i => $button ) {
            $button = new Sly_DataObject( $button );

            $type = $button->getType( 'submit' );
            $text = $button->getText( 'Submit' );

            $styleDefault = $i == 0 ? 'primary' : false;

            $style = $button->getStyle( $styleDefault );
            $size = $button->getSize();
            $disabled = $button->getDisabled();
            $attributes = $button->getAttributes( array() );

            $classes = array( $className );
            if ( $style ) {
                $classes[] = $className.$classDelimiter.$style;
            }
            if ( $size ) {
                $classes[] = $className.$classDelimiter.$size;
            }
            if ( $disabled ) {
                $classes[] = 'disabled';
            }

            $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class' , join( $classes, ' ') );

            if ( $type == 'button' || $type == 'submit' ) {
                $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'type' , $type );
                if ( $disabled ) {
                    $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'disabled' , 'disabled' );
                }
                $btnMarkup = '<button '.$this->view->htmlAttributes($attributes).'>'.$text.'</button>';
            } else if ( $type == 'link' && $button->getLink() ) {

                $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'href' , $button->getLink() );
                $btnMarkup = '<a '.$this->view->htmlAttributes($attributes).'>'.$text.'</a>';
            }
            else {
                $btnMarkup = $text;
            }

            if ($btnMarkup) {
                $pieces[] = $this->wrapContent($btnMarkup, $button);
            }

        }

        $title = $this->wrapContent(join( $pieces, ' ' ), $options);

        if ( $returnType == 'title' ) {
            return $title;
        } else {
            return array(
                'title' => $title,
                'itemAttributes' => array(
                    'class' => $this->getItemClasses( 'form-actions' )
                )
            );
        }
    }

    public function getButton ( $button, $options = array() ) {
        $button = new Sly_DataObject( $button );
        $options = new Sly_DataObject( $options );

        $returnType = $options->getReturnType();

        $type = $button->getType( 'submit' );
        $text = $button->getText( 'Submit' );

        $styleDefault = 'primary';

        $style = $button->getStyle( $styleDefault );
        $size = $button->getSize();
        $disabled = $button->getDisabled();
        $attributes = $button->getAttributes( array() );

        $classes = array( 'btn' );
        if ( $style ) {
            $classes[] = 'btn-'.$style;
        }
        if ( $size ) {
            $classes[] = 'btn-'.$size;
        }
        if ( $disabled ) {
            $classes[] = 'disabled';
        }

        $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class' , join( $classes, ' ') );

        if ( $type == 'button' || $type == 'submit' ) {
            $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'type' , $type );
            if ( $disabled ) {
                $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'disabled' , 'disabled' );
            }
            $btnMarkup = '<button '.$this->view->htmlAttributes($attributes).'>'.$text.'</button>';
        } else if ( $type == 'link' && $button->getLink() ) {

            $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes, 'href' , $button->getLink() );
            $btnMarkup = '<a '.$this->view->htmlAttributes($attributes).'>'.$text.'</a>';
        }
        else {
            $btnMarkup = $text;
        }

        $title = $this->wrapContent($btnMarkup, $button);

        if ( $returnType == 'title' ) {
            return $title;
        } else {
            return array(
                'title' => $title,
                'itemAttributes' => array(
                    'class' => 'control-group form-group submit'
                )
            );
        }
    }

    public function getSelects ( $inputs = array(), $label = array(), $options = array() )
    {

        $htmlElement = $this->view->htmlElement();
        $formatForm = $this->view->formatForm();
        $formatUtil = $this->view->formatUtil();
        $inputs = new Sly_DataObject( $inputs );
        $label = new Sly_DataObject( $label );
        $options = new Sly_DataObject( $options );

        $name = $inputs->getName();

        $returnType = $options->getReturnType();
        $controlWrap = $options->getControlWrap( true );
        $defaultWidth = $inputs->getWidth();


        $extraChoice = null;
        if( $inputs->getExtraChoice() )
        {
            $extraChoice = array( '' => array( 'text' => $inputs->getExtraChoice() ) );
        }

        $pieces = array();
        $pieces[] = $this->wrapContent( $this->_getLabel( $label, '' ), $label );
        if ( $controlWrap ) {
            $pieces[] = '<div class="controls controls-row">';
        }
        $itemCount = 0;



        foreach( $inputs->getItems() as  $item ) {
            $item = new Sly_DataObject( $item );

            $itemName = $item->getName($name);
            $itemAttributes = $item->getAttributes( array() );

            if (!isset($itemAttributes['id'])) {
                $id = str_replace( '[]', '', $itemName ).'-'.$itemCount;
                $itemAttributes = $formatUtil->addItemToAttributes( $itemAttributes, 'id', $id );
            }
            $itemAttributes = $formatUtil->addItemToAttributes( $itemAttributes, 'class', 'select' );
            $width = $item->getWidth();
            if ( $width ) {
                $itemAttributes = $formatUtil->addItemToAttributes( $itemAttributes, 'class', 'span'.$width );
            }

            $item->setAttributes( $itemAttributes );

            $itemOptions = $item->getSelectOptions( array() );

            if ($extraChoice) {
                $itemOptions = $extraChoice + $itemOptions;
            }
            $itemValues = $item->getSelectValues( array() );
            $item->setText($this->wrapContent( $htmlElement->getSelect( $itemName, $itemOptions, $itemValues, $itemAttributes ), $item ).$item->getText( '' ));

            //$pieces[] = $this->_getLabel( $item );
            $pieces[] = $item->getText();
            $itemCount++;
        }
        $pieces[] = $formatForm->getError( $name );

        $pieces[] = $this->_getHelp( $options );
        if ( $controlWrap ) {
            $pieces[]  = '</div>';
        }

        $title = $this->wrapContent(join( $pieces, '' ), $options);


        if ( $returnType == 'title' ) {
            return $title;
        } else {

            $classes = $this->getItemClasses( 'control-group form-group select', $inputs->getIsRequired(),  $formatForm->hasError( $name ) );
            $optionAttributes = $options->getAttributes( array() );
            $optionAttributes = $this->view->formatUtil()->addItemToAttributes( $optionAttributes , 'class', $classes );
            return array(
                'title' => $title,
                'itemAttributes' => $optionAttributes
            );
        }
    }


    public function getFileUpload( $input = array(), $label = array(), $options = array() )
    {

        $htmlElement = $this->view->htmlElement();
        $formatForm = $this->view->formatForm();
        $input = new Sly_DataObject( $input );
        $label = new Sly_DataObject( $label );
        $options = new Sly_DataObject( $options );

        $value = $input->getValue();
        $defaultValue = $input->getDefaultValue();
        $name = $input->getName();
        $inputAttributes = $input->getAttributes( array() );

        $id = isset($inputAttributes['id']) ? $inputAttributes['id'] : $name;


        if ( $input->getIsRequired() ) {
            $inputAttributes = $this->view->formatUtil()->addItemToAttributes( $inputAttributes , 'required', 'true' );
        }

        $inputAttributes['id'] = $id;

        if ( !$value && $defaultValue !== null ) {
            $value = $defaultValue;
        }
        $returnType = $options->getReturnType();
        $controlWrap = $options->getControlWrap( true );

        $pieces = array();
        $pieces[] = $this->wrapContent( $this->_getLabel( $label, $id ), $label );
        if ( $controlWrap ) {
            $controlsAttribs = $this->view->htmlAttributes($options->getControlAttributes(array('class' => 'controls')));
            $pieces[] = '<div ' . $controlsAttribs . '>';
        }
        $pieces[] = $this->wrapContent( $htmlElement->getFileUpload( $name, $inputAttributes ), $input );
        $pieces[] = $formatForm->getError( $name );

        $pieces[] = $this->_getHelp( $options );
        if ( $controlWrap ) {
            $pieces[]  = '</div>';
        }

        $title = $this->wrapContent(join( $pieces, '' ), $options);


        if ( $returnType == 'title' ) {
            return $title;
        } else {
            $itemClass = 'control-group form-group fileupload';
            $classes = $this->getItemClasses( $itemClass, $input->getIsRequired(),  $formatForm->hasError( $name ) );
            $optionAttributes = $options->getAttributes( array() );
            $optionAttributes = $this->view->formatUtil()->addItemToAttributes( $optionAttributes , 'class', $classes );
            return array(
                'title' => $title,
                'itemAttributes' => $optionAttributes
            );
        }
    }

    public function wrapContent( $string, $object )
    {
        return $object->getPreContent( '' ).$string.$object->getPostContent( '' );
    }

    public function getTime( $input = array(), $label = array(), $options = array() )
    {

        $inputSettings = array(
            'attributes' => array(
                'class' => 'time-picker'
            )
        );

        $labelSettings = array();
        $optionsSettings = array();

        $input = array_merge_recursive( $inputSettings, $input );
        $label = array_merge_recursive( $labelSettings, $label );
        $options = array_merge_recursive( $options, $optionsSettings );

        return $this->getTextbox( $input, $label, $options );
    }

    public function getTextarea( $input = array(), $label = array(), $options = array() )
    {

        $inputSettings = array(
            'type' => 'textarea'
        );
        $labelSettings = array();
        $optionsSettings = array();

        $input = array_merge_recursive( $inputSettings, $input );
        $label = array_merge_recursive( $labelSettings, $label );
        $options = array_merge_recursive( $options, $optionsSettings );

        return $this->getTextbox( $input, $label, $options );
    }

    public function getPassword( $input = array(), $label = array(), $options = array() )
    {

        $inputSettings = array(
            'type' => 'password'
        );
        $labelSettings = array();
        $optionsSettings = array();

        $input = array_merge_recursive( $inputSettings, $input );
        $label = array_merge_recursive( $labelSettings, $label );
        $options = array_merge_recursive( $options, $optionsSettings );

        return $this->getTextbox( $input, $label, $options );
    }

    public function getEmail( $input = array(), $label = array(), $options = array() )
    {

        $inputSettings = array(
            'type' => 'email'
        );
        $labelSettings = array();
        $optionsSettings = array();

        $input = array_merge_recursive( $inputSettings, $input );
        $label = array_merge_recursive( $labelSettings, $label );
        $options = array_merge_recursive( $options, $optionsSettings );

        return $this->getTextbox( $input, $label, $options );
    }


    public function getCalendar( $input = array(), $label = array(), $options = array() )
    {

        $inputSettings = array(
            'attributes' => array(
                'class' => 'calendar'
            )
        );

        $labelSettings = array();
        $optionsSettings = array();

        $input = array_merge_recursive( $inputSettings, $input );
        $label = array_merge_recursive( $labelSettings, $label );
        $options = array_merge_recursive( $options, $optionsSettings );

        return $this->getTextbox( $input, $label, $options );
    }

    public function getNameValue( $value = array(), $name = array(), $options = array() )
    {

        $htmlElement = $this->view->htmlElement();
        $formatForm = $this->view->formatForm();
        $value = new Sly_DataObject( $value );
        $name = new Sly_DataObject( $name );
        $options = new Sly_DataObject( $options );


        $valueAttributes = $value->getAttributes( array() );

        $width = $value->getWidth();
        if ( $width ) {
            $valueAttributes = $this->view->formatUtil()->addItemToAttributes( $valueAttributes , 'class', 'span'.$width );
        }
        $valueAttributes = $this->view->formatUtil()->addItemToAttributes( $valueAttributes , 'class', 'control-value' );

        $returnType = $options->getReturnType();
        $controlWrap = $options->getControlWrap( true );

        $pieces = array();
        $pieces[] = $this->wrapContent( $this->_getName( $name ), $name );
        if ( $controlWrap ) {
            $pieces[] = '<div class="controls">';
        }

        $text = strlen($value->getText('')) > 0 ? $htmlElement->getContainingTag( 'span', $value->getText(''), $valueAttributes ) : '';
        $pieces[] = $this->wrapContent( $text, $value );
        $pieces[] = $this->_getHelp( $options );
        if ( $controlWrap ) {
            $pieces[]  = '</div>';
        }

        $title = $this->wrapContent(join( $pieces, '' ), $options);


        if ( $returnType == 'title' ) {
            return $title;
        } else {
            $classes = $this->getItemClasses( 'control-group form-group name-value' );
            $optionAttributes = $options->getAttributes( array() );
            $optionAttributes = $this->view->formatUtil()->addItemToAttributes( $optionAttributes , 'class', $classes );
            return array(
                'title' => $title,
                'itemAttributes' => $optionAttributes
            );
        }
    }

    public function getNameValueSimple( $value, $name, $options = array() )
    {
        return $this->getNameValue( array( 'text' => $value ), array( 'text' => $name ), $options );
    }

    //this is private since it expects a Sly_DataObject
    private function _getLabel( $label, $id = '' )
    {

        if ( $label->getText() ) {
            if ( ! $label->getAttributes() ) {
                $attributes = $this->view->formatUtil()->addItemToAttributes( $label->getAttributes(array()), 'class' , 'control-label' );
            } else {
                $attributes = $label->getAttributes( array() );
            }
            return $this->view->htmlElement()->getLabel( $label->getText(), $id, $attributes ).' ';
        } else {
            return '';
        }
    }

    //this is private since it expects a Sly_DataObject
    private function _getName( $name )
    {
        if ( $name->getText() ) {
            $attributes = $this->view->formatUtil()->addItemToAttributes( $name->getAttributes( array() ), 'class' , 'control-label' );
            return $this->view->htmlElement()->getContainingTag( 'span', $name->getText(''), $attributes ).' ';
        } else {
            return '';
        }
    }

    //this is private since it expects a Sly_DataObject
    private function _getHelp( $options )
    {
        if ( $options->getHelp() ) {
            return '<p class="help-block">'.$options->getHelp().'</p> ';
        } else {
            return '';
        }
    }

    /**
     * gets classes for list item attributes
     *
     * @param string $type type of element
     * @param bool $isRequired optional - defaults to false
     * @param bool $hasErrors optional - does item contain errors
     * @return string
     */
    public function getItemClasses( $type, $isRequired = false, $hasErrors = false ) {
        $classes = array();
        $classes[] = $type;
        if( $isRequired ) {
            $classes[] = 'required';
        }
        if( $hasErrors ) {
            $classes[] = 'error';
        }
        return join(' ',$classes );
    }

    /**
     * get formatted error block
     *
     * @param string $name input name to get view errors for
     * @return string
     */
    public function getError( $name ) {
        $name = str_replace( '[]', '', $name );
        if ( $this->view->errors->hasErrors( $name ) ) {
            foreach( $this->view->errors->getErrors( $name ) as $thisError ) {
                $errorMessages[] = array( 'title' => $thisError->getMessage() );
            }
            return '<span class="help-inline">'.$this->view->linkList($errorMessages).'</span>';
        }
        return '';
    }

    public function getLegend( $legend = array(), $options = array() ) {

        $htmlElement = $this->view->htmlElement();
        $legend = new Sly_DataObject( $legend );
        $options = new Sly_DataObject( $options );
        $legendAttributes = $legend->getAttributes(array());

        $text = $legend->getText();
        $title = $this->wrapContent($htmlElement->getContainingTag( 'legend', $text, $legendAttributes ), $legend );
        $title = $this->wrapContent( $title, $options );

        $returnType = $options->getReturnType();

        if ( $returnType == 'title' ) {
            return $title;
        } else {
            return array(
                'title' => $title,
                'itemAttributes' => array(
                    'class' => 'legend'
                )
            );
        }
    }

    public function getHelpTooltip(  $text = '' ) {

        $tooltip = '';
        if ( $text ) {
            $tooltip = ' <span class="help-icon"><i class="tooltip-item icon-question-sign" data-original-title="'.$text.'"></i></span>';
        }
        return $tooltip;

    }

    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }



    public function getSelect( $input = array(), $label = array(), $options = array() )
    {

        $htmlElement = $this->view->htmlElement();
        $formatForm = $this->view->formatForm();
        $formatUtil = $this->view->formatUtil();
        $input = new Sly_DataObject( $input );
        $label = new Sly_DataObject( $label );
        $options = new Sly_DataObject( $options );

        $value = $input->getValue(array());
        $defaultValue = $input->getDefaultValue(array());
        $name = $input->getName();
        $attributes = $input->getAttributes();

        $checkStrict = $options->getCheckStrict();
        $returnType = $options->getReturnType();
        $controlWrap = $options->getControlWrap( true );
        $width = $input->getWidth();
        $id = isset($attributes['id']) ? $attributes['id'] : $name;

        if ( ! $value && $value !== 0 && $defaultValue !== null ) {
            $value = $defaultValue;
        }

        if ( $width ) {
            $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes , 'class', 'span'.$width );
        }

        if ( $input->getIsRequired() ) {
            $attributes = $this->view->formatUtil()->addItemToAttributes( $attributes , 'required', 'true' );
        }
        $attributes['id'] = $id;
        $attributeValues = is_array( $value ) ? $value : array( $value );
        $attributes['data-values'] = join(',', $attributeValues );

        $pieces = array();
        $pieces[] = $this->wrapContent( $this->_getLabel( $label, '' ), $label );
        if ( $controlWrap ) {
            $pieces[] = '<div class="controls">';
        }

        $selectOptions = array();

        foreach( $input->getItems() as $itemIndex => $item ) {
            $item = new Sly_DataObject( $item );
            $itemAttributes = $item->getAttributes( array() );
            $selectOptions[$item->getValue()] = array('text' => $item->getText(), 'itemAttributes' => $itemAttributes );
        }

        $pieces[] = $this->wrapContent( $htmlElement->getSelect( $name, $selectOptions, $value, $attributes, $checkStrict ), $input );
        $pieces[] = $formatForm->getError( $name );

        $pieces[] = $this->_getHelp( $options );
        if ( $controlWrap ) {
            $pieces[]  = '</div>';
        }

        $title = $this->wrapContent(join( $pieces, '' ), $options);


        if ( $returnType == 'title' ) {
            return $title;
        } else {

            $classes = $this->getItemClasses( 'control-group form-group select', $input->getIsRequired(),  $formatForm->hasError( $name ) );
            $optionAttributes = $options->getAttributes( array() );
            $optionAttributes = $this->view->formatUtil()->addItemToAttributes( $optionAttributes , 'class', $classes );
            return array(
                'title' => $title,
                'itemAttributes' => $optionAttributes
            );
        }
    }

    public function getHidden( $input = array(), $options = array(), $strict = true ) {



        $htmlElement = $this->view->htmlElement();
        $formatForm = $this->view->formatForm();
        $input = new Sly_DataObject( $input );
        $options = new Sly_DataObject( $options );

        $value = $input->getValue();
        $defaultValue = $input->getDefaultValue();
        $name = $input->getName();
        $inputAttributes = $input->getAttributes( array() );
        $id = isset($inputAttributes['id']) ? $inputAttributes['id'] : $name;

        $inputAttributes['id'] = $id;

        if ( !$strict ) {
            if ( !$value && $defaultValue !== null ) {
                $value = $defaultValue;
            }
        } else {
            if ( $value === null && $defaultValue !== null ) {
                $value = $defaultValue;
            }
        }

        $returnType = $options->getReturnType('title');
        $pieces = array();
        $pieces[] = $this->wrapContent( $htmlElement->getHidden( $name, $value, $inputAttributes ), $input );
        $title = $this->wrapContent(join( '', $pieces ), $options);


        if ( $returnType == 'title' ) {
            return $title;
        } else {
            $classes = $this->getItemClasses( 'control-group form-group hidden', $input->getIsRequired(),  $formatForm->hasError( $name ) );
            $optionAttributes = $options->getAttributes( array() );
            $optionAttributes = $this->view->formatUtil()->addItemToAttributes( $optionAttributes , 'class', $classes );
            return array(
                'title' => $title,
                'itemAttributes' => $optionAttributes
            );
        }
    }

    public function getHiddenSimple( $name, $value, $inputElem = array(), $options = array(), $useStrict = false )
    {
        $inputSettings = array(
            'name' => $name,
            'value' => $value
        );

        $optionsSettings = array();

        return $this->getHidden( array_merge( $inputSettings, $inputElem ), array_merge( $optionsSettings, $options), $useStrict );
    }

    public function setItemClasses($items) {

        foreach($items as $key => $item ) {
            $items[$key]['itemAttributes']['class'] .= ' form-item-'.$key;
        }

        return $items;

    }

    public function getList(
                        $items,
                        $listAttributes = array(),
                        $setClasses = false
    ) {

        $items = $this->setItemClasses( $items );

        $listAttributes['attributes'] = isset($listAttributes['attributes']) ? $listAttributes['attributes']:  array();
        $listAttributes['attributes'] = $this->view->formatUtil()->addItemToAttributes($listAttributes['attributes'], 'class', 'formItems' );
        return $this->view->linkList($items, $listAttributes);
    }


    public function getStartDateAndTime($inputStartDate, $inputStartTime, $defaultValue, $timezone, $input = array(), $label = array(), $options = array() )
    {
        // start time
        $defaultStartTime = $defaultValue ? strtoupper( Sly_Date::formatDate( $defaultValue, 'h:ia', $timezone ) )  : '';

        $inputSettings = array(
                               'value' => $inputStartTime,
                               'defaultValue' => $defaultStartTime,
                               'name' => 'startTime',
                               'width' => 2,
                               'postContent' => " $timezone</span>",
                               'preContent' => '<span class="timePicker"> @ '
                               );

        $labelSettings = array(
                               'text' => ''
                               );

        $optionsSettings = array(
                                 'returnType' => 'title',
                                 'controlWrap' => false
                                 );

        $startTime = $this->getTextbox( array_merge( $inputSettings, $input ), array_merge( $labelSettings, $label ), array_merge( $options, $optionsSettings ) );

        // start date  - append start time to this
        $defaultStartDate = $defaultValue ? Sly_Date::formatDate( $defaultValue, 'm/d/Y', $timezone )  : '';

        $formItem = $this->getCalendar(
                                       array(
                                             'name' => 'startDate',
                                             'value' => $inputStartDate,
                                             'defaultValue' => $defaultStartDate,
                                             'width' => 2,
                                             'postContent' => ' '.$startTime
                                             ),
                                       array(
                                             'text' => 'Start Time'
                                             )
                                        );

        return $formItem;
    }

    public function getEndDateAndTime($inputEndDate, $inputEndTime, $defaultValue, $timezone, $input = array(), $label = array(), $options = array() )
    {
        // end time
        $defaultEndTime = $defaultValue ? strtoupper( Sly_Date::formatDate( $defaultValue, 'h:ia', $timezone ) )  : '';

        $inputSettings = array(
                               'value' => $inputEndTime,
                               'defaultValue' => $defaultEndTime,
                               'name' => 'endTime',
                               'width' => 2,
                               'postContent' => " $timezone</span>",
                               'preContent' => '<span class="timePicker"> @ '
                               );

        $labelSettings = array(
                               'text' => ''
                               );

        $optionsSettings = array(
                                 'returnType' => 'title',
                                 'controlWrap' => false
                                 );

        $endTime = $this->getTextbox( array_merge( $inputSettings, $input ), array_merge( $labelSettings, $label ), array_merge( $options, $optionsSettings ) );

        // end date  - append end time to this
        $defaultEndDate = $defaultValue ? Sly_Date::formatDate( $defaultValue, 'm/d/Y', $timezone )  : '';

        $formItem = $this->getCalendar(
                                       array(
                                             'name' => 'endDate',
                                             'value' => $inputEndDate,
                                             'defaultValue' => $defaultEndDate,
                                             'width' => 2,
                                             'postContent' => ' '.$endTime
                                             ),
                                       array(
                                             'text' => 'End Time'
                                             )
                                        );

        return $formItem;
    }

    public function getPublishDateAndTime($inputPublishDate, $inputPublishTime, $defaultValue, $timezone, $input = array(), $label = array(), $options = array() )
    {
        // publish time
        $defaultPublishTime = $defaultValue ? strtoupper( Sly_Date::formatDate( $defaultValue, 'h:ia', $timezone ) )  : '';

        $inputSettings = array(
                               'value' => $inputPublishTime,
                               'defaultValue' => $defaultPublishTime,
                               'name' => 'publishTime',
                               'width' => 2,
                               //'type' => 'time',
                               'postContent' => " $timezone</span>",
                               'preContent' => '<span class="timePicker"> @ '
                               );

        $labelSettings = array(
                               'text' => ''
                               );

        $optionsSettings = array(
                                 'returnType' => 'title',
                                 'controlWrap' => false
                                 );

        $publishTime = $this->getTextbox( array_merge( $inputSettings, $input ), array_merge( $labelSettings, $label ), array_merge( $options, $optionsSettings ) );

        // publish date  - append publish time to this
        $defaultPublishDate = $defaultValue ? Sly_Date::formatDate( $defaultValue, 'm/d/Y', $timezone )  : '';

        $formItem = $this->getCalendar(
                                       array(
                                             'name' => 'publishDate',
                                             'value' => $inputPublishDate,
                                             'defaultValue' => $defaultPublishDate,
                                             'width' => 2,
                                             'postContent' => ' '.$publishTime
                                             ),
                                       array(
                                             'text' => 'Start Time'
                                             )
                                        );

        return $formItem;
    }

}

?>
