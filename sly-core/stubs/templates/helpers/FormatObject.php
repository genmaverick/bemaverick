<?php

/**
 * Helper for formatting objects
 */
class Bb_View_Helper_FormatObject
{
    /**
     * The view that created this helper.
     *
     * @var Zend_View
     */
    public $view;

    /**
     * Returns this helper
     *
     * @return Bb_View_Helper_FormatObject
     */
    public function formatObject()
    {
        return $this;
    }


    public function getEditFormItems($object, $input, $cancelUrl = '')
    {

        $formItems = array();

        $translator = $this->view->translator;
        $formatForm = $this->view->formatForm();

        // name
        $objectName = $object ? $object->getName() : '';
        $formItems['objectName'] = $formatForm->getTextboxListAttributes(
                                                            'objectName',
                                                            $translator->_('Object Name'),
                                                            $input->objectName,
                                                            $objectName,
                                                            true);

        // submit button
        $formItems['jSubmit'] = $formatForm->getSubmitButtonListAttributes('jSubmit', $translator->_('Save') );
        if ( $cancelUrl ) {
            $formItems['jSubmit']['postTitleContent'] .= '<a href="'.$cancelUrl.'" class="cancel button">Cancel</a>';
        }

        $formItems = $formatForm->setItemClasses($formItems);

        return $formItems;
    }

    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

}
