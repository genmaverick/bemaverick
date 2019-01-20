<?php

/**
 * Helper for interpreting page configs, and
 * rendering the corresponding templates.
 *
 * Initially built for grid templates.
 */
class Sly_View_Helper_FormatTemplate
{

    const GRID_PREFIX            = 'y';

    public function getGrid( $grid )
    {

        $gridAttributes = $grid->getAttributes();
        $gridAttributes = $this->view->formatUtil()->addItemToAttributes( $gridAttributes , 'class', self::GRID_PREFIX . '-d' );
        switch ($grid->getType()) {
        case 'fluid' : 
            $gridAttributes = $this->view->formatUtil()->addItemToAttributes( $gridAttributes , 'class', self::GRID_PREFIX . '-d-fluid' );
            break;
        case 'fixed' :
            // No special class, i.e. default
            break;
        }
        if ($grid->getId() &&
            !isset($gridAttributes['id'])) {
            $gridAttributes = $this->view->formatUtil()->addItemToAttributes( $gridAttributes , 'id', self::GRID_PREFIX . '-d-' . $grid->getId());
        }


        $markup = $this->getRows($grid->getRows());

        return $this->view->htmlElement()->tag('div', $markup, $gridAttributes);
    }

    public function getRows( $rows )
    {
        $gridMarkup = '';
        foreach ( $rows as $row ) {
            $gridMarkup .= $this->getRow($row);
        }
        return $gridMarkup;
    }

    public function getRow( $row )
    {
        if ( is_array($row) ) {
            $row = new Sly_GridRow($row);
        }
        $rowAttributes = $row->getAttributes();
        $rowAttributes = $this->view->formatUtil()->addItemToAttributes( $rowAttributes , 'class', self::GRID_PREFIX . '-g' );

        $markup = $this->getUnits($row->getUnits());
        if ( !$markup ) {
            return '';
        }
        return $this->view->htmlElement()->tag('div', $markup, $rowAttributes);
    }

    public function getUnits( $units )
    {
        $markup = '';
        foreach ( $units as $unit ) {
            $markup .= $this->getUnit($unit);
        }
        return $markup;
    }

    protected function getUnit( $unit )
    {
        $markup = '';

        $unitAttributes = $unit->getAttributes();
        $unitAttributes = $this->view->formatUtil()->addItemToAttributes( $unitAttributes , 'class', self::GRID_PREFIX . '-u' );

        $unitWidths = $unit->getWidths();
        foreach ( $unitWidths as $unitWidth ) {
            $unitAttributes = $this->view->formatUtil()->addItemToAttributes( $unitAttributes , 'class',  self::GRID_PREFIX . '-u-' . $unitWidth);
        }
        if ( $unit->getId() &&
             !isset($unitAttributes['id']) ) {
            $unitAttributes = $this->view->formatUtil()->addItemToAttributes( $unitAttributes , 'id', self::GRID_PREFIX . '-u-' . $unit->getId());
        }

        // content to drop in
        $unitContent = $unit->getContent();
        if ( $unitContent ) {
            $markup .= $unitContent;
        }

        // Files to render
        $files = $unit->getFiles();
        if ( $files ) {
            foreach ( $files as $file ) {
                $markup .= $this->view->render( $file );
            }
        }

        if ( !$markup ) {
            return '';
        }

        if ($unit->isContentWrapped()) {
            $markup = '<div class="' . self::GRID_PREFIX . '-u-' . 'content' . '">' . $markup . '</div>';
        }

        return $this->view->htmlElement()->tag('div', $markup, $unitAttributes);
    }

    public function formatTemplate()
    {
        return $this;
    }

    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

}

?>