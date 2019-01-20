<?php

require_once( SLY_ROOT_DIR . '/lib/Sly/StringHash.php' );

/**
 * Helper for creating form elements. Not using the zend stuff, not a fan.
 */
class Sly_View_Helper_FormatForm
{
    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public $view;

    /**
     * get this helper
     *
     * @return Sly_View_Helper_FormatForm
     */
    public function formatForm()
    {
        return $this;
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
            return '<div class="error">'.$this->view->linkList($errorMessages).'</div>';
        }
        //return '<div class="error">'.$this->view->linkList(array(array('title'=>'this is and error messge'))).'</div>';
        return '';
    }

    /**
     * does input have errors
     *
     * @param string $name input name to check against view errors
     * @return bool
     */
    public function hasError( $name ) {
        $name = str_replace( '[]', '', $name );
        return $this->view->errors->hasErrors( $name );
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
            $classes[] = 'hasErrors';
        }
        return join(' ',$classes );
    }

    /**
     * get the To field for a private message - has everything that the js needs
     *
     * @param array $users list of Sly_Users to prepopulate the field with
     * @param array $emails list of email addresses to prepopulate the field with
     * @param string $text optional - label text defaults to 'To'
     * @param array $attribs optional - textbox attributes - use $attribs['id'] which will be used as the
     *         prefix anywhere that the id is specified - default to 'to'
     * @return string
     */
    public function getPrivateMessageTo(
                                    $users = null,
                                    $emails = null,
                                    $maxItems = null,
                                    $text = 'To',
                                    $message = null,
                                    $attribs = array()
    ){

        $htmlElement = $this->view->htmlElement();
        $pieces  = array();

        $id = isset($attribs['id']) ? $attribs['id'] : 'to';
        $attribs['id'] = $id;
        $error = $this->getError( 'userIds[]' );
        $pieces[] = $error;

        $pieces[] = $htmlElement->getLabel( $text, $id ).' ';
        $pieces[] = '<div id="'.$id.'Container">';
        if ( $users ) {
            foreach( $users as $user ) {
                $name = $user->getFirstName().' '.$user->getLastName();
                if ($name == ' ' ){
                    $name = $user->getDisplayName();
                }
                $pieces[] = '<span class="nameHolder">' .$name. $htmlElement->getHidden('userIds[]', $user->getId()).'<em class="delete"></em></span>';
            }
        }

        if ( $emails ) {
            foreach( $emails as $email ) {
                $pieces[] = '<span class="nameHolder">' .$email. $htmlElement->getHidden('emailAddresses[]', $email, array( 'class'=>'addressValue')).'<em class="delete"></em></span>';
            }
        }

        $pieces[] = $htmlElement->getTextbox( $id, '', $attribs );

        $pieces[] = '<div id="'.$id.'Complete"></div>';

        $pieces[] = '</div>';
        if (!$maxItems && !$message ) {
            $pieces[] = '<p>Begin typing and select a user or enter email addresses separated by commas</p>';
        } else if (!$message)  {
            if ($maxItems === 1 ) {
                 $pieces[] = '<p>Begin typing and select a user or enter an email address</p>';
            } else {
                 $pieces[] = '<p>Begin typing and select a user or enter email addresses separated by commas (Maximum Items: '.$maxItems.')</p>';
            }
        } else {
           $pieces[] = '<p>'.$message.'</p>';
        }
        return join('', $pieces);

    }


    /**
     * list attribute convenience method for getPrivateMessageTo
     *
     * @param array $users list of Sly_Users to prepopulate the field with
     * @param array $emails list of email addresses to prepopulate the field with
     * @param string $text optional - label text defaults to 'To'
     * @param array $attribs optional - textbox attributes - use $attribs['id'] which will be used as the
     *         prefix anywhere that the id is specified - default to 'to'
     * @return $array
     */
    public function getPrivateMessageToListAttributes(
                                                    $users = null,
                                                    $emails = null,
                                                    $maxItems = null,
                                                    $text = 'To',
                                                    $message = null,
                                                    $attribs = array()
     ) {
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getPrivateMessageTo' ), $args  ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'textbox js to', true, $this->hasError( 'userIds[]' ) )
            )
        );
    }

    /**
     * get a textbox with label and error block
     *
     * @param string $name name of input - will be textbox id if not passed in $textboxAttributes
     * @param string $text optional - label text, omit and no label element
     * @param string $value optional - current value of text box
     * @param string $defaultValue optional - value if no $value is passed in
     * @param bool   $isRequired optional - is a required elem
     * @param array  $textboxAttributes optional - attributes for text box
     * @param array  $labelAttributes optional - attributes for the label
     * @return string
     */
    public function getTextbox(
                            $name,
                            $text = null,
                            $value = null,
                            $defaultValue = null,
                            $isRequired = null,
                            $textboxAttributes = array(),
                            $labelAttributes = array()
    ){
        $htmlElement = $this->view->htmlElement();

        $id = isset($textboxAttributes['id']) ? $textboxAttributes['id'] : $name;
        $textboxAttributes['id'] = $id;

        if ( ($value === null || $value === false) && $defaultValue !== null ) {
            $value = $defaultValue;
        }
        $error = $this->getError( $name );
        $pieces  = array();
        $pieces['error'] = $error;


        if ( $isRequired && $this->view->html5Forms ) {
            $textboxAttributes['required'] = 'required';
        }

        if ( $text ) {
            $pieces['label'] = $htmlElement->getLabel( $text, $id, $labelAttributes ).' ';
        }
        $pieces['input'] = $htmlElement->getTextbox( $name, $value, $textboxAttributes );


        return new Sly_StringHash($pieces);

    }

    /**
     * list attribute convenience method for getTextbox
     *
     * @param string $name name of input - will be textbox id if not passed in $textboxAttributes
     * @param string $text optional - label text, omit and no label element
     * @param string $value optional - current value of text box
     * @param string $defaultValue optional - value if no $value is passed in
     * @param bool   $isRequired optional - is a required elem
     * @param array  $textboxAttributes optional - attributes for text box
     * @param array  $labelAttributes optional - attributes for the label
     * @return array
     */
    public function getTextboxListAttributes(
                                            $name,
                                            $text,
                                            $value = null,
                                            $defaultValue = null,
                                            $isRequired = null,
                                            $textboxAttributes = array(),
                                            $labelAttributes = array()
    ){
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getTextbox' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'textbox', $isRequired, $this->hasError( $name ) )
            )
        );
    }


    /**
     * get a date picker with label and error block
     *
     * @param string $name name of input - will be textbox id if not passed in $textboxAttributes
     * @param string $text optional - label text, omit and no label element
     * @param string $value optional - current value of text box
     * @param string $defaultValue optional - value if no $value is passed in
     * @param bool   $isRequired optional - is a required elem
     * @param array  $textboxAttributes optional - attributes for text box
     * @param array  $labelAttributes optional - attributes for the label
     * @return string
     */
    public function getDatePicker(
                            $name,
                            $text = null,
                            $value = null,
                            $defaultValue = null,
                            $isRequired = null,
                            $textboxAttributes = array(),
                            $labelAttributes = array()
    ) {
        $htmlElement = $this->view->htmlElement();

        $id = isset($textboxAttributes['id']) ? $textboxAttributes['id'] : $name;
        $textboxAttributes['id'] = $id;

        if ( !$value && $defaultValue !== null ) {
            $value = $defaultValue;
        }
        $error = $this->getError( $name );
        $pieces  = array();
        $pieces[] = $error;

        if ( $text ) {
            $pieces[] = $htmlElement->getLabel( $text, $id, $labelAttributes ).' ';
        }

        if ( $isRequired && $this->view->html5Forms ) {
            $textboxAttributes['required'] = 'required';
        }

        $pieces[] = '<div class="dateItem">';
        $pieces[] = $htmlElement->getTextbox( $name, $value, $textboxAttributes );
        $pieces[] = '<span></span></div>';


        return join('', $pieces);

    }

    /**
     * list attribute convenience method for getDatePicker
     *
     * @param string $name name of input - will be textbox id if not passed in $textboxAttributes
     * @param string $text optional - label text, omit and no label element
     * @param string $value optional - current value of text box
     * @param string $defaultValue optional - value if no $value is passed in
     * @param bool   $isRequired optional - is a required elem
     * @param array  $textboxAttributes optional - attributes for text box
     * @param array  $labelAttributes optional - attributes for the label
     * @return array
     */
    public function getDatePickerListAttributes(
                                            $name,
                                            $text,
                                            $value = null,
                                            $defaultValue = null,
                                            $isRequired = null,
                                            $textboxAttributes = array(),
                                            $labelAttributes = array()
    ){
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getDatePicker' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'textbox dateItem', $isRequired, $this->hasError( $name ) )
            )
        );
    }



    /**
     * get a password element with label and error block
     *
     * @param string $name name of input - will be password id if not passed in $inputAttributes
     * @param string $text optional - label text, omit and no label element
     * @param string $value optional - current value of text box
     * @param string $defaultValue optional - value if no $value is passed in
     * @param bool   $isRequired optional - is a required elem
     * @param array  $inputAttributes optional - attributes for text box
     * @param array  $labelAttributes optional - attributes for the label
     * @return string
     */
    public function getPassword(
                            $name,
                            $text = null,
                            $value = null,
                            $defaultValue = null,
                            $isRequired = null,
                            $inputAttributes = array(),
                            $labelAttributes = array()
    ){
        $htmlElement = $this->view->htmlElement();

        $id = isset($inputAttributes['id']) ? $inputAttributes['id'] : $name;
        $inputAttributes['id'] = $id;

        if ( !$value && $defaultValue ) {
            $value = $defaultValue;
        }
        $error = $this->getError( $name );
        $pieces  = array();
        $pieces['error'] = $error;


        if ( $isRequired && $this->view->html5Forms ) {
            $inputAttributes['required'] = 'required';
        }

        if ( $text ) {
            $pieces['label'] = $htmlElement->getLabel( $text, $id, $labelAttributes ).' ';
        }
        $pieces['input'] = $htmlElement->getPassword( $name, $value, $inputAttributes );

        return new Sly_StringHash($pieces);
    }

    /**
     * list attribute convenience method for getPassword
     *
     * @param string $name name of input - will be textbox id if not passed in $inputAttributes
     * @param string $text optional - label text, omit and no label element
     * @param string $value optional - current value of text box
     * @param string $defaultValue optional - value if no $value is passed in
     * @param bool   $isRequired optional - is a required elem
     * @param array  $inputAttributes optional - attributes for text box
     * @param array  $labelAttributes optional - attributes for the label
     * @return array
     */
    public function getPasswordListAttributes(
                                            $name,
                                            $text,
                                            $value = null,
                                            $defaultValue = null,
                                            $isRequired = null,
                                            $inputAttributes = array(),
                                            $labelAttributes = array()
    ){
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getPassword' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'textbox', $isRequired, $this->hasError( $name ) )
            )
        );
    }

    /**
     * get a textarea with label and error block
     *
     * @param string $name name of input - will be textarea id if not passed in $textareaAttributes
     * @param string $text optional - label text, omit and no label element
     * @param string $value optional - current value of text box
     * @param string $defaultValue optional - value if no $value is passed in
     * @param bool   $isRequired optional - is a required elem
     * @param array  $textareaAttributes optional - attributes for text area
     * @param array  $labelAttributes optional - attributes for the label
     * @return string
     */
    public function getTextarea(
                            $name,
                            $text = null,
                            $value = null,
                            $defaultValue = null,
                            $isRequired = null,
                            $textareaAttributes = array(),
                            $labelAttributes = array()
    ){
        $htmlElement = $this->view->htmlElement();

        $id = isset($textareaAttributes['id']) ? $textareaAttributes['id'] : $name;
        $textareaAttributes['id'] = $id;

        if ( !$value && $defaultValue ) {
            $value = $defaultValue;
        }

        if ( $isRequired && $this->view->html5Forms ) {
            $textareaAttributes['required'] = 'required';
        }

        $pieces  = array();
        $pieces[] = $this->getError( $name );

        if( $text ) {
            $pieces[] = $htmlElement->getLabel( $text, $id, $labelAttributes ).' ';
        }
        $pieces[] = $htmlElement->getTextarea( $name, $value, $textareaAttributes );
        return join('', $pieces);
    }

    /**
     * list attribute convenience method for getTextarea
     *
     * @param string $name name of input - will be textarea id if not passed in $textareaAttributes
     * @param string $text optional - label text, omit and no label element
     * @param string $value optional - current value of text box
     * @param string $defaultValue optional - value if no $value is passed in
     * @param bool   $isRequired optional - is a required elem
     * @param array  $textareaAttributes optional - attributes for text area
     * @param array  $labelAttributes optional - attributes for the label
     * @return array
     */
    public function getTextareaListAttributes( $name, $text = null, $value = null, $defaultValue = null, $isRequired = null, $textareaAttributes = array(), $labelAttributes = array() ){
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getTextarea' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'textarea', $isRequired, $this->hasError( $name ) )
            )
        );
    }

    public function getFileUpload(
                            $name,
                            $text = null,
                            $value = null,
                            $defaultValue = null,
                            $isRequired = null,
                            $inputAttributes = array(),
                            $labelAttributes = array()
    ){
        $htmlElement = $this->view->htmlElement();

        $id = isset($inputAttributes['id']) ? $inputAttributes['id'] : $name;
        $inputAttributes['id'] = $id;

        if ( !$value && $defaultValue ) {
            $value = $defaultValue;
        }

        $pieces  = array();
        $pieces[] = $this->getError( $name );

        if( $text ) {
            $pieces[] = $htmlElement->getLabel( $text, $id, $labelAttributes ).' ';
        }
        $pieces[] = $htmlElement->getFileUpload( $name, $inputAttributes );
        return join('', $pieces);
    }

    /**
     * list attribute convenience method for getTextarea
     *
     * @param string $name name of input - will be textarea id if not passed in $textareaAttributes
     * @param string $text optional - label text, omit and no label element
     * @param string $value optional - current value of text box
     * @param string $defaultValue optional - value if no $value is passed in
     * @param bool   $isRequired optional - is a required elem
     * @param array  $textareaAttributes optional - attributes for text area
     * @param array  $labelAttributes optional - attributes for the label
     * @return array
     */
    public function getFileUploadListAttributes( $name, $text = null, $value = null, $defaultValue = null, $isRequired = null, $inputAttributes = array(), $labelAttributes = array() ){
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getFileUpload' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'fileUpload', $isRequired, $this->hasError( $name ) )
            )
        );
    }


    /**
     * get a submit button
     *
     * @param string $name name of input
     * @param string $value optional - button text default to 'Submit'
     * @param array  $attribs optional - button attributes
     * @return string
     */
    public function getSubmitButton( $name = 'jSubmit', $value = 'Submit', $attribs = array() ) {
        $htmlElement = $this->view->htmlElement();
        return $htmlElement->getSubmitButton( $name, $value, $attribs );
    }

    /**
     * list attribute convenience method for getSubmitButton
     *
     * @param string $name name of input
     * @param string $value optional - button text default to 'Submit'
     * @param array  $attribs optional - button attributes
     * @return array
     */
    public function getSubmitButtonListAttributes( $name = 'jSubmit', $value = 'Submit', $attribs = array() ){
        $args = func_get_args();
        return array(
            'preTitleContent' => '<strong class="submit">',
            'postTitleContent' => '</strong>',
            'title' => call_user_func_array( array( $this, 'getSubmitButton' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'submit', false, false )
            )
        );
    }

    /**
     * get a checkbox
     *
     * @param string $name name of input
     * @param string $value the value of the input
     * @param string $text optional - the value of the label
     * @param bool $checked optional - is checked defaults to false
     * @param array  $inputAttributes optional - checkbox attributes
     * @param array  $labelAttributes optional - label attributes
     * @return string
     */
    public function getCheckbox(
                            $name,
                            $value,
                            $text = null,
                            $checked = false,
                            $includeErrors = false,
                            $inputAttributes = array(),
                            $labelAttributes = array()
    ){
        $id = isset($inputAttributes['id']) ? $inputAttributes['id'].'-'.$value : str_replace('[]','',$name).'-'.$value;
        $inputAttributes['id'] = $id;
        $htmlElement = $this->view->htmlElement();
        $pieces = array();
        if ( $includeErrors ) {
            $pieces[] = $this->getError( $name );
        }
        if($text) {
            $pieces[] =  $htmlElement->getLabel( $htmlElement->getCheckbox( $name, $value, $checked, $inputAttributes ).$text, $id, $labelAttributes  );
        } else {
            $pieces[] = $htmlElement->getCheckbox( $name, $value, $checked, $inputAttributes );
        }
        return join('', $pieces);
    }

    /**
     * list attribute convenience method for getCheckbox
     *
     * @param string $name name of input
     * @param string $value the value of the input
     * @param string $text optional - the value of the label
     * @param bool $checked optional - is checked defaults to false
     * @param array  $inputAttributes optional - checkbox attributes
     * @param array  $labelAttributes optional - label attributes
     * @return array
     */
    public function getCheckboxListAttributes(
                            $name,
                            $value,
                            $text = null,
                            $checked = false,
                            $includeErrors = false,
                            $inputAttributes = array(),
                            $labelAttributes = array()
    ){
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getCheckbox' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'checkbox', false, $this->hasError( $name ) )
            )
        );
    }

    /**
     * get a radio
     *
     * @param string $name name of input
     * @param string $value the value of the input
     * @param string $text optional - the value of the label
     * @param bool $checked optional - is checked defaults to false
     * @param bool $includeErros optional - show errors if has one
     * @param array  $inputAttributes optional - checkbox attributes
     * @param array  $labelAttributes optional - label attributes
     * @return string
     */
    public function getRadio(
                            $name,
                            $value,
                            $text = null,
                            $checked = false,
                            $includeErrors = false,
                            $inputAttributes = array(),
                            $labelAttributes = array()
    ){

        $id = isset($inputAttributes['id']) ? $inputAttributes['id'].'-'.$value : str_replace('[]','',$name).'-'.$value;
        $inputAttributes['id'] = $id;
        $htmlElement = $this->view->htmlElement();
        $pieces = array();
        if ( $includeErrors ) {
            $pieces[] = $this->getError( $name );
        }
        if( isset($text) ){
            $pieces[] = $htmlElement->getLabel( $htmlElement->getRadio( $name, $value, $checked, $inputAttributes ).$text, $id, $labelAttributes  );
        } else {
            $pieces[] = $htmlElement->getRadio( $name, $value, $checked, $inputAttributes );
        }

        return join('', $pieces);
    }

    /**
     * list attribute convenience method for getRadio
     *
     * @param string $name name of input
     * @param string $value the value of the input
     * @param string $text the value of the label
     * @param bool $checked optional - is checked defaults to false
     * @param bool $includeErros optional - show errors if has one
     * @param array  $inputAttributes optional - checkbox attributes
     * @param array  $labelAttributes optional - label attributes
     * @return string
     */
    public function getRadioListAttributes(
                            $name,
                            $value,
                            $text = null,
                            $checked = false,
                            $includeErrors = false,
                            $inputAttributes = array(),
                            $labelAttributes = array()
    ){
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getRadio' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'radio', false, $this->hasError( $name ) )
            )
        );
    }

    /**
     * get a checkbox collection
     *
     * @param string $name name of input
     * @param array $options list of options
     * @param string $text heading for the group
     * @param array $values optional - checked values
     * @param array $defaultValue optional - value for hidden input
     * @param array  $listInitVars optional - list attributes
     * @return string
     */
    public function getCheckboxCollection( $name, $options, $text = null, $values = array(), $defaultValue = null, $listInitVars = array() ) {
        $pieces = array();
        $list = array();
        $pieces[] = $text ? '<h5>'.$text.'</h5>' : '';
        $pieces[] = $this->getError( $name );
        foreach( $options as $optValue => $option ){
            $labelAttributes = isset($option['labelAttributes'] ) ? $option['labelAttributes'] : null;
            $itemAttributes = isset($option['itemAttributes'] ) ? $option['itemAttributes'] : null;
            $postTitleContent = isset($option['postTitleContent'] ) ? $option['postTitleContent'] : null;
            $class = isset($option['class'] ) ? $option['class'] : '';
            $list[] = array(
                'title' => $this->getCheckbox( $name, $optValue, $option['text'], in_array( $optValue, $values), false,  $itemAttributes, $labelAttributes ),
                'itemAttributes' => array(
                    'class' => 'checkboxItem '.$class,
                ),
                'postTitleContent' => $postTitleContent
            );
        }

        if ( $defaultValue !== null ) {
            $pieces[] = $this->getHidden( $name, $defaultValue );
        }

        $attributes = isset($listInitVars['attributes']) ? $listInitVars['attributes'] : array();
        $listInitVars['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class' , 'collection' );
        $listInitVars['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class' , 'unstyled' );
        $pieces[] = $this->view->linkList( $list, $listInitVars );
        return  join('', $pieces);
    }

    /**
     * list attribute convenience method for getCheckboxCollection
     *
     * @param string $name name of input
     * @param array $options list of options
     * @param string $text heading for the group
     * @param array $values optional - checked values
     * @param array $defaultValue optional - value for hidden input
     * @param array  $listInitVars optional - list attributes
     * @return string
     */
    public function getCheckboxCollectionListAttributes( $name, $options, $text = null, $values = array(), $defaultValue = null, $listInitVars = array() ) {
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getCheckboxCollection' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'checkboxes', false, $this->hasError( $name ) )
            )
        );
    }

    /**
     * get a radio collection
     *
     * @param string $name name of input
     * @param array $options list of options
     * @param string $text heading for the group
     * @param bool $value optional - checked value
     * @param array  $listInitVars optional - list attributes
     * @return string
     */
    public function getRadioCollection( $name, $options, $text = null, $value = null, $defaultValue = null, $listInitVars = array() ) {
        $pieces = array();
        $list = array();
        $pieces[] = $text ? '<h5>'.$text.'</h5>' : '';
        $pieces[] = $this->getError( $name );



        if (!$value) {
            $value = $defaultValue;
        }


        foreach( $options as $optValue => $option ){

            $labelAttributes = isset($option['labelAttributes'] ) ? $option['labelAttributes'] : null;
            $itemAttributes = isset($option['itemAttributes'] ) ? $option['itemAttributes'] : null;

            $postTitleContent = isset($option['postTitleContent'] ) ? $option['postTitleContent'] : null;
            $class = isset($option['class'] ) ? $option['class'] : '';
            $list[] = array(
                'title' => $this->getRadio( $name, $optValue, $option['text'], $optValue == $value, false, $itemAttributes, $labelAttributes ),
                'itemAttributes' => array(
                    'class' => 'radio '.$class
                ),
                'postTitleContent' => $postTitleContent
            );
        }

        $attributes = isset($listInitVars['attributes']) ? $listInitVars['attributes'] : array();
        $listInitVars['attributes'] = $this->view->formatUtil()->addItemToAttributes( $attributes, 'class' , 'collection' );

        $pieces[] = $this->view->linkList( $list, $listInitVars );

        return join('', $pieces);

    }

    /**
     * list attribute convenience method for getRadioCollection
     *
     * @param string $name name of input
     * @param array $options list of options
     * @param string $text heading for the group
     * @param array $values optional - checked values
     * @param array  $listInitVars optional - list attributes
     * @return string
     */
    public function getRadioCollectionListAttributes( $name, $options, $text = null, $value = null, $defaultValue = null, $listInitVars = array() ) {
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getRadioCollection' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'radios', false, $this->hasError( $name ) )
            )
        );
    }

    /**
     * get a select
     *
     * @param string $name name of input
     * @param array $options list of options
     * @param string $text label
     * @param array $values optional - checked values
     * @param array $defaultValues optional - checked values by default
     * @param bool $isRequired optional - is this requried
     * @param array $inputAttributes optional - select attributes
     * @param array $labelAttributes optional - label attributes
     * @return string
     */
    public function getSelect(
                        $name,
                        $options,
                        $text = null,
                        $values = array(),
                        $defaultValues = array(),
                        $isRequired = false,
                        $inputAttributes = array(),
                        $labelAttributes = array(),
                        $checkStrict = false
    ) {
        $pieces = array();
        $list = array();
        $htmlElement = $this->view->htmlElement();

        $id = isset($inputAttributes['id']) ? $inputAttributes['id'] : $name;
        $inputAttributes['id'] = $id;

        if ( is_array( $values )) {
            if ( !count( $values ) ||
                 $values[0] === false ||
                 $values[0] === null ) {
                $values = $defaultValues;
            }
        } else if ( $values === false || $values === null ) {
            $values = $defaultValues;
        }


        $pieces[] = $this->getError( $name );
        if ($text) {
            $pieces[] = $htmlElement->getLabel( $text, $id, $labelAttributes ).' ';
        }

        if ( $this->view->html5Forms ) {
            $attributeValues = is_array( $values ) ? $values : array( $values );
            $inputAttributes['data-values'] = join(',', $attributeValues );
        }

        if ( $isRequired && $this->view->html5Forms ) {
            $inputAttributes['required'] = 'required';
        }

        $hasGroups = false;
        $first = current($options);
        if ( $first && isset($first['options']) ) {
            $hasGroups = true;
        }

        if ( $hasGroups ) {
            $pieces['select'] = $htmlElement->getSelectWithGroups( $name, $options, $values, $inputAttributes, $checkStrict );
        } else {
            $pieces['select'] = $htmlElement->getSelect( $name, $options, $values, $inputAttributes, $checkStrict );
        }

        return new Sly_StringHash($pieces);
    }

    /**
     * list attribute convenience method for getSelect
     *
     * @param string $name name of input
     * @param array $options list of options
     * @param string $text label
     * @param array $values optional - checked values
     * @param array $defaultValues optional - checked values by default
     * @param bool $isRequired optional - is this requried
     * @param array $inputAttributes optional - select attributes
     * @param array $labelAttributes optional - label attributes
     * @return array
     */
    public function getSelectListAttributes(
                                        $name,
                                        $options,
                                        $text = null,
                                        $values = array(),
                                        $defaultValues = array(),
                                        $isRequired = false,
                                        $inputAttributes = array(),
                                        $labelAttributes = array(),
                                        $checkStrict = false
    ) {
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getSelect' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'select', $isRequired, $this->hasError( $name ) )
            )
        );
    }


    /**
     * list attribute convenience method for getSelect
     *
     * @param string $name name of input
     * @param array $options list of options
     * @param string $text label
     * @param array $values optional - checked values
     * @param bool $isRequired optional - is this requried
     * @param array $inputAttributes optional - select attributes
     * @param array $labelAttributes optional - label attributes
     * @return array
     */
    public function getHidden(
                        $name,
                        $value,
                        $inputAttributes = array()
    ) {
        $htmlElement = $this->view->htmlElement();
        return $htmlElement->getHidden($name,$value,$inputAttributes);
    }


    public function getHiddenListAttributes(
        $name,
        $value,
        $valueItemAttributes = array()
    ) {
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getHidden' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'hidden', false, $this->hasError( $name ) )
            )
        );
    }

    public function getNameValue(
                        $name,
                        $value,
                        $nameItemAttributes = array(),
                        $valueItemAttributes = array()
    ) {
        $pieces = array();



        $pieces[] = $this->view->htmlElement()->getContainingTag('em', $name, $nameItemAttributes);

        if ( isset( $valueItemAttributes['class'] ) ) {

            if ( is_array( $valueItemAttributes['class']) ) {
                 $valueItemAttributes['class'][] = 'value';
            } else {
                $valueItemAttributes['class'] .= ' value';
            }
        } else {
            $valueItemAttributes['class'] = 'value';
        }


        $pieces[] = $this->view->htmlElement()->getContainingTag('div', $value, $valueItemAttributes);
        return  join('', $pieces);

    }


    public function getNameValueListAttributes(
        $name,
        $value,
        $nameItemAttributes = array(),
        $valueItemAttributes = array()
    ) {
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getNameValue' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'nameValue', false, $this->hasError( $name ) )
            )
        );
    }


    public function getTimePicker(
        $namePrefix,
        $text,
        $value = null,
        $defaultValue = null,
        $timezone = null,
        $includeMinutes = false,
        $labelAttributes = array(),
        $isRequired = false
    ) {
        $htmlElement = $this->view->HtmlElement();
        $formatDate = $this->view->formatDate();


        $hour = isset($value['hour']) ? $value['hour'] : $formatDate->getDate($defaultValue, 'HOUR', $timezone );
        $minutes = isset($value['minutes']) ? $value['minutes'] : $formatDate->getDate($defaultValue, 'MINUTES', $timezone );
        $amPm = isset($value['amPm']) ? $value['amPm'] : $formatDate->getDate($defaultValue, 'AMPM', $timezone );

        $ampmOptions = array(
            'am' => array( 'text' => 'am' ),
            'pm' => array( 'text' => 'pm' ),
        );

        $pieces  = array();
        $pieces[] = $this->getError( $namePrefix.'Hour' );
        $pieces[] = $this->getError( $namePrefix.'Minutes' );
        $pieces[] = $this->getError( $namePrefix.'AmPm' );

        $inputAttributes= array();
        if ( $isRequired && $this->view->html5Forms ) {
            $inputAttributes['required'] = 'required';
        }

        if( $text ) {
            $pieces[] = $htmlElement->getLabel( $text, $namePrefix . 'Hour', $labelAttributes ).' ';
        }
        $pieces[] = '<div class="value">';
        $pieces[] = $htmlElement->getTextbox( $namePrefix . 'Hour', $hour, array_merge( $inputAttributes, array( 'class' => 'text hour', 'maxlength' => 2, 'id' =>  $namePrefix . 'Hour'  ) ) );
        if ( $includeMinutes ) {
            $pieces[] = $htmlElement->getTextbox( $namePrefix . 'Minutes', $minutes, array_merge( $inputAttributes, array( 'class' => 'text minutes', 'maxlength' => 2, 'id' =>  $namePrefix . 'Minutes' ) ) );
        }

        $pieces[] = $htmlElement->getSelect(
            $namePrefix . 'AmPm',
            $ampmOptions,
            array($amPm),
            array( 'class' => 'select amPm'),
            false
        );

        if ( $timezone ) {
            $pieces[] = '<em>'.$formatDate->getDate(time(), 'TIMEZONE', $timezone ).'</em>';
        }
        $pieces[] = '</div>';
        return join( '', $pieces );
    }


    public function getTimePickerListAttributes(
        $namePrefix,
        $text,
        $value = null,
        $defaultValue = null,
        $displayTimezone = null,
        $includeMinutes = false,
        $labelAttributes = array()
    ) {
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getTimePicker' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'timePicker', false, $this->hasError( $namePrefix ) )
            )
        );
    }

    public function getDatePickerDropdown(
        $namePrefix,
        $text,
        $value = null,
        $defaultValue = null,
        $labelAttributes = array(),
        $extraChoice = null
    ) {
        $htmlElement = $this->view->HtmlElement();
        $formatDate = $this->view->formatDate();

        $month = isset( $value['month'] ) ? $value['month'] : $formatDate->getDate($defaultValue, 'MONTH', null );
        $day = isset( $value['day'] ) ? $value['day'] : $formatDate->getDate($defaultValue, 'DAY', null );
        $year = isset( $value['year'] ) ? $value['year'] : $formatDate->getDate($defaultValue, 'YEAR', null );

        // most recent year in dropdown - useful for limiting ages
        $thisYear = (array_key_exists('thisYear', $value) && $value['thisYear']) ? $value['thisYear'] : date( 'Y' );

        $monthOptions = array(
            '01' => array( 'text' => 'Jan' ),
            '02' => array( 'text' => 'Feb' ),
            '03' => array( 'text' => 'Mar' ),
            '04' => array( 'text' => 'Apr' ),
            '05' => array( 'text' => 'May' ),
            '06' => array( 'text' => 'Jun' ),
            '07' => array( 'text' => 'Jul' ),
            '08' => array( 'text' => 'Aug' ),
            '09' => array( 'text' => 'Sep' ),
            '10' => array( 'text' => 'Oct' ),
            '11' => array( 'text' => 'Nov' ),
            '12' => array( 'text' => 'Dec' ),
        );

        $dayOptions = array(
            '01' => array( 'text' => '1' ),
            '02' => array( 'text' => '2' ),
            '03' => array( 'text' => '3' ),
            '04' => array( 'text' => '4' ),
            '05' => array( 'text' => '5' ),
            '06' => array( 'text' => '6' ),
            '07' => array( 'text' => '7' ),
            '08' => array( 'text' => '8' ),
            '09' => array( 'text' => '9' ),
            '10' => array( 'text' => '10' ),
            '11' => array( 'text' => '11' ),
            '12' => array( 'text' => '12' ),
            '13' => array( 'text' => '13' ),
            '14' => array( 'text' => '14' ),
            '15' => array( 'text' => '15' ),
            '16' => array( 'text' => '16' ),
            '17' => array( 'text' => '17' ),
            '18' => array( 'text' => '18' ),
            '19' => array( 'text' => '19' ),
            '20' => array( 'text' => '20' ),
            '21' => array( 'text' => '21' ),
            '22' => array( 'text' => '22' ),
            '23' => array( 'text' => '23' ),
            '24' => array( 'text' => '24' ),
            '25' => array( 'text' => '25' ),
            '26' => array( 'text' => '26' ),
            '27' => array( 'text' => '27' ),
            '28' => array( 'text' => '28' ),
            '29' => array( 'text' => '29' ),
            '30' => array( 'text' => '30' ),
            '31' => array( 'text' => '31' ),
        );

        $yearOptions = array();
        for( $thisYear; $thisYear > 1900; $thisYear-- ) {
            $yearOptions[$thisYear] = array( 'text' => $thisYear );
        }

        if( $extraChoice )
        {
            $monthOptions = array( '' => array( 'text' => $extraChoice ) ) + $monthOptions ;
            $dayOptions = array( '' => array( 'text' => $extraChoice ) ) + $dayOptions ;
            $yearOptions = array( '' => array( 'text' => $extraChoice ) ) + $yearOptions ;
        }

        $pieces  = array();
        $pieces[] = $this->getError( $namePrefix.'Month' );
        $pieces[] = $this->getError( $namePrefix.'Day' );
        $pieces[] = $this->getError( $namePrefix.'Year' );

        if( $text ) {
            $pieces['label'] = $htmlElement->getLabel( $text, $namePrefix . 'Month', $labelAttributes ).' ';
        }

        $pieces[] = '<div class="value">';
        $pieces[] = $htmlElement->getSelect( $namePrefix . 'Month', $monthOptions, array( $month ), array( 'class' => 'select month', 'id' =>  $namePrefix . 'Month'  ) );
        $pieces[] = $htmlElement->getSelect( $namePrefix . 'Day', $dayOptions, array( $day ), array( 'class' => 'select day', 'id' =>  $namePrefix . 'Day' ) );
        $pieces[] = $htmlElement->getSelect( $namePrefix . 'Year', $yearOptions, array( $year ), array( 'class' => 'select year', 'id' =>  $namePrefix . 'Year' ) );
        $pieces[] = '</div>';
        return new Sly_StringHash($pieces);
        //return join( '', $pieces );
    }


    public function getDatePickerDropdownListAttributes(
        $namePrefix,
        $text,
        $value = null,
        $defaultValue = null,
        $labelAttributes = array(),
        $extraChoice = null
    ) {
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getDatePickerDropdown' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'datePicker', false, $this->hasError( $namePrefix ) )
            )
        );
    }

    public function getList(
                        $items,
                        $listAttributes = array()
    ) {
        $listAttributes['attributes'] = isset($listAttributes['attributes']) ? $listAttributes['attributes']:  array();
        $listAttributes['attributes'] = $this->view->formatUtil()->addItemToAttributes($listAttributes['attributes'], 'class', 'formItems' );
        return $this->view->linkList($items, $listAttributes);
    }


    /**
     * get a time with label and error block
     *
     * @param string $name name of input - will be textbox id if not passed in $textboxAttributes
     * @param string $text optional - label text, omit and no label element
     * @param string $value optional - current value of text box
     * @param string $defaultValue optional - value if no $value is passed in
     * @param bool   $isRequired optional - is a required elem
     * @param array  $textboxAttributes optional - attributes for text box
     * @param array  $labelAttributes optional - attributes for the label
     * @return string
     */
    public function getTime(
                            $name,
                            $text = null,
                            $value = null,
                            $defaultValue = null,
                            $isRequired = null,
                            $textboxAttributes = array(),
                            $labelAttributes = array()
    ){
        $htmlElement = $this->view->htmlElement();

        $id = isset($textboxAttributes['id']) ? $textboxAttributes['id'] : $name;
        $textboxAttributes['id'] = $id;

        if ( !$value && $defaultValue !== null ) {
            $value = $defaultValue;
        }
        $error = $this->getError( $name );
        $pieces  = array();
        $pieces[] = $error;


        if ( $isRequired && $this->view->html5Forms ) {
            $textboxAttributes['required'] = 'required';
        }

        if ( $text ) {
            $pieces[] = $htmlElement->getLabel( $text, $id, $labelAttributes ).' ';
        }
        $pieces[] = $htmlElement->getTime( $name, $value, $textboxAttributes );


        return join('', $pieces);

    }

    /**
     * list attribute convenience method for getTextbox
     *
     * @param string $name name of input - will be textbox id if not passed in $textboxAttributes
     * @param string $text optional - label text, omit and no label element
     * @param string $value optional - current value of text box
     * @param string $defaultValue optional - value if no $value is passed in
     * @param bool   $isRequired optional - is a required elem
     * @param array  $textboxAttributes optional - attributes for text box
     * @param array  $labelAttributes optional - attributes for the label
     * @return array
     */
    public function getTimeListAttributes(
                                            $name,
                                            $text,
                                            $value = null,
                                            $defaultValue = null,
                                            $isRequired = null,
                                            $textboxAttributes = array(),
                                            $labelAttributes = array()
    ){
        $args = func_get_args();
        return array(
            'title' => call_user_func_array( array( $this, 'getTime' ), $args ),
            'itemAttributes' => array(
                'class' => $this->getItemClasses( 'time', $isRequired, $this->hasError( $name ) )
            )
        );
    }

    /**
     * list attribute convenience method for legend
     *
     * @param string $name legend title
     * @return array
     */
    public function getLegendListAttributes($name){
        return array(
            'title' => '<legend>' . $name . '</legend>',
            'itemAttributes' => array(
                                      'class' => 'legend'
            )
        );
    }







    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }
}
