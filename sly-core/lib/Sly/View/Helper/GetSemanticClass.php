<?php

class Sly_View_Helper_GetSemanticClass
{

    public function getSemanticClass( $curCount, $max, $key = null, $curItem = null, $oddAndEven = false, $highlightClass = 'selected')
    {
        $xhtml = '';
        $class = array();
        if ( $key && $curItem && $key == $curItem) {
            $class[] = $highlightClass;
        }
        if ( $oddAndEven) {
            $class[] = $curCount%2 ? 'even': 'odd';
        }
        if ( $curCount == 0 ) {
            $class[] = 'first';
        }
        if ( $curCount == $max-1) {
           $class[] = 'last';
        }

        return join(' ', $class);
    }

}
?>
