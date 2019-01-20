<?php

/**
 *
 */
class Sly_View_Helper_BootstrapAdapter
{
    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public $view;

    public function bootstrapAdapter() {
        return $this;
    }

    public function adaptTextboxListAttributes ($item, $tip = '', $tipType = 'inline' ) {
        $item['title'] = $this->adaptInput($item['title'], $tip, $tipType);
        return $item;
    }

    public function adaptDatePickerDropdownListAttributes ($item, $tip = '', $tipType = 'inline' ) {
        $item['title'] = $this->adaptInput($item['title'], $tip, $tipType);
        return $item;
    }

    public function adaptButtonListAttributes ($item, $tip = '', $tipType = 'inline' ) {
        $item['title'] = $this->adaptActionButtons($item['title'], $tip, $tipType);
        // Don't want this wrapped in a 'strong' invalid markup
        $item['preTitleContent'] = null;
        $item['postTitleContent'] = null;
        return $item;
    }

    public function adaptInput ($inputHash, $tip = '', $tipType = 'inline') {

        if ($inputHash->keyExists('input')) {
            $input = $inputHash->getKeyValue('input');
            if ($tip) {
                $input .= ' ' . $this->view->htmlElement()->getContainingTag('span', $tip, array('class' => 'help-'.$tipType));
            }
            $input = $this->view->htmlElement()->getContainingTag('div', $input, array('class' => 'input'));
            $inputHash->setKeyValue('input', $input);
        }
        if ($inputHash->keyExists('select')) {
            $select = $inputHash->getKeyValue('select');
            if ($tip) {
                $select .= ' ' . $this->view->htmlElement()->getContainingTag('span', $tip, array('class' => 'help-'.$tipType));
            }
            $select = $this->view->htmlElement()->getContainingTag('div', $select, array('class' => 'input'));
            $inputHash->setKeyValue('select', $select);
        }

        $inputHash = $this->view->htmlElement()->getContainingTag('div', $inputHash, array('class' => 'clearfix'));

        return $inputHash;
    }

    public function adaptActionButtons ($buttons) {

        $buttons = $this->view->htmlElement()->getContainingTag('div', $buttons, array('class' => 'actions'));

        return $buttons;
    }

    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

}

?>
